Embedding Tying
===============

tags: embedding, tying, llm, weight-tying

今天在读Qwen2[1]论文的时候看到了一个Embedding Tying的概念。查了一下，来自于一篇16年的论文 Using the Output Embedding to Improve Language Models[2]，说是通过共享一部分权重实现输出头的正则化，同时提升性能减少大小。

huggingface/transformers已经实现了这个功能。接下来读一下代码：

`src/transformers/modeling_utils.py`[3]的`class PreTrainedModel`中，有`def tie_weights()`调用了，`def _tie_or_clone_weights()`，大意为：

```python
# （为易于阅读，进行了适当修改）
def tie_weights(self):
    output_embeddings = self.get_output_embeddings()
    input_embeddings = self.get_input_embeddings()
    self._tie_or_clone_weights(output_embeddings, input_embeddings)

def _tie_or_clone_weights(self, output_embeddings, input_embeddings):
    output_embeddings.weight = input_embeddings.weight
```

例如Qwen2(`src/transformers/models/qwen2/modeling_qwen2.py`)中有：

```python
class Qwen2ForCausalLM(Qwen2PreTrainedModel):
    def get_input_embeddings(self):
        return self.model.embed_tokens

    def get_output_embeddings(self):
        return self.lm_head
```

就是说，直接把embedding的权重赋给了lm_head。太神奇了，我来试试能不能训练出来。

### 引用

1. Qwen2 Technical Report https://arxiv.org/pdf/2407.10671
2. Using the Output Embedding to Improve Language Models https://arxiv.org/abs/1608.05859
3. src/transformers/modeling_utils.py https://github.com/huggingface/transformers/blob/main/src/transformers/modeling_utils.py
4. Why do GPT models use a transpose of the embedding matrix to convert outputs to logits? https://datascience.stackexchange.com/questions/123149/why-do-gpt-models-use-a-transpose-of-the-embedding-matrix-to-convert-outputs-to
   * 啊？最早的GPT也做embedding tying?
5. Tying Word Vectors and Word Classifiers: A Loss Framework for Language Modeling https://arxiv.org/pdf/1611.01462
   * 感觉这篇写得比[2]好些