# Antigravity CLI（`agy`）工具映射

技能以动作语言来表达（"派发子代理"、"创建一个 todo"、"读取文件"）。在 Antigravity CLI（`agy`）上，这些动作解析为下面的工具。

| 技能请求的动作 | Antigravity CLI 对应 |
|----------------------|----------------------|
| 派发子代理（`Subagent (general-purpose):` 模板） | `invoke_subagent`，配一个内建 `TypeName` —— 全能力工作用 `self`，只读工作用 `research` |
| 任务追踪（"创建一个 todo"、"标记完成"） | 一个 **task artifact** —— 用 `write_to_file` 写入，带 `IsArtifact: true`、`ArtifactType: "task"`（见[任务追踪](#task-tracking)）。**不是** `manage_task`，后者管理的是后台进程。 |

## 任务追踪（Task tracking）

Antigravity **没有 todo 工具**（`manage_task` 管理的是后台进程——`list`/`kill`/`status`/`send_input`——它 *不是* 一个检查清单）。当技能说要创建 todo 清单或追踪任务时，维护一个 **task artifact**：用 `write_to_file` 保存的 markdown 检查清单（`IsArtifact: true`、`ArtifactMetadata.ArtifactType: "task"`），随进度用 `replace_file_content` / `multi_replace_file_content` 编辑。

在开始任何多步骤任务时，创建列出计划中每一步的 task artifact。每完成一步，就编辑该 artifact 把它标记为完成（`- [x]`）。如果计划变了，更新检查清单。让它保持最新——它是你还剩什么没做的真相来源；一旦对话变长，在开始每一步之前重新读它。
