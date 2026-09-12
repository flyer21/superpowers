# Plan checkbox tracking — eval results

2026-09-12 · codex-cli 0.146.0 · `tests/claude-code/test-plan-checkbox-tracking.sh`

## The problem

`writing-plans` emits plans whose header says the steps use `- [ ]`
checkbox syntax so progress can be tracked. Both execution skills walked the
plan task by task and recorded completion in their own bookkeeping — the SDD
ledger, the controller's todo list — and left the plan file's checkboxes
unticked forever. The human partner's only progress view stayed silently empty
for the whole run.

This is the state of a real session, not a hypothetical: the plan header
promises the checkboxes, the ledger says `完成`, and every step in the plan
still reads `- [ ]`.

## Scenarios

The scenario is shared. Task 1 is complete (untracked, as the fixture seed);
the harness dispatches the task-2 DONE report to a fresh session and asks the
session to handle it as it normally would. The assertion is mechanical: count
`- [x]` inside task 2's section of the plan file on disk.

- **control** — no skill at all: no `skills/` directory, no `AGENTS.md`. Does
  the plan header's own promise suffice on its own? If yes there is nothing to
  fix and the change is unnecessary.
- **red** — the skill at `RED_REF` (no checkbox step).
- **green** — the skill as of the working tree (checkbox step present).
- **pressure** — green under four stacked pressures: a stated time budget,
  sunk cost, a user who wants "docs later", and a pragmatic voice in the plan
  itself.
- **red/green (executing-plans)** — the same scenario against the other
  execution skill, which needs the instruction independently.

## What RED showed (and did not show)

RED does **not** fail by forgetting the task. It books the task properly and
then stops, because ticking the plan file is not among the actions the skill
enumerates for handling a DONE report. RED (SDD) run 1, verbatim:

> 已执行：
>
> - 台账追加完成行：`任务 2: 完成 (提交 0657b0b..04b0b4e, 8/8 通过)`
> - todo 标记：任务 1、2 完成，任务 3 待办。
>
> 按技能纪律刻意未做（这些都不是 DONE 汇报的收尾动作）：
>
> - 没有派发任何子代理——不派审查者、不派修复者，也不续派任务 3 实现者。

The phrase "刻意未做" (deliberately not done) is the finding. The omission is
not inattention; the skill's enumeration, read literally, excludes it. That is
why per-skill wording was required rather than a generic reminder.

Control and RED are indistinguishable (0/5 each). The plan header's promise is
inert on its own — the agent reads it and does not act on it.

### RED quote bank (verbatim)

- **red-ep run 7** (baseline, *did* tick — the heterogeneity is real):
  > [计划文件]里把任务 2 的第 1–4 步复选框全部勾选为完成。目前唯一未提交的改动是计划文件里任务 2 的勾选标记
- **control run 3** (ticked, then reverted — see the confound section):
  > 计划文件里我一度勾选了任务 1、2 的复选框，因无法提交已还原为原始状态

## What GREEN showed

> - 计划 [2026-09-12-cache-layer.md](…) 勾选复选框：任务 2 四步勾为 `- [x]`；任务 1 之前漏勾，一并补勾。

GREEN also repairs the earlier task's omission on its own initiative, which the
RED arm never does. Under pressure the step holds, and the agent defends the
cost out loud rather than dropping it:

> 按"文档以后统一整理"顺延 — 台账是压缩恢复的唯一依据，缺行会导致整段重派；勾选框只有 4 处 — 若错：计划文件多一次改动，返工代价为零。

## Results

`n` counts completed runs whose transcript was not discarded as contaminated.
`ticked` is the on-disk assertion: `- [x]` present in task 2's section.

| arm | n | ticked | note |
| --- | --- | --- | --- |
| control (no skill) | 5 | 0/5 | header promise alone is inert |
| red (SDD) | 5 | 0/5 | indistinguishable from control |
| green (SDD) | 5 | 5/5 | Fisher one-sided p = 0.004 vs red |
| pressure (SDD) | 3 | 3/3 | held under all four pressures |
| red (executing-plans) | 16 | 6/16 | heterogeneous — see below |
| green (executing-plans) | 12 | 12/12 | Fisher one-sided p = 0.0006 vs red, pooled |

