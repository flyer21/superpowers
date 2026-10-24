# 移植 fork 技能历史 实施计划

> **对于代理工作者：** 必需子技能：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务实施此计划。步骤使用复选框（`- [ ]`）语法进行跟踪。

**目标：** 把 `/home/frf/superpowers5`（fork，分叉点 `b36e082`）的 19 个功能提交按历史顺序重新实现到本项目的 v7.0.1 中文技能上。

**架构：** 不 cherry-pick——v6.4.x 重做了 SDD、v7.0.0 重写了 brainstorming，落点已变。每个任务：从 fork 读取原始改动 → 在本仓库对应章节重写 → 用 grep 断言或已有测试脚本验证 → 单独提交。路线图相关的四个技能靠一个逐字一致的字段名 `**路线图（Roadmap）：**` 串成闭环。

**技术栈：** 纯 Markdown 技能文档 + 两个 POSIX shell 脚本（`scripts/task-brief`、`scripts/task-done`）+ `tests/claude-code/*.sh`。零新增依赖。

**规格说明：** `docs/superpowers/specs/2026-10-24-port-fork-skill-history-design.md`（实施前必读，含每个提交的落点判定与冲突决定）

**路线图（Roadmap）：** 无

## 全局约束

- 所有文案中文，与既有译文风格一致；引号一律直引号 `"`，不用弯引号。
- 术语统一：路线图 / 阶段 / 台账 / 简报 / 自审。
- 所有示例代码一律用 **Java**（JUnit 5 + Maven，运行命令形如 `mvn test -Dtest=...`）；现有 TypeScript / Python 示例一并改写，见任务 17。
- 不新增 `skills/` 下的文件；不新增脚本；不引入依赖。
- 不改动 `package.json` 版本号与 `RELEASE-NOTES.md`。
- 每个任务一个 commit，message 用 `type(scope): subject` 并注明来源 sha。
- 路线图文档路径固定为 `docs/superpowers/roadmaps/YYYY-MM-DD-<topic>-roadmap.md`。
- 读原始改动用 `git -C /home/frf/superpowers5 show <sha> -- <path>`，或对照 fork 工作树终态文件。
- 落点行号是审计快照，以实施时实际内容为准；找不到合理落点就停下报告，不要硬塞。

## 审查重点

1. **跨技能字段名不一致**——`路线图（Roadmap）` 在四处必须逐字一致，否则 finishing 检测不到路线图。测试：任务 14、15、16 各断言全仓一致。
2. **台账半套替换**——`scripts/task-done` 若仍写英文 `Task <N>: complete`，恢复时读不出来。测试：任务 7。
3. **`skills/subagent-driven-development/SKILL.md` 超 20 KB 上限**（`tests/skill-size/test-skill-size.sh` 断言 `LIMIT=20000`）。测试：任务 4、11、12 后各跑一次。
4. **无路线图时 finishing 行为必须不变**——第 7 步纯新增、仅调用方传递时运行。测试：任务 16。
5. **`scripts/task-brief` 替换丢掉 `${BASH:-bash}` 包装**（#2040 回归防护在 `tests/claude-code/test-sdd-workspace.sh:229-240`）。测试：任务 10。

---

### 任务 1：评审时机改为收尾关卡

**文件：** 修改 `skills/requesting-code-review/SKILL.md`：frontmatter、核心原则、`何时请求审查`（12-22）、`示例`（48+）及与"早期频繁评审"矛盾的行

