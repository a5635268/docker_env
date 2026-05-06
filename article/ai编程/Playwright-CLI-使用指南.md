# Playwright CLI 使用指南

> Playwright 专为 AI 编程助手设计的轻量级命令行工具，提供 Token 高效的浏览器自动化接口

---

## 概述

Playwright CLI 是 Microsoft 官方推出的命令行工具，专门为 Claude Code、Copilot 等 AI 编程助手优化：

- ✅ **Token 高效**：使用 YAML 格式快照，避免加载大型工具 Schema
- ✅ **无 Schema 加载**：命令行直接交互，不占用模型上下文
- ✅ **Accessibility Tree**：基于可访问性树而非视觉模型，降低资源消耗
- ✅ **跨浏览器**：支持 Chromium、Firefox、WebKit

---

## 安装

### 全局安装

```bash
npm install -g @playwright/cli@latest
```

### 本地使用

```bash
npx playwright-cli <command>
```

### 安装 Skills（用于 AI 编程助手）

```bash
playwright-cli install --skills
```

---

## 启动选项

Playwright CLI 支持以下启动参数：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--headed` | 显示浏览器窗口（非无头模式） | `false` |
| `--persistent` | 使用持久化浏览器上下文，保持 cookies 和登录状态 | `false` |
| `--browser=<name>` | 指定浏览器类型 | `chromium` |

### `--headed` 模式

显示浏览器窗口，便于观察自动化过程：

```bash
# 显示浏览器窗口打开网页
playwright-cli --headed open https://example.com

# 调试时推荐使用有头模式
playwright-cli --headed open https://example.com
playwright-cli snapshot    # 可以同时看到页面和快照
playwright-cli click e5    # 观察点击效果
```

### `--persistent` 模式

持久化浏览器上下文，保存登录状态：

```bash
# 持久化模式 - 登录状态会保存
playwright-cli --persistent open https://github.com

# 登录 GitHub（cookies 会保存）
playwright-cli snapshot
playwright-cli fill e3 "your-username"
playwright-cli fill e5 "your-password"
playwright-cli click e7

# 关闭后再打开，仍然保持登录状态
playwright-cli close
playwright-cli --persistent open https://github.com
playwright-cli snapshot  # 已登录状态，无需重新登录
```

### 组合使用

```bash
# 有头 + 持久化：适合开发调试和需要登录的场景
playwright-cli --headed --persistent open https://example.com

# 持久化 + 指定浏览器
playwright-cli --persistent --browser=firefox open https://example.com
```

> **注意**：`--persistent` 会创建用户数据目录 `~/.playwright-cli/user-data/`，存储 cookies、localStorage 和 session 数据。

---

## 核心命令

### 浏览器管理

| 命令 | 说明 | 示例 |
|------|------|------|
| `open` | 打开浏览器 | `playwright-cli open` |
| `open <url>` | 打开并导航 | `playwright-cli open https://example.com` |
| `close` | 关闭浏览器 | `playwright-cli close` |
| `resize <w> <h>` | 调整窗口大小 | `playwright-cli resize 1920 1080` |

### 页面导航

| 命令 | 说明 | 示例 |
|------|------|------|
| `goto <url>` | 导航到 URL | `playwright-cli goto https://playwright.dev` |
| `navigate-back` | 返回上一页 | `playwright-cli navigate-back` |
| `tab-list` | 列出所有标签页 | `playwright-cli tab-list` |
| `tab-new` | 新建标签页 | `playwright-cli tab-new` |
| `tab-new <url>` | 新建并导航 | `playwright-cli tab-new https://example.com` |
| `tab-close` | 关闭当前标签页 | `playwright-cli tab-close` |
| `tab-close <index>` | 关闭指定标签页 | `playwright-cli tab-close 2` |
| `tab-select <index>` | 选择标签页 | `playwright-cli tab-select 0` |

### 页面快照

| 命令 | 说明 | 示例 |
|------|------|------|
| `snapshot` | 捕获页面快照 | `playwright-cli snapshot` |
| `snapshot --filename=<name>` | 指定文件名保存 | `playwright-cli snapshot --filename=after-click.yaml` |
| `snapshot <selector>` | 元素快照 | `playwright-cli snapshot "#main"` |
| `snapshot --depth=<n>` | 限制深度 | `playwright-cli snapshot --depth=4` |
| `screenshot --type=png` | 截图（PNG） | `playwright-cli screenshot --type=png` |
| `screenshot --type=jpeg` | 截图（JPEG） | `playwright-cli screenshot --type=jpeg` |
| `screenshot --fullPage` | 全页截图 | `playwright-cli screenshot --type=png --fullPage` |

> **快照格式**：YAML 格式的 Accessibility Tree，包含元素引用 ID（如 `e3`、`e7`）

### 元素交互

| 命令 | 说明 | 示例 |
|------|------|------|
| `click <ref>` | 点击元素 | `playwright-cli click e3` |
| `dblclick <ref>` | 双击元素 | `playwright-cli dblclick e7` |
| `type <text>` | 输入文本 | `playwright-cli type "search query"` |
| `fill <ref> <text>` | 填充表单 | `playwright-cli fill e5 "user@example.com"` |
| `fill <ref> <text> --submit` | 填充并提交 | `playwright-cli fill e5 "value" --submit` |
| `hover <ref>` | 悬停元素 | `playwright-cli hover e4` |
| `drag <start> <end>` | 拖拽元素 | `playwright-cli drag e2 e8` |
| `select <ref> <value>` | 选择下拉选项 | `playwright-cli select e9 "option-value"` |
| `upload <path>` | 上传文件 | `playwright-cli upload ./document.pdf` |
| `check <ref>` | 勾选复选框 | `playwright-cli check e12` |
| `uncheck <ref>` | 取消勾选 | `playwright-cli uncheck e12` |

