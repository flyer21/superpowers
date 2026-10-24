---
name: finishing-a-development-branch
description: 当实施完成、所有测试通过，且你需要决定如何集成工作时使用
---

# 完成开发分支

## 概述

**核心原则：** 验证测试 → 检测环境 → 呈现选项 → 执行选择 → 清理。

**开始时声明：** "我正在使用 finishing-a-development-branch 技能来完成这项工作。"

## 步骤 1：验证测试

运行项目的完整测试套件（`npm test` / `cargo test` / `pytest` / `go test ./...`）。

**如果测试失败**，报告失败并停止——菜单在绿色套件之后：

```
测试失败（<N> 个失败）。在完成之前必须修复：

[显示失败]
```

**如果测试通过：** 继续步骤 2。

## 步骤 2：检测环境

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# 现在捕获，当仍在工作区内时——步骤 5 更改目录
# 在清理之前（步骤 6）需要这个值
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

这决定了显示哪个菜单以及清理如何工作：

| 状态 | 菜单 | 清理 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON`（普通仓库） | 标准 3 个选项 | 无需清理 worktree |
| `GIT_DIR != GIT_COMMON`，命名分支 | 标准 3 个选项 | 基于来源（见步骤 6） |
| `GIT_DIR != GIT_COMMON`，分离 HEAD | 减少的 2 个选项（无合并） | 外部管理——保持原位 |

## 步骤 3：确定基础分支

基础分支是此工作分叉自的任何东西——通常在计划、对话或分支的上游中命名。如果还不知道，问："这个分支分叉自 <你的最佳猜测>——对吗？"在合并之前确认：合并到错误的基础是昂贵的撤销。

## 步骤 4：呈现选项

**普通仓库和命名分支 worktree——精确呈现这 3 个选项：**

```
实施完成。你想做什么？

1. 本地合并回 <base-branch>（推荐）
2. 推送并创建 Pull Request
3. 保持分支原样（我稍后处理）

哪个选项？
```

5 秒内无异议，我将按推荐项（本地合并）继续。要改就在这 5 秒内说。

**分离 HEAD——精确呈现这 2 个选项：**

```
实施完成。你在分离 HEAD 上（外部管理工作区）。

1. 作为新分支推送并创建 Pull Request
2. 保持原样（我稍后处理）

哪个选项？
```

精确呈现菜单——简洁，每个选项来自上面的列表。丢弃工作只在你的（人类）搭档明确要求时发生（见下方"如果你的（人类）搭档要求丢弃工作"）。等待他们的回答；集成决定是他们的。

**不参与自动推进的例外：**
- **推送**：不参与自动推进，必须明确要求。
- **创建 PR**：不参与自动推进，必须明确要求。
- **丢弃工作**：不参与自动推进，必须明确要求/确认。

## 步骤 5：执行选择

### 选项 1：本地合并

```bash
# 获取主仓库根目录以保证 CWD 安全
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 先合并——在删除任何内容之前验证成功
git checkout <base-branch>
git pull
git merge <feature-branch>

# 在合并结果上验证测试
<测试命令>
```

如果合并结果上测试失败：停止，保持 worktree 和分支原位，并调查——没有推送任何内容，所以合并是局部的且可恢复的。

一旦合并结果是绿色的：清理 worktree（步骤 6），然后删除分支：

```bash
git branch -d <feature-branch>
```

### 选项 2：推送并创建 PR

```bash
git push -u origin <feature-branch>
# 从分离 HEAD，在远程命名新分支：
# git push origin HEAD:refs/heads/<new-branch>
```

然后使用 forge 的工具创建针对 <base-branch> 的 pull/merge request——如果有 CLI 则使用它，或者大多数 forge 在推送时打印的创建 URL——遵循仓库的 PR 模板和约定（如果存在），并向你的（人类）搭档报告 URL。

保持 worktree——你的（人类）搭档在 PR 反馈上迭代。

### 选项 3：保持原样

报告："保持分支 <name>。Worktree 保留在 <path>。"

### 如果你的（人类）搭档要求丢弃工作

此路径仅作为对丢弃工作的明确请求的响应存在。首先确认：

```
这将永久删除：
- 分支 <name>
- 所有提交：<commit-list>
- Worktree 在 <path>

输入 'discard' 确认。
```

等待那个确切确认。当它到达时：

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

然后清理 worktree（步骤 6）并强制删除分支：

```bash
git branch -D <feature-branch>
```

## 步骤 6：清理工作区

**为选项 1 和确认的丢弃运行。** 选项 2 和 3 始终保留 worktree。两个调用者都已更改目录到主仓库根目录——worktree 移除必须在 worktree 之外运行——并使用步骤 2 中捕获的 `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` 值，在目录更改之前。

**如果 `GIT_DIR == GIT_COMMON`：** 普通仓库，无需清理 worktree。完成。

**如果 `WORKTREE_PATH` 在 `.worktrees/` 或 `worktrees/` 下：** Superpowers 创建了这个 worktree——我们拥有清理：

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 自愈：清理任何陈旧注册
```

**如果拒绝移除**（`contains modified or untracked files`）：worktree 持有不存在于其他地方的文件——未提交的计划、笔记或临时工作。永远不要主动使用 `--force`。向你的（人类）搭档展示风险并询问：

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree 移除被拒绝——这些文件从未提交：

<文件列表>

1. 在清理之前将它们提交到 <branch>
2. 将它们移动到 <主仓库根目录>
3. 删除它们（不可恢复）

哪个？
```

执行选择，然后移除 worktree。

**否则：** 宿主环境拥有这个工作区——保持原位。

## 第 7 步：路线图检测

**仅在调用方传递了路线图信息时运行。** 没有路线图信息时，跳过此步骤——行为与现在完全一致。

当调用方传递了"（路线图 <路径>，阶段 N：<名称>）"时：

1. **读取路线图文件** — 打开 `<路径>`，确认阶段 N 存在
2. **标记阶段 N 为已完成** — 在路线图的阶段列表中，将阶段 N 标记为"已完成"，提交此更改
3. **检查后续阶段** — 如果路线图还有未完成的阶段：
   - 报告："阶段 N 已完成。后续阶段：[列出阶段名称]"
   - 5 秒内无异议，我将按推荐项（开始下一阶段头脑风暴）继续。要改就在这 5 秒内说。
   - 无干预则自动调用 `superpowers:brainstorming` 开始下一阶段的设计（brainstorming 会先回读路线图与前期成果）
   - **明确边界**：自动开始的是下一阶段的头脑风暴；它的设计文档仍然需要你的（人类）搭档批准
   - **拒绝** → 结束流程
4. **全部完成** — 如果所有阶段都已完成：报告"路线图全部完成"，建议归档路线图到 `$HOME/.superpowers/archives/`

**不加自动扫描 `docs/superpowers/roadmaps/` 的逻辑。** 路线图检测完全依赖调用方传递的上下文。