# Agent-Browser 自动化测试指南

> 专为 AI 编程助手设计的快速浏览器自动化 CLI，支持 Chrome/Chromium CDP 协议

---

## 概述

agent-browser 是 Vercel Labs 开发的浏览器自动化工具，专为 AI Agent 优化：

- ✅ **Rust 高性能** - 原生 CLI，非 Node.js 包装
- ✅ **Accessibility Tree** - 使用可访问性树而非视觉模型
- ✅ **Element Refs** - 紧凑 `@eN` 元素引用，Token 高效
- ✅ **跨 Agent 支持** - Claude Code、Cursor、Codex、Windsurf 等
- ✅ **Electron 支持** - VS Code、Slack、Discord 等桌面应用

---

## 与 Playwright 对比

### 设计目标差异

| 维度 | agent-browser | Playwright |
|------|---------------|------------|
| **目标用户** | AI Agent（自动化决策） | 人类开发者（手动编写脚本） |
| **设计理念** | Token 高效、输出紧凑 | 功能全面、API 丰富 |
| **交互方式** | CLI 命令 + 元素引用 | Node.js/Python API |
| **页面理解** | Accessibility Tree（语义） | DOM + 视觉模型 |

### Token 效率对比

**Playwright MCP 输出（约 500+ tokens）：**
```yaml
- webpage "Login Page":
  - heading "User Login"
  - paragraph "Enter credentials"
  - textbox "Username" [focused=true, editable=true]:
      value: ""
      placeholder: "Enter username"
  - textbox "Password" [editable=true]:
      value: ""
      placeholder: "Enter password"
  - button "Submit" [disabled=false]
  - link "Forgot password?" [url="/reset"]
```

**agent-browser snapshot 输出（约 100 tokens）：**
```yaml
- textbox "Username" [ref=e5]
- textbox "Password" [ref=e6]
- button "Submit" [ref=e7]
- link "Forgot password" [ref=e8]
```

关键差异：
- agent-browser 使用紧凑的 `@eN` 元素引用，避免重复描述属性
- 精简输出减少 AI Agent 的上下文消耗，适合长时间自动化任务

### 元素定位方式

| 方式 | agent-browser | Playwright |
|------|---------------|------------|
| **定位器** | `@e5`（快照引用） | CSS、XPath、Text、Role |
| **稳定性** | 引用绑定快照版本 | 选择器可能因 DOM 变化失效 |
| **使用方式** | `click @e5` | `page.click('button[data-testid="submit"]')` |

agent-browser 的 `@eN` 引用来自当前快照，确保操作精准匹配页面状态。

### 技术架构对比

| 维度 | agent-browser | Playwright |
|------|---------------|------------|
| **实现语言** | Rust（原生 CLI） | Node.js（TypeScript） |
| **协议** | Chrome DevTools Protocol (CDP) | CDP + WebKit/Firefox 协议 |
| **浏览器支持** | Chromium/Chrome | Chromium、Firefox、WebKit |
| **安装依赖** | npm + Chrome 二进制 | npm + 浏览器二进制包 |

### 适用场景选择

**推荐使用 agent-browser：**
- AI Agent 自动化任务（Claude Code、Cursor）
- 长对话中需要多次浏览器操作
- Token 成本敏感的场景
- 快速原型验证和探索性测试
- Electron 桌面应用自动化

**推荐使用 Playwright：**
- 人类编写的测试脚本（E2E 测试套件）
- 需要 Firefox/WebKit 跨浏览器测试
- 复杂测试框架集成（Jest、Mocha）
- 团队协作的长期维护测试项目
- 需要完整 DOM 访问和调试能力

### 工作流对比示例

**相同任务的两种实现：**

```bash
# agent-browser（AI Agent 方式）
agent-browser open https://app.com/login
agent-browser snapshot              # ~100 tokens
agent-browser type @e5 "admin"
agent-browser click @e7

# Playwright MCP（人类/AI 共用方式）
# 需加载 Playwright MCP Schema ~2000 tokens
# 输出完整页面树 ~500 tokens
# 使用语义化选择器操作
```

### 混合使用建议

两者可以互补使用：

```bash
# 快速探索：agent-browser
agent-browser open https://app.com
agent-browser snapshot  # 快速了解页面结构

# 深度测试：Playwright
# 编写完整的 E2E 测试脚本
# 使用 Playwright 的断言和报告功能
```

---

## 安装

### CLI 安装

```bash
# npm 全局安装
npm install -g agent-browser --no-audit --no-fund

# 安装 Chrome 浏览器
agent-browser install
```

### 技能安装（Agent 指导）

```bash
# 安装 agent-browser 技能
npx skills add https://github.com/vercel-labs/agent-browser --skill agent-browser -g -y
```

---

## 核心命令

### 导航操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `open <url>` | 打开 URL | `agent-browser open https://example.com` |
| `back` | 返回上一页 | `agent-browser back` |
| `forward` | 前进 | `agent-browser forward` |
| `reload` | 刷新页面 | `agent-browser reload` |

### 元素交互

| 命令 | 说明 | 示例 |
|------|------|------|
| `click <sel>` | 点击元素 | `agent-browser click @e5` |
| `dblclick <sel>` | 双击 | `agent-browser dblclick @e3` |
| `type <sel> <text>` | 输入文本 | `agent-browser type @e10 "hello"` |
| `fill <sel> <text>` | 清空并填写 | `agent-browser fill @e10 "new value"` |
| `hover <sel>` | 悬停 | `agent-browser hover @e7` |
| `focus <sel>` | 获取焦点 | `agent-browser focus @e8` |

