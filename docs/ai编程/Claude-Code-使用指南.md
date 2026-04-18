# Claude Code 使用指南

## 工具简介

**Claude Code** 是 Anthropic 官方推出的智能编程助手，直接在终端中运行，理解代码库，通过自然语言命令帮助你更快编码。

- **GitHub**: https://github.com/anthropics/claude-code
- **官方文档**: https://code.claude.com/docs/
- **特点**: 代理式编码、代码理解、Git 工作流自动化、MCP 支持

---

## 安装方式

### macOS/Linux

```bash
# 官方推荐方式
curl -fsSL https://claude.ai/install.sh | bash

# Homebrew 安装
brew install --cask claude-code

# npm 安装（已弃用但仍可用）
npm install -g @anthropic-ai/claude-code
```

### Windows

```powershell
# 官方推荐方式
irm https://claude.ai/install.ps1 | iex

# WinGet 安装
winget install Anthropic.ClaudeCode
```

---

## 认证方式

### Claude 账号登录

```bash
claude
# 选择登录方式，按提示完成认证
```

### API Key 方式

```bash
# 使用 Anthropic Console API
claude auth login --console

# 或设置环境变量
export ANTHROPIC_API_KEY="YOUR_API_KEY"
```

### 企业认证

```bash
# Amazon Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
claude

# Google Vertex AI
export CLAUDE_CODE_USE_VERTEX=1
claude
```

---

## CLI 命令

### 启动与会话

| 命令 | 说明 |
|------|------|
| `claude` | 启动交互式会话 |
| `claude "query"` | 带初始提示启动会话 |
| `claude -p "query"` | 非交互模式，执行后退出 |
| `claude -c` | 继续当前目录最近会话 |
| `claude -r "<session>"` | 按 ID 或名称恢复会话 |
| `cat file \| claude -p "query"` | 处理管道输入内容 |

### 认证管理

| 命令 | 说明 |
|------|------|
| `claude auth login` | 登录 Anthropic 账号 |
| `claude auth logout` | 登出账号 |
| `claude auth status` | 查看认证状态 |

### 其他 CLI 命令

| 命令 | 说明 |
|------|------|
| `claude update` | 更新到最新版本 |
| `claude agents` | 列出配置的子代理 |
| `claude mcp` | 配置 MCP 服务器 |
| `claude plugin` | 管理插件 |
| `claude setup-token` | 生成长期 OAuth token |

---

## CLI Flags 常用参数

### 基础参数

| Flag | 说明 |
|------|------|
| `-p` / `--print` | 非交互模式 |
| `-c` / `--continue` | 继续最近会话 |
| `-r` / `--resume` | 恢复指定会话 |
| `-n` / `--name` | 设置会话名称 |
| `-w` / `--worktree` | 在隔离 git worktree 中启动 |

### 模型与配置

| Flag | 说明 |
|------|------|
| `--model` | 指定模型（如 `sonnet`, `opus`） |
| `--effort` | 设置努力级别（`low`, `medium`, `high`, `max`） |
| `--fast` | 快速模式 |
| `--theme` | 设置主题 |

### 权限模式

| Flag | 说明 |
|------|------|
| `--permission-mode` | 设置权限模式（`default`, `acceptEdits`, `plan`, `auto`） |
| `--dangerously-skip-permissions` | 跳过权限提示 |

### 输出格式

| Flag | 说明 |
|------|------|
| `--output-format` | 输出格式（`text`, `json`, `stream-json`） |
| `--verbose` | 详细输出 |

### 目录与 MCP

| Flag | 说明 |
|------|------|
| `--add-dir` | 添加额外工作目录 |
| `--mcp-config` | 加载 MCP 配置 |

### 示例

```bash
# 指定模型启动
claude --model sonnet

# 非交互模式输出 JSON
claude -p "分析这个项目" --output-format json

# 多目录项目
claude --add-dir ../lib ../docs

# Plan 模式启动
claude --permission-mode plan

# Git worktree 隔离开发
claude -w feature-auth

# 继续上次会话
claude -c "继续完成这个任务"
```

---

## Slash 命令

在 Claude Code 内部使用 `/` 开头的命令：

### 基础命令

| 命令 | 功能 |
|------|------|
| `/help` | 显示帮助信息 |
| `/clear` | 清空对话历史 |
| `/exit` 或 `/quit` | 退出 CLI |
| `/copy [N]` | 复制最近回复到剪贴板 |
| `/cost` | 显示 token 使用统计 |
| `/stats` | 显示每日使用统计 |
| `/status` | 显示当前状态（版本、模型等） |
| `/export [filename]` | 导出对话为文本 |

### 会话管理

| 命令 | 功能 |
|------|------|
| `/resume [session]` | 恢复历史会话 |
| `/rename [name]` | 重命名当前会话 |
| `/branch [name]` | 创建会话分支 |
| `/rewind` | 回退对话或代码状态 |
| `/compact` | 压缩对话上下文 |

