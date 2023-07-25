import gzip
import pickle
import torch
import itertools
from torch import nn
import transformers
from transformers import BertModel, AutoModel, AutoTokenizer
from torch.optim.lr_scheduler import ExponentialLR
from transformers.modeling_outputs import (
    BaseModelOutputWithPoolingAndCrossAttentions,
)
from dataclasses import dataclass, field

from typing import Tuple, List, Dict

from torch.utils.data import Dataset, Subset, DataLoader, random_split


from tqdm import tqdm

import metrics


class NewsDataset(Dataset):
    def __init__(self, category_and_titles: List[Tuple[str, str]]) -> None:
        super().__init__()
        self._category_and_titles = category_and_titles

    def __getitem__(self, index) -> Tuple[str, str]:
        return self._category_and_titles[index]

    def __len__(self):
        return len(self._category_and_titles)


def ys_to_one_hot(ys: List[str], tag_list: List[str]):
    ys_index = torch.tensor([tag_list.index(y) for y in ys])
    ys_one_hot = torch.nn.functional.one_hot(ys_index, len(tag_list)).type(
        torch.float
    )
    return ys_one_hot


def one_hot_to_ys(one_hot: torch.Tensor, tag_list: List[str]) -> List[str]:
    ys_index = torch.argmax(one_hot, dim=1).tolist()
    ys = [tag_list[i] for i in ys_index]
    return ys


@dataclass
class ExperimentParameters:
    EXPERIMENT_SEED: int = 42
    PICKLE_PATH = "./THUCNews.pickle.gz"
    DEVICE = "cuda:0"
    MODEL_NAME = "bert-base-chinese"
    MODEL_HIDDEN_SIZE = 768
    MODEL_PATH = "./model_with_softmax_no_sequential.pickle"

    documents: Dict[str, List[Tuple[str, str]]] = field(default_factory=list)
    category_and_titles: List[Tuple[str, str]] = field(default_factory=list)
    train_dataset: Subset = None
    test_dataset: Subset = None
    quick_test_dataset: Subset = None
    tag_list: List[str] = field(default_factory=list)

    LEARNING_RATE_INITIAL = 0.06
    SCHEDULER_GAMMA = 0.95
    BATCH_SIZE = 200
    EPOCHES = 1

    MODEL = None
    tester: "Tester" = None


def load_data(params: ExperimentParameters):
    print("loading data...")
    with gzip.open(params.PICKLE_PATH) as file:
        params.documents: Dict[str, List[Tuple[str, str]]] = pickle.load(file)

    print(params.documents.keys())

    params.tag_list = list(params.documents.keys())
    params.category_and_titles: List[Tuple[str, str]] = []

    for category, items in params.documents.items():
        for item in items:
            params.category_and_titles.append((category, item[1]))


def setup_datasets(params: ExperimentParameters):
    print("splitting datasets...")
    from sklearn.model_selection import train_test_split

    ys = []
    xs = []
    for y, x in params.category_and_titles:
        ys.append(y)
        xs.append(x)

    xs_train, xs_test, ys_train, ys_test = train_test_split(
        xs, ys, test_size=0.2, random_state=params.EXPERIMENT_SEED, stratify=ys
    )

    train = list(zip(ys_train, xs_train))
    test = list(zip(ys_test, xs_test))

    params.train_dataset = NewsDataset(train)
    params.test_dataset = NewsDataset(test)

    xs_, xs_quick, ys_, ys_quick = train_test_split(
        xs_test,
        ys_test,
        test_size=0.01,
        random_state=params.EXPERIMENT_SEED,
        stratify=ys_test,
    )

    params.quick_test_dataset = NewsDataset(list(zip(ys_quick, xs_quick)))


