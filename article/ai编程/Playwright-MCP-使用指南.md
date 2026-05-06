# Playwright MCP 使用指南

> Playwright MCP Server —— 基于 Model Context Protocol 的浏览器自动化服务，为 AI 编程助手提供网页交互能力

---

## 概述

Playwright MCP 是 Microsoft 官方推出的 MCP Server，让 Claude、Gemini 等 AI 通过 MCP 协议操控浏览器：

- ✅ **MCP 协议**：标准化的 Model Context Protocol 接口
- ✅ **Accessibility Tree**：基于可访问性树交互，无需视觉模型
- ✅ **完整工具集**：导航、点击、截图、执行 JS、网络拦截等
- ✅ **跨浏览器**：支持 Chromium、Firefox、WebKit
- ✅ **多种配置**：本地运行、远程连接、浏览器扩展集成

---

## 安装

### 方式一：全局安装

```bash
npm install -g @playwright/mcp@latest
```

### 方式二：项目本地

```bash
npm install @playwright/mcp
```

### 方式三：直接使用（无需安装）

```bash
npx @playwright/mcp@latest
```

---

## MCP 配置

### Claude Desktop 配置

编辑 `~/.claude.json`（用户配置）或项目 `.mcp.json`：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### 带参数配置

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--headless",
        "--browser=chromium"
      ]
    }
  }
}
```

### 远程 SSE 连接

```json
{
  "mcpServers": {
    "playwright-remote": {
      "url": "http://localhost:8931/mcp"
    }
  }
}
```

### 浏览器扩展模式

需要安装 [Playwright MCP Bridge](https://github.com/microsoft/playwright-mcp#browser-extension) 扩展：

```json
{
  "mcpServers": {
    "playwright-extension": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--extension"],
      "env": {
        "PLAYWRIGHT_MCP_EXTENSION_TOKEN": "your-token-here"
      }
    }
  }
}
```

---

## 可用工具（20+）

### 浏览器管理

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_navigate` | 导航到 URL | `url: string` |
| `browser_close` | 关闭浏览器 | 无 |
| `browser_resize` | 调整窗口 | `width, height: number` |
| `browser_tabs` | 标签页管理 | `action: list/new/close/select` |

### 页面快照与截图

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_snapshot` | Accessibility 快照 | `depth?: number, filename?: string` |
| `browser_take_screenshot` | 截图 | `type: png/jpeg, fullPage?: boolean` |

### 元素交互

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_click` | 点击元素 | `ref: string, element: string` |
| `browser_hover` | 悬停元素 | `ref: string, element: string` |
| `browser_type` | 输入文本 | `ref, text: string, submit?: boolean` |
| `browser_select_option` | 选择下拉选项 | `ref: string, values: string[]` |
| `browser_drag` | 拖拽元素 | `startRef, endRef: string` |
| `browser_fill_form` | 批量填充表单 | `fields: Field[]` |
| `browser_file_upload` | 上传文件 | `paths: string[]` |

### JavaScript 执行

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_evaluate` | 执行 JS | `function: string, ref?: string` |

### 等待与对话框

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_wait_for` | 等待状态 | `text?, textGone?, time?: number` |
| `browser_handle_dialog` | 处理对话框 | `accept: boolean, promptText?: string` |
| `browser_press_key` | 按键 | `key: string` |

