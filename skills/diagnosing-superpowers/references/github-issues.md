# GitHub 问题

使用 `gh`（当已安装且已认证时）；它处理认证、速率限制和 JSON。回退到使用 curl 的公共 API，然后到你伙伴打开的 URL。

## 搜索

```bash
gh search issues --repo obra/superpowers --limit 10 "<terms>" \
  --json number,state,title --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
```

没有 `gh` 时（未认证，每分钟 10 个请求）：

```bash
curl -s -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:obra/superpowers+is:issue+<url编码的术语>&per_page=10" \
  | jq -r '.items[] | "\(.number)\t\(.state)\t\(.title)"'
```

没有 curl 时，交给你伙伴打开 `https://github.com/obra/superpowers/issues?q=<terms>`。

## 提交

将填好的 `templates/issue.md` 写入工作区并显示确切文本。获得批准后：

```bash
gh issue create --repo obra/superpowers --title "<title>" --body-file <path> \
  --label bug --label automated-issue-report
```

当报告者没有推送权限时，GitHub 会静默丢弃标签，所以标签只对协作者生效；模板页脚仍然标记问题为技能提交。`gh` 无法附加文件：在问题存在后，通过浏览器让你的伙伴附加捆绑路径。

没有 `gh` 时，交给你一个预填充的链接，使用 `bug_report.md` 模板，它为任何报告者应用 `bug` 标签：

```
https://github.com/obra/superpowers/issues/new?template=bug_report.md&title=<url编码的标题>&body=<url编码的内容>
```

GitHub 拒绝超过约 8,000 个字符的 URL；超过该限制时，只发送带标题的链接，并告诉你的伙伴从文件粘贴内容。