## 子代理派发需要多代理支持

添加到你的 Codex 配置（`~/.codex/config.toml`）：

```toml
[features]
multi_agent = true
```

这启用了 `dispatching-parallel-agents` 和 `subagent-driven-development` 等技能使用的多代理工具。你获得的工具取决于你的模型预设选择的多代理版本（当前预设运行 V2；较旧的运行 V1）。当它们不一致时，相信你的实际工具列表而不是任何表格 — 包括这个。

- **生成：** 使用 `spawn_agent {fork_turns: "none"}` 给子代一个干净的上下文；默认值 `"all"` 会将你的整个转录复制到子代中。在 Codex 0.145+ 上，`~/.codex/agents/` 下的角色文件通过 `agent_type` 附加到隔离分支。完整历史分支接受 `model` 和 `reasoning_effort` 覆盖（只有 `agent_type` 在那里被拒绝）— 隔离分支是 SDD 的默认上下文卫生选择，不是因为覆盖需要它们。
- **修复轮次：** 使用 `followup_task` 恢复实现者 — 它传递你的消息、触发轮次，并透明地重新加载工具驱逐的子代。绝不要基于生成的代理无法再次被消息的理论派发新的实现者；在 V2 上总是可以。
- **生命周期：** V2 没有 `close_agent`。当需要槽位时，完成的子代会自动被驱逐；让它们不关闭不会花费任何代价。只有 V1 会话有 `close_agent` — 在那里，当审查返回时关闭审查者，并在每个实现者的任务审查通过后关闭它。
- **模型名称：** 在将模型名称从技能、表格或旧会话复制到 `spawn_agent` 之前，始终根据你的当前生成允许列表检查它 — V2 仅接受 V2 能力的预设，并对其余的硬错误。

## 等待子代

`wait_agent` 是事件订阅，不是轮询：长等待在子代产生邮箱活动时立即唤醒，与短等待具有相同的延迟。短超时轮询没有任何好处，每次轮询只会花费一个工具调用 — 以及上下文重新计费 — 。在测量的会话中，大约三分之二的 wait 调用是超时的短轮询。

- 当你仍有本地工作时，根本不要等待。完成的子代的最终答案被推入你的邮箱，并在你的下一个轮次到达。
- 当你真正空闲且有未完成的子代时，在有界 stretches 中等待：`wait_agent` 带 `timeout_ms` 300000-600000（5-10 分钟）。每次 stretch 后 — 唤醒或超时 — 发布一行状态，运行 `list_agents`，并追踪任何完成但未报告的子代。绝不要堆叠短于五分钟的轮询；事件订阅在有界 stretch 中的唤醒速度与短轮询一样快。
- 完成邮件无法唤醒空闲的控制器（它在传递时不会触发轮次）；覆盖该空闲窗口是 `wait_agent` 的唯一工作。超时且没有活动的 stretch 是你进行协调的信号，而不是缩短下一个 stretch。

## 生成时的模型路由

你发出的每个 `spawn_agent` — 包括当你自己是运行扇出的生成子代时 — 根据你正在执行的技能的模型选择规则显式设置 `model` 和 `reasoning_effort`。仅设置 `model` 是一个陷阱：子代的 effort 会静默重置为该模型的默认值，而不是你的。

让你的伙伴在 `~/.codex/config.toml` 中添加机器级后备，以便任何漏掉的生成仍然路由到故意的层级，而不是静默继承会话中最昂贵的模型：

```toml
[agents]
default_subagent_model = "<你的生成允许列表中的中等模型>"
default_subagent_reasoning_effort = "medium"
```

## 环境检测

创建工作树或完成分支的技能应在继续之前使用只读 git 命令检测其环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已在链接的工作树中（跳过创建）
- `BRANCH` 为空 → 分离 HEAD（无法从沙盒分支/推送/PR）

参见 `using-git-worktrees` 步骤 0 和 `finishing-a-development-branch` 步骤 1，了解每个技能如何使用这些信号。

## Codex App 完成

当沙盒阻止分支/推送操作（外部管理工作树中的分离 HEAD）时，代理提交所有工作并告知用户使用 App 的本机控件：

- **"创建分支"** — 命名分支，然后通过 App UI 提交/推送/PR
- **"交接到本地"** — 将工作转移到用户的本地检出

代理仍然可以运行测试、暂存文件，并输出建议的分支名称、提交消息和 PR 描述供用户复制。