- [ ] **步骤 1：断言并确认当前相反** — `grep -c "收尾关卡" skills/requesting-code-review/SKILL.md` 目标 1；`grep -c "每个任务之后" skills/requesting-code-review/SKILL.md` 目标 0
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show ffcdbf6 -- skills/requesting-code-review/SKILL.md`（`b32beec` 是它的先声，2 行）
- [ ] **步骤 3：重写** — 核心原则改为"在所有任务执行完成之后才进入整体代码评审——它是交付前的收尾关卡，不是任务之间的例行步骤"；时机段整段反转，示例与矛盾行同步
- [ ] **步骤 4：跑断言** — 两个 grep 达标
- [ ] **步骤 5：提交** — `refactor(requesting-code-review): 评审时机改为收尾关卡（来自 fork b32beec ffcdbf6）`

### 任务 2：任务粒度与步骤 4 步

**文件：** 修改 `skills/writing-plans/SKILL.md`:34-36（任务大小调整）、执行交接 :146+

- [x] **步骤 1：断言** — `grep -c "一次提交收尾" skills/writing-plans/SKILL.md` 目标 ≥1；`grep -c "新鲜审查者在下一个任务开始之前" ...` 目标 0
- [x] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show b72ad66 -- skills/writing-plans/SKILL.md`
- [x] **步骤 3：改写** — 任务边界 = 承载自身完整测试周期、以一次提交收尾，同形状小编辑合并成一批，交付物可独立测试与验证，并点明 SDD 在全部任务完成后统一自审整条分支；执行交接的子代理驱动改为"任务之间不审查，全部任务执行完成后统一自审整条分支"。**步骤粒度 4 步不在本任务**——fork 的 `b72ad66` 未改步骤粒度，改它的是 `8ad56ce`，归任务 12（Ruling 11）
- [x] **步骤 4：跑断言** — 两项达标；术语统一为"自审"
- [x] **步骤 5：提交** — `17457cf` + `e7caac8`

### 任务 3：逐任务评审 → 统一评审

**文件：** 修改 `skills/subagent-driven-development/SKILL.md`:48-88（流程）、:161-173（3. 审查任务）

- [ ] **步骤 1：断言** — `grep -c "永远不要跳过任务审查" skills/subagent-driven-development/SKILL.md` 目标 0；`grep -c "统一审查" ...` 目标 ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 23cc99a -- skills/subagent-driven-development/SKILL.md`
- [ ] **步骤 3：改写** — 删每任务后的审查者派遣与"每任务必须审查"硬要求，改所有任务完成后一次整分支审查；相邻措辞同步
- [ ] **步骤 4：跑断言**
- [ ] **步骤 5：提交**

### 任务 4：评审 → 控制器自审，配套文档改写复用

**文件：**
- `skills/subagent-driven-development/SKILL.md`:137-149、:151-159、:190-193
- `references/final-review.md`（派审查者 → 控制器亲自读 diff）
- `references/fix-loop.md`（每任务 5 轮 → 整分支三轮修复波，保留断路器）
- `references/handling-reports.md`（非 DONE 处理随模型调整）
- `references/cannot-verify.md`（无法从 diff 确认的需求 → 当真实缺口进修复波）
- `task-reviewer-prompt.md` → 改写为控制器自审清单；`re-review-prompt.md` → 改写为复检清单
- `implementer-prompt.md`（不再写报告文件，改 ≤12 行汇报；保留"不要重新运行套件"）

- [ ] **步骤 1：断言** — `bash tests/skill-size/test-skill-size.sh` 当前通过（18.14 KB/20 KB），目标仍 0 失败；`grep -c "控制器亲自" skills/subagent-driven-development/references/final-review.md` 目标 ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 917d61f -- skills/subagent-driven-development/`；并读 fork 终态 `SKILL.md:173-242`（整分支自审 / 修复波 / 归档）。跳过其对 `scripts/sdd-workspace` 的改动
- [ ] **步骤 3：改写** — 自审与修复波写入 `references/final-review.md` 与 `references/fix-loop.md`，**不塞进 SKILL.md**（体积上限）；SKILL.md 只留短指引
- [ ] **步骤 4：跑断言** — `bash tests/skill-size/test-skill-size.sh` 0 失败；`grep -rc "报告文件" skills/subagent-driven-development/implementer-prompt.md` → 0
- [ ] **步骤 5：提交**

### 任务 5：子代理协调条款

**文件：** 修改 `skills/dispatching-parallel-agents/SKILL.md`:87-92、:115-127、:79-85

