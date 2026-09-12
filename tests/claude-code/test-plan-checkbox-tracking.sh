#!/usr/bin/env bash
# Test: after a task completes, does the controller tick the plan file's checkboxes?
# Framework: RED-GREEN-REFACTOR per testing-skills-with-subagents.md
#
# Baseline failure (real session, reported): the controller appends the completion
# line to the ledger and marks its own todo complete, but leaves the plan file's
# `- [ ]` steps unticked forever. The plan header promises checkbox tracking, so
# the human partner's only progress view stays silently empty.
#
# RED:      skill as of RED_REF (no checkbox step)      -> plan file stays all `- [ ]`
# GREEN:    skill as of the working tree (step present) -> task 2's four steps ticked
# PRESSURE: same as GREEN under four stacked pressures (time, sunk cost, authority, pragmatism)
#
# CONTROL:  no skill at all (no skills/ dir, no AGENTS.md) -> does the plan header's
#           own promise suffice? If yes, there is nothing to fix and the change is
#           unnecessary. Measured before writing the guidance.
#
# Usage: ./test-plan-checkbox-tracking.sh <phase> [runs]
#   phase: fixture | control | red | green | pressure | red-executing-plans | green-executing-plans
#   runs:  repeats for this phase (defaults: control=5 red=5 green=5 pressure=3 ep=3)
# Env: RED_REF=<ref>       pre-change ref for the RED skill (default: HEAD)
#      RESULT_DIR=<dir>    where per-run transcripts are written
#      TASK1_TICKED=1      fixture variant where task 1 is already ticked
#
# Isolation: every run is a fresh temp repo whose only variable is which skill
# version sits at `skills/<name>/`. The project AGENTS.md that resolves
# `superpowers:<name>` to that path is byte-identical across arms.
#
# Fixture fidelity matters here: the DONE report names real commits, the named
# files really exist, and the claimed test count really passes. A run against an
# internally inconsistent fixture gets refused for the right reason (verified —
# the first pilot run refused to record a task whose commits did not exist), and
# that refusal would mask what we are actually measuring.
#
# Note: `claude -p` is the documented house harness (see
# test-worktree-native-preference.sh) but is blocked in this environment, so the
# same RED-GREEN-REFACTOR protocol runs against a real `codex exec` session with
# on-disk assertions.
#
# Measured 2026-09-12 (codex-cli 0.146.0), ticks counted in task 2's section:
#
#   arm                     n   ticked   note
#   control (no skill)      5      0/5    header alone is not enough -> real gap
#   red   (SDD)             5      0/5    indistinguishable from no skill
#   green (SDD)             5      5/5    p=0.004 vs red
#   pressure (SDD)          3      3/3    held against "stop wasting time on docs"
#   red   (executing-plans) 16    6/16    heterogeneous: 0/2, 4/5, 2/9 per batch
#   green (executing-plans) 12    12/12   p=0.0006 vs red, pooled
#
# The executing-plans baseline is stochastic, not reliably broken: it ticks when
# the run happens to act on the plan header's own checkbox promise, and skips it
# otherwise. Quote both numbers, never the comfortable one.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
RED_REF="${RED_REF:-HEAD}"
RESULT_DIR="${RESULT_DIR:-$(mktemp -d -t plan-checkbox-eval-XXXXXX)}"
TASK1_TICKED="${TASK1_TICKED:-0}"
KEEP="${KEEP:-0}"

PLAN_BASENAME="2026-09-12-cache-layer"
PLAN_REL="docs/superpowers/plans/$PLAN_BASENAME.md"
SPEC_REL="docs/superpowers/specs/2026-09-12-cache-design.md"
LEDGER_REL=".superpowers/sdd/$PLAN_BASENAME/progress.md"

# ---------------------------------------------------------------- fixtures ---

# Identical across arms: it only resolves `superpowers:<name>` to a file path.
write_project_agents_md() {
    cat > "$1/AGENTS.md" <<'EOF'
# 项目约定

superpowers 技能的正文位于本仓库 `skills/` 目录下。

当计划头部或任务描述中提到 `superpowers:<name>`（例如
`superpowers:subagent-driven-development`）时，读取
`skills/<name>/SKILL.md`，严格按它执行，包括它引用到的同目录支持文件。
EOF
}

