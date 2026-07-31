# tool_call_notes · 工具调用到模型实际看到什么

一个教学笔记本，把「函数调用（tool calling）」从**调用方视角**一路拉到**模型视角**，让你看清中间每一层映射：

```
SDK / API 层 :  messages=[{role, content, tool_calls:[{function:{name, arguments}}]}, {role:"tool", content}, ...]
      │  apply_chat_template   (模型自带的 Jinja2 模板)
      ▼
文本层       :  <|im_start|>system\n...<tools>...</tools>...<|im_end|>\n<|im_start|>assistant\n<tool_call>\n{"name":...}\n</tool_call><|im_end|>\n...
      │  tokenize (encode)
      ▼
模型层       :  [151644, 8948, 198, ..., 151657, ..., 151658, ..., 151645, ...]
```

## 笔记本做了什么

1. **Part 1**：用 OpenAI SDK 发起带工具的多轮对话（两个工具 `read_file` / `write_file`，返回**虚拟结果**）。通过传给 SDK 的 `httpx.Client`（带事件钩子）把每一轮的原始请求/响应 JSON 抓下来，重建出这轮对话的**最终 JSON**，保存到 `conversation.json`。
2. **Part 2**：把 `conversation.json` 喂给 HuggingFace `transformers` 的 `apply_chat_template`，渲染成模型真正看到的**文本**（带 `<|im_start|>` / `<tool_call>` 等特殊标记），再 `encode` 成 **token id**，并给出「结构化对象 ↔ 特殊 token」的对照表。

## 目录结构

```
tool_call_notes/
├── tool_call_notes.ipynb        # 主笔记本
├── conversation.json            # 一份示例对话（Part 2 可直接跑；Part 1 真实运行后会覆盖它）
├── make_sample_conversation.py  # 重新生成上面的示例 conversation.json
├── qwen3_tokenizer/             # 本地 Qwen3 tokenizer（只含 tokenizer 文件，不含权重，离线可用）
├── requirements.txt
└── .venv/                       # uv 创建的虚拟环境
```

`qwen3_tokenizer/` 是从本地 Qwen3 模型里**只提取 tokenizer 相关文件**得到的（不含 `model.safetensors` 权重）：

```
config.json  generation_config.json  merges.txt  tokenizer.json  tokenizer_config.json  vocab.json
```

## 环境准备

需要 [uv](https://docs.astral.sh/uv/)。已在本仓库创建好 `.venv`，如需重建：

```bash
uv venv --python 3.12 .venv
uv pip install --python .venv/bin/python -r requirements.txt
```

启动 Jupyter：

```bash
.venv/bin/jupyter notebook tool_call_notes.ipynb
```

## 怎么跑

1. 打开笔记本，在最上面的「**0 · 全局配置**」里填上你的 OpenAI 兼容服务：
   - `SDK_BASE_URL`、`SDK_API_KEY`、`MODEL_NAME`
2. 从头到尾依次运行。Part 1 会真实调用你的服务、抓包、保存 `conversation.json`。
3. **没有可用的 API 服务？** 直接跳到 Part 2 即可--仓库自带的 `conversation.json` 能让 Part 2 独立运行（`apply_chat_template` + tokenization 不需要联网，用的是本地 Qwen3 tokenizer）。

## 几个关键结论

- 模型只吃 **token id**（一串整数）。SDK 里的 `tool_calls`、`role`、`arguments` 都是「给人看的结构」，到了模型全是扁平序列。
- `tool_calls` 在模型眼里是一段被 `<tool_call>`（token id `151657`）包起来的 JSON 文本；`role:"tool"` 被改写成 `user` + `<tool_response>`，并不存在独立的 tool 角色。
- `apply_chat_template` 是结构化对象 ↔ token 序列之间的翻译层；**换模型就换模板**，同样对话会渲染成不同 token 序列。
