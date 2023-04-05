from typing import List, Tuple


def compute_metrics(
    ys_prediction: List[str], ys_ground: List[str], tag_list: List[str]
) -> Tuple[List[float], List[float], float]:
    """GPT-4生成"""
    assert len(ys_prediction) == len(
        ys_ground
    ), "ys_prediction 和 ys_ground 应该具有相同的长度"

    # 初始化字典以存储计数
    tag_counts = {tag: {"tp": 0, "fp": 0, "fn": 0, "tn": 0} for tag in tag_list}
    total = len(ys_ground)

    # 计算 tp、fp、fn、tn
    for pred, ground in zip(ys_prediction, ys_ground):
        if pred == ground:
            tag_counts[pred]["tp"] += 1
            for tag in tag_list:
                if tag != pred:
                    tag_counts[tag]["tn"] += 1
        else:
            tag_counts[pred]["fp"] += 1
            tag_counts[ground]["fn"] += 1
            for tag in tag_list:
                if tag != pred and tag != ground:
                    tag_counts[tag]["tn"] += 1

    # 计算 precision 和 recall
    precision = []
    recall = []
    for tag in tag_list:
        tp = tag_counts[tag]["tp"]
        fp = tag_counts[tag]["fp"]
        fn = tag_counts[tag]["fn"]

        if tp + fp > 0:
            precision.append(tp / (tp + fp))
        else:
            precision.append(0.0)

        if tp + fn > 0:
            recall.append(tp / (tp + fn))
        else:
            recall.append(0.0)

    # 计算 accuracy
    correct = sum([tag_counts[tag]["tp"] for tag in tag_list])
    accuracy = correct / total

    return precision, recall, accuracy


if __name__ == "__main__":
    ys_prediction1 = ["A", "B", "B"]
    ys_ground1 = ["A", "B", "C"]
    tag_list1 = ["A", "B", "C"]

    precision, recall, accuracy = compute_metrics(
        ys_prediction1, ys_ground1, tag_list1
    )
    print(precision)
    print(recall)
    print(accuracy)
    assert precision == [
        1.0,
        0.5,
        0.0,
    ], f"Expected [1.0, 0.5, 0.0], but got {precision}"
    assert recall == [
        1.0,
        1.0,
        0.0,
    ], f"Expected [1.0, 1.0, 0.0], but got {recall}"
    assert (
        abs(accuracy - 0.66666666) < 0.00001
    ), f"Expected 0.6666666666666666, but got {accuracy}"
