# Gemini CLI 工具映射

技能以动作表述（"派发子代理"、"创建待办"、"读取文件"）。在 Gemini CLI 上，这些动作解析为以下工具。

| 技能请求的动作 | Gemini CLI 等效 |
|----------------------|----------------------|
| 读取文件 | `read_file` |
| 一次读取多个文件 | `read_many_files` |
| 创建新文件 | `write_file` |
| 编辑文件 | `replace` |
| 运行 shell 命令 | `run_shell_command` |
| 搜索文件内容 | `grep_search` |
| 按名称查找文件 | `glob` |
| 列出文件和子目录 | `list_directory` |
| 获取 URL | `web_fetch` |
| 搜索网页 | `google_web_search` |
| 调用技能 | `activate_skill` |
| 派发子代理（`Subagent (general-purpose):` 模板） | `invoke_agent`，使用 `agent_name: "generalist"`（可通过 `@generalist` 聊天语法调用 — 参见[子代理支持](#subagent-support)） |
| 多次并行派发 | 同一响应中的多次 `invoke_agent` 调用 |
| 任务跟踪（"创建待办"、"标记完成"） | `write_todos`（状态：pending、in_progress、completed、cancelled、blocked） |

## 指令文件

当技能提到"你的指令文件"时，在 Gemini CLI 上这是 **`GEMINI.md`**。Gemini CLI 分层加载 `GEMINI.md`：全局在 `~/.gemini/GEMINI.md`，项目级文件在工作区目录及其祖先中，以及当工具访问这些目录中的文件时的子目录 `GEMINI.md` 文件。

## 个人技能目录

用户级技能位于 **`~/.gemini/skills/`**，**`~/.agents/skills/`** 作为跨运行时别名（与 Codex 和 Copilot CLI 共享）。当两个目录在同一作用域都存在时，`.agents/skills/` 优先。每个技能是一个包含 `SKILL.md`（带有 `name` 和 `description` frontmatter）的子目录。

## 子代理支持

Gemini CLI 通过 `invoke_agent` 工具派发子代理，该工具接受 `agent_name` 和 `prompt` 参数。相同的派发也作为聊天语法快捷方式出现：输入 `@generalist <prompt>` 等效于使用 `agent_name: "generalist"` 调用 `invoke_agent`。内置代理名称包括 `generalist`、`cli_help`、`codebase_investigator`，以及（启用浏览器工具时）`browser_agent`。

技能使用 `Subagent (general-purpose):` 派发，并引用提示模板文件（例如 `superpowers:subagent-driven-development` 的 `./implementer-prompt.md`）或提供内联提示。在 Gemini CLI 上：

| 技能派发形式 | Gemini CLI 等效 |
|---------------------|----------------------|
| 引用 `*-prompt.md` 模板（实现者、任务审查者、代码审查者等） | 填充模板，然后使用 `invoke_agent`，设置 `agent_name: "generalist"` 和填充后的提示 |
| 引用 `superpowers:requesting-code-review` 的 `./code-reviewer.md` | `invoke_agent`，使用 `agent_name: "generalist"` 和填充的审查模板 |
| 内联提示（未引用模板） | `invoke_agent`，使用 `agent_name: "generalist"` 和你的内联提示 |

### 提示填充

技能提供带有 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]` 等占位符的提示模板。在将完整提示传递给 `invoke_agent` 之前填充所有占位符。提示模板本身包含代理的角色、审查标准和预期输出格式 — 子代理将遵循它。

### 并行派发

Gemini CLI 支持并行子代理派发。在同一响应中发出多次 `invoke_agent` 调用（或在一个提示中多次 `@generalist` 调用）以并行运行独立的子代理工作。保持依赖任务顺序执行，但不要仅为了保持更简单的历史而将独立的子代理任务序列化。

## 额外的 Gemini CLI 工具

这些工具是 Gemini CLI 独有的：

| 工具 | 用途 |
|------|---------|
| `save_memory`（旧版） | 当 `experimental.memoryV2 = false` 时跨会话持久化事实 |
| `get_internal_docs` | 查找 Gemini CLI 的捆绑文档 |
| `ask_user` | 向用户提出结构化问题（文本/单选/多选） |
| `enter_plan_mode` / `exit_plan_mode` | 切换进入和退出只读计划模式 |
| `update_topic` | 更新当前对话的主题/战略意图元数据 |
| `complete_task` | 信号 Gemini 子代理已完成并将其结果返回给父代理 |
| `tracker_create_task`、`tracker_update_task`、`tracker_get_task`、`tracker_list_tasks`、`tracker_add_dependency`、`tracker_visualize` | 带有依赖和可视化支持的丰富任务跟踪器 |
| `read_mcp_resource`、`list_mcp_resources` | MCP 资源访问 |