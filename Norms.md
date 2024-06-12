Norms
=====

TAG: layernorm; normalization; rmsnorm;

## BatchNorm

(2015) Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift https://arxiv.org/abs/1502.03167

在batch范围内对其中的每个值进行规范化，用于解决Internal Covariate Shift问题。

$$
\mu_i = \frac{1}{M}\sum{x_i}, \sigma_i = \sqrt{\frac{1}{M}\sum(x_i - \mu_i)^2 + \epsilon}
$$

(M为mini batch的大小，计算针对与每一个元素)

Internal Covariate Shift（内部协变量偏移）：在深度网络中，前一层参数的变化将导致后一层输入的分布发生变化，后一层的参数将需要不断调整以适应之前的改动，导致难以训练。

* 详解深度学习中的Normalization，BN/LN/WN https://zhuanlan.zhihu.com/p/33173246

## LayerNorm

(2016) Layer Normalization https://arxiv.org/abs/1607.06450

在值的范围内对该张量的每个元素进行规范化。

公式：

$$
y=\frac{x - E[x]}{\sqrt{Var[x] + \epsilon}} * \gamma + \beta
$$

其中：

* $E[x]$ 为平均
* $Var[x]$ 为标准差，$\sigma=\sqrt{\frac{1}{N}\sum_i(x_i-\bar{x})^2}$
* $\epsilon$ 为一个小数用于防除0，pytorch的`nn.modules.normalization.LayerNorm`中该值默认为`1e-5`
* $\gamma$ 和 $\beta$ 为可训练参数
  * pytorch中有`elementwise_affine`开关，如果开启，则会增加`weight`（$\gamma$）和`bias`（$\beta$）两个可训练参数,后者可单独开关

研究[A ConvNet for the 2020s](https://arxiv.org/abs/2201.03545)中有对BatchNorm vs LayerNorm的讨论（引用了 Rethinking "Batch" in BatchNorm https://arxiv.org/abs/2105.07576）。

## RMS Norm

Root Mean Square Layer Normalization. 去掉了原LayerNorm中的中心偏移(效果不显著)，计算上比标准的LayerNorm来得简单。

LlamaRMSNorm公式（transformers `src/transformers/models/llama/modeling_llama.py`）：

$$
y = \frac{W\cdot x}{\sqrt{E(x^2) + \epsilon}}
$$

* LlamaRMSNorm的mean只处理`dim=-1`
* $\epsilon$ = `1e-6`来防止除以0
* `LlamaRMSNorm is equivalent to T5LayerNorm`
* W为参数，形状与x一致，用于点乘

原论文的RMS（ https://arxiv.org/pdf/1910.07467 ）：

$$
\text{RMS}(a) = \sqrt{\frac{1}{n}\sum_i{a_i^2}}
$$

## TODO

* Weight normalization
* Instance normalization