### 调试工具

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_console_messages` | 获取 Console 日志 | `level: error/warning/info/debug` |
| `browser_network_requests` | 获取网络请求 | `filter?: string, requestBody?: boolean` |

### 高级功能

| 工具 | 说明 | 参数 |
|------|------|------|
| `browser_run_code` | 执行 Playwright 代码 | `code: string, filename?: string` |

---

## 命令行参数

### 启动参数

```bash
npx @playwright/mcp@latest [options]
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--browser <name>` | 浏览器类型 | `chromium` |
| `--headless` | 无头模式 | `false`（有头） |
| `--port <number>` | SSE 端口 | `8931` |
| `--host <host>` | 绑定主机 | `localhost` |
| `--caps <caps>` | 能力列表 | `core` |
| `--config <path>` | 配置文件路径 | - |
| `--output-dir <dir>` | 输出目录 | `./playwright-output` |
| `--device <name>` | 设备模拟 | - |

### 能力选项（`--caps`）

| 能力 | 说明 |
|------|------|
| `core` | 核心浏览器自动化（默认） |
| `vision` | 坐标定位交互 |
| `pdf` | PDF 生成与操作 |
| `devtools` | 开发者工具功能 |
| `testing` | 测试功能 |

### 网络控制

| 参数 | 说明 |
|------|------|
| `--allowed-origins <origins>` | 允许请求的源（分号分隔） |
| `--blocked-origins <origins>` | 阻止请求的源（分号分隔） |

### 其他参数

| 参数 | 说明 |
|------|------|
| `--isolated` | 内存中浏览器配置（不保存到磁盘） |
| `--extension` | 连接浏览器扩展 |
| `--cdp-endpoint <url>` | 连接现有 CDP 端点 |
| `--executable-path <path>` | 自定义浏览器路径 |
| `--ignore-https-errors` | 忽略 HTTPS 错误 |
| `--no-sandbox` | 禁用沙箱 |
| `--image-responses <mode>` | 图片响应：`allow`/`omit` |
| `--console-level <level>` | 日志级别 |
| `--save-session` | 保存会话 |
| `--testIdAttribute <attr>` | 测试 ID 属性名 |

---

## JSON 配置文件

创建 `playwright-mcp.config.json`：

```json
{
  "browser": {
    "browserName": "chromium",
    "isolated": false,
    "userDataDir": "/path/to/profile",
    "launchOptions": {
      "headless": false,
      "channel": "chrome",
      "executablePath": "/usr/bin/google-chrome"
    },
    "contextOptions": {
      "viewport": { "width": 1920, "height": 1080 },
      "userAgent": "Custom User Agent"
    },
    "initScript": ["./inject.js"]
  },
  "server": {
    "port": 8931,
    "host": "0.0.0.0",
    "allowedHosts": ["localhost", "127.0.0.1"]
  },
  "capabilities": ["core", "pdf", "vision", "devtools", "storage", "network", "testing"],
  "network": {
    "allowedOrigins": ["https://example.com:*"],
    "blockedOrigins": ["https://ads.example.com:*"]
  },
  "timeouts": {
    "action": 5000,
    "navigation": 60000,
    "expect": 5000
  },
  "console": {
    "level": "info"
  },
  "snapshot": {
    "mode": "incremental"
  },
  "outputDir": "./playwright-output",
  "outputMode": "file",
  "saveSession": true,
  "imageResponses": "allow",
  "codegen": "typescript",
  "testIdAttribute": "data-testid"
}
```

---

## 使用场景

### 场景 1：Claude Code 网页交互

```bash
# 在 Claude Code 中
请打开 https://example.com 并截图

# Claude 自动调用 MCP 工具
# browser_navigate -> browser_snapshot -> browser_take_screenshot
```

### 场景 2：自动化测试流程

```bash
帮我测试登录流程：
1. 打开 https://app.example.com/login
2. 输入用户名 test@example.com
3. 输入密码 password123
4. 点击登录按钮
5. 检查是否跳转到 Dashboard
```

### 场景 3：网页内容提取

```bash
帮我从 https://news.example.com 提取：
1. 所有新闻标题
2. 每条新闻的链接
3. 发布时间
4. 保存为 JSON 文件
```

### 场景 4：调试网页问题

```bash
帮我调试 https://example.com 的 Console 错误：
1. 打开页面
2. 获取所有 console 错误
3. 查看网络请求失败
4. 分析问题原因
```

### 场景 5：设备模拟测试

```bash
# 配置设备模拟
npx @playwright/mcp@latest --device="iPhone 15"

