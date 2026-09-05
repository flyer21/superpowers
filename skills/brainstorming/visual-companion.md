# 可视化伴档指南（Visual Companion Guide）

用于在头脑风暴中展示原型图、示意图和选项的基于浏览器的可视化伴档。

## 何时使用（When to Use）

按**问题**逐个决定，而不是按会话决定。判断标准：**用户通过"看到"它，是否比"读到"它更容易理解？**

**用浏览器**，当内容本身就是视觉性的：

- **UI 原型图（UI mockups）** — 线框、布局、导航结构、组件设计
- **架构图（Architecture diagrams）** — 系统组件、数据流、关系图
- **并排视觉对比（Side-by-side visual comparisons）** — 对比两种布局、两套配色方案、两个设计方向
- **设计打磨（Design polish）** — 当问题关乎外观与感觉、间距、视觉层级时
- **空间关系（Spatial relationships）** — 以图呈现的状态机、流程图、实体关系

**用终端**，当内容是文字或表格性的：

- **需求与范围问题（Requirements and scope questions）** — "X 是什么意思？""哪些功能在范围内？"
- **概念性 A/B/C 选择（Conceptual A/B/C choices）** — 在用语言描述的几种方案之间挑选
- **权衡清单（Tradeoff lists）** — 优缺点、对比表格
- **技术决策（Technical decisions）** — API 设计、数据建模、架构方案选择
- **澄清问题（Clarifying questions）** — 凡是答案是一段话、而非一种视觉偏好的问题

一个关于 UI *主题*的问题并不自动就是可视化问题。"你想要哪种向导？"是概念性的——用终端。"这些向导布局中哪一种感觉对？"是视觉性的——用浏览器。

## 工作原理（How It Works）

服务器监视一个目录里的 HTML 文件，并把最新的一份提供给浏览器。你把 HTML 内容写到 `screen_dir`，用户在浏览器里看到它，并可以点击选择选项。选择会被记录到 `state_dir/events`，你在下一轮读取它。

**内容片段 vs 完整文档（Content fragments vs full documents）：** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头，服务器就原样提供它（只注入辅助脚本）。否则，服务器会自动把你的内容包进框架模板（frame template）——加入页眉、CSS 主题、连接状态以及全部交互基础设施。**默认写内容片段。** 只有当你需要对页面有完全控制时，才写完整文档。

## 启动一个会话（Starting a Session）

```bash
# Start AFTER the user approves the companion. --open auto-opens their browser on
# the first screen; --project-dir persists mockups and enables same-port restart.
scripts/start-server.sh --project-dir /path/to/project --open

# Returns: {"type":"server-started","port":52341,
#           "url":"http://localhost:52341/?key=ab12…",
#           "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从响应中保存 `screen_dir` 和 `state_dir`。使用 `--open` 时，当你推送第一屏，浏览器会自己打开——你不必让用户手动打开，但仍然要分享 URL 作为后备（无头/远程环境不会自动打开）。

**URL 里包含一个会话密钥（`?key=…`）。** 服务器会拒绝任何不带密钥的请求，所以始终把 `url` 字段中的**完整** URL 给用户——绝不删掉查询字符串，也绝不给出光秃秃的 `http://host:port`。该密钥把关着 HTTP 与 WebSocket 的访问，因此一个不相干的浏览器标签页或网络上的另一台机器都无法读取屏幕或注入事件。首次加载后，浏览器会通过 cookie 记住这个密钥，所以刷新和 `/files/*` 资源都不必再次带上它。

**查找连接信息：** 服务器会把它的启动 JSON 写到 `$STATE_DIR/server-info`。如果你在后台启动服务器、没有捕获 stdout，就读取这个文件来获得 URL 和端口。使用 `--project-dir` 时，到 `<project>/.superpowers/brainstorm/` 下查找会话目录。

**注意：** 把项目根目录作为 `--project-dir` 传入，这样原型图会持久保存在 `.superpowers/brainstorm/` 中，并能在服务器重启后存活。不传的话，文件会进入 `/tmp` 并被清理掉。提醒用户：如果 `.gitignore` 里还没有 `.superpowers/`，就把它加进去。

**按平台启动服务器：**

**Claude Code：**
```bash
# Default mode works — the script backgrounds the server itself.
scripts/start-server.sh --project-dir /path/to/project --open
```

在 Windows 上，脚本会自动检测并切换到前台模式（这会阻塞工具调用）。在 Bash 工具调用上使用 `run_in_background: true`，让服务器能跨对话轮存活，然后在下一轮读取 `$STATE_DIR/server-info` 来获取 URL 和端口。

**Codex：**
```bash
# Codex reaps background processes. The script auto-detects CODEX_CI and
# switches to foreground mode. Run it normally — no extra flags needed.
scripts/start-server.sh --project-dir /path/to/project --open
```

**Gemini CLI：**
```bash
# Use --foreground and set is_background: true on your shell tool call
# so the process survives across turns
scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**Copilot CLI：**
```bash
# Start it with Copilot CLI's non-blocking/background shell mechanism so the
# server survives across turns. Keep --foreground so the harness, not the
# script, owns backgrounding. The launcher is a .sh, so invoke it via bash
# (on Windows, call Git Bash's bash.exe from the PowerShell tool).
bash scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**其他环境：** 服务器必须能留在后台、跨对话轮存活。如果你的环境会收割（reap）分离的进程，就使用 `--foreground`，并用你所在平台的后台执行机制来启动该命令。