### JavaScript 执行

| 命令 | 说明 | 示例 |
|------|------|------|
| `eval <code>` | 执行 JS | `playwright-cli eval "document.title"` |
| `eval <fn> <ref>` | 元素 JS | `playwright-cli eval "el => el.textContent" e5` |
| `eval "el => el.id"` | 获取元素 ID | `playwright-cli eval "el => el.id" e5` |
| `eval "el => el.getAttribute(...)"` | 获取属性 | `playwright-cli eval "el => el.getAttribute('data-testid')" e5` |

### 对话框处理

| 命令 | 说明 | 示例 |
|------|------|------|
| `dialog-accept` | 接受对话框 | `playwright-cli dialog-accept` |
| `dialog-accept <text>` | 接受并输入文本 | `playwright-cli dialog-accept "确认"` |
| `dialog-dismiss` | 拒绝对话框 | `playwright-cli dialog-dismiss` |

### 等待操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `wait-for --text=<text>` | 等待文本出现 | `playwright-cli wait-for --text="Loading complete"` |
| `wait-for --textGone=<text>` | 等待文本消失 | `playwright-cli wait-for --textGone="Loading..."` |
| `wait-for --time=<seconds>` | 等待指定时间 | `playwright-cli wait-for --time=5` |

---

## 调试工具

### Console 日志

```bash
playwright-cli open https://example.com
playwright-cli console --level=error    # 仅错误
playwright-cli console --level=warning  # 警告及以上
playwright-cli console --level=info     # 信息及以上（默认）
playwright-cli console --level=debug    # 所有日志
```

### 网络请求

```bash
playwright-cli open https://example.com
playwright-cli network                  # 查看网络请求
playwright-cli network --filter="/api"  # 过滤 API 请求
playwright-cli network --requestHeaders # 包含请求头
playwright-cli network --requestBody    # 包含请求体
```

### Tracing 追踪

```bash
playwright-cli open https://example.com
playwright-cli tracing-start            # 开始追踪
playwright-cli click e4
playwright-cli fill e7 "test"
playwright-cli tracing-stop             # 停止追踪
playwright-cli close
```

追踪内容包括：
- **Actions**：点击、填充、悬停、键盘输入、导航
- **DOM**：每个操作前后的完整快照
- **Screenshots**：每步的视觉状态
- **Network**：请求、响应、头、体、时间
- **Console**：日志、警告、错误
- **Timing**：精确的操作时间

---

## 配置文件

配置文件位置：`.playwright/cli.config.json`

```json
{
  "browser": {
    "browserName": "chromium",
    "isolated": false,
    "launchOptions": {
      "headless": true,
      "channel": "chrome"
    },
    "contextOptions": {
      "viewport": { "width": 1280, "height": 720 }
    }
  },
  "outputDir": ".playwright-cli",
  "outputMode": "stdout",
  "console": {
    "level": "info"
  },
  "network": {
    "allowedOrigins": ["https://example.com"],
    "blockedOrigins": ["https://ads.example.com"]
  },
  "testIdAttribute": "data-testid",
  "timeouts": {
    "action": 5000,
    "navigation": 60000
  }
}
```

### 配置项说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `browser.browserName` | 浏览器类型 | `chromium` |
| `browser.launchOptions.headless` | 无头模式 | `false` |
| `browser.launchOptions.channel` | 浏览器渠道 | - |
| `browser.contextOptions.viewport` | 视口大小 | - |
| `outputDir` | 输出目录 | `.playwright-cli` |
| `outputMode` | 输出模式 | `stdout` |
| `console.level` | 日志级别 | `info` |
| `network.allowedOrigins` | 允许的源 | 所有 |
| `network.blockedOrigins` | 阻止的源 | 无 |
| `timeouts.action` | 操作超时（ms） | 5000 |
| `timeouts.navigation` | 导航超时（ms） | 60000 |

---

## 使用场景

### 场景 1：网页内容抓取

```bash
# 打开网页并获取快照
playwright-cli open https://news.example.com
playwright-cli snapshot --filename=news.yaml

# 解析 YAML 文件获取结构化数据
```

### 场景 2：表单自动化填写

```bash
playwright-cli open https://example.com/login
playwright-cli snapshot               # 获取元素引用
playwright-cli fill e5 "username"     # 填写用户名
playwright-cli fill e7 "password"     # 填写密码
playwright-cli click e9               # 点击登录
playwright-cli wait-for --text="Dashboard"
```

### 场景 3：调试页面问题

```bash
playwright-cli open https://example.com
playwright-cli console --level=error
playwright-cli network --filter="/api"
playwright-cli tracing-start
# 执行一系列操作...
playwright-cli tracing-stop
```

### 场景 4：AI 编程助手集成

在 Claude Code 或 Copilot CLI 中：

```bash
# Claude Code 自动调用
请帮我打开 https://example.com 并截图

# 或通过 Skill 自动执行
/skill playwright-cli
```

---

## 与 Playwright MCP 的区别

| 特性 | Playwright CLI | Playwright MCP |
|------|---------------|----------------|
| **接口** | 命令行 | MCP Server（工具调用） |
| **Token 消耗** | 极低（无 Schema） | 较高（加载工具定义） |
| **AI 集成** | Skill 自动调用 | MCP 工具调用 |
| **适用场景** | 简单快速操作 | 复杂自动化流程 |
| **配置方式** | JSON 文件 | MCP Server 配置 |

---

## 参考资源

- [Playwright CLI GitHub](https://github.com/microsoft/playwright-cli)
- [Playwright 官方文档](https://playwright.dev)
- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)

---

*文档生成时间：2026-04-21*