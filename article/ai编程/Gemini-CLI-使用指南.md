# Gemini CLI 使用指南

## 工具简介

**Gemini CLI** 是 Google 官方推出的开源 AI 终端助手，将 Gemini 大模型的能力直接带入命令行。

- **GitHub**: https://github.com/google-gemini/gemini-cli
- **官方文档**: https://geminicli.com/docs/
- **特点**: 免费额度、1M token 上下文、内置工具、MCP 支持

---

## 安装方式

### macOS/Linux

```bash
# Homebrew 安装（推荐）
brew install gemini-cli

# npm 全局安装
npm install -g @google/gemini-cli

# npx 直接运行（无需安装）
npx @google/gemini-cli
```

### 版本渠道

| 渠道 | 说明 | 安装命令 |
|------|------|---------|
| `latest` | 稳定版（每周二 UTC 20:00 发布） | `npm install -g @google/gemini-cli@latest` |
| `preview` | 预览版（每周二 UTC 23:59 发布） | `npm install -g @google/gemini-cli@preview` |
| `nightly` | 每日构建版 | `npm install -g @google/gemini-cli@nightly` |

---

## 认证方式

### 方式 1：Google 账号登录（推荐）

**免费额度**：60 次/分钟，1000 次/天

```bash
gemini
# 选择 "Sign in with Google"，按提示完成浏览器认证
```

### 方式 2：API Key

```bash
# 从 https://aistudio.google.com/apikey 获取
export GEMINI_API_KEY="YOUR_API_KEY"
gemini
```

### 方式 3：Vertex AI（企业版）

```bash
export GOOGLE_API_KEY="YOUR_API_KEY"
export GOOGLE_GENAI_USE_VERTEXAI=true
gemini
```

---

## 基本使用

### 启动方式

```bash
# 在当前目录启动
gemini

# 包含多个目录
gemini --include-directories ../lib,../docs

# 指定模型
gemini -m gemini-2.5-flash

# 非交互模式（脚本中使用）
gemini -p "Explain this codebase"
gemini -p "Run tests" --output-format json
```

### 上下文文件 (GEMINI.md)

在项目根目录创建 `GEMINI.md` 文件，为 Gemini 提供项目特定的上下文信息：

```markdown
# 项目概述
这是一个 Node.js 项目...

# 技术栈
- Express.js
- PostgreSQL

# 编码规范
- 使用 ESLint
- 遵循 Airbnb style guide
```

---

## Slash 命令

在 Gemini CLI 内部使用 `/` 开头的命令：

### 基础命令

| 命令 | 功能 |
|------|------|
| `/help` 或 `/?` | 显示帮助信息 |
| `/about` | 显示版本信息 |
| `/clear` | 清屏（等同于 Ctrl+L） |
| `/quit` 或 `/exit` | 退出 CLI |
| `/copy` | 复制最后输出到剪贴板 |
| `/stats` | 显示当前会话统计信息 |

### 会话管理

| 命令 | 功能 |
|------|------|
| `/resume` 或 `/chat` | 浏览并恢复历史会话 |
| `/rewind` | 回退对话历史 |
| `/restore` | 恢复项目文件到工具执行前的状态 |
| `/compress` | 将对话上下文压缩为摘要 |

### 模型与配置

| 命令 | 功能 |
|------|------|
| `/model` | 管理模型配置 |
| `/auth` | 更改认证方式 |
| `/settings` | 打开设置编辑器 |
| `/theme` | 更改视觉主题 |
| `/vim` | 开关 Vim 模式 |

### 工具与扩展

| 命令 | 功能 |
|------|------|
| `/tools` | 显示可用工具列表 |
| `/mcp` | 管理 MCP 服务器 |
| `/extensions` | 管理扩展 |
| `/agents` | 管理子代理 |
| `/skills` | 管理 Agent Skills |
| `/commands` | 管理自定义 slash 命令 |

### 项目管理

| 命令 | 功能 |
|------|------|
| `/init` | 分析当前目录并生成 GEMINI.md |
| `/dir` 或 `/directory` | 管理工作目录（多目录支持） |
| `/memory` | 管理 GEMINI.md 上下文 |
| `/permissions` | 管理文件夹信任设置 |
| `/hooks` | 管理行为钩子 |

### 模式切换

| 命令 | 功能 |
|------|------|
| `/plan` | 切换到计划模式（只读） |
| `/shells` 或 `/bashes` | 显示后台 shell |
| `/terminal-setup` | 配置终端多行输入 |

### 其他

| 命令 | 功能 |
|------|------|
| `/docs` | 在浏览器中打开文档 |
| `/bug` | 提交问题报告 |
| `/privacy` | 显示隐私声明 |
| `/upgrade` | 打开升级页面 |

---

## 键盘快捷键

### 基础控制