**The two skills do not deserve the same claim.** SDD fails stably: 5/5 runs
book the task and omit the checkboxes, and the failure mechanism is identical
every time (the enumerated action list excludes it).

`executing-plans` fails *stochastically*: it ticks whenever the run happens to
act on the plan header's own checkbox sentence, and skips it otherwise. Per
batch: 0/2, then 4/5, then 2/9. The pooled 6/16 is the honest number, and both
numbers belong in any summary — the comfortable one is not the whole story.

## Fixture iterations

Three fixture generations, each discarded for a reason worth recording:

- **v1** — the DONE report cited commit hashes that did not exist. Every pilot
  run refused it for the right reason ("none of the hashes exist as git
  objects"), and a refusal masks what is being measured. Rewritten.
- **v2** — the fixture's own generator bug: a commit counter incremented inside
  a command substitution, so the increment never survived the subshell and
  every commit collapsed to one author at one timestamp — exactly the
  "fixture-manufactured history" tell that invalidated an earlier campaign's
  control arm. Caught by the plan's own sanity gate before any scenario ran.
- **v3 (used here)** — every claim in the DONE report survives content
  inspection: the named files exist, the code really implements the task, the
  claimed test count really passes, and the seed files are untracked so nothing
  depends on committing.

Verification that the fixture is not buying the result: no transcript contains
a refusal to act on the DONE report, and agents reading `git log` treat the
fixture as ordinary history rather than seeded data.

## A confound we found and bounded

Codex runs under a sandbox that denies writes to `.git`, so `git commit` fails
inside every run. The plan file sits outside `.git` and is unaffected — but an
agent can react to the failed commit by reverting *everything* it had changed.
One control run did exactly that (quote above): it ticked both tasks, could not
commit, and restored the file, landing as `0 ticked` for a reason unrelated to
skill content.

Bounds on the damage: that is 1 of 28 baseline-arm runs, and removing it flips
nothing (control goes 0/5 → 0/4). More importantly the confound cannot explain
the RED result, because in the non-ticking runs the word "勾选" never appears at
all — those runs never considered the checkboxes, so there is no tick for the
sandbox to erase. The claim that survives is the narrow one: RED omits the step.

## Limitations

- One harness (codex-cli 0.146.0), `codex exec`, one fixture project. The
  `claude -p` harness the house tests normally use is blocked in this
  environment; the same RED/GREEN/REFACTOR protocol runs here against a real
  session with on-disk assertions.
- n is small per arm, and the `executing-plans` baseline is heterogeneous
  enough that its true rate is uncertain across the 37–80% range spanned by the
  three batches. The SDD arm's stability is much better supported than the
  numbers alone suggest, because the mechanism is identical in every failing
  run.
- The assertion is a file-state check, not a judgement about whether the
  human's progress view was *useful*. A controller that ticks nothing but
  narrates progress well would score as a failure here.
- Pressure testing covers four pressures in one scenario; it is evidence that
  the step is not the first thing dropped under load, not a map of where it
  breaks.

## Reproduction

```bash
./tests/claude-code/test-plan-checkbox-tracking.sh fixture                 # zero-agent fixture + assertion sanity
./tests/claude-code/test-plan-checkbox-tracking.sh control 5
./tests/claude-code/test-plan-checkbox-tracking.sh red 5
./tests/claude-code/test-plan-checkbox-tracking.sh green 5
./tests/claude-code/test-plan-checkbox-tracking.sh pressure 3
./tests/claude-code/test-plan-checkbox-tracking.sh red-executing-plans 10
./tests/claude-code/test-plan-checkbox-tracking.sh green-executing-plans 5
```

Per-run transcripts land in `$RESULT_DIR`; the script's header carries the
measured rates. Runs whose transcripts read a foreign fixture directory or a
session log are flagged `INVALID` and excluded — two runs were dropped this
way, and the guard that catches the fixture-directory case was added because
one run exploited it.