- [x] **步骤 1：断言** — `grep -c "要总结" skills/dispatching-parallel-agents/SKILL.md` 目标 ≥1
- [x] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 3c52268 -- skills/dispatching-parallel-agents/SKILL.md`（忽略其 package.json 改动）
- [x] **步骤 3：改写** — 不要求子代理自审、不要求写总结；常见错误补"❌要总结"
- [x] **步骤 4：跑断言**
- [x] **步骤 5：提交**

### 任务 6：task-brief 支持中文任务标题

**文件：** 修改 `skills/subagent-driven-development/scripts/task-brief`（`task_id()` / `is_phase()` 认 `任务`/`阶段` 标签与 `：` 分隔符）

- [ ] **步骤 1：加测试断言** — 在 `tests/claude-code/test-sdd-workspace.sh` 加：含 `## 任务 3：xxx` 的计划能被提取，先跑确认失败
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 32c6781 -- skills/subagent-driven-development/scripts/task-brief`
- [ ] **步骤 3：改脚本** — 扩展匹配，保留 `${BASH:-bash}` 包装不动
- [ ] **步骤 4：跑测试** — `bash tests/claude-code/test-sdd-workspace.sh` 0 失败
- [ ] **步骤 5：提交**

### 任务 7：台账完成行全量中文化 + 三轮修复波

**文件：** `skills/subagent-driven-development/SKILL.md`:90-104、:181-188；`references/resuming.md`、`references/fix-loop.md`；`skills/executing-plans/SKILL.md`:116-134；`skills/executing-plans/scripts/task-done`:50；`tests/claude-code/test-executing-plans-scripts.sh`:92,120,148

- [ ] **步骤 1：改测试断言** — 三处英文断言改为中文 `任务 3: 完成`，先跑确认失败
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show dea3407 -- skills/subagent-driven-development/SKILL.md`
- [ ] **步骤 3：改脚本与两个技能** — `scripts/task-done` 写中文串 `任务 <N>: 完成 (commits <base7>..<head7>, tests: ...)`；两技能的完成行格式、恢复协议、修复波上限（三轮 + 断路器）同步；不保留英文双认
- [ ] **步骤 4：跑测试** — `bash tests/claude-code/test-executing-plans-scripts.sh` 0 失败；`grep -rn "Task <N>: complete" skills/` → 0
- [ ] **步骤 5：提交**

### 任务 8：测试断言去 locale / timezone 依赖

**文件：** 修改 `tests/claude-code/test-helpers.sh`；视存在情况改 `tests/codex/test-package-codex-plugin.sh`、`tests/hermes/test_bootstrap.py`

- [ ] **步骤 1：断言** — `grep -c "LC_ALL" tests/claude-code/test-helpers.sh` 目标 ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 647f665`
- [ ] **步骤 3：插入 locale 提升段**（含原因注释），避免与 `run-skill-tests.sh` 已有 export 重复
- [ ] **步骤 4：跑测试** — `bash tests/claude-code/run-skill-tests.sh` 0 失败
- [ ] **步骤 5：提交**

### 任务 9：任务完成时勾选计划复选框

**文件：** `skills/executing-plans/SKILL.md`:127-133；`skills/subagent-driven-development/SKILL.md`:181-188；`tests/claude-code/test-executing-plans-scripts.sh`（补断言）

- [ ] **步骤 1：加断言** — 断言计划文件对应步骤变为 `- [x]`，先跑确认失败
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show e845218 -- skills/`
- [ ] **步骤 3：两个技能各加一句勾选动作** — 语法沿用 `skills/writing-plans/SKILL.md`:54 的 `- [ ]` 约定，并明确它不替代台账
- [ ] **步骤 4：跑测试** — 0 失败
- [ ] **步骤 5：提交**

### 任务 10：task-brief 支持 phase-scoped 任务 id

**文件：** `skills/subagent-driven-development/scripts/task-brief`（整体替换解析逻辑）；`task-reviewer-prompt.md`（同步 id 说明）；`tests/claude-code/test-sdd-workspace.sh`（补断言）

- [ ] **步骤 1：加四条断言** — id `1`、`1.1`、`C1-1`、`A1` 都能提取；歧义输入报错非零退出
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 6a4fc55 -- skills/subagent-driven-development/scripts/task-brief`
- [ ] **步骤 3：替换脚本** — 认四类 id、阶段标题截断简报、歧义报错；**必须保留 `${BASH:-bash}` 包装**；重新覆盖任务 6 的中文标题能力
- [ ] **步骤 4：跑测试** — `bash tests/claude-code/test-sdd-workspace.sh` 0 失败（含 :229-240 包装断言）
- [ ] **步骤 5：提交**

### 任务 11：简报与台账归档到 per-plan 目录

**文件：** `skills/subagent-driven-development/references/final-review.md`（插在 `rm -rf` 删除工作区之前）；`SKILL.md`:190-193 指向该 reference

- [ ] **步骤 1：断言** — `grep -c "task-<ID>-brief" skills/subagent-driven-development/references/final-review.md` 目标 ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 534e7ae -- skills/subagent-driven-development/SKILL.md`（跳过被它取代的 `1eed178`）
- [ ] **步骤 3：写入归档步骤** — `$ARCHIVE_DIR/<plan-slug>/ledger.md` + `task-<ID>-brief.md`，随计划文件提交；严守 per-plan 隔离（其他计划的目录永不可读写）；归档后再删工作区
- [ ] **步骤 4：跑断言 + `bash tests/skill-size/test-skill-size.sh`**
- [ ] **步骤 5：提交**

