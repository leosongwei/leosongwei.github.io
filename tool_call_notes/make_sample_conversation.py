"""Generate a sample conversation.json in the exact shape the OpenAI SDK
produces (and that Part 2 of the notebook consumes).

In a real run, Part 1 of the notebook overwrites this file with the actual
captured conversation. This sample exists so Part 2 (apply_chat_template) can
run out of the box, without a live API server.
"""
import json

tools = [
    {
        "type": "function",
        "function": {
            "name": "read_file",
            "description": "读取指定路径的文件内容并返回。",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "要读取的文件路径"}
                },
                "required": ["path"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "write_file",
            "description": "把内容写入指定路径的文件。",
            "parameters": {
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "要写入的文件路径"},
                    "content": {"type": "string", "description": "要写入的文件内容"},
                },
                "required": ["path", "content"],
            },
        },
    },
]

# Mocked return values of the two tools.
read_result = json.dumps(
    {"timeout": 10, "retries": 3, "host": "localhost"}, ensure_ascii=False
)
new_config = json.dumps(
    {"timeout": 30, "retries": 3, "host": "localhost"}, ensure_ascii=False
)
write_result = json.dumps(
    {"status": "ok", "bytes_written": len(new_config)}, ensure_ascii=False
)

messages = [
    {"role": "system", "content": "你是一个文件管理助手。"},
    {
        "role": "user",
        "content": "请读取 config.json 的内容，然后把 timeout 字段改为 30 后保存回去。",
    },
    {
        "role": "assistant",
        "content": "",
        "tool_calls": [
            {
                "id": "call_abc1",
                "type": "function",
                "function": {
                    "name": "read_file",
                    "arguments": json.dumps({"path": "config.json"}, ensure_ascii=False),
                },
            }
        ],
    },
    {
        "role": "tool",
        "tool_call_id": "call_abc1",
        "content": read_result,
    },
    {
        "role": "assistant",
        "content": "",
        "tool_calls": [
            {
                "id": "call_abc2",
                "type": "function",
                "function": {
                    "name": "write_file",
                    "arguments": json.dumps(
                        {"path": "config.json", "content": new_config},
                        ensure_ascii=False,
                    ),
                },
            }
        ],
    },
    {
        "role": "tool",
        "tool_call_id": "call_abc2",
        "content": write_result,
    },
    {
        "role": "assistant",
        "content": f"已将 config.json 的 timeout 字段从 10 改为 30，并成功保存（写入 {len(new_config)} 字节）。",
    },
]

with open("conversation.json", "w", encoding="utf-8") as f:
    json.dump({"model": "qwen3-0.6b", "tools": tools, "messages": messages},
              f, ensure_ascii=False, indent=2)

print("wrote conversation.json")