如果从你的浏览器访问不到该 URL（在远程/容器化环境中很常见），就绑定一个非环回（non-loopback）主机：

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

用 `--url-host` 控制返回的 URL JSON 里打印的是哪个主机名。

## 工作循环（The Loop）

1. **确认服务器存活**，然后把 HTML 写进 `screen_dir` 里的一个新文件：
   - **必需：在提及 URL 或推送屏幕之前，先确认服务器还活着。** 检查 `$STATE_DIR/server-info` 存在、且 `$STATE_DIR/server-stopped` 不存在。如果它已经关闭，就用**相同的 `--project-dir`** 重新运行 `start-server.sh` 启动它——它会复用同一个端口，所以用户已打开的标签页会自动重连（服务器宕机期间它会显示一个"已暂停"遮罩），你也不必发送新 URL。服务器闲置 4 小时后会自动退出（可用 `--idle-timeout-minutes` 配置）。
   - 使用语义化的文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **绝不要复用文件名**——每一屏都用一个全新文件
   - 用你的文件创建工具——**绝不要用 cat/heredoc**（会把噪音倒进终端）
   - 服务器会自动提供最新的文件

2. **告诉用户接下来会看到什么，然后结束你的回合：**
   - 提醒他们 URL（每一步都要，不只是第一步）
   - 简要文字总结一下屏幕上有什么（例如"正在展示首页的 3 种布局选项"）
   - 请他们在终端里回应："看一下，然后告诉我你的想法。如果你想选择，点击即可。"

3. **在下一个回合**——用户已在终端回应之后：
   - 如果 `$STATE_DIR/events` 存在就读取它——里面以 JSON 行的形式记录着用户的浏览器交互（点击、选择）
   - 把它与用户在终端输入的文字合并起来，获得全貌
   - 终端消息是主要反馈；`state_dir/events` 提供结构化的交互数据

4. **迭代或推进**——如果反馈改变了当前屏幕，就写一个新文件（例如 `layout-v2.html`）。只有当前步骤得到验证后，才推进到下一个问题。

5. **回到纯终端讨论时卸载（unload）**——当下一步不需要浏览器时（例如澄清问题、权衡讨论），就推送一个等待屏幕，清掉已过期的内容：

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   这可以防止用户在对话已经推进之后，还盯着一屏已经了结的选择。当下一个可视化问题出现时，照常推送一个新的内容文件。

6. 一直重复，直到完成。

## 写内容片段（Writing Content Fragments）

只写要放进页面里的内容。服务器会自动把它包进框架模板（页眉、主题 CSS、连接状态，以及全部交互基础设施）。

**最小示例：**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

就这些。不需要 `<html>`、不需要 CSS、不需要 `<script>` 标签。服务器会提供全部这些东西。

## 可用的 CSS 类（CSS Classes Available）

框架模板为你的内容提供以下 CSS 类：

### 选项（Options，A/B/C 选择）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**多选：** 给容器加上 `data-multiselect` 属性，让用户可以选择多个选项。每次点击都会切换该项的选中样式。

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### 卡片（Cards，视觉设计）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### 原型图容器（Mockup Container）

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### 分屏视图（Split View，并排对比）

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### 优缺点（Pros/Cons）

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### 模拟元素（Mock Elements，线框构建块）

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 排版与区块（Typography and Sections）

- `h2` — 页面标题
- `h3` — 区块标题
- `.subtitle` — 标题下方的次级文本
- `.section` — 带底部外边距的内容块
- `.label` — 小型大写标签文本

## 浏览器事件格式（Browser Events Format）

当用户在浏览器中点击选项时，他们的交互会被记录到 `$STATE_DIR/events`（每行一个 JSON 对象）。当你推送新的一屏时，该文件会被自动清空。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流展示着用户的探索路径——他们可能会先点好几个选项才最终定下来。最后一条 `choice` 事件通常就是最终选择，但点击的模式可能透露出犹豫或值得追问的偏好。

如果 `$STATE_DIR/events` 不存在，说明用户没有与浏览器交互——只用他们的终端文字即可。

## 设计提示（Design Tips）

- **按问题缩放保真度（Scale fidelity to the question）** — 布局问题用线框，打磨问题用高保真稿
- **在每一页上说明问题（Explain the question on each page）** — 写"哪种布局显得更专业？"，而不要只写"挑一个"
- **推进之前先迭代（Iterate before advancing）** — 如果反馈改变了当前屏幕，就写一个新版本
- **每屏最多 2-4 个选项**
- **在重要处用真实内容（Use real content when it matters）** — 对摄影作品集，就使用真实图片（Unsplash）。占位内容会掩盖设计问题。
- **保持原型图简单（Keep mockups simple）** — 聚焦布局与结构，而不是像素级完美的设计

## 文件命名（File Naming）

- 使用语义化名称：`platform.html`、`visual-style.html`、`layout.html`
- 绝不要复用文件名——每一屏必须是新文件
- 迭代时：追加版本后缀，如 `layout-v2.html`、`layout-v3.html`
- 服务器按修改时间提供最新的文件

## 清理（Cleaning Up）

```bash
scripts/stop-server.sh $SESSION_DIR
```

如果会话用了 `--project-dir`，原型图文件会持久保存在 `.superpowers/brainstorm/` 中供以后参考。只有 `/tmp` 会话会在停止时被删除。

## 参考（Reference）

- 框架模板（CSS 参考）：`scripts/frame-template.html`
- 辅助脚本（客户端）：`scripts/helper.js`
