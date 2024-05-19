Llama的形状
===========

tags: LLM; transformer

本例中展示了给LLama实际输入10个token时各层的形状（batch size为1），模型为Llama-2-7b-hf。

本文可配合[LLaMA 3/2/1模型结构总览](https://zhuanlan.zhihu.com/p/636784644)阅读。

模型信息：
* hidden_size: 4096
* num_hidden_layers: 32
* max_position_embeddings: 2048
* causal_mask(bool): [2048, 2048]
* vocab_size: 32000
* embed_tokens: Embedding(3200, 4096)
* num_heads: 32
* num_key_value_heads: 32
* head_dim: 128

输入（10个token）：
* input_ids: [1, 10]
* attention_mask: [1, 10] (全为1)
* position_ids: [1, 10] (0~9)
* inputs_embeds: [1, 10, 4096] -> hidden_states
  - 每个token被embedding为一个长为4096的张量

1. RMSNorm -> [1, 10, 4096], 保持一直
2. QKV，拆成三份：
   - Q: Linear(4096, 4096) -> query_states: [1, 10, 4096]
   - K: Linear(4096, 4096) -> key_states: [1, 10, 4096]
   - V: Linear(4096, 4096) -> value_states: [1, 10, 4096]
3. 多头
   - query_states: [1, 32, 10, 128] 
     - view(bsz, q_len, num_heads, head_dim).transpose(1,2)
   - key_states: [1, 32, 10, 128]
     - view(bsz, q_len, num_key_value_heads, head_dim).transpose(1,2)
   - value_states: [1, 32, 10, 128]
     - view(bsz, q_len, num_key_value_heads, head_dim).transpose(1,2)
4. Grouped Query Attention（GQA）
   - repeat_kv: repeat grouped attentions
   - num_key_value_groups = num_heads / num_key_value_heads
   - 本例中，因为num_heads和num_key_value_heads算出来一致，所以没有repeat
5. RoPE
   - cos, sin: [1, 10, 128]
   - query_states, key_states: [1, 32, 10, 128]
6. 裁切Causal Mask到序列长度
   - [causal_mask[:, :, cache_position, : key_states.shape[-2]]]
     - [1, 1, 2048, 2048] -> [1, 1, 10, 10]
7. MatMul (matrix product) Q x K.transpose(2,3)
   - attn_weights: [1, 32, 10, 10]
   - 矩阵乘法在这里起了对于每个对应embedding（token）的点乘作用
8. 对attention应用SoftMax(dim=-1)
   - softmax需要高精度，所以实现中先转换为32位浮点数再转换回来
9. MatMul Attention Weights x V
   - [1, 32, 10, 10] x [1, 32, 10, 128]
   - attn_output: [1, 32, 10, 128]
   - 每个新embedding张量的每一个元素为所有embedding上同位置元素按attention的加权和
   - "Attention is just a weighted sum over a set of vectors" - https://news.ycombinator.com/item?id=15938639
     - 在HackerNews上看到了这个有趣的说法.
   - transpose(1,2).reshape(bsz, q_len, hidden_size): [1, 10, 4096]
10. Attention Output
   - Linear(4096, 4096): same shape
11. Residual Add: same shape
   - 这里开始是MLP部分
12. Post Attention RMSNorm: same shape
13. UP: Linear(4096, 11008), 独立地应用于每一个token
14. Gate: Linear(4096, 11008), 独立地应用于每一个token
15. Dot Product: 这里是按位置一一相乘，独立地应用于每一个token
16. Down: Linear(4096, 11008), 独立地应用于每一个token
17. Residual Add，形状不变
18. 输出LM头lm_head: Linear(4096, 32000)，将每一个embedding映射到词表大小（32000）的one-hot encoding上
    - [1, 10, 32000]
19. Loss计算：
    - shift_logits = logits[..., :-1, :] # [1, 9, 32000]
    - shift_labels = labels[..., 1:] # [1, 9]
    - 按CrossEntropy计算loss
20. Greedy Search：
    - outputs.logits: [1, 10, 32000]
    - next_token_logits = outputs.logits[:, -1, :] # [1, 1, 32000]
    - next_tokens = torch.argmax(next_tokens_scores, dim=-1) # [1]
      - 最终argmax得到token id

TODO
----

* 展示GQA中分组后的形状变化（本例中组数为1，所以无法展示）
* 展示Causal Mask图像