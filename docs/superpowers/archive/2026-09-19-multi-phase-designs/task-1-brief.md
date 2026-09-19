### 任务 1：基线记录与断言脚本（RED）

**文件（Files）：**
- 新建（Create）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
- 新建（Create）：`docs/superpowers/evals/2026-09-19-multi-phase/baseline.md`

**接口（Interfaces）：**
- 消费（Consumes）：无
- 产出（Produces）：可执行的 `check.sh`（后续任务 2-5 各追加一个断言函数；用法 `bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`，全部断言通过时退出码 0 并打印 `ALL CHECKS PASS`）；`baseline.md` 记录改动前的失败证据

- [ ] **第 1 步：编写断言脚本**

创建 `docs/superpowers/evals/2026-09-19-multi-phase/check.sh`，内容如下（此时只有任务 1 的既有状态断言，后续任务各自追加）：

```bash
#!/usr/bin/env bash
# 多阶段设计改动的结构断言（RED→GREEN）
# 用法：bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh
cd "$(dirname "$0")/../../.." || exit 1
fail=0

check() { # check <名称> <命令...>
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"; fail=1
  fi
}

# 任务 1（基线）：改动前，5 个技能都没有"顺序阶段"支持——这些是记录基线用的反向断言
check "基线：brainstorming 无顺序阶段指引" bash -c '! grep -q "顺序阶段" skills/brainstorming/SKILL.md'
check "基线：writing-plans 无路线图字段" bash -c '! grep -q "路线图（Roadmap）" skills/writing-plans/SKILL.md'
check "基线：finishing 无路线图检测" bash -c '! grep -q "路线图检测" skills/finishing-a-development-branch/SKILL.md'

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASS" || echo "CHECKS FAILED"
exit "$fail"
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：3 条基线反向断言全部 PASS、打印 `ALL CHECKS PASS`（证明改动前"顺序阶段"支持不存在——这就是 RED 证据的静态部分）

- [ ] **第 2 步：编写基线记录**

创建 `docs/superpowers/evals/2026-09-19-multi-phase/baseline.md`：

```markdown
# 多阶段设计改动 — 基线记录（RED）

日期：2026-09-19
规格：docs/superpowers/specs/2026-09-19-multi-phase-designs-design.md

## 基线证据（静态分析，非 LLM 实测）

以下断言在改动前全部成立（见 check.sh 的"基线"反向断言与运行记录）：

1. `skills/brainstorming/SKILL.md` 的范围评估只覆盖"相互独立的子系统"分解，
   没有"顺序阶段"概念——一个顺序阶段型大目标会被误拆为独立子项目，或塞进一份规格。
2. `skills/writing-plans/SKILL.md` 的范围检查与计划头部都没有路线图/阶段概念，
   无法区分"独立子系统拆多计划"与"顺序阶段每阶段一计划"。
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
```

- [ ] **第 3 步：运行脚本，确认基线成立**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`（3 条基线断言 PASS）

- [ ] **第 4 步：提交**

```bash
git add docs/superpowers/evals/2026-09-19-multi-phase/
git commit -m "docs(eval): add multi-phase baseline evidence and check script"
```

