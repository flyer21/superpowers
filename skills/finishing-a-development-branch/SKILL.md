---
name: finishing-a-development-branch
description: 当实现已完成、所有测试通过、需要决定如何整合这份工作时使用
---

# 完成一个开发分支（Finishing a Development Branch）

## 概述（Overview）

**核心原则：** 验证测试 → 检测环境 → 给出选项 → 执行选择 → 清理。

**开头就宣布：** "我正在用 finishing-a-development-branch 技能来完成这份工作。"

## 第 1 步：验证测试（Verify Tests）

运行项目的完整测试套件（`npm test` / `cargo test` / `pytest` / `go test ./...`）。

**如果测试失败**，报告失败并停下——菜单要在套件变绿之后才给出：

```
测试失败（<N> 处失败）。完成前必须先修复：

[展示失败详情]
```

**如果测试通过：** 继续到第 2 步。

## 第 2 步：检测环境（Detect Environment）

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# 现在捕获——趁还待在工作区里。第 5 步会改变目录，
# 而清理（第 6 步）需要这个值
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

这一步决定展示哪个菜单以及清理如何工作：

| 状态（State） | 菜单（Menu） | 清理（Cleanup） |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 3 选项 | 无需清理的工作树 |
| `GIT_DIR != GIT_COMMON`，带名字的分支 | 标准 3 选项 | 基于来源（见第 6 步） |
| `GIT_DIR != GIT_COMMON`，游离的 HEAD | 精简 2 选项（无合并） | 外部托管——原地保留 |

## 第 3 步：确定基分支（Determine Base Branch）

基分支就是这份工作分叉自的那个分支——通常在计划、对话或该分支的
上游（upstream）里已指明。如果还不知道，就问："这个分支是从 <你的最佳猜测>
分出来的——对吗？" 合并之前先确认：合并错基分支，撤销的代价很高。

## 第 4 步：给出选项（Present Options）

**普通仓库与带名字分支的工作树——只给出下面这 3 个选项：**

```
实现已完成。你想怎么做？

1. 本地合并回 <base-branch>
2. 推送并创建一个 Pull Request
3. 分支保持原样（我稍后处理）

选哪个？
```

**游离的 HEAD——只给出下面这 2 个选项：**

```
实现已完成。你正处在一个游离的 HEAD 上（外部托管的工作区）。

1. 作为新分支推送并创建一个 Pull Request
2. 保持原样（我稍后处理）

选哪个？
```

菜单按写定的原样给出——简洁，且每个选项都来自上面的清单。丢弃这份
工作只发生在你的人类搭档明确要求时（见下面"如果你的人类搭档要求丢弃
工作"）。等他们回答；整合的决定权在他们。

## 第 5 步：执行选择（Execute Choice）

### 选项 1：本地合并

```bash
# 为 CWD 安全起见，先拿到主仓库根目录
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并——在移除任何东西之前确认成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 在合并结果上验证测试
<test command>
```

如果合并结果上测试失败：停下，让工作树和分支都留在原地，去调查——
还没有推送任何东西，所以这次合成本地且可恢复。

合并结果变绿之后：清理工作树（第 6 步），然后删除分支：

```bash
git branch -d <feature-branch>
```

### 选项 2：推送并创建 PR

```bash
git push -u origin <feature-branch>
# 从游离的 HEAD 推送时，给远端上的新分支命名：
# git push origin HEAD:refs/heads/<new-branch>
```

然后针对 <base-branch> 用平台（forge）的工具创建 pull/merge request——
有 CLI 就用 CLI，否则用多数平台推送时打印出的创建 URL——遵循仓库现有的
PR 模板与约定（如果有的话），并把 URL 报告给你的人类搭档。

保留工作树——你的人类搭档要在那里针对 PR 反馈做迭代。

### 选项 3：保持原样

报告："保留分支 <name>。工作树保留在 <path>。"

### 如果你的人类搭档要求丢弃工作

这条路径只作为对"明确要求扔掉工作"的响应而存在。先确认：

```
这将永久删除：
- 分支 <name>
- 全部提交：<commit-list>
- <path> 处的工作树

输入 'discard' 以确认。
```

等待那条确切的确认。当它到达时：

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后清理工作树（第 6 步）并强制删除分支：

```bash
git branch -D <feature-branch>
```

## 第 6 步：清理工作区（Cleanup Workspace）

**只针对选项 1 和已确认的丢弃运行。** 选项 2 和 3 始终保留工作树。
两个调用方都已经把目录切到了主仓库根目录——移除工作树必须在工作树之外
执行——并使用第 2 步中、在那个目录切换之前捕获的 `GIT_DIR` /
`GIT_COMMON` / `WORKTREE_PATH` 值。

**如果 `GIT_DIR == GIT_COMMON`：** 普通仓库，无需清理的工作树。完成。

**如果 `WORKTREE_PATH` 位于 `.worktrees/` 或 `worktrees/` 之下：**
Superpowers 创建了这棵工作树——清理归我们管：

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清理任何过期的注册
```

**如果移除被拒绝**（`contains modified or untracked files`）：这棵工作树
持有只在别处才没有的文件——未提交的计划、笔记或草稿工作。绝不要自作主张
`--force`。把利害关系展示给你的人类搭档并询问：

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
工作树移除被拒绝——这些文件从未被提交：

<文件清单>

1. 在清理前把它们提交到 <branch>
2. 把它们移进 <主仓库根目录>
3. 删除它们（不可恢复）

选哪个？
```

执行所选方案，然后移除工作树。

**否则：** 宿主机环境拥有这个工作区——原地保留。如果你的平台提供了
退出工作区的工具，就使用它。

## 快速参考（Quick Reference）

| 选项（Option） | 合并（Merge） | 推送（Push） | 保留工作树（Keep Worktree） | 清理分支（Cleanup Branch） |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | 是 | - | - | 是 |
| 2. 创建 PR | - | 是 | 是 | - |
| 3. 保持原样 | - | - | 是 | - |
| 丢弃（仅限明确要求） | - | - | - | 是（强制） |

## 常见的自我合理化（Common Rationalizations）

| 借口（Excuse） | 现实（Reality） |
|--------|---------|
| "这个会话早些时候测试通过过" | 在你将要整合的那棵树（tree）上跑整套测试。一次绿色运行只能证明它所运行的那棵树是好的。 |
| "他们显然想合并它" | 整合是你的人类搭档的决定。给出菜单并等待。 |
| "他们看起来已经不用这个特性了——我主动提议丢弃吧" | 菜单按写定的就是完整的。只有当搭档用明确的语言要求时才丢弃。 |
| "'对，把它弄掉'也算确认" | 只有键盘上敲出的 `discard` 一词才授权删除。 |
| "PR 已经挂上去了，工作树现在是累赘" | PR 反馈要在那棵工作树里修。它要一直留到工作落地。 |
| "那棵工作树看起来过期了——我一并清理掉" | 只清理位于 `.worktrees/` 或 `worktrees/` 之下的工作树。其余一切属于宿主机。 |
| "移除被拒绝——`--force` 不过是把清理做完" | 拒绝意味着有些文件只存在于那棵工作树里。`--force` 会永久销毁它们。展示给你的人类搭档并询问。 |
| "合并结果上的失败大概是偶发的" | 合并结果失败会叫停一切。在你调查期间，分支和工作树都保持原地不动。 |
| "基分支显然就是 main" | 确认分叉点或直接问。合并错基分支，撤销代价很高。 |
| "推送被拒——force-push 能解决" | 推送被拒意味着远端已经移动了。去调查；只有在你的人类搭档明确要求时才 force-push。 |