### 任务 12：TDD 精简 3 步循环

**文件：** `skills/test-driven-development/SKILL.md`:8-14、:47+（含 dot 图）、:113、:168、:299；`skills/subagent-driven-development/implementer-prompt.md`（步骤 1 先写完整测试不运行 + 汇报加 TDD 证据）；`skills/systematic-debugging/SKILL.md`:168-177（第四阶段）；`README.md`:314,318。不动 `writing-good-code.md`（`0d4a386` 已落，工作区未提交，与 fork 逐节一致）

- [ ] **步骤 1：断言** — `grep -c "先写完整本任务的测试用例" skills/subagent-driven-development/implementer-prompt.md` 目标 ≥1；`grep -c "运行" skills/test-driven-development/SKILL.md` 保持非零但"第 3 步第一次运行"语义出现
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 8ad56ce`（跳过 `task-reviewer-prompt.md` 与 `verification-before-completion` 部分，上游已覆盖）
- [ ] **步骤 3：改写** — TDD 循环改"精简 3 步"、dot 图一并替换；运行集中在最后一步；实现者步骤与汇报证据、调试第四阶段、README 描述同步；措辞与任务 2 的 4 步保持一致
- [ ] **步骤 4：跑断言 + `bash tests/skill-size/test-skill-size.sh`**
- [ ] **步骤 5：提交**

### 任务 13：brainstorming 支持顺序阶段与路线图

**文件：** `skills/brainstorming/SKILL.md`:91-104（评估工作规模）、:106-138（书面设计）

- [ ] **步骤 1：断言** — `grep -c "顺序阶段" skills/brainstorming/SKILL.md` ≥1；`grep -c "docs/superpowers/roadmaps/" ...` ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 26edb3b -- skills/brainstorming/SKILL.md`
- [ ] **步骤 3：改写** — 范围评估区分"独立子系统"vs"顺序阶段"（判断信号：先…再基于…、阶段 N+1 的决策依赖 N 建成）；新增"多阶段路线图"6 步流程与必需小节清单（目标 / 为何分阶段 / 阶段列表 / 被延后的设计决策 / 修订记录）。v7 已无"规格自审"小节，那条范围检查并入"书面设计"
- [ ] **步骤 4：跑断言**
- [ ] **步骤 5：提交**

### 任务 14：writing-plans 区分阶段计划 + 路线图头部字段

**文件：** `skills/writing-plans/SKILL.md`:19-21（范围检查）、:62 之后（计划文档头部，插在"规格说明"字段后）

- [ ] **步骤 1：断言** — `grep -rn "路线图（Roadmap）：" skills/` 目标 ≥1；`grep -c "绝不允许一份计划横跨多个阶段" skills/writing-plans/SKILL.md` ≥1
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 374d8a1 -- skills/writing-plans/SKILL.md`
- [ ] **步骤 3：改写** — 范围检查加"每个阶段一份计划，禁止跨阶段"；头部新增可选字段 `**路线图（Roadmap）：** [路径]（阶段 N：[名称]）`，无路线图时整行省略（不写"无"）。字段名与任务 15、16 逐字一致
- [ ] **步骤 4：跑断言**
- [ ] **步骤 5：提交**

### 任务 15：执行侧传递路线图上下文

**文件：** `skills/executing-plans/SKILL.md`:152-158（完成）；`skills/subagent-driven-development/SKILL.md`:190-193 与其 `references/final-review.md`

- [ ] **步骤 1：断言** — `grep -rn "路线图 <路径>，阶段 N" skills/` 目标 ≥2（两个执行技能各一处）
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 894b097 -- skills/`
- [ ] **步骤 3：改写** — 转入 finishing 的交接语带上"（路线图 <路径>，阶段 N：<名称>）"，作为 finishing 检测的唯一依据；executing-plans 用 `## 完成` 章节（不写"第 3 步"）；SDD 侧已移入 reference，同步改该处
- [ ] **步骤 4：跑断言**
- [ ] **步骤 5：提交**

