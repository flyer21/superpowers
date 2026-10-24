# Hermes Agent 工具映射

技能以动作表述（"派发子代理"、"创建待办"、"读取文件"）。在 Hermes Agent 上，这些动作解析为以下工具。

## 工具

| 技能请求的动作 | Hermes 工具 |
|---|---|
| 读取文件 | `read_file` |
| 创建新文件 | `write_file` |
| 编辑文件（目标补丁） | `patch` |
| 运行 shell 命令 | `terminal` |
| 搜索文件内容 | `search_files` |
| 按名称查找文件 | `terminal` 使用 `find` |
| 获取 URL/读取网页 | `web_extract(urls=[...])` |
| 搜索网页 | `web_search(query=...)` |
| 派发子代理 | `delegate_task(goal=..., context=..., toolsets=[...], role="leaf")` |
| 任务跟踪 | `todo` 工具 |
| 调用技能 | `skill_view("skill-name")` |

## 指令文件

当技能提到"你的指令文件"时，在 Hermes Agent 上这是项目目录中的 **`AGENTS.md`**，或全局在 `~/.hermes/SOUL.md` 的 **`SOUL.md`**。

## 调用技能

Hermes Agent 有一个 `skills` 工具集，包含 `skill_view` 和 `skills_list` 工具。
要调用 superpowers 技能，使用：

```
skill_view("brainstorming")
skill_view("test-driven-development")
```

如果 `skill_view` 找不到 superpowers 技能（在插件完全注册之前它可能不会出现在目录中），回退到直接读取 SKILL.md：

```
read_file(path="~/.hermes/plugins/superpowers/skills/<skill-name>/SKILL.md")
```

这个回退机制与其他没有本地技能加载的工具使用的机制相同。

## 子代理派发

使用 `delegate_task` 生成隔离的子代理以进行并行或顺序工作流：

```
delegate_task(goal="...", context="...", toolsets=[...], role="leaf")
```

如果 `delegate_task` 不可用，内联完成工作而不是发明工具调用。

## 任务跟踪

在会话中使用 `todo` 工具进行任务跟踪。对于多代理任务板，如果可用，使用 `hermes kanban` CLI。将旧的 `TodoWrite` 引用视为任务跟踪动作。