### 模型与配置

| 命令 | 功能 |
|------|------|
| `/model [model]` | 切换模型 |
| `/effort [level]` | 设置努力级别 |
| `/fast [on|off]` | 切换快速模式 |
| `/config` 或 `/settings` | 打开设置界面 |
| `/theme` | 更改主题 |
| `/keybindings` | 配置快捷键 |

### 权限与模式

| 命令 | 功能 |
|------|------|
| `/permissions` | 管理权限规则 |
| `/plan [description]` | 进入计划模式 |
| `/sandbox` | 切换沙箱模式 |

### 项目管理

| 命令 | 功能 |
|------|------|
| `/init` | 初始化项目 CLAUDE.md |
| `/add-dir <path>` | 添加工作目录 |
| `/memory` | 管理 CLAUDE.md 文件 |
| `/context` | 查看上下文使用情况 |
| `/diff` | 查看 git diff |

### 工具与扩展

| 命令 | 功能 |
|------|------|
| `/mcp` | 管理 MCP 服务器 |
| `/agents` | 管理子代理配置 |
| `/skills` | 列出可用技能 |
| `/plugin` | 管理插件 |
| `/hooks` | 查看钩子配置 |
| `/tasks` | 管理后台任务 |

### Git 与 PR

| 命令 | 功能 |
|------|------|
| `/review [PR]` | 本地审查 PR |
| `/ultrareview [PR]` | 云端深度审查 |
| `/autofix-pr` | 自动修复 PR CI 问题 |
| `/security-review` | 安全审查当前分支 |

### 其他

| 命令 | 功能 |
|------|------|
| `/btw <question>` | 快速提问（不影响上下文） |
| `/doctor` | 诊断安装问题 |
| `/insights` | 分析使用报告 |
| `/loop [interval]` | 循环执行任务 |
| `/schedule` | 创建定时任务 |
| `/desktop` | 在桌面应用中继续 |
| `/mobile` | 显示下载手机 App 的二维码 |

---

## 键盘快捷键

### 基础控制

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+C` | 取消当前输入或生成 |
| `Ctrl+D` | 退出 Claude Code |
| `Ctrl+L` | 清空输入内容 |
| `Ctrl+G` | 在外部编辑器中打开 |
| `Ctrl+R` | 反向搜索历史 |
| `Ctrl+B` | 后台运行当前任务 |
| `Ctrl+T` | 切换任务列表 |
| `Ctrl+O` | 切换详细执行视图 |

### 模式切换

| 快捷键 | 功能 |
|--------|------|
| `Shift+Tab` | 切换权限模式 |
| `Alt+P` | 切换模型 |
| `Alt+T` | 切换扩展思考 |
| `Alt+O` | 切换快速模式 |
| `Esc` + `Esc` | 回退或总结 |

### 文本编辑

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+K` | 删除到行尾 |
| `Ctrl+U` | 删除到行首 |
| `Ctrl+Y` | 粘贴删除的文本 |
| `Alt+B` | 向左移动一个词 |
| `Alt+F` | 向右移动一个词 |

### 多行输入

| 快捷键 | 功能 |
|--------|------|
| `Shift+Enter` | 插入换行（不提交） |
| `\` + `Enter` | 插入换行（通用） |
| `Ctrl+J` | 换行符 |

### Bash 模式

| 输入 | 功能 |
|------|------|
| `!` | 进入 Bash 模式，直接执行命令 |
| `!command` | 执行 shell 命令并添加到上下文 |

### 其他

| 快捷键 | 功能 |
|--------|------|
| `/` | 显示命令列表 |
| `@` | 文件路径自动补全 |
| `Ctrl+V` | 从剪贴板粘贴图片 |
| `Space`（长按） | 语音输入（需启用） |

---

## Vim 编辑模式

通过 `/config` → Editor mode 启用。

### 模式切换

| 命令 | 功能 |
|------|------|
| `Esc` | 进入 NORMAL 模式 |
| `i` | 光标前插入 |
| `I` | 行首插入 |
| `a` | 光标后插入 |
| `A` | 行尾插入 |
| `o` | 下方新建行 |
| `O` | 上方新建行 |

### NORMAL 模式导航

| 命令 | 功能 |
|------|------|
| `h/j/k/l` | 左/下/上/右移动 |
| `w` | 下一个词 |
| `b` | 上一个词 |
| `0` | 行首 |
| `$` | 行尾 |
| `gg` | 输入开头 |
| `G` | 输入结尾 |

### NORMAL 模式编辑

| 命令 | 功能 |
|------|------|
| `x` | 删除字符 |
| `dd` | 删除行 |
| `D` | 删除到行尾 |
| `yy` | 复制行 |
| `p` | 粘贴 |
| `>>` | 缩进 |
| `<<` | 取消缩进 |

---

## 使用场景

### 场景 1：代码理解与分析

```bash
claude
> 分析这个项目的架构设计
> 解释 src/auth 模块的工作原理
> 查找所有使用 deprecated API 的地方
```

### 场景 2：代码生成与重构

```bash
claude
> 创建一个 Express.js REST API 项目
> 重构 utils.js，提取可复用函数
> 为 User 模型添加 TypeScript 类型定义
```

### 场景 3：调试与问题排查

```bash
claude
> 为什么测试用例 test_login 失败了？
> 查找可能导致内存泄漏的代码
> 分析这个错误日志并给出解决方案
```

### 场景 4：Git 工作流

```bash
claude
> 总结昨天所有提交的变更
> 解决当前的 merge conflict
> 创建 feature 分支并提交这些改动
> 审查 PR #123 的代码变更
```

### 场景 5：文档生成

```bash
claude
> 为 API 接口生成 OpenAPI 文档
> 写一份 README.md 描述项目
> 根据代码生成 API 使用示例
```

### 场景 6：非交互自动化

```bash
# CI/CD 脚本中使用
claude -p "检查代码风格问题" --output-format json

