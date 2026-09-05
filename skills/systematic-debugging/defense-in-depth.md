# 纵深防御校验（Defense-in-Depth Validation）

## 概述（Overview）

当你修复了一个由无效数据引起的 bug 时，感觉只在一个地方加校验就够了。但那一处检查可能被不同的代码路径、重构或 mock 绕过。

**核心原则：** 在数据经过的每一层都做校验。让 bug 在结构上变得不可能。

## 为什么要多层（Why Multiple Layers）

单层校验："我们修掉了这个 bug"
多层校验："我们让这个 bug 变得不可能"

不同层次能抓住不同的情况：
- 入口校验抓住大多数 bug
- 业务逻辑抓住边界情况
- 环境守卫防止特定上下文里的危险
- 调试日志在其他层失败时提供帮助

## 四层防御（The Four Layers）

### 第 1 层：入口点校验（Entry Point Validation）
**目的：** 在 API 边界拒绝明显无效的输入

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### 第 2 层：业务逻辑校验（Business Logic Validation）
**目的：** 确保数据对这个操作而言是合理的

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### 第 3 层：环境守卫（Environment Guards）
**目的：** 在特定上下文中阻止危险操作

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

### 第 4 层：调试插桩（Debug Instrumentation）
**目的：** 为取证捕获上下文

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## 套用这个模式（Applying the Pattern）

当你发现一个 bug 时：

1. **追踪数据流** - 坏值源自哪里？在哪里被使用？
2. **画出所有检查点** - 列出数据经过的每一个点
3. **在每一层加校验** - 入口、业务、环境、调试
4. **测试每一层** - 尝试绕过第 1 层，验证第 2 层能接住它

## 会话中的示例（Example from Session）

Bug：空的 `projectDir` 导致在源代码里执行了 `git init`

**数据流：**
1. 测试设置 → 空字符串
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init` 运行在 `process.cwd()` 里

**添加的四层：**
- 第 1 层：`Project.create()` 校验不为空 / 存在 / 可写
- 第 2 层：`WorkspaceManager` 校验 projectDir 不为空
- 第 3 层：`WorktreeManager` 在测试中拒绝 tmpdir 之外的 git init
- 第 4 层：git init 之前的堆栈追踪日志

**结果：** 全部 1847 个测试通过，bug 无法复现

## 关键洞见（Key Insight）

四层全部是必要的。测试期间，每一层都抓住了其他层漏掉的问题：
- 不同的代码路径绕过了入口校验
- mock 绕过了业务逻辑检查
- 不同平台上的边界情况需要环境守卫
- 调试日志识别出了结构性误用

**不要只停在一个校验点上。** 在每一层都加上检查。
