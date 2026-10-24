# 根因追踪

## 概述

Bug 通常出现在调用栈深处（在错误的目录中 git init、在错误的位置创建文件、用错误的路径打开数据库）。你的直觉是修复错误出现的地方，但那是在治疗症状。

**核心原则：** 沿着调用链向后追踪，直到找到原始触发器，然后在源头修复。

## 何时使用

```dot
digraph when_to_use {
    "Bug 出现在栈深处？" [shape=diamond];
    "可以向后追踪？" [shape=diamond];
    "在症状点修复" [shape=box];
    "追踪到原始触发器" [shape=box];
    "更好：也添加纵深防御" [shape=box];

    "Bug 出现在栈深处？" -> "可以向后追踪？" [label="是"];
    "可以向后追踪？" -> "追踪到原始触发器" [label="是"];
    "可以向后追踪？" -> "在症状点修复" [label="否 - 死胡同"];
    "追踪到原始触发器" -> "更好：也添加纵深防御";
}
```

**在以下情况使用：**
- 错误在执行深处发生（不在入口点）
- 堆栈跟踪显示长调用链
- 不清楚无效数据从哪里来
- 需要找到哪个测试/代码触发问题

## 追踪过程

### 1. 观察症状
```
错误：在 ~/project/packages/core 中 git init 失败
```

### 2. 找到直接原因
**什么代码直接导致这个？**
```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. 问：什么调用了这个？
```typescript
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → 由 Session.initializeWorkspace() 调用
  → 由 Session.create() 调用
  → 由 Project.create() 的测试调用
```

### 4. 继续向上追踪
**传递了什么值？**
- `projectDir = ''`（空字符串！）
- 空字符串作为 `cwd` 解析为 `process.cwd()`
- 那是源代码目录！

### 5. 找到原始触发器
**空字符串从哪里来？**
```typescript
const context = setupCoreTest(); // 在 beforeEach 之前返回 { tempDir: '' }
Project.create('name', context.tempDir); // 在 beforeEach 之前访问！
```

## 添加堆栈跟踪

当你无法手动追踪时，添加工具：

```typescript
// 在有问题的操作之前
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

**关键：** 在测试中使用 `console.error()`（不是 logger - 可能不显示）

**运行并捕获：**
```bash
npm test 2>&1 | grep 'DEBUG git init'
```

**分析堆栈跟踪：**
- 查找测试文件名
- 找到触发调用的行号
- 识别模式（相同的测试？相同的参数？）

## 找到哪个测试导致污染

如果某些东西在测试期间出现但你不知道哪个测试：

使用此目录中的二分脚本 `find-polluter.sh`：

```bash
bash ./find-polluter.sh '.git' 'src/**/*.test.ts'
```

逐个运行测试，在第一个污染者处停止。参见脚本获取用法。

## 真实示例：空 projectDir

**症状：** 在 `packages/core/`（源代码）中创建 `.git`

**追踪链：**
1. `git init` 在 `process.cwd()` 中运行 ← 空 cwd 参数
2. WorktreeManager 用空 projectDir 调用
3. Session.create() 传递空字符串
4. 测试在 beforeEach 之前访问 `context.tempDir`
5. setupCoreTest() 最初返回 `{ tempDir: '' }`

**根因：** 顶层变量初始化访问空值

**修复：** 使 tempDir 成为 getter，如果在 beforeEach 之前访问则抛出

**也添加了纵深防御：**
- 层 1：Project.create() 验证目录
- 层 2：WorkspaceManager 验证不为空
- 层 3：NODE_ENV 守卫拒绝在 tmpdir 之外 git init
- 层 4：在 git init 之前记录堆栈跟踪

## 关键原则

```dot
digraph principle {
    "找到直接原因" [shape=ellipse];
    "可以向上追踪一层？" [shape=diamond];
    "向后追踪" [shape=box];
    "这是源头吗？" [shape=diamond];
    "在源头修复" [shape=box];
    "在每层添加验证" [shape=box];
    "Bug 不可能" [shape=doublecircle];
    "永远不要只修复症状" [shape=octagon, style=filled, fillcolor=red, fontcolor=white];

    "找到直接原因" -> "可以向上追踪一层？";
    "可以向上追踪一层？" -> "向后追踪" [label="是"];
    "可以向上追踪一层？" -> "永远不要只修复症状" [label="否"];
    "向后追踪" -> "这是源头吗？";
    "这是源头吗？" -> "向后追踪" [label="否 - 继续"];
    "这是源头吗？" -> "在源头修复" [label="是"];
    "在源头修复" -> "在每层添加验证";
    "在每层添加验证" -> "Bug 不可能";
}
```

**永远不要只修复错误出现的地方。** 向后追踪找到原始触发器。

## 堆栈跟踪提示

**在测试中：** 使用 `console.error()` 而不是 logger - logger 可能被抑制
**在操作之前：** 在危险操作之前记录，而不是在失败之后
**包含上下文：** 目录、cwd、环境变量、时间戳
**捕获堆栈：** `new Error().stack` 显示完整调用链

## 真实影响

来自调试会话（2025-10-03）：
- 通过 5 层追踪找到根因
- 在源头修复（getter 验证）
- 添加了 4 层防御
- 1847 个测试通过，零污染