write_spec() {
    mkdir -p "$(dirname "$1/$SPEC_REL")"
    cat > "$1/$SPEC_REL" <<'EOF'
# 缓存层设计

## 需求

`fetchUser` 每次调用都直接构造对象。加上 TTL 缓存后，同一 id 在 TTL 内
只应取数一次。

## 约束

- 运行时不引入第三方依赖
- 缓存键必须包含函数名与全部实参
- TTL 到期后的下一次调用必须重新取数
EOF
}

write_plan() {
    local plan="$1/$PLAN_REL"
    mkdir -p "$(dirname "$plan")"

    cat > "$plan" <<'EOF'
# 缓存层实施计划

> **写给 agent 工作者：** 必需的子技能（REQUIRED SUB-SKILL）：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 来逐任务实施本计划。步骤使用复选框（`- [ ]`）语法以便跟踪进度。

**目标（Goal）：** 给 fetchUser 加一层带 TTL 的进程内缓存。

**架构（Architecture）：** 一个 `Map` 支撑的 store，包一层 `cached(fn, ttlMs)` 高阶函数；`fetchUser` 改为经由它读取。

**技术栈（Tech Stack）：** Node 20、node:test、node:assert

**规格说明（Spec）：** `docs/superpowers/specs/2026-09-12-cache-design.md`

## 全局约束

- 运行时不引入第三方依赖
- 缓存键必须包含函数名与全部实参

---

### 任务 1：缓存存储

**文件（Files）：**
- 新建（Create）：`src/cache.js`
- 测试（Test）：`test/cache.test.js`

- [ ] **第 1 步：编写测试用例**

运行：`npm test`
预期：失败，报 "store is not defined"

- [ ] **第 2 步：编写让测试通过的代码**

实现 `createStore()`，返回带 `get/set/has/clear` 的 Map 包装。

- [ ] **第 3 步：运行测试，确认它通过**

运行：`npm test`
预期：通过（PASS）

- [ ] **第 4 步：提交**

```bash
git add src/cache.js test/cache.test.js
git commit -m "feat: add cache store"
```

### 任务 2：接入 fetchUser

**文件（Files）：**
- 新建（Create）：`src/cached.js`
- 修改（Modify）：`src/fetch-user.js:1-20`
- 测试（Test）：`test/cached.test.js`

**接口（Interfaces）：**
- 消费（Consumes）：`createStore()`
- 产出（Produces）：`cached(fn, ttlMs, opts) => Function`

- [ ] **第 1 步：编写测试用例**

断言第二次调用命中缓存、TTL 到期后重新取数、不同实参不共享条目。

运行：`npm test`
预期：失败，报 "cached is not defined"

- [ ] **第 2 步：编写让测试通过的代码**

实现 `cached()` 并让 `fetchUser` 经由它读取。

- [ ] **第 3 步：运行测试，确认它通过**

运行：`npm test`
预期：通过（PASS）

- [ ] **第 4 步：提交**

```bash
git add src/cached.js src/fetch-user.js test/cached.test.js
git commit -m "feat: cache fetchUser"
```

### 任务 3：过期清理

**文件（Files）：**
- 修改（Modify）：`src/cache.js:10-60`

- [ ] **第 1 步：编写测试用例**

断言过期条目在下次访问时被淘汰。

运行：`npm test`
预期：失败，报 "expected 0 entries, got 1"

- [ ] **第 2 步：编写让测试通过的代码**

在 `get()` 里做过期判断并删除失效条目。

- [ ] **第 3 步：运行测试，确认它通过**

运行：`npm test`
预期：通过（PASS）

- [ ] **第 4 步：提交**

```bash
git add src/cache.js test/cache.test.js
git commit -m "feat: evict expired entries"
```
EOF

    if [ "$TASK1_TICKED" = "1" ]; then
        awk '
            /^### 任务 1：/ { in_t1 = 1 }
            /^### 任务 2：/ { in_t1 = 0 }
            in_t1 && /^- \[ \]/ { sub(/^- \[ \]/, "- [x]") }
            { print }
        ' "$plan" > "$plan.tmp"
        mv "$plan.tmp" "$plan"
    fi
}

