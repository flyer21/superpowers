# Hermes Agent 工具映射

技能以动作语言来表达（"派发子代理"、"创建一个 todo"、"读取文件"）。在 Hermes Agent 上，这些动作解析为下面的工具。

## 工具（Tools）

| 技能请求的动作 | Hermes 工具 |
|---|---|
| 读取文件 | `read_file` |
| 创建新文件 | `write_file` |
| 编辑文件（定向补丁） | `patch` |
| 运行 shell 命令 | `terminal` |
| 搜索文件内容 | `search_files` |
| 按文件名查找 | 用 `find` 的 `terminal` |
| 抓取 URL / 读取网页 | `web_extract(urls=[...])` |
| 搜索网络 | `web_search(query=...)` |
| 派发子代理 | `delegate_task(goal=..., context=..., toolsets=[...], role="leaf")` |
| 任务追踪 | `todo` 工具 |
| 调用一个技能 | `skill_view("skill-name")` |

## 指令文件（Instructions file）

当技能提到"你的指令文件"时，在 Hermes Agent 上它就是项目目录里的 **`AGENTS.md`**，或全局的 **`SOUL.md`**（`~/.hermes/SOUL.md`）。

## 调用技能（Invoking a skill）

Hermes Agent 有一个 `skills` 工具集，含 `skill_view` 和 `skills_list` 工具。
要调用 superpowers 技能，使用：

```
skill_view("brainstorming")
skill_view("test-driven-development")
```

如果 `skill_view` 找不到某个 superpowers 技能（插件完全注册它之前，它可能不会出现在目录里），回退为直接读取 SKILL.md：

```
read_file(path="~/.hermes/plugins/superpowers/skills/<skill-name>/SKILL.md")
```

这个回退与没有原生技能加载机制的其他 harness 所用的机制相同。

## 派发子代理（Subagent dispatch）

用 `delegate_task` 为并行或串行的工作流生成隔离的子代理：

```
delegate_task(goal="...", context="...", toolsets=[...], role="leaf")
```

如果 `delegate_task` 不可用，就在本地内联完成工作，而不要编造工具调用。

## 任务追踪（Task tracking）

在一个会话内用 `todo` 工具做任务追踪。对于多代理任务看板，如果可用，用 `hermes kanban` CLI。把更早的 `TodoWrite` 引用当作任务追踪动作。