# 管道处理
cat logs.txt | claude -p "分析这些日志"

# 指定模型和输出格式
claude -p --model opus --output-format json "生成测试用例"
```

### 场景 7：并行开发

```bash
# Git worktree 隔离开发
claude -w feature-auth
claude -w feature-api

# 会话命名方便恢复
claude -n "auth-refactor"
claude -n "api-migration"

# 恢复会话
claude -r "auth-refactor"
```

### 场景 8：计划模式

```bash
# 进入计划模式，只读分析
claude --permission-mode plan
> 规划如何重构认证模块

# 或使用命令
/plan 设计新的 API 网关架构
```

### 场景 9：批量操作

```bash
# 批量重构
/batch migrate src/ from Solid to React

# 简化代码审查
/simplify focus on memory efficiency

# 安全审查
/security-review
```

---

## CLAUDE.md 上下文文件

在项目根目录创建 `CLAUDE.md` 文件，为 Claude 提供项目上下文：

```markdown
# 项目概述
这是一个 Node.js 项目...

# 技术栈
- Express.js
- PostgreSQL
- Redis

# 编码规范
- 使用 ESLint + Prettier
- 遵循 Airbnb style guide
- 所有函数需要 TypeScript 类型

# 常用命令
- npm run dev: 开发服务器
- npm test: 运行测试
- npm run build: 构建

# 注意事项
- 不要修改 src/core 目录
- 新功能需要在 tests/ 添加测试
```

### 初始化 CLAUDE.md

```bash
claude
> /init  # 自动分析项目并生成 CLAUDE.md
```

---

## MCP 服务器集成

在 `~/.claude/settings.json` 中配置 MCP 服务器：

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"]
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-slack"]
    }
  }
}
```

使用 MCP 命令：

```bash
/mcp  # 管理 MCP 连接
```

---

## Skills 技能系统

创建自定义技能在 `.claude/skills/` 目录：

```markdown
---
name: review
description: Review code changes before commit
---

Review all uncommitted changes for:
- Code quality
- Security issues
- Test coverage
```

使用技能：

```bash
/skills  # 列出所有技能
/review  # 执行自定义技能
```

---

## 对比其他 CLI 工具

| 特性 | Claude Code | Gemini CLI | Cursor | Aider |
|------|-------------|------------|--------|-------|
| 模型 | Claude 系列 | Gemini 系列 | Claude + 其他 | 多模型 |
| 上下文窗口 | 200K | 1M | 取决于模型 | 取决于模型 |
| 内置工具 | 文件、Shell、Web | 文件、Shell、Web | IDE 集成 | Git |
| MCP 支持 | ✅ | ✅ | ❌ | ❌ |
| Git 工作流 | ✅ 强 | ✅ | ✅ | ✅ 强 |
| Vim 模式 | ✅ | ❌ | ❌ | ❌ |
| 免费额度 | 无（需订阅） | 60次/分钟 | 无 | 无 |

---

## 注意事项

1. **认证要求**：需要 Anthropic 账号或 API Key
2. **终端配置**：macOS 需配置 Option as Meta（见终端设置）
3. **上下文文件**：建议每个项目创建 `CLAUDE.md`
4. **会话管理**：使用 `/resume` 和 `/rewind` 管理长对话
5. **权限模式**：生产环境建议使用 `plan` 模式预览

---

## 相关资源

- **GitHub**: https://github.com/anthropics/claude-code
- **官方文档**: https://code.claude.com/docs/
- **命令参考**: https://code.claude.com/docs/en/commands
- **快捷键参考**: https://code.claude.com/docs/en/interactive-mode
- **CLI 参考**: https://code.claude.com/docs/en/cli-reference
- **Discord**: https://anthropic.com/discord