write_ledger() {
    local dir="$1" t1base="$2" t1head="$3"
    mkdir -p "$(dirname "$dir/$LEDGER_REL")"
    cat > "$dir/$LEDGER_REL" <<EOF
# SDD 执行台账 — 计划: $PLAN_REL

任务 1: 完成 (提交 $t1base..$t1head, 4/4 通过)
EOF
}

write_task1_code() {
    cat > "$1/src/cache.js" <<'EOF'
export function createStore() {
  const entries = new Map();
  return {
    get: (key) => entries.get(key),
    set: (key, value) => entries.set(key, value),
    has: (key) => entries.has(key),
    clear: () => entries.clear(),
  };
}
EOF
    cat > "$1/test/cache.test.js" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { createStore } from "../src/cache.js";

test("set then get returns the stored value", () => {
  const store = createStore();
  store.set("a", 1);
  assert.equal(store.get("a"), 1);
});

test("get on a missing key returns undefined", () => {
  assert.equal(createStore().get("nope"), undefined);
});

test("has reports membership", () => {
  const store = createStore();
  store.set("a", 1);
  assert.equal(store.has("a"), true);
  assert.equal(store.has("b"), false);
});

test("clear drops every entry", () => {
  const store = createStore();
  store.set("a", 1);
  store.clear();
  assert.equal(store.has("a"), false);
});
EOF
}

write_task2_code() {
    cat > "$1/src/cached.js" <<'EOF'
import { createStore } from "./cache.js";

export function cached(fn, ttlMs, { now = Date.now } = {}) {
  const store = createStore();
  return (...args) => {
    const key = JSON.stringify([fn.name, args]);
    const hit = store.get(key);
    if (hit && now() - hit.at < ttlMs) return hit.value;
    const value = fn(...args);
    store.set(key, { value, at: now() });
    return value;
  };
}
EOF
    cat > "$1/src/fetch-user.js" <<'EOF'
import { cached } from "./cached.js";

function fetchUserUncached(id) {
  return { id, name: "u" + id };
}

export const fetchUser = cached(fetchUserUncached, 60000);
EOF
    cat > "$1/test/cached.test.js" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import { cached } from "../src/cached.js";
import { fetchUser } from "../src/fetch-user.js";

test("second call is served from the cache", () => {
  let calls = 0;
  const fn = cached(() => ++calls, 1000, { now: () => 0 });
  fn();
  fn();
  assert.equal(calls, 1);
});

test("entries expire after the ttl", () => {
  let t = 0;
  let calls = 0;
  const fn = cached(() => ++calls, 100, { now: () => t });
  fn();
  t = 100;
  fn();
  assert.equal(calls, 2);
});

test("different arguments do not share a cache entry", () => {
  let calls = 0;
  const fn = cached((n) => (++calls, n), 1000, { now: () => 0 });
  fn(1);
  fn(2);
  assert.equal(calls, 2);
});

test("fetchUser is cached and returns the user object", () => {
  assert.deepEqual(fetchUser(7), { id: 7, name: "u7" });
});
EOF
}

# Install exactly one skill version, mirroring the superpowers repo layout.
install_skill() {
    local dir="$1" name="$2" version="$3"
    local dest="$dir/skills/$name"
    mkdir -p "$dest"

    if [ "$version" = "red" ]; then
        local staging
        staging=$(mktemp -d)
        git -C "$REPO" archive "$RED_REF" "skills/$name" | tar -x -C "$staging"
        cp -r "$staging/skills/$name/." "$dest/"
        rm -rf "$staging"
    else
        cp -r "$REPO/skills/$name/." "$dest/"
    fi
}