class NewsTitleClassifierContrastive(nn.Module):
    def __init__(
        self,
        device: str,
        model_name: str,
        model_hidden_size: int,
        tag_list: List[str],
        prompt_list: List[str],
        softmax: True,
    ) -> None:
        super().__init__()
        self._tag_list = tag_list
        self._prompt_list = prompt_list
        self._device = device
        self._model: BertModel = AutoModel.from_pretrained(model_name)
        self._tokenizer = AutoTokenizer.from_pretrained(model_name)
        self._hidden_size = model_hidden_size
        self._softmax = softmax

        self._xs_vectorizer = nn.Sequential(
            nn.Linear(self._hidden_size, self._hidden_size),
            nn.ReLU(),
            nn.Linear(self._hidden_size, self._hidden_size),
            # nn.ReLU(),
        )
        self._prompt_vectorizer = nn.Sequential(
            nn.Linear(self._hidden_size, self._hidden_size),
            nn.ReLU(),
            nn.Linear(self._hidden_size, self._hidden_size),
            # nn.ReLU(),
        )

        self._softmax = torch.nn.Softmax(dim=1)

        self._encoded_prompts = self.tokenize(self._prompt_list)

    def tokenize(self, input: List[str]):
        encoded = self._tokenizer(
            input,
            padding=True,
            truncation=True,
            max_length=512,
            return_tensors="pt",
        ).to(self._device)
        return encoded

    def _invoke_model(self, encoded):
        out: BaseModelOutputWithPoolingAndCrossAttentions = self._model(
            **encoded, output_attentions=True
        )
        return out.pooler_output

    def forward(self, encoded_xs):
        xs_embedding = self._invoke_model(encoded_xs)
        # xs_embedding = self._xs_vectorizer(xs_embedding)
        xs_embedding = xs_embedding / xs_embedding.norm(dim=1, keepdim=True)

        prompt_embedding = self._invoke_model(self._encoded_prompts)
        # prompt_embedding = self._prompt_vectorizer(prompt_embedding)
        prompt_embedding = prompt_embedding / prompt_embedding.norm(
            dim=1, keepdim=True
        )

        matrix = xs_embedding @ prompt_embedding.t()

        if self._softmax:
            matrix = self._softmax(matrix)

        return matrix


class NewsTitleClassifierBaseline(nn.Module):
    def __init__(
        self,
        device: str,
        model_name: str,
        model_hidden_size: int,
        tag_list: List[str],
    ) -> None:
        super().__init__()
        self._tag_list = tag_list
        self._device = device
        self._model: BertModel = AutoModel.from_pretrained(model_name)
        self._tokenizer = AutoTokenizer.from_pretrained(model_name)
        self._hidden_size = model_hidden_size

        self._xs_classifier = nn.Linear(self._hidden_size, len(self._tag_list))

    def tokenize(self, input: List[str]):
        encoded = self._tokenizer(
            input,
            padding=True,
            truncation=True,
            max_length=512,
            return_tensors="pt",
            add_special_tokens=True,
        ).to(self._device)
        return encoded

    def _invoke_model(self, encoded):
        out: BaseModelOutputWithPoolingAndCrossAttentions = self._model(
            **encoded, output_attentions=True
        )
        out = out.last_hidden_state.select(1, 0)
        return out

    def forward(self, encoded_xs):
        xs_embedding = self._invoke_model(encoded_xs)
        xs_embedding = xs_embedding / xs_embedding.norm(dim=1, keepdim=True)
        result = self._xs_classifier(xs_embedding)
        return result
        # return matrix


