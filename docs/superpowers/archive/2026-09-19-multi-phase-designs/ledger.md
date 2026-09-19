# SDD 执行台账 — 计划: docs/superpowers/plans/2026-09-19-multi-phase-designs.md

工作区: /home/frf/superpowers/.worktrees/multi-phase-designs（分支 multi-phase-designs，基于 main c4f6ef9）
规格: docs/superpowers/specs/2026-09-19-multi-phase-designs-design.md

## 预检扫描（派发任务 1 之前）

| 任务对/任务 | 产出 → 消费 | 发现 |
|---|---|---|
| 任务 1 ↔ 任务 2-5 | check.sh 骨架 → 各任务追加断言 | 任务 1 的基线反向断言在任务 2 落地后必然 FAIL；任务 2 步骤 1 已写明删除基线断言块（运行记录已留在 baseline.md）——一致 |
| 任务 2 | 编辑 2a 把单行改为子列表结构，原句逐字保留 | 与全局约束"只做插入和明确的追加，不重写既有句子"字面冲突 → 裁决 R1 |
| 任务 3 ↔ 任务 4/5 | 产出计划头部字段"路线图（Roadmap）" → 交接语/路线图检测引用 | 字符串逐字核对通过——一致 |
| 任务 4 | 编辑 4b 锚点"使用 superpowers:finishing-a-development-branch。" | 该字符串在 subagent-driven-development/SKILL.md 出现 2 次（收尾 L250 独立行、示例 L339 "完成！使用 …"）→ 裁决 R2 |
| 任务 5 | 锚点"## 快速参考（Quick Reference）"（L194）与核心原则行（L10） | 唯一存在——一致 |
| 任务 6 | 消费任务 2-5 全部锚点字符串做一致性断言 | 计划文本中断言字符串与编辑文本逐字核对通过——一致 |
| 任务 1 产出 check.sh → 仓库 lint 工具 | check.sh（`.sh` 后缀）落入 `scripts/lint-shell.sh` 的 lint 范围 | 仓库无 `.github/workflows/`（无 CI 自动跑）；本机装有 shellcheck → 裁决 R3 |

裁决: R1 — 全局约束"不重写既有句子"按其意图执行：既有句子的措辞必须逐字保留（可移动位置/缩进），编辑 2a 把原句逐字保留在"独立子系统"子列表项内，满足约束意图 — 约束本意是防止改写措辞、保护精心调优内容，不是禁止结构性扩展 — 若错了，代价是约束被弱化，但原句仍在 diff 中逐字可核对。
裁决: R2 — 任务 4 编辑 4b 的目标是"收尾（Finish）"小节的独立行（约 L250），不是示例工作流里"完成！使用 superpowers:finishing-a-development-branch。"那行（约 L339）；派发时明确点名此消歧 — 锚点字符串不唯一，不点名会改错行 — 若错了，代价是示例行被误改，整分支自审可见可修。
裁决: R3 — check.sh 按计划文本逐字转写（不在任务内"顺手"改写成 lint 友好形式）；整分支自审时对该文件跑 shellcheck，报错则作为发现进修复波，做不改断言语义的最小修复 — 计划文本是权威，但仓库自带 lint 工具与 lint 测试，新增 .sh 文件应能过 lint — 若错了，代价是 lint 债务留在分支上，收尾时呈现给搭档。（已核实：shellcheck 对任务 1 的 check.sh 零输出、exit 0 —— R3 无发现，关闭）
裁决: R4 — 计划任务 1 脚本的 `cd "$(dirname "$0")/../../.."` 少一层（实测解析到 docs/ 而非仓库根），改为 `../../../../`；理由是计划意图是断言从仓库根解析 `skills/...` 路径，任务 2-6 的正向断言依赖它（不换成 git rev-parse，保持计划文本风格、不引入 git 依赖）— 若错了，代价是一个路径段，且断言会在任务 2 立刻暴露。
裁决: R5 — 评估证据保留在计划的 `docs/superpowers/evals/2026-09-19-multi-phase/` 路径（不改路径、不改 .gitignore），各任务提交步骤对该目录一律用 `git add -f`（实测 `.gitignore:13` 的无锚点 `evals/` 规则会忽略该目录下的新文件；该规则本意是根目录的 drill 克隆）— 若错了，代价是维护者可能更希望一条反忽略规则，此事实记入 verification.md 供其分诊。

### 任务记录

