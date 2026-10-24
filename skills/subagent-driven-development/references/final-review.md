# 最终审查与完成

属于 superpowers:subagent-driven-development。计划中的每个任务都已完成。

最终的整个分支审查也获得一个包：运行 `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD`（MERGE_BASE = 分支开始的提交，例如 `git merge-base main HEAD`）并在最终审查派遣中包含打印的路径，这样最终审查者阅读一个文件而不是用 git 命令重新推导分支 diff。在最可用的有能力的模型上派遣（参见 SKILL.md 的模型选择），使用 superpowers:requesting-code-review 的 [code-reviewer.md](../../requesting-code-review/code-reviewer.md)。指向账本的延迟次要和停放行，以便它可以分类哪些必须在合并之前修复。

如果最终整个分支审查返回发现，派遣一个修复子代理与完整的发现列表——不是每个发现一个修复者。每个发现的修复者各自重建上下文并重新运行套件；真实会话的最终审查修复波成本超过其所有任务的总和。然后精确运行一次修复波的范围重新审查（`bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 覆盖修复范围，[re-review-prompt.md](../re-review-prompt.md)）。裁决任何剩余发现如同修复循环的断路器（references/fix-loop.md）：用裁决停放，或对负载关键的发现裁决并账本你决定的内容。只有停止运行计划的东西（SKILL.md 顶部）在这里停止你。没有第二次修复波——剩余负载关键发现表面给你的合作伙伴，当 finishing-a-development-branch 呈现选项时。

### 完成

在删除任何东西之前，收集每个包含 `Ruling:` 的账本行——预飞行裁决、停放发现、断路器裁决，所有——在你的最终消息下"我做的裁决"，按你做的顺序，每个带有如果错误的成本。列表是详尽的：如果账本持有裁决，列表持有它。该列表是你代表你的合作伙伴做的决定到达他们的唯一地方——他们阅读它并重新做你做的任何错误的东西。与工作区一起死去的裁决是秘密做的决定。

当最终整个分支审查干净且其修复已合并，删除此计划的工作区（`rm -rf <workspace>`）——git 历史现在是记录。兄弟目录属于其他计划；不要动它们。

使用 superpowers:finishing-a-development-branch。