def train(params: ExperimentParameters, symmetric_loss=False):
    train_accuracy_record = []
    test_accuracy_record = []

    loss_fn = torch.nn.CrossEntropyLoss()
    optimizer = torch.optim.SGD(
        params.MODEL.parameters(), lr=params.LEARNING_RATE_INITIAL
    )
    scheduler = ExponentialLR(
        optimizer, gamma=params.SCHEDULER_GAMMA, verbose=True
    )

    training_dataloader = DataLoader(
        params.train_dataset, batch_size=params.BATCH_SIZE, shuffle=True
    )

    ys_batches = []
    xs_batches = []
    xs_encoded_batches = []

    for ys, xs in training_dataloader:
        ys_batches.append(ys)
        xs_batches.append(xs)
        xs_encoded_batches.append(params.MODEL.tokenize(xs))

    for epoch in range(params.EPOCHES):
        print(f"epoch: {epoch}")

        correct = 0
        total = 0

        for i, (ys, xs, xs_encoded) in tqdm(
            list(enumerate(zip(ys_batches, xs_batches, xs_encoded_batches)))
        ):
            result = params.MODEL(xs_encoded)

            ys_encoded = ys_to_one_hot(ys, params.tag_list).to(params.DEVICE)

            optimizer.zero_grad()
            if not symmetric_loss:
                loss = loss_fn(result, ys_encoded)
            else:
                ys_encoded_t = ys_encoded.t()
                loss = loss_fn(result, ys_encoded)
                loss_t = loss_fn(result.t(), ys_encoded_t)
                loss = (loss + loss_t) / 2
            loss.backward()
            optimizer.step()

            yps = one_hot_to_ys(result, params.tag_list)

            for yp, yg in zip(yps, ys):
                if yp == yg:
                    correct += 1
            total += len(yps)

            if i != 0 and i % 100 == 0:
                train_accuracy = correct / total
                correct = 0
                total = 0
                test_metrics = params.tester.test()
                # params.tester.pretty_print(*test_metrics)
                (
                    tag_list,
                    test_recall,
                    test_precision,
                    test_accuracy,
                ) = test_metrics

                print(f"training accuracy: {train_accuracy:.4f}")
                print(f"test accuracy: {test_accuracy:.4f}")
                train_accuracy_record.append(train_accuracy)
                test_accuracy_record.append(test_accuracy)

            if i % 200 == 0 and i != 0:
                scheduler.step()

    test_metrics = params.tester.test()
    params.tester.pretty_print(*test_metrics)

    return train_accuracy_record, test_accuracy_record


class Tester:
    def __init__(self, params: ExperimentParameters, test_dataset) -> None:
        test_dataloader = DataLoader(
            test_dataset,
            batch_size=100,
            shuffle=True,
        )

        self.tag_list = params.tag_list

        self.xs = []
        self.ygs = []
        self.xs_encoded_batches = []

        for ys, xs in test_dataloader:
            self.xs += xs
            self.ygs += ys
            self.xs_encoded_batches.append(params.MODEL.tokenize(xs))

        self._params = params

    @staticmethod
    def pretty_print(
        tag_list: List[str],
        recall: List[float],
        precision: List[float],
        accuracy: float,
    ):
        print(f"overall accuracy: {accuracy:.4f}")
        print("tag,\trecall,\tprecision")
        for tag, r, p in zip(tag_list, recall, precision):
            print(f"{repr(tag)},\t{r:.4f},\t{p:.4f}")

    def test(self):
        yps = []

        for xs_encoded in self.xs_encoded_batches:
            result = self._params.MODEL(xs_encoded)
            yps_batch = one_hot_to_ys(result, self._params.tag_list)
            yps += yps_batch

        precision, recall, accuracy = metrics.compute_metrics(
            yps, self.ygs, self._params.tag_list
        )
        return self._params.tag_list, recall, precision, accuracy


def setup_NewsTitleClassifierContrastive(PARAMS: ExperimentParameters):
    load_data(PARAMS)
    setup_datasets(PARAMS)

    PARAMS.MODEL = NewsTitleClassifierContrastive(
        PARAMS.DEVICE,
        PARAMS.MODEL_NAME,
        PARAMS.MODEL_HIDDEN_SIZE,
        PARAMS.tag_list,
    ).to(PARAMS.DEVICE)

    # PARAMS.MODEL.load_state_dict(torch.load(PARAMS.MODEL_PATH))
    PARAMS.tester = Tester(PARAMS, PARAMS.quick_test_dataset)


if __name__ == "__main__":
    PARAMS = ExperimentParameters()
    setup_NewsTitleClassifierContrastive(PARAMS)
    PARAMS.tester.pretty_print(*PARAMS.tester.test())