任务 1: 完成 (提交 c4f6ef9..864a8d4, 3/3 断言通过 + shellcheck 干净 + cd 缺陷已按 R4 修复并验证断言不再空过)
任务 2: 完成 (提交 864a8d4..26edb3b, RED 5 FAIL → GREEN 5/5 通过, 3 处编辑逐字)
任务 3: 完成 (提交 26edb3b..374d8a1, RED 3 FAIL → GREEN 8/8 通过)
  实现者顾虑（已核，不改变 R5）：check.sh 已被追踪，故 `git check-ignore` 不报告它；R5 适用于该目录下**新增未追踪**文件（任务 6 的 verification.md）——仍需 `git add -f`
任务 4: 完成 (提交 374d8a1..894b097, RED 2 FAIL → GREEN 10/10 通过; 4b 按 R2 改 L250 独立行、示例行 L339 未动)
任务 5: 完成 (提交 894b097..5185a12, RED 4 FAIL → GREEN 14/14 通过; 第 7 步插入在 L194=第 6 步之后、L209 快速参考之前)
裁决: R6 — 任务 6 的 verification.md 在计划的模板文本之外，于"## 基础设施测试说明"小节末尾追加一行，记录 `docs/superpowers/evals/` 被 `.gitignore` 的 `evals/` 规则匹配、故证据文件按 R5 以 `git add -f` 提交 — 这是审阅者需要的事实（照抄 `git add` 命令会失败），计划的全局约束允许插入式追加 — 若错了，代价是多一行文档说明，无行为影响。
任务 6: 完成 (提交 5185a12..ae5582b, 3/3 一致性断言直接 PASS（非 RED，符合预期）+ 最终 17/17 通过; verification.md 63 行)
  实现者顾虑（自审时核实）：① "令牌效率"小节正文写"记录增量"但填的是绝对 wc -w 值；实现者算出增量 +42/+4/+3/+1/+39 词（均远低于 400 词/文件预算）但未写入；② R6 追加行未加前置空行，渲染时与上一段同段

### 整分支自审（c4f6ef9..ae5582b）

核对通过项：计划指定的全部 hunk 均存在且无越界改动（brainstorming 2 / writing-plans 2 / executing-plans 1 / SDD 1 / finishing 2）；YAML 前置元数据零改动；dot 流程图零改动；hooks/、scripts/、tests/ 零改动；17/17 断言通过；每个任务都有 RED→GREEN 证据；跨技能交接契约前后一致（"路线图（Roadmap）"字段名 ↔ executing-plans/SDD 交接语 ↔ finishing 第 7 步检测）；路线图路径拼写全库唯一；check.sh 过仓库 lint（scripts/lint-shell.sh，exit 0 —— R3 关闭，shellcheck 在 info 级的 SC2016 低于仓库 --severity=warning 阈值，且单引号是内层 bash -c 展开所必需）。

审查: 引号形态偏离计划原文 (重要) — skills/brainstorming/SKILL.md 4 行 + docs/superpowers/evals/2026-09-19-multi-phase/baseline.md 4 行用 “ ” 替代计划原文的 " " — 计划要求逐字照抄；skills/ 语料在改动前零弯引号（git grep 于 c4f6ef9 无命中），本分支是唯一引入处 → 进修复波
审查: 次要(延后): verification.md 令牌效率小节填绝对 wc -w 值，而正文要求"记录增量"（实现者已算出增量 +42/+4/+3/+1/+39 词）
审查: 次要(延后): 规格 §5"若无路线图或所有阶段已完成 → 建议用户归档/更新路线图状态"里的"归档"建议未落地（"更新状态"已由第 7 步第 1 条落实）
审查: 次要(延后): verification.md 的 R6 追加行缺前置空行，与上一段同段渲染
裁决: R7 — verification.md"令牌效率"小节以模板占位符 `<wc -w 输出>` 为准（绝对值为合规记录），正文"记录增量"被更具体的占位符收窄；增量数据作为延后项记录（均远低于 400 词/文件预算）— 计划文本自身歧义，取更具体的一方 — 若错了，代价是证据文档少一行增量数据。

审查: 修复波 (1/3, 1 已解决, 0 未决 — 引号形态; 提交 ae5582b..1632e55)
  复检证据：本轮 diff 仅 2 文件 8 行（纯引号码点变更）；独立重跑逐字比对 → 109 行逐字命中、引号形态差异 0、计划外 24 行全部为既定偏离（R4 的 cd 修复、verification.md 的占位符填充 22 行、R6 注记 1 行）；check.sh 17/17 ALL CHECKS PASS；scripts/lint-shell.sh exit 0；全库零弯引号
计划: 完成 (提交 c4f6ef9..1632e55, 自审干净)
