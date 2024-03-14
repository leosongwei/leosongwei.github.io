Norms
=====

TAG: layernorm; normalization; rmsnorm;

## LayerNorm

公式：

$y=\frac{x - E[x]}{\sqrt{Var[x] + \epsilon}} * \gamma + \beta$

其中：

* $E[x]$ 为平均
* $Var[x]$ 为标准差
* $\epsilon$ 为一个小数用于防除0，pytorch的`nn.modules.normalization.LayerNorm`中该值默认为`1e-5`
* $\gamma$ 和 $\beta$ 为可训练参数
  * pytorch中有`elementwise_affine`开关，如果开启，则会增加`weight`（$\gamma$）和`bias`（$\beta$）两个可训练参数,后者可单独开关

## RMS Norm

Root Mean Square Layer Normalization.

公式（LlamaRMSNorm `src/transformers/models/llama/modeling_llama.py`）：

$y = \frac{Wx}{\sqrt{mean(x^2) + \epsilon}}$

* LlamaRMSNorm的mean只处理`dim=-1`
* $\epsilon$ = `1e-6`来防止除以0
