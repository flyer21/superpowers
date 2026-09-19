# 多阶段设计改动 — 基线记录（RED）

日期：2026-09-19
规格：docs/superpowers/specs/2026-09-19-multi-phase-designs-design.md

## 基线证据（静态分析，非 LLM 实测）

以下断言在改动前全部成立（见 check.sh 的“基线”反向断言与运行记录）：

1. `skills/brainstorming/SKILL.md` 的范围评估只覆盖“相互独立的子系统”分解，
   没有“顺序阶段”概念——一个顺序阶段型大目标会被误拆为独立子项目，或塞进一份规格。
2. `skills/writing-plans/SKILL.md` 的范围检查与计划头部都没有路线图/阶段概念，
   无法区分“独立子系统拆多计划”与“顺序阶段每阶段一计划”。
3. `skills/executing-plans/SKILL.md`、`skills/subagent-driven-development/SKILL.md`
   进入收尾时不传递任何阶段上下文。
4. `skills/finishing-a-development-branch/SKILL.md` 收尾后直接结束，
   没有回到下一阶段设计的闭环。

## 压力场景（待 drill 实测）

- 场景 A（多阶段目标）：给出明确需要顺序阶段的大目标 → 期望产出路线图而非单一规格。
- 场景 B（阶段闭环）：阶段 1 收尾完成 → 期望自动提示进入阶段 2 头脑风暴。
- 场景 C（无回归）：普通单阶段目标（有界/架构级）→ 行为与现状一致。

## 评估状态

本仓库未配置 superpowers-evals（drill）本地环境。基于 LLM 判定的完整 eval
按 AGENTS.md 要求仍需在 drill 上补充运行（见 verification.md 的后续工作记录）；
本次改动的验证 = 本基线 + check.sh 结构断言 + 整分支自审。