# 或在配置文件中
{
  "browser": {
    "contextOptions": {
      "viewport": { "width": 393, "height": 852 },
      "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0..."
    }
  }
}
```

### 场景 6：系统管理模块自动化测试

```bash
# 复杂业务流程测试 - 系统管理模块

使用 playwright mcp 工具访问 http://localhost:3000/#/login 网站，
登录账号：admin，密码：Ywz@2022，点击登录后，选择总院，
我在系统管理 - 组织机构 - 用户管理（部门管理），新增了关联用户和分配角色两个操作列，
并有相关弹窗，按照 @系统管理用例.csv 的测试用例，
帮我测试下用户管理和部门模块两个模块。
按测试用例跑完所有流程，并记录问题，生成测试报告，到根目录
```

**测试流程分解：**

1. **登录阶段**
   - 导航到登录页面
   - 输入账号密码
   - 点击登录
   - 选择组织机构（总院）

2. **用户管理模块**
   - 进入系统管理 - 组织机构 - 用户管理
   - 测试关联用户功能
   - 测试分配角色功能
   - 验证弹窗交互

3. **部门管理模块**
   - 进入部门管理页面
   - 执行部门相关操作
   - 验证功能完整性

4. **输出报告**
   - 记录测试问题
   - 生成测试报告到根目录


---

## 配置文件位置

| 配置类型 | 文件路径 |
|----------|----------|
| Claude 用户配置 | `~/.claude.json` |
| Claude 项目配置 | `.mcp.json` 或 `.claude/settings.local.json` |
| MCP Server 配置 | `playwright-mcp.config.json`（自定义） |

---

## 常见问题

### 问题 1：浏览器启动失败

**可能原因：**
- 浏览器未安装
- 无头模式配置错误

**解决方案：**
```bash
# 安装浏览器
npx playwright install chromium

# 尝试有头模式
npx @playwright/mcp@latest --headless=false
```

### 问题 2：MCP 连接失败

**解决方案：**
```bash
# 检查 Claude Code MCP 状态
claude mcp list

# 重启 MCP 服务器
claude mcp restart playwright
```

### 问题 3：元素无法找到

**解决方案：**
- 使用 `browser_snapshot` 获取最新的 Accessibility Tree
- 检查元素引用 ID 是否正确
- 使用 `browser_wait_for` 等待元素加载

### 问题 4：网络请求被阻止

**解决方案：**
```bash
# 配置允许的源
npx @playwright/mcp@latest --allowed-origins="https://example.com;https://api.example.com"
```

---

## 与 Playwright CLI 的区别

| 特性 | Playwright MCP | Playwright CLI |
|------|----------------|---------------|
| **接口** | MCP Server（工具调用） | 命令行 |
| **Token 消耗** | 较高（加载工具定义） | 极低（无 Schema） |
| **AI 集成** | MCP 工具调用 | Skill 自动调用 |
| **工具数量** | 20+ 工具 | 30+ 命令 |
| **适用场景** | 复杂自动化流程 | 简单快速操作 |
| **远程访问** | 支持 SSE | 不支持 |

---

## 设备模拟列表

常用设备模拟（`--device` 参数）：

| 设备 | 说明 |
|------|------|
| `iPhone 15` | iPhone 15 |
| `iPhone 15 Pro` | iPhone 15 Pro |
| `Galaxy S24` | Samsung Galaxy S24 |
| `Pixel 7` | Google Pixel 7 |
| `iPad Pro` | iPad Pro |

完整设备列表见 [Playwright Device Descriptors](https://playwright.dev/docs/emulation#devices)

---

## 参考资源

- [Playwright MCP GitHub](https://github.com/microsoft/playwright-mcp)
- [Playwright 官方文档](https://playwright.dev)
- [MCP 协议官网](https://modelcontextprotocol.io)
- [Claude Code 文档](https://claude.ai/code)

---

*文档生成时间：2026-04-21*