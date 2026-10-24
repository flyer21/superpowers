# Antigravity CLI (`agy`) 工具映射

技能以动作表述（"派发子代理"、"创建待办"、"读取文件"）。在 Antigravity CLI (`agy`) 上，这些动作解析为以下工具。

| 技能请求的动作 | Antigravity CLI 等效 |
|----------------------|----------------------|
| 派发子代理（`Subagent (general-purpose):` 模板） | `invoke_subagent`，使用内置 `TypeName` — `self` 用于全能力工作，`research` 用于只读 |
| 任务跟踪（"创建待办"、"标记完成"） | **任务工件** — 使用 `write_to_file`，设置 `IsArtifact: true` 和 `ArtifactType: "task"`（参见[任务跟踪](#task-tracking)）。**不是** `manage_task`，后者管理后台进程。 |

## 任务跟踪

Antigravity **没有待办工具**（`manage_task` 管理后台进程 — `list`/`kill`/`status`/`send_input` — 它*不是*检查清单）。当技能说要创建待办列表或跟踪任务时，维护一个**任务工件**：使用 `write_to_file`（`IsArtifact: true`，`ArtifactMetadata.ArtifactType: "task"`）保存的 markdown 检查清单，在过程中使用 `replace_file_content` / `multi_replace_file_content` 编辑。

在任何多步骤任务的开始时，创建任务工件，列出计划的每个步骤。完成每个步骤时，编辑工件将其标记为完成（`- [x]`）。如果计划发生变化，更新检查清单。保持其最新状态 — 它是剩余工作的真相来源；一旦对话变长，在开始每个步骤之前重新阅读它。