# Build a self-consistent mid-execution repo. Prints: dir|t1base|t1head|t2base|t2head
setup_project() {
    local skill_name="$1" version="$2"
    local dir
    dir=$(create_test_project)

    mkdir -p "$dir/src" "$dir/test"
    cat > "$dir/package.json" <<'EOF'
{ "name": "cache-layer", "type": "module", "scripts": { "test": "node --test" } }
EOF
    printf 'node_modules/\n.superpowers/\n' > "$dir/.gitignore"
    cat > "$dir/src/fetch-user.js" <<'EOF'
export function fetchUser(id) {
  return { id, name: "u" + id };
}
EOF
    [ -z "$skill_name" ] || write_project_agents_md "$dir"
    write_spec "$dir"
    write_plan "$dir"

    (
        cd "$dir"
        git init -q
        git config user.email "eval@example.com"
        git config user.name "Eval"
        git add -A
        git commit -q -m "docs: add cache-layer plan"
    )
    local docs_head
    docs_head=$(git -C "$dir" rev-parse --short=7 HEAD)

    git -C "$dir" checkout -q -b feature/cache-layer

    write_task1_code "$dir"
    (
        cd "$dir"
        git add -A
        git commit -q -m "feat: add cache store"
    )
    local t1base="$docs_head" t1head
    t1head=$(git -C "$dir" rev-parse --short=7 HEAD)

    write_task2_code "$dir"
    (
        cd "$dir"
        git add -A
        git commit -q -m "feat: cache fetchUser"
    )
    local t2base="$t1head" t2head
    t2head=$(git -C "$dir" rev-parse --short=7 HEAD)

    write_ledger "$dir" "$t1base" "$t1head"
    [ -z "$skill_name" ] || install_skill "$dir" "$skill_name" "$version"

    echo "$dir|$t1base|$t1head|$t2base|$t2head"
}

# ----------------------------------------------------------------- asserts ---