### 表单操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `check <sel>` | 勾选复选框 | `agent-browser check @e2` |
| `uncheck <sel>` | 取消勾选 | `agent-browser uncheck @e2` |
| `select <sel> <val>` | 下拉选择 | `agent-browser select @e4 "option1"` |
| `upload <sel> <files>` | 上传文件 | `agent-browser upload @e6 file.pdf` |

### 键盘操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `press <key>` | 按键 | `agent-browser press Enter` |
| `keyboard type <text>` | 真实键盘输入 | `agent-browser keyboard type "text"` |

### 页面操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `scroll <dir> [px]` | 滚动 | `agent-browser scroll down 200` |
| `scrollintoview <sel>` | 滚动到元素 | `agent-browser scrollintoview @e5` |
| `wait <sel|ms>` | 等待 | `agent-browser wait @e10` 或 `wait 1000` |

### 输出操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `screenshot [path]` | 截图 | `agent-browser screenshot page.png` |
| `pdf <path>` | 保存 PDF | `agent-browser pdf report.pdf` |
| `snapshot` | 可访问性树快照 | `agent-browser snapshot` |
| `eval <js>` | 执行 JS | `agent-browser eval "document.title"` |

---

## 使用场景

### 1. Web 应用自动化测试

```bash
# 打开应用
agent-browser open https://myapp.com/login

# 获取页面快照
agent-browser snapshot

# 输入用户名密码
agent-browser type @e5 "admin"
agent-browser type @e6 "password123"

# 点击登录
agent-browser click @e7

# 等待页面加载
agent-browser wait 2000

# 截图验证
agent-browser screenshot dashboard.png
```

### 2. 表单填写自动化

```bash
agent-browser open https://forms.example.com
agent-browser snapshot

# 填写各字段
agent-browser fill @e2 "张三"
agent-browser fill @e3 "zhangsan@example.com"
agent-browser select @e4 "北京"
agent-browser check @e5

# 提交
agent-browser click @e6 "提交"
```

### 3. 数据提取

```bash
agent-browser open https://news.example.com
agent-browser snapshot

# 执行 JS 提取数据
agent-browser eval "
  Array.from(document.querySelectorAll('.article'))
    .map(a => ({title: a.querySelector('h2').textContent, link: a.href}))
"
```

### 4. Electron 应用自动化

```bash
# 加载 Electron 技能
agent-browser skills get electron

# 连接 VS Code
agent-browser connect --electron "Visual Studio Code"
```

---

## AI Agent 工作流

### 加载技能指导

在使用前，AI Agent 应加载技能内容：

```bash
# 核心工作流指导
agent-browser skills get core

# 包含完整命令参考
agent-browser skills get core --full
```

### 专用技能

| 技能 | 用途 |
|------|------|
| `electron` | Electron 桌面应用（VS Code、Slack、Discord） |
| `slack` | Slack 工作区自动化 |
| `dogfood` | 探索性测试 / QA / Bug 搜索 |
| `vercel-sandbox` | Vercel Sandbox 微虚拟机 |
| `agentcore` | AWS Bedrock AgentCore 云浏览器 |

```bash
agent-browser skills get electron
agent-browser skills get slack
agent-browser skills get dogfood
```

---

## Snapshot 输出格式

`snapshot` 命令返回可访问性树，包含元素引用：

```yaml
- button "登录" [ref=e5]:
    focused: true
- textbox "用户名" [ref=e6]:
    value: ""
- link "帮助" [ref=e7]:
    url: /help
```

AI Agent 使用 `@eN` 引用操作元素：
- `agent-browser click @e5` - 点击登录按钮
- `agent-browser type @e6 "admin"` - 输入用户名

---

## 高级功能

### 会话持久化

**说明**：`9222` 是 Chrome DevTools Protocol (CDP) 的默认调试端口。agent-browser 通常自动管理浏览器实例，无需手动指定端口。

```bash
# 手动启动 Chrome 调试模式（macOS）
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug

# 查看监听的调试端口
lsof -i :9222-9230

# 连接到已有 Chrome 实例
agent-browser connect 9222

# 保持登录状态（复用已有 session）
agent-browser open --persistent https://app.com
```

**使用场景**：手动连接主要用于复用已有登录状态、连接外部 Chrome 实例、或调试 Electron 应用。

### 视频录制

```bash
# 启用录制
agent-browser open --record test.mp4 https://app.com

# 操作后关闭
agent-browser close
```

### 多标签页

```bash
# 列出标签页
agent-browser tabs list

# 选择标签页
agent-browser tabs select 2

# 新建标签页
agent-browser tabs new

# 关闭标签页
agent-browser tabs close 1
```

---

## 常见问题

### Q: Chrome 下载失败？

Chrome 约 180MB，确保网络稳定：
```bash
# 手动指定 Chrome 路径
agent-browser install --chrome /path/to/chrome
```

### Q: 元素找不到？

使用 `snapshot` 获取最新页面状态，确保 `@eN` 引用正确。

### Q: 操作顺序混乱？

使用 `wait` 命令确保页面加载完成：
```bash
agent-browser wait @e10  # 等待元素出现
agent-browser wait 1000  # 等待 1 秒
```

---

## 参考链接

- [GitHub 仓库](https://github.com/vercel-labs/agent-browser)
- [技能详情](https://skills.sh/vercel-labs/agent-browser)
- [Vercel Sandbox](https://vercel.com/docs/sandbox)