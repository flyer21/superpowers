## 派发子代理需要多代理支持（Subagent dispatch requires multi-agent support）

在你的 Codex 配置里加上（`~/.codex/config.toml`）：

```toml
[features]
multi_agent = true
```

这会启用 `dispatching-parallel-agents` 和 `subagent-driven-development` 这类技能所用的多代理工具。你能得到哪些工具，取决于你的模型预设选择的多代理版本（当前预设运行 V2；旧版运行 V1）。当它们不一致时，以你实际的工具清单为准，而不是任何表格——包括这张。

- **生成（Spawning）：** 用 `spawn_agent {fork_turns: "none"}` 给子代理干净的上下文；默认值 `"all"` 会把你的整个转录复制进子代理。在 Codex 0.145+ 上，`~/.codex/agents/` 下的角色文件（role files）通过 `agent_type` 挂接到隔离的 fork 上。全历史 fork 接受 `model` 和 `reasoning_effort` 覆盖（那里只拒绝 `agent_type`）——隔离 fork 是 SDD 出于上下文卫生的默认，不是因为覆盖需要它们。
- **修复轮次（Fix rounds）：** 用 `followup_task` 恢复实现者——它会投递你的消息、触发一轮对话，并透明地重新加载一个被 harness 逐出的子代理。绝不要基于"被生成的代理无法再次被联系"的理论派发新的实现者；在 V2 上它永远可以。
- **生命周期（Lifecycle）：** V2 没有 `close_agent`。完成的子代理在需要槽位时会被自动逐出；不关它们也不花任何代价。只有 V1 会话有 `close_agent`——在那里，评审者的评审返回后关掉它们，每个实现者在其任务的评审通过后关掉它。
- **模型名（Model names）：** 绝不要把从技能、表格或旧会话里拿到的模型名不经核对就放进 `spawn_agent`——先对你的当前生成许可清单（spawn allowlist）核对——V2 只接受支持 V2 的预设，对其余的会硬报错。

## 等待子代理（Waiting on children）

`wait_agent` 是一种事件订阅，不是轮询：一次长等待会在子代理一产生信箱活动时就醒来，延迟和短等待一样。短超时的轮询毫无收益，而且每次轮询都要花一次工具调用——以及一次上下文计费（context rebill）。在实测的会话里，大约三分之二的等待调用都是超时了的短轮询。

- 当你还有本地工作要做时，根本不要等待。一个完成子代理的最终答案会被推进你的信箱，随你的下一轮一起到达。
- 当你真的空闲但还有子代理未完成时，用有界的时间段等待：`wait_agent` 带 `timeout_ms` 300000-600000（5-10 分钟）。每段之后——无论醒来还是超时——发一行状态，运行 `list_agents`，并追查任何完成了却没汇报的子代理。绝不要堆叠短于五分钟的轮询；事件订阅唤醒一个有界时间段和唤醒一个短时间段一样快。
- 完成邮件无法唤醒一个空闲的控制器（它在不触发对话轮次的情况下被投递）；覆盖那段空闲窗口正是 `wait_agent` 唯一的工作。某段时间超时且毫无活动，是你的信号去核对调和，而不是去缩短下一段时间。

## 生成时的模型路由（Model routing on spawns）

你发出的每一个 `spawn_agent`——包括当你自己就是一个做扇出的被生成子代理时——都按你正在执行技能的模型选择规则，显式设置 `model` 和 `reasoning_effort`。只设 `model` 是个陷阱：子代理的努力级别会静默重置为该模型的默认值，而不是你的。

请你的搭档在 `~/.codex/config.toml` 里加一道机器级兜底（backstop），这样任何漏网之鱼的生成仍会路由到某个深思熟虑的档位，而不是静默继承会话里最贵的模型：

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

## 环境检测（Environment Detection）

创建工作树或收尾分支的技能，在继续之前应该用只读 git 命令检测自己的环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已经在一棵链接的工作树里（跳过创建）
- `BRANCH` 为空 → 游离的 HEAD（无法在沙箱里建分支 / 推送 / 建 PR）

关于每个技能如何使用这些信号，见 `using-git-worktrees` 的第 0 步和 `finishing-a-development-branch` 的第 1 步。

## Codex App 收尾（Codex App Finishing）

当沙箱阻止分支 / 推送操作时（在外部托管工作树里的游离 HEAD），代理提交全部工作，并告知用户使用 App 的原生控件：

- **"Create branch"** —— 命名分支，然后通过 App UI 提交 / 推送 / 建 PR
- **"Hand off to local"** —— 把工作转移到用户的本地检出

代理仍然可以运行测试、暂存文件，并输出建议的分支名、提交信息和 PR 描述供用户复制。
