# Pi 工具映射

技能以动作语言来表达（"派发子代理"、"创建一个 todo"、"读取文件"）。在 Pi 上，这些动作解析为下面的工具。

| 技能请求的动作 | Pi 对应 |
| --- | --- |
| 派发子代理（`Subagent (general-purpose):` 模板） | 如果可用，使用已安装的子代理工具，例如来自 `pi-subagents` 的 `subagent` |
| 任务追踪（"创建一个 todo"、"标记完成"） | 如果可用，使用已安装的 todo/任务工具；否则把任务记在计划里或 `TODO.md` 中 |

## 子代理（Subagents）

Pi 核心不自带标准子代理工具。`pi-subagents` 包是一个得力的可选搭档，提供一个 `subagent` 工具，支持单代理、链式、并行、异步、forked-context 以及恢复/状态工作流。如果没有可用的子代理工具，不要编造 `Task` 调用；在当前会话里串行执行，或者说明可选的子代理能力尚未安装。

## 任务清单（Task lists）

Pi 核心不自带标准的任务清单工具。如果安装了某个 todo/任务扩展，就用它文档化的工具。否则用 Superpowers 计划文件、Markdown 检查清单或仓库本地的 `TODO.md` 做任务追踪。更早的 Superpowers 文档可能提到 `TodoWrite`；把它当作上面的任务追踪动作。
