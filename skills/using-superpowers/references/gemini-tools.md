# Gemini CLI 工具映射

技能以动作语言来表达（"派发子代理"、"创建一个 todo"、"读取文件"）。在 Gemini CLI 上，这些动作解析为下面的工具。

| 技能请求的动作 | Gemini CLI 对应 |
|----------------------|----------------------|
| 读取文件 | `read_file` |
| 一次读取多个文件 | `read_many_files` |
| 创建新文件 | `write_file` |
| 编辑文件 | `replace` |
| 运行 shell 命令 | `run_shell_command` |
| 搜索文件内容 | `grep_search` |
| 按文件名查找 | `glob` |
| 列出文件和子目录 | `list_directory` |
| 抓取一个 URL | `web_fetch` |
| 搜索网络 | `google_web_search` |
| 调用一个技能 | `activate_skill` |
| 派发子代理（`Subagent (general-purpose):` 模板） | `invoke_agent`，配 `agent_name: "generalist"`（可通过 `@generalist` 聊天语法调用——见[子代理支持](#subagent-support)） |
| 多个并行派发 | 同一条响应里多次 `invoke_agent` 调用 |
| 任务追踪（"创建一个 todo"、"标记完成"） | `write_todos`（状态：pending、in_progress、completed、cancelled、blocked） |

## 指令文件（Instructions file）

当技能提到"你的指令文件"时，在 Gemini CLI 上它就是 **`GEMINI.md`**。Gemini CLI 分层加载 `GEMINI.md`：全局在 `~/.gemini/GEMINI.md`，项目级文件在工作区目录及其祖先目录里，而当工具访问子目录里的文件时，也会加载那些目录的子级 `GEMINI.md` 文件。

## 个人技能目录（Personal skills directory）

用户级技能位于 **`~/.gemini/skills/`**，以 **`~/.agents/skills/`** 作为跨运行时别名（与 Codex 和 Copilot CLI 共享）。当同一作用域下两个目录都存在时，`.agents/skills/` 优先。每个技能是一个包含 `SKILL.md`（带 `name` 和 `description` frontmatter）的子目录。

## 子代理支持（Subagent support）

Gemini CLI 通过 `invoke_agent` 工具派发子代理，它接收 `agent_name` 和 `prompt` 参数。同样的派发也以聊天语法快捷方式呈现：输入 `@generalist <prompt>` 等价于以 `agent_name: "generalist"` 调用 `invoke_agent`。内建代理名包括 `generalist`、`cli_help`、`codebase_investigator`，以及（启用浏览器工具时）`browser_agent`。

技能以 `Subagent (general-purpose):` 派发，并且要么引用一个 prompt 模板文件（例如 `superpowers:subagent-driven-development` 的 `./implementer-prompt.md`），要么提供一个内联 prompt。在 Gemini CLI 上：

| 技能派发形式 | Gemini CLI 对应 |
|---------------------|----------------------|
| 引用一个 `*-prompt.md` 模板（implementer、task-reviewer、code-reviewer 等） | 填好模板，然后以 `agent_name: "generalist"` 和填好的 prompt 调用 `invoke_agent` |
| 引用 `superpowers:requesting-code-review` 的 `./code-reviewer.md` | 以 `agent_name: "generalist"` 和填好的评审模板调用 `invoke_agent` |
| 内联 prompt（不引用模板） | 以 `agent_name: "generalist"` 和你的内联 prompt 调用 `invoke_agent` |

### 填写 prompt（Prompt filling）

技能提供的 prompt 模板带 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]` 之类的占位符。在把完整 prompt 传给 `invoke_agent` 之前，填好所有占位符。prompt 模板本身含有代理的角色、评审标准以及期望的输出格式——子代理会遵循它。

### 并行派发（Parallel dispatch）

Gemini CLI 支持并行子代理派发。在同一条响应里发出多次 `invoke_agent` 调用（或在一条 prompt 里多次 `@generalist` 调用），即可并行运行相互独立的子代理工作。有依赖的任务保持串行，但不要仅仅为了保住更简单的历史，就把相互独立的子代理任务串行化。

## Gemini CLI 特有的其他工具（Additional Gemini CLI tools）

这些工具是 Gemini CLI 独有的：

| 工具 | 用途 |
|------|---------|
| `save_memory`（遗留） | 当 `experimental.memoryV2 = false` 时，跨会话持久化事实 |
| `get_internal_docs` | 查询 Gemini CLI 自带的文档 |
| `ask_user` | 向用户提出结构化问题（文本 / 单选 / 多选） |
| `enter_plan_mode` / `exit_plan_mode` | 切入和切出只读的计划模式 |
| `update_topic` | 更新当前会话的主题 / 战略意图元数据 |
| `complete_task` | 发出信号表示某个 Gemini 子代理已完成，并把其结果返回给父代理 |
| `tracker_create_task`、`tracker_update_task`、`tracker_get_task`、`tracker_list_tasks`、`tracker_add_dependency`、`tracker_visualize` | 支持依赖和可视化的丰富任务追踪器 |
| `read_mcp_resource`、`list_mcp_resources` | MCP 资源访问 |
