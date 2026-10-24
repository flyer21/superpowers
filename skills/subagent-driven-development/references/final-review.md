# 整分支自审与完成

属于 superpowers:subagent-driven-development。计划中的每个任务都已完成。

整分支自审由你本人执行，不派遣审查子代理：用 `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD`（MERGE_BASE = 分支开始的提交，例如 `git merge-base main HEAD`）生成整条分支的 diff 包，亲自通读它，连同计划文件（或规格）与账本对照。逐项核实的清单见 [task-reviewer-prompt.md](../task-reviewer-prompt.md)。

你发现的问题按严重级别分诊：Critical / Important / 规格 ❌ 进修复波；Minor 记入账本延后（`Review: minor (deferred): <one-liner>`）。

如果自审发现了问题，派遣**一个**修复子代理携带完整的问题清单——不是每个问题一个修复者。每个问题的修复者各自重建上下文并重新运行套件；真实会话里那样做的成本超过其所有任务的总和。修复完成后做一次限定范围的复检（`bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 覆盖修复范围，[re-review-prompt.md](../re-review-prompt.md)）。裁决任何剩余问题如同修复波的断路器（references/fix-loop.md）：用裁决停放，或对负载关键的问题裁决并记入账本你决定的内容。只有停止运行计划的东西（SKILL.md 顶部）在这里停止你。

### 完成

在删除任何东西之前，收集每个包含 `Ruling:` 的账本行——预飞行裁决、停放发现、断路器裁决，所有——在你的最终消息下"我做的裁决"，按你做的顺序，每个带有如果错误的成本。列表是详尽的：如果账本持有裁决，列表持有它。该列表是你代表你的（人类）搭档做的决定到达他们的唯一地方——他们阅读它并重新做你做的任何错误的东西。与工作区一起死去的裁决是秘密做的决定。

当整分支自审干净且其修复已合并，删除此计划的工作区（`rm -rf <workspace>`）——git 历史现在是记录。同级目录属于其他计划；不要动它们。

使用 superpowers:finishing-a-development-branch。