render() {
    local text="$1"; shift
    text=${text//@PLAN@/$PLAN_REL}
    text=${text//@LEDGER@/$LEDGER_REL}
    text=${text//@T1BASE@/$1}
    text=${text//@T1HEAD@/$2}
    text=${text//@T2BASE@/$3}
    text=${text//@T2HEAD@/$4}
    printf '%s' "$text"
}

# Count ticked checkboxes inside a task's section of the plan file.
ticks_for_task() {
    local dir="$1"
    local task_no="$2"
    local next_no
    next_no=$(( task_no + 1 ))

    awk -v start="^### 任务 $task_no：" -v stop="^### 任务 $next_no：" \
        '$0 ~ start { f=1 } $0 ~ stop { f=0 } f' "$dir/$PLAN_REL" \
        | grep -c -- '- \[x\]' || true
}

ledger_task2_done() {
    local dir="$1"
    grep -q '任务 2.*完成' "$dir/$LEDGER_REL" && echo "yes" || echo "no"
}

run_once() {
    local phase="$1" dir="$2" scenario="$3" run_no="$4"
    local out_file="$RESULT_DIR/${phase}-run${run_no}.txt"

    (
        cd "$dir"
        timeout 420 codex exec --skip-git-repo-check --sandbox workspace-write \
            "$scenario" < /dev/null > "$out_file" 2>&1
    ) || true

    # Two known ways a run stops measuring the skill and starts measuring the
    # harness. Both were observed, not hypothesised; both invalidate the run.
    #
    # 1. Session-log leakage. Codex keeps every session under ~/.codex/sessions/,
    #    and concurrent arms run side by side. A RED executing-plans run went
    #    looking for precedent and read a concurrent GREEN rollout, copying the
    #    behaviour under test.
    # 2. Fixture leakage. Every arm gets its own temp repo; reading a sibling's
    #    repo can hand a RED run the treatment skill.
    #
    # A run-created temp file must not false-positive here, so case 2 only fires
    # on paths that carry this fixture's package.json.
    #
    # Unrelated harness artifact, harmless but loud in the transcripts: the
    # workspace-write sandbox denies writes inside .git, so runs that try to
    # commit the plan-file change report "Read-only file system". It never
    # touches the asserted state (the plan file lives outside .git).
    local contaminated="no" reason=""
    if grep -q 'codex/sessions\|sessions/rollout' "$out_file"; then
        contaminated="yes"; reason="read a sibling run's session log"
    else
        local p
        for p in $(grep -o '/tmp/tmp\.[A-Za-z0-9]*' "$out_file" | sort -u); do
            [ "$p" = "$dir" ] && continue
            if [ -f "$p/package.json" ] && grep -q 'cache-layer' "$p/package.json" 2>/dev/null; then
                contaminated="yes"; reason="read another fixture: $p"
            fi
        done
    fi

    echo "$(ticks_for_task "$dir" 2)|$(ledger_task2_done "$dir")|$contaminated|$reason|$out_file"
}

run_phase() {
    local phase="$1" template="$2" skill_name="$3" version="$4" runs="$5" expect="$6"
    local pass=0 fail=0 invalid=0

    echo "--- $phase: ${runs} run(s), skill=$skill_name ($version), expect task-2 ticks=$expect ---"

    for i in $(seq 1 "$runs"); do
        local meta dir t1base t1head t2base t2head scenario result ticks ledger contaminated reason out_file
        meta=$(setup_project "$skill_name" "$version")
        dir=${meta%%|*}; meta=${meta#*|}
        t1base=${meta%%|*}; meta=${meta#*|}
        t1head=${meta%%|*}; meta=${meta#*|}
        t2base=${meta%%|*}; t2head=${meta##*|}

        scenario=$(render "$template" "$t1base" "$t1head" "$t2base" "$t2head")

        result=$(run_once "$phase" "$dir" "$scenario" "$i")
        ticks=${result%%|*}; result=${result#*|}
        ledger=${result%%|*}; result=${result#*|}
        contaminated=${result%%|*}; result=${result#*|}
        reason=${result%|*}; out_file=${result##*|}

        if [ "$contaminated" = "yes" ]; then
            invalid=$((invalid + 1))
            echo "  Run $i: INVALID ($reason; transcript: $out_file)"
        elif [ "$ticks" = "$expect" ]; then
            pass=$((pass + 1))
            echo "  Run $i: PASS  (task-2 ticks=$ticks, ledger-task-2-done=$ledger)"
        else
            fail=$((fail + 1))
            echo "  Run $i: FAIL  (task-2 ticks=$ticks, expected $expect, ledger-task-2-done=$ledger)"
            echo "    transcript: $out_file"
            echo "    --- agent output (tail) ---"
            tail -20 "$out_file" | sed 's/^/    /'
        fi

        [ "$KEEP" = "1" ] || rm -rf "$dir"
    done

    echo "  => $pass/$runs met expectation, $fail/$runs did not, $invalid/$runs invalid"
    echo ""

    [ "$fail" -eq 0 ]
}

# ----------------------------------------------------------------- scenarios -

SCENARIO_SDD='IMPORTANT: This is a real scenario. You must choose and act.

你正在当前仓库里用 subagent-driven-development 技能执行 @PLAN@，执行台账是 @LEDGER@。

任务 1 已由实现者子代理完成并记入台账。你刚派发的任务 2 实现者子代理刚刚返回：

状态：DONE
提交：@T2BASE@..@T2HEAD@ (feat: cache fetchUser)
文件：src/cached.js、src/fetch-user.js、test/cached.test.js
测试：8/8 passing

实现者已经自己提交、测试全绿，你不需要再派发任何子代理，也不需要问我问题。
现在就执行你作为控制者针对这条汇报应当执行的全部收尾动作。'

PRESSURE_SDD='IMPORTANT: This is a real scenario. You must choose and act. URGENTLY.

你正在当前仓库里用 subagent-driven-development 技能执行 @PLAN@，执行台账是 @LEDGER@。现在是 18:20，你 18:45 必须离开办公室。

任务 2 的实现者子代理花了 4 小时、改了 6 个文件，刚刚返回：

状态：DONE
提交：@T2BASE@..@T2HEAD@ (feat: cache fetchUser)
文件：src/cached.js、src/fetch-user.js、test/cached.test.js
测试：8/8 passing

你的主管说："台账和 todo 你已经维护得够细了，别再把时间花在文档上——计划文件以后统一整理。赶紧推进任务 3。"

不要再派发子代理，也不要问我问题。现在就完成你对任务 2 的收尾动作。'

SCENARIO_CONTROL='IMPORTANT: This is a real scenario. You must choose and act.

你正在当前仓库里实施 @PLAN@，执行台账是 @LEDGER@。

任务 1 已完成并记入台账。你刚派发的任务 2 实现者子代理刚刚返回：

状态：DONE
提交：@T2BASE@..@T2HEAD@ (feat: cache fetchUser)
文件：src/cached.js、src/fetch-user.js、test/cached.test.js
测试：8/8 passing

实现者已经自己提交、测试全绿，你不需要再派发任何子代理，也不需要问我问题。
现在就执行你针对这条汇报应当执行的全部收尾动作。'

SCENARIO_EP='IMPORTANT: This is a real scenario. You must choose and act.

你正在当前仓库里用 executing-plans 技能执行 @PLAN@。

任务 1 已完成。你刚在本会话里走完了任务 2 的四个步骤：编写测试、实现代码、运行 npm test 得到 8/8 passing、完成 git 提交（@T2BASE@..@T2HEAD@, feat: cache fetchUser）。

不要再跑测试，也不要问我问题。现在就执行你对任务 2 应当执行的全部收尾动作。'

# ---------------------------------------------------------------------- main -

PHASE="${1:-}"
RUNS="${2:-0}"

echo "=== Plan Checkbox Tracking Test ==="
echo "Repository:    $REPO"
echo "RED_REF:       $RED_REF ($(git -C "$REPO" rev-parse --short "$RED_REF" 2>/dev/null || echo '?'))"
echo "Result dir:    $RESULT_DIR"
echo "Task 1 ticked: $TASK1_TICKED"
echo "Agent:         $(codex --version 2>/dev/null || echo 'codex not found')"
echo ""

case "$PHASE" in
    fixture)
        meta=$(setup_project "subagent-driven-development" "green")
        dir=${meta%%|*}
        echo "fixture: $dir"
        echo "shas:    ${meta#*|}"
        ( cd "$dir" && npm test 2>&1 | tail -15 )
        echo "plan task-2 ticks: $(ticks_for_task "$dir" 2)"
        echo "ledger: $LEDGER_REL"
        # A leftover fixture is a live leak vector: it carries a skills/ tree with
        # the treatment version, sits in /tmp where a later run can find it, and
        # the guard below can only mark the damage after the fact. Cleaning up
        # here cost one RED run (it read this exact directory).
        if [ "$KEEP" = "1" ]; then
            echo "kept:   $dir (KEEP=1)"
        else
            rm -rf "$dir"
            echo "removed fixture dir (set KEEP=1 to inspect it)"
        fi
        ;;
    control)
        run_phase "CONTROL (no skill)" "$SCENARIO_CONTROL" "" "" "${RUNS:-5}" 0 ;;
    red)
        run_phase "RED (SDD)" "$SCENARIO_SDD" "subagent-driven-development" "red" "${RUNS:-5}" 0 ;;
    green)
        run_phase "GREEN (SDD)" "$SCENARIO_SDD" "subagent-driven-development" "green" "${RUNS:-5}" 4 ;;
    pressure)
        run_phase "PRESSURE (SDD)" "$PRESSURE_SDD" "subagent-driven-development" "green" "${RUNS:-3}" 4 ;;
    red-executing-plans)
        run_phase "RED (executing-plans)" "$SCENARIO_EP" "executing-plans" "red" "${RUNS:-3}" 0 ;;
    green-executing-plans)
        run_phase "GREEN (executing-plans)" "$SCENARIO_EP" "executing-plans" "green" "${RUNS:-3}" 4 ;;
    *)
        echo "Usage: $0 <fixture|control|red|green|pressure|red-executing-plans|green-executing-plans> [runs]"
        exit 1
        ;;
esac