| 快捷键 | 功能 |
|--------|------|
| `Enter` | 确认选择或提交 |
| `Esc` | 取消/关闭对话框 |
| `Ctrl+C` | 取消请求或退出（输入为空时） |
| `Ctrl+D` | 退出 CLI（输入为空时） |

### 光标移动

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+A` / `Home` | 移到行首 |
| `Ctrl+E` / `End` | 移到行尾 |
| `Ctrl+←` / `Alt+←` | 向左移动一个词 |
| `Ctrl+→` / `Alt+→` | 向右移动一个词 |

### 编辑

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+K` | 删除到行尾 |
| `Ctrl+U` | 删除到行首 |
| `Ctrl+W` | 删除前一个词 |
| `Ctrl+Y` | 切换 YOLO（自动审批）模式 |
| `Cmd+Z` / `Alt+Z` | 撤销 |

### 历史

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+P` / `↑` | 上一条历史记录 |
| `Ctrl+N` / `↓` | 下一条历史记录 |
| `Ctrl+R` | 反向搜索历史 |

### 多行输入

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Enter` / `Shift+Enter` | 插入换行（不提交） |
| `Ctrl+G` | 在外部编辑器中打开 |

### 应用控制

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+L` | 清屏重绘 |
| `Ctrl+S` | 切换鼠标模式 |
| `Ctrl+Y` | 切换 YOLO 模式 |
| `Shift+Tab` | 切换审批模式 |
| `F12` | 显示调试控制台 |
| `Ctrl+B` | 切换后台 Shell |
| `Alt+M` | 切换 Markdown 渲染 |

---

## 使用场景

### 场景 1：代码理解与分析

```bash
cd my-project
gemini
> 分析这个项目的架构设计
> 解释 src/auth 模块的工作原理
> 查找所有使用 deprecated API 的地方
```

### 场景 2：代码生成与重构

```bash
gemini
> 创建一个 Express.js 的 REST API 项目结构
> 重构 utils.js 文件，提取可复用的函数
> 为 User 模型添加 TypeScript 类型定义
```

### 场景 3：调试与问题排查

```bash
gemini
> 为什么测试用例 test_login 失败了？
> 查找可能导致内存泄漏的代码
> 分析这个错误日志并给出解决方案
```

### 场景 4：Git 操作辅助

```bash
gemini
> 总结昨天所有提交的变更内容
> 解决当前的 merge conflict
> 创建一个 feature 分支并提交这些改动
```

### 场景 5：文档生成

```bash
gemini
> 为 API 接口生成 OpenAPI 文档
> 写一份 README.md 描述项目用途
> 根据代码生成 API 使用示例
```

### 场景 6：多目录项目

```bash
# 同时分析多个关联目录
gemini --include-directories ../shared-lib,../docs
> 分析 shared-lib 如何被主项目引用
```

### 场景 7：脚本自动化

```bash
# 非交互模式，适合 CI/CD
gemini -p "检查代码风格问题" --output-format json > report.json

# 流式输出，适合长时间任务
gemini -p "运行完整测试套件" --output-format stream-json
```

### 场景 8：会话恢复

```bash
gemini
> /resume  # 浏览历史会话，选择恢复
> /rewind  # 回退到之前的对话点
```

---

## MCP 服务器集成

在 `~/.gemini/settings.json` 中配置 MCP 服务器：

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"]
    }
  }
}
```

使用示例：

```bash
> @github List my open pull requests
> @slack Send summary to #dev channel
```

---

## 自定义快捷键

在 `~/.gemini/keybindings.json` 中配置：

```json
[
  { "command": "edit.clear", "key": "cmd+l" },
  { "command": "input.submit", "key": "ctrl+y" },
  { "command": "-app.toggleYolo", "key": "ctrl+y" }
]
```

---

## 对比其他 CLI 工具

| 特性 | Gemini CLI | Claude Code | Aider |
|------|------------|-------------|-------|
| 免费额度 | 60次/分钟，1000次/天 | 无 | 无 |
| 上下文窗口 | 1M tokens | 200K | 取决于模型 |
| 内置工具 | 文件、Shell、Web | 文件、Shell、Web | 文件、Git |
| MCP 支持 | ✅ | ✅ | ❌ |
| 模型选择 | Gemini 系列 | Claude 系列 | 多模型 |

---

## 注意事项

1. **网络要求**：需要能访问 Google 服务
2. **终端支持**：推荐使用支持真彩色的现代终端（Ghostty、iTerm2）
3. **上下文文件**：建议每个项目创建 `GEMINI.md` 提供上下文
4. **会话管理**：使用 `/resume` 和 `/rewind` 管理长对话

---

## 相关资源

- **GitHub**: https://github.com/google-gemini/gemini-cli
- **官方文档**: https://geminicli.com/docs/
- **命令参考**: https://geminicli.com/docs/reference/commands
- **快捷键参考**: https://geminicli.com/docs/reference/keyboard-shortcuts
- **NPM 包**: https://www.npmjs.com/package/@google/gemini-cli