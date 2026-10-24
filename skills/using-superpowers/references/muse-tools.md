# Muse 工具映射

技能以动作表述（"派发子代理"、"创建待办"、"读取文件"）。在 Muse 上，这些动作解析为以下工具。

| 技能请求的动作 | Muse 等效 |
|----------------------|----------------|
| 读取文件 | `read_file` |
| 读取多个文件 | `read_file`（多次调用）或 `search` |
| 创建新文件 | `write_file` |
| 编辑文件 | `edit_file` |
| 运行 shell 命令 | `bash` |
| 搜索文件内容 | `search` |
| 按名称查找文件 | `search` 使用 `glob` |
| 获取 URL | `web_fetch` |
| 搜索网页 | `web_search` |
| 调用技能 | 读取 `skills/<name>/SKILL.md` 或本地技能工具 |
| 派发子代理（`Subagent (general-purpose):` 模板） | `subagent_spawn`，填充提示 |
| 任务跟踪（"创建待办"、"标记完成"） | `write_todos` 或 `bash` 任务文件 |
| 向用户提问 | `request_user_input` |

## 指令文件

当技能提到"你的指令文件"时，在 Muse 上这是项目根目录中的 **`CLAUDE.md`** 或 **`AGENTS.md`**。Muse 在配置的地方分层加载它们。

## 技能调用

Muse 通过 `muse skills` 提供本地技能支持。要调用 Superpowers 技能，读取其 `SKILL.md` 并遵循说明。引导程序（`using-superpowers`）通过插件钩子在 `SessionStart` 时自动注入 — 你已经在遵循它，不要重新加载它。

## 子代理派发

使用 `subagent_spawn` 将工作委派给隔离的子代理。在派发之前填充提示模板（例如 `implementer-prompt.md`、`task-reviewer-prompt.md`）。如果没有子代理工具可用，内联完成工作而不是发明工具调用。

## 任务跟踪

使用 `write_todos` 进行检查清单跟踪。为每个技能检查清单项创建一个待办，随着进度标记 in_progress/completed。如果 `write_todos` 不可用，通过 `write_file`/`edit_file` 维护 markdown 任务文件。