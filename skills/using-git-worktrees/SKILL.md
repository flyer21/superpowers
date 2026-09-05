---
name: using-git-worktrees
description: 在开始需要与当前工作区隔离的特性工作或执行实施计划之前使用 - 确保通过平台原生工具或 git worktree 回退方案存在一个隔离的工作区
---

# 使用 Git Worktrees

## 概述（Overview）

确保工作在隔离的工作区中进行。优先使用你所在平台的原生 worktree 工具。只有在没有原生工具可用时才回退到手工 git worktree。

**核心原则：** 先检测是否已有隔离。然后使用原生工具。然后回退到 git。绝不要与工作台（harness）对抗。

**开始时声明：** "我正在使用 using-git-worktrees 技能来搭建一个隔离的工作区。"

## 第 0 步：检测已有的隔离

**在创建任何东西之前，先检查你是否已经在隔离的工作区中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块防护：** 在 git 子模块内部，`GIT_DIR != GIT_COMMON` 同样成立。在断定"已经在 worktree 中"之前，先验证你不处于子模块中：

```bash
# 如果这返回一个路径，你就处在子模块里，而不是 worktree 中——按普通仓库对待
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（且不是子模块）：** 你已经在链接的 worktree 中了。跳到第 2 步（项目设置）。不要再创建一个 worktree。

结合分支状态汇报：
- 在某个分支上："已经在隔离工作区中：`<path>`，当前分支 `<name>`。"
- 分离 HEAD："已经在隔离工作区中：`<path>`（分离 HEAD，由外部管理）。收尾时需要创建分支。"

**如果 `GIT_DIR == GIT_COMMON`（或处于子模块中）：** 你在一个普通仓库检出中。

你的指令里是否已经写明用户对 worktree 的偏好？如果没有，在创建 worktree 之前先征求同意：

> "你希望我搭建一个隔离的 worktree 吗？它可以保护你当前的分支不受改动影响。"

尊重任何已经声明的偏好，无需再问。如果用户拒绝同意，就在原地工作并跳到第 2 步。

## 第 1 步：创建隔离工作区

**你有两种机制。按这个顺序尝试。**

### 1a. 原生 Worktree 工具（优先）

用户已经要求一个隔离工作区（第 0 步已获同意）。你是否已经有创建 worktree 的方式？可能是名为 `EnterWorktree`、`WorktreeCreate` 的工具、一个 `/worktree` 命令、或一个 `--worktree` 标志。如果有，就用它并跳到第 2 步。

原生工具会自动处理目录放置、分支创建和清理。当你拥有原生工具却使用 `git worktree add`，会制造出你的工作台看不见、也管理不了的幽灵状态（phantom state）。

只有当没有任何原生 worktree 工具可用时，才继续到第 1b 步。

### 1b. Git Worktree 回退方案

**只有第 1a 步不适用时才用这个**——即你没有原生 worktree 工具可用。这时用 git 手工创建 worktree。

#### 目录选择

按这个优先级顺序。用户显式声明的偏好永远优先于观察到的文件系统状态。

1. **检查你的指令里是否有声明过的 worktree 目录偏好。** 如果用户已经指定了，直接使用，不必再问。

2. **检查是否已有项目本地的 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 优先（隐藏目录）
   ls -d worktrees 2>/dev/null      # 备选
   ```
   如果找到，就使用它。如果两者都存在，`.worktrees` 胜出。

3. **如果没有其他可参考的指引**，默认使用项目根目录下的 `.worktrees/`。

#### 安全检查（仅限项目本地目录）

**创建 worktree 之前必须验证目录已被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未被忽略：** 加入 .gitignore、提交该改动，然后再继续。

**为什么这至关重要：** 防止不小心把 worktree 的内容提交进仓库。

#### 创建 Worktree

```bash
# 根据选定的位置确定路径
path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱回退：** 如果 `git worktree add` 因权限错误（沙箱拒绝）而失败，就告诉用户沙箱阻止了 worktree 的创建，你改为在当前目录工作。然后在原地运行项目设置和基线测试。

## 第 2 步：项目设置

自动检测并运行合适的设置：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## 第 3 步：验证干净的基线

运行测试，确保工作区是从干净状态起步：

```bash
# 使用适合项目的命令
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：** 汇报失败情况，询问是继续还是调查。

**如果测试通过：** 汇报一切就绪。

### 汇报

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情况 | 操作 |
|-----------|--------|
| 已经在链接的 worktree 中 | 跳过创建（第 0 步） |
| 处于子模块中 | 按普通仓库对待（第 0 步防护） |
| 有原生 worktree 工具可用 | 使用它（第 1a 步） |
| 没有原生工具 | Git worktree 回退方案（第 1b 步） |
| 存在 `.worktrees/` | 使用它（验证已被忽略） |
| 存在 `worktrees/` | 使用它（验证已被忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 两者都不存在 | 检查指令文件，然后默认 `.worktrees/` |
| 目录未被忽略 | 加入 .gitignore 并提交 |
| 创建时权限错误 | 沙箱回退，原地工作 |
| 基线的测试失败 | 汇报失败并询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见的自我合理化

| 借口 | 现实 |
|--------|---------|
| "我显然不在 worktree 里——没必要检查" | 去跑第 0 步。工作台创建的隔离和子模块都会骗过目测；那些检测命令能给出定论。 |
| "`git worktree add` 比找原生工具更快" | 原生工具（如 `EnterWorktree`）掌管着目录放置、分支创建和清理。绕过它是第一大错误——它会制造出你的工作台看不见、也管理不了的幽灵状态。 |
| "worktree 目录肯定已经被忽略了" | 去跑 `git check-ignore`。一个未被忽略的 worktree 目录会把整棵树提交进仓库。 |
| "什么目录名都行" | 显式指令胜过已有的项目本地目录，已有的项目本地目录胜过 `.worktrees/` 这个默认值。 |
| "工作区是全新的——基线测试可以等等" | 脏基线会让之后每一次失败都变得含混不清。现在就跑测试；是否带着失败继续前行由你的人类搭档来定。 |
