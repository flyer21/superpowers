---
name: using-git-worktrees
description: 当开始需要与当前工作区隔离的功能工作或执行实施计划之前使用——确保通过原生工具或 git worktree 回退方案存在隔离的工作区
---

# 使用 Git Worktrees

## 概述

确保工作在隔离的工作区中进行。偏好平台的原生 worktree 工具。仅在没有原生工具可用时才回退到手动 git worktree。

**核心原则：** 首先检测现有隔离。然后使用原生工具。然后回退到 git。永远不要与工具对抗。

**开始时声明：** "我正在使用 using-git-worktrees 技能来设置隔离的工作区。"

## 步骤 0：检测现有隔离

**在创建任何东西之前，检查你是否已经在隔离的工作区中。**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**子模块守卫：** `GIT_DIR != GIT_COMMON` 在 git 子模块内也是真的。在得出"已经在 worktree 中"的结论之前，验证你不在子模块中：

```bash
# 如果这返回路径，你在子模块中，而不是 worktree——视为普通仓库
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**如果 `GIT_DIR != GIT_COMMON`（并且不是子模块）：** 你已经在链接的 worktree 中。跳到步骤 2（项目设置）。不要创建另一个 worktree。

报告分支状态：
- 在分支上："已经在 `<path>` 的隔离工作区中，分支 `<name>`。"
- 分离 HEAD："已经在 `<path>` 的隔离工作区中（分离 HEAD，外部管理）。完成时需要创建分支。"

**如果 `GIT_DIR == GIT_COMMON`（或在子模块中）：** 你在普通仓库检出中。

用户是否已在你的指令中表明他们的 worktree 偏好？如果没有，在创建 worktree 之前请求同意：

> "你想让我设置隔离的 worktree 吗？它保护你的当前分支免受更改影响。"

尊重任何现有的声明偏好而不询问。如果用户拒绝同意，就地工作并跳到步骤 2。

## 步骤 1：创建隔离工作区

**你有两种机制。按此顺序尝试它们。**

### 1a. 原生 Worktree 工具（首选）

用户已请求隔离工作区（步骤 0 同意）。你已经有创建 worktree 的方法吗？它可能是名为 `EnterWorktree`、`WorktreeCreate`、`/worktree` 命令或 `--worktree` 标志的工具。如果有，使用它并跳到步骤 2。

原生工具自动处理目录放置、分支创建和清理。当你有原生工具时使用 `git worktree add` 会创建你的工具无法看到或管理的幻象状态。

仅在没有原生 worktree 工具可用时才继续步骤 1b。

### 1b. Git Worktree 回退

**仅在步骤 1a 不适用时使用**——你没有可用的原生 worktree 工具。使用 git 手动创建 worktree。

#### 目录选择

遵循此优先级顺序。明确的用户偏好总是胜过观察到的文件系统状态。

1. **检查你的指令中声明的 worktree 目录偏好。** 如果用户已指定一个，使用它而不询问。

2. **检查现有的项目本地 worktree 目录：**
   ```bash
   ls -d .worktrees 2>/dev/null     # 首选（隐藏）
   ls -d worktrees 2>/dev/null      # 备选
   ```
   如果找到，使用它。如果两者都存在，`.worktrees` 获胜。

3. **如果没有其他指导可用**，默认使用项目根目录下的 `.worktrees/`。

#### 安全验证（仅项目本地目录）

**在创建 worktree 之前必须验证目录被忽略：**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果未忽略：** 添加到 .gitignore，提交更改，然后继续。

**为什么关键：** 防止意外将 worktree 内容提交到仓库。

#### 创建 Worktree

```bash
# 根据选择的位置确定路径
path="$LOCATION/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**沙箱回退：** 如果 `git worktree add` 因权限错误失败（沙箱拒绝），告诉用户沙箱阻止了 worktree 创建，你正在当前目录中工作。然后在原地运行设置和基线测试。

## 步骤 2：项目设置

自动检测并运行适当的设置：

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

## 步骤 3：验证干净基线

运行测试以确保工作区开始干净：

```bash
# 使用项目适当的命令
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：** 报告失败，询问是否继续或调查。

**如果测试通过：** 报告就绪。

### 报告

```
Worktree 就绪，位于 <full-path>
测试通过（<N> 个测试，0 个失败）
准备实施 <feature-name>
```

## 快速参考

| 情况 | 操作 |
|------|------|
| 已在链接的 worktree 中 | 跳过创建（步骤 0） |
| 在子模块中 | 视为普通仓库（步骤 0 守卫） |
| 原生 worktree 工具可用 | 使用它（步骤 1a） |
| 没有原生工具 | Git worktree 回退（步骤 1b） |
| `.worktrees/` 存在 | 使用它（验证忽略） |
| `worktrees/` 存在 | 使用它（验证忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 都不存在 | 检查指令文件，然后默认 `.worktrees/` |
| 目录未忽略 | 添加到 .gitignore + 提交 |
| 创建时权限错误 | 沙箱回退，就地工作 |
| 基线期间测试失败 | 报告失败 + 询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见合理化

| 借口 | 现实 |
|------|------|
| "我显然不在 worktree 中——无需检查" | 运行步骤 0。工具创建的隔离和子模块都会欺骗 eyeballing；检测命令解决它。 |
| "`git worktree add` 比寻找原生工具更快" | 原生工具（例如 `EnterWorktree`）拥有放置、分支和清理。绕过它是 #1 错误——它创建你的工具无法看到或管理的幻象状态。 |
| "worktree 目录肯定已经被忽略了" | 运行 `git check-ignore`。未忽略的 worktree 目录将整个树提交到仓库。 |
| "任何目录名都可以" | 明确指令胜过现有的项目本地目录，胜过 `.worktrees/` 默认。 |
| "工作区是新鲜的——基线测试可以等待" | 脏基线使每个后续失败模糊。现在运行测试；超过失败继续是你的（人类）搭档的决定。 |