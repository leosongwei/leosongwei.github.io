# Claude Code with Kimi k2

原文： 国内用Claude Code的Kimi K2方案， CatAI0， https://mp.weixin.qq.com/s/77zgt1yMhNcR9lkGFpIW6g

原文在微信上公众号上，故在此留档。

0. npm自理

1. 安装Claude

```bash
npm install -g @anthropic-ai/claude-code
```

2. 配置环境变量：

```bash
export ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic/
export ANTHROPIC_API_KEY=YOUR_API_KEY_HERE
```

3. 配置`~/.claude.json`

```json
{
  "installMethod": "unknown",
  "autoUpdates": false,
  "hasCompletedOnboarding": true
}
```

4. **充钱才能变强**：充50，累计50以下都有非常严格的调用频次限制，实际上不可用。