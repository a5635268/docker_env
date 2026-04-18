# Codex CLI 使用指南

> 最后更新：2026-04-16

OpenAI Codex CLI 官方文档：https://developers.openai.com/codex/cli/

---

## 目录

1. [简介](#1-简介)
2. [安装](#2-安装)
3. [快速开始](#3-快速开始)
4. [核心命令参考](#4-核心命令参考)
5. [交互式 Slash 命令](#5-交互式-slash-命令)
6. [使用场景](#6-使用场景)
7. [与 Claude Code 对比](#7-与-claude-code-对比)
8. [最佳实践](#8-最佳实践)
9. [常见问题](#9-常见问题)

---

## 1. 简介

### 什么是 Codex CLI

Codex CLI 是 OpenAI 推出的命令行 AI 编程助手，作为轻量级编码 agent 在终端中运行。它能够：

- **读取仓库代码** - 理解项目结构和现有代码
- **自动编写代码** - 根据自然语言指令生成和修改代码
- **执行命令** - 运行 shell 命令、测试、构建等
- **迭代开发** - 多轮对话完成复杂任务

### 技术特点

| 特性 | 说明 |
|------|------|
| 开发语言 | Rust |
| 运行环境 | 本地终端 |
| UI 模式 | 全屏 TUI / 纯文本 |
| 核心能力 | 代码理解、编辑、执行 |
| 会话管理 | 支持保存和恢复历史会话 |

### 适用场景

- 快速原型开发
- 代码重构和优化
- 添加新功能或修复 bug
- 生成测试代码
- 编写文档和注释
- 学习新技术和代码库

---

## 2. 安装

### 方式一：npm 安装（推荐）

```bash
npm install -g @openai/codex
```

### 方式二：Homebrew 安装（macOS）

```bash
brew install --cask codex
```

### 方式三：源码安装

```bash
git clone https://github.com/openai/codex.git
cd codex
cargo install --path .
```

### 验证安装

```bash
codex --version
```

---

## 3. 快速开始

### 3.1 配置 API 密钥

```bash
export OPENAI_API_KEY="sk-..."
```

或使用配置文件：

```bash
codex config set api_key "sk-..."
```

### 3.2 启动 Codex CLI

```bash
# 在当前目录启动
codex

# 指定工作目录
codex --path /path/to/project

# 带提示词启动
codex "为这个项目添加单元测试"
```

### 3.3 首次使用

1. 进入项目目录
2. 运行 `codex`
3. 输入任务描述，如："帮我创建一个简单的 HTTP 服务器"
4. 查看 AI 生成的代码和执行结果
5. 确认或拒绝变更

---

## 4. 核心命令参考

### 4.1 启动参数

| 参数 | 简写 | 说明 | 示例 |
|------|------|------|------|
| `--path <dir>` | `-p` | 设置工作目录 | `codex --path ./my-project` |
| `--profile <name>` | | 指定配置配置文件 | `codex --profile production` |
| `--model <name>` | `-m` | 指定 AI 模型 | `codex --model gpt-4` |
| `--oss` | | 使用本地 OSS 模型 | `codex --oss` |
| `--no-alternate-screen` | | 禁用 TUI 全屏模式 | `codex --no-alternate-screen` |
| `-c <key=value>` | | 配置参数 | `codex -c timeout=300` |
| `--help` | `-h` | 显示帮助信息 | `codex --help` |
| `--version` | `-v` | 显示版本号 | `codex --version` |

### 4.2 配置命令

```bash
# 查看当前配置
codex config list

# 设置配置项
codex config set api_key "sk-..."
codex config set model "gpt-4"
codex config set timeout 300

# 删除配置项
codex config delete model

# 导出配置
codex config export > config.json
```

### 4.3 会话管理

```bash
# 列出历史会话
codex sessions list

# 查看会话详情
codex sessions show <session-id>

# 恢复会话
codex --resume <session-id>

# 删除会话
codex sessions delete <session-id>

# 导出会话
codex sessions export <session-id> > transcript.md
```

---

## 5. 交互式 Slash 命令

在 Codex CLI 交互会话中可用的命令：

### 5.1 会话控制

| 命令 | 说明 | 使用场景 |
|------|------|----------|
| `/new` | 开始新会话 | 换个话题重新开始 |
| `/resume` | 恢复历史会话 | 继续之前的对话 |
| `/clear` | 清空当前对话历史 | 清理上下文重新开始 |
| `/compact` | 上下文压缩 | 避免触发上下文限制 |

### 5.2 模型与配置

| 命令 | 说明 | 使用场景 |
|------|------|----------|
| `/model <name>` | 切换模型 | 更换 AI 模型 |
| `/fast` | 切换 Fast 模式 | 快速响应模式 |
| `/status` | 查看状态 | 检查模型、权限、token 使用情况 |
| `/config` | 查看配置 | 检查当前配置 |

### 5.3 代码操作

| 命令 | 说明 | 使用场景 |
|------|------|----------|
| `/plan` | 进入计划模式 | 规划复杂任务 |
| `/review` | 审查代码变更 | 代码审查 |
| `/diff` | 显示 git 差异 | 查看代码变更 |
| `/mention <file>` | 引用文件 | 让 AI 关注特定文件 |
| `/init` | 初始化 AGENTS.md | 项目初始化 AI 上下文 |

### 5.4 使用示例

```
> /status
当前模型：gpt-4
权限模式：确认执行
Token 使用：12,450 / 100,000

> /model gpt-4o
已切换到 gpt-4o 模型

> /mention src/main.go
已引用 src/main.go，AI 将重点关注此文件

> /diff
显示本次会话的代码变更...
```

---

## 6. 使用场景

### 6.1 快速原型开发

```bash
codex "创建一个 Python Flask 应用，包含 /hello 和 /api/data 两个端点"
```

**适用场景：**
- 新项目脚手架
- 概念验证（POC）
- 技术调研

### 6.2 添加新功能

```bash
codex "给这个项目添加用户认证功能，使用 JWT"
```

**适用场景：**
- 功能迭代开发
- 集成第三方服务
- 添加 API 端点

### 6.3 代码重构

```bash
codex "将这个文件的函数重构为更简洁的形式，保持功能不变"
```

**适用场景：**
- 代码优化
- 提取公共逻辑
- 改善代码结构

### 6.4 调试修复

```bash
codex "这个测试失败了，帮我分析原因并修复"
```

**适用场景：**
- Bug 排查
- 测试修复
- 性能优化

### 6.5 生成测试

```bash
codex "为 src/auth 模块编写完整的单元测试"
```

**适用场景：**
- 补充测试覆盖
- 生成测试数据
- E2E 测试脚本

### 6.6 文档编写

```bash
codex "为这个模块生成 API 文档，使用 Markdown 格式"
```

**适用场景：**
- README 编写
- API 文档
- 代码注释

---

## 7. 与 Claude Code 对比

| 特性 | Codex CLI | Claude Code |
|------|-----------|-------------|
| 开发商 | OpenAI | Anthropic |
| 底层模型 | GPT-4 系列 | Claude 4 系列 |
| 安装方式 | npm / brew | npm / 独立应用 |
| 界面风格 | TUI 全屏 / 文本 | TUI 全屏 |
| 中文支持 | 良好 | 优秀 |
| 代码理解 | 强 | 极强 |
| 命令执行 | 需确认 | 需确认 |
| 会话恢复 | 支持 | 支持 |
| 本地模型 | 支持（--oss） | 不支持 |
| 价格 | 按 OpenAI API 计费 | 订阅制 / API 计费 |
| MCP 支持 | 有限 | 完整生态 |
| 技能系统 | 无 | 支持自定义技能 |

### 选择建议

**选择 Codex CLI：**
- 已有 OpenAI API 额度
- 需要本地模型支持
- 偏好 GPT-4 的输出风格

**选择 Claude Code：**
- 需要更强的代码理解能力
- 需要 MCP 工具集成
- 需要自定义技能系统
- 需要更好的中文支持

---

## 8. 最佳实践

### 8.1 提示词技巧

- **具体明确**：说明要什么，不要只说什么不要
- **分步请求**：复杂任务拆分为多个小请求
- **提供上下文**：引用相关文件帮助 AI 理解
- **设定边界**：说明约束条件和预期结果

### 8.2 安全实践

- 始终审查 AI 生成的代码变更
- 谨慎批准命令执行
- 敏感操作前备份代码
- 使用 git 追踪所有变更

### 8.3 效率技巧

- 使用 `/mention` 引用关键文件
- 使用 `/plan` 规划复杂任务
- 定期使用 `/compact` 清理上下文
- 保存常用会话以便恢复

### 8.4 会话管理

- 为不同任务使用独立会话
- 定期导出重要会话记录
- 清理不再需要的历史会话

---

## 9. 常见问题

### Q1: 如何查看剩余 token 额度？

```bash
/status
```

### Q2: 如何切换模型？

```bash
/model <模型名称>
```

### Q3: 如何恢复之前的会话？

```bash
codex sessions list
codex --resume <session-id>
```

### Q4: 如何在非交互模式下运行？

```bash
codex "执行这个任务" --no-interactive
```

### Q5: 如何配置代理？

```bash
export HTTP_PROXY="http://proxy:port"
export HTTPS_PROXY="http://proxy:port"
```

### Q6: 如何禁用自动命令执行？

在配置中设置确认模式：
```bash
codex config set auto_execute false
```

### Q7: 会话记录保存在哪里？

默认保存在 `~/.codex/sessions/` 目录。

---

## 参考资源

- [官方文档](https://developers.openai.com/codex/cli/)
- [GitHub 仓库](https://github.com/openai/codex)
- [命令参考](https://developers.openai.com/codex/cli/reference)
- [功能介绍](https://developers.openai.com/codex/cli/features)

---

*文档创建时间：2026-04-16*