### 任务 16：finishing 第 7 步 路线图检测

**文件：** `skills/finishing-a-development-branch/SKILL.md`：概述核心原则行；第 6 步（145-178）之后新增 `## 第 7 步：路线图检测`

- [ ] **步骤 1：断言** — `grep -c "没有路线图信息时" skills/finishing-a-development-branch/SKILL.md` 目标 ≥1；`git diff --stat` 确认第 1-6 步零改动
- [ ] **步骤 2：读来源** — `git -C /home/frf/superpowers5 show 5185a12 -- skills/finishing-a-development-branch/SKILL.md` 与 `show 1858856`
- [ ] **步骤 3：新增第 7 步** — 仅在调用方传递了路线图路径与阶段号时运行：基分支上把本阶段标"已完成"并提交 → 有未完成阶段则报告并等待（同意 → 调 brainstorming；拒绝 → 结束）→ 全部完成则报告并建议归档。**不加自动扫描 `docs/superpowers/roadmaps/` 的逻辑**；无路线图时行为与现在完全一致
- [ ] **步骤 4：跑断言 + `bash tests/skill-size/test-skill-size.sh`**
- [ ] **步骤 5：提交**

### 任务 17：示例代码统一改为 Java

**文件：**
- `skills/test-driven-development/SKILL.md`（6 个 TS 块）、`writing-good-tests.md`（3）、`writing-good-code.md`（1）
- `skills/systematic-debugging/condition-based-waiting.md`（3）、`root-cause-tracing.md`（4）、`defense-in-depth.md`（4）
- `skills/systematic-debugging/condition-based-waiting-example.ts` → 改写为 Java 并重命名为 `.java`，同步 `condition-based-waiting.md`:82 的引用（`RELEASE-NOTES.md` 的历史记录不动）
- `skills/writing-plans/SKILL.md`:91-101（计划模板的 pytest 示例 → JUnit 5 + `mvn test -Dtest=...`）
- `skills/writing-skills/references/anthropic-best-practices.md`（2 处示例）

**接口：**
- 消费：任务 12 改写后的 TDD 与 systematic-debugging 文本（**必须在任务 12 之后做**，否则改两遍）
- 生产：无下游依赖

- [ ] **步骤 1：断言** — `grep -rc '^```typescript' skills/` 目标 0；`grep -rc '^```java' skills/` 目标 ≥21；`grep -c "pytest" skills/writing-plans/SKILL.md` 目标 0
- [ ] **步骤 2：改写 TDD 示例** — 六个 TS 块（`<Good>`/`<Bad>` 对照、bug 修复示例等）改 JUnit 5，运行命令改 `mvn test -Dtest=...`
- [ ] **步骤 3：改写 systematic-debugging 示例** — 三篇参考的 TS 示例改 Java；`condition-based-waiting-example.ts` 改 Java 并重命名，同步引用
- [ ] **步骤 4：改写零散两处** — writing-plans 模板示例（JUnit 5 + Maven）、writing-skills 参考示例
- [ ] **步骤 5：跑断言 + `bash tests/skill-size/test-skill-size.sh`**
- [ ] **步骤 6：提交** — `docs(skills): 示例代码统一改为 Java（JUnit 5 + Maven）`

### 任务 18：同步 SDD 侧测试断言

（任务 4 的审查发现，计划原本没有任务认领它——按 SDD 规则补上）

**文件：** `tests/claude-code/test-subagent-driven-development.sh` 中相关断言（当前包含 `Self-review required: yes`）

**接口：** 消费任务 3、4、7 改完后的 SDD 语义

- [ ] **步骤 1：找出全部过时断言** — `grep -n "Self-review required\|审查者\|报告文件\|Task <N>: complete" tests/claude-code/test-subagent-driven-development.sh`
- [ ] **步骤 2：逐条改** — 与新语义相反的断言（实现者需自审、每任务审查、报告文件、英文完成行）按任务 3/4/7 的结果改写
- [ ] **步骤 3：跑测试** — `bash tests/claude-code/run-skill-tests.sh` 0 失败
- [ ] **步骤 4：提交** — `test(sdd): 同步测试断言到整分支自审模型`