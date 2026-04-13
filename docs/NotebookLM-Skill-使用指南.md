# NotebookLM Claude Code Skill 使用指南

## 概述

NotebookLM Skill 是一个让 Claude Code 直接与 Google NotebookLM 对话的工具，基于你上传的文档提供有来源依据的智能回答。

**核心优势：**
- **零幻觉**：仅基于你上传的文档回答
- **零 Token 消耗**：不需要将文档喂给 Claude
- **智能综述**：Gemini 理解跨文档关联
- **引用溯源**：每个回答附带来源引用

---

## 使用场景

### 1. 大型文档库查询
- 技术手册、API 文档、规范文档
-  workshop/manual 等参考资料
- 多篇研究论文、技术报告

### 2. 代码开发与文档对照
- 查询框架官方文档的最佳实践
- 对照 API 规范编写代码
- 理解复杂库的使用方式

### 3. 个人知识库激活
- 笔记软件中的吃灰内容
- 收藏的技术文章
- 项目文档和会议纪要

### 4. 多源信息整合
- 同时上传 50+ 相关文档
- Gemini 自动关联跨文档信息
- 生成综合性回答

---

## 安装步骤

```bash
# 1. 进入 skills 目录
cd ~/.claude/skills

# 2. 克隆仓库
git clone https://github.com/PleasePrompto/notebooklm-skill notebooklm

# 3. 完成（首次使用时自动安装依赖）
```

---

## 快速开始

### 步骤 1：认证（一次性）

在 Claude Code 中输入：
```
"Set up NotebookLM authentication"
```
或手动执行：
```bash
cd ~/.claude/skills/notebooklm
python3 scripts/run.py auth_manager.py setup
```

> 会打开 Chrome 窗口，登录 Google 账号

### 步骤 2：创建知识库

1. 访问 [notebooklm.google.com](https://notebooklm.google.com)
2. 创建新 Notebook
3. 上传文档（PDF、Markdown、网页、YouTube 等）
4. 点击 **Share** → **Anyone with link** → 复制链接

### 步骤 3：添加 Notebook 到库

**智能添加（推荐）**：
```
"Query this notebook and add it to my library: [URL]"
```
Claude 会自动查询内容并添加合适的元数据

**手动添加**：
```bash
python3 scripts/run.py notebook_manager.py add \
  --url "https://notebooklm.google.com/notebook/..." \
  --name "描述性名称" \
  --description "文档内容概述" \
  --topics "主题 1，主题 2，主题 3"
```

### 步骤 4：开始查询

```
"Ask my API docs about authentication"
```
或：
```bash
python3 scripts/run.py ask_question.py --question "你的问题"
```

---

## 常用命令

| 命令 | 功能 |
|------|------|
| `python3 scripts/run.py auth_manager.py status` | 检查认证状态 |
| `python3 scripts/run.py auth_manager.py setup` | 设置认证（打开浏览器） |
| `python3 scripts/run.py notebook_manager.py list` | 列出所有 Notebook |
| `python3 scripts/run.py notebook_manager.py add --url URL --name NAME --description DESC --topics TOPICS` | 添加 Notebook |
| `python3 scripts/run.py notebook_manager.py activate --id ID` | 设置活跃 Notebook |
| `python3 scripts/run.py ask_question.py --question "问题"` | 查询当前 Notebook |
| `python3 scripts/run.py ask_question.py --question "问题" --notebook-id ID` | 查询指定 Notebook |
| `python3 scripts/run.py cleanup_manager.py --preserve-library` | 清理浏览器数据（保留库） |

---

## 工作原理

```
用户任务 → Claude 加载 Skill → 启动浏览器 → 访问 NotebookLM
→ Gemini 阅读文档并生成回答 → Claude 获取回答 → 编写正确代码
```

### 架构

```
~/.claude/skills/notebooklm/
├── SKILL.md              # Skill 指令
├── scripts/
│   ├── ask_question.py   # 查询接口
│   ├── notebook_manager.py # 库管理
│   ├── auth_manager.py   # 认证管理
│   └── run.py            # 统一执行器
├── .venv/                # Python 虚拟环境
└── data/
    ├── library.json      # Notebook 库
    └── browser_state/    # 浏览器会话
```

---

## 最佳实践

### 1. 使用 `run.py` 执行器
```bash
# ✅ 正确
python3 scripts/run.py auth_manager.py status

# ❌ 错误（跳过虚拟环境）
python3 scripts/auth_manager.py status
```

### 2. 利用追问机制
每个 NotebookLM 回答结尾会提示：
> "Is that ALL you need to know?"

Claude 应继续追问直到信息完整：
```bash
python3 scripts/run.py ask_question.py \
  --question "Follow-up: 关于刚才的认证流程，具体如何实现？"
```

### 3. 为 Notebook 添加详细元数据
添加时提供：
- **描述**：详细说明了什么内容
- **主题**：便于后续搜索定位

### 4. 检查认证状态
遇到问题先检查：
```bash
python3 scripts/run.py auth_manager.py status
```

---

## 限制与注意事项

| 限制 | 说明 |
|------|------|
| **仅限本地 Claude Code** | Web UI 沙箱无网络访问权限 |
| **无会话持久化** | 每次查询打开新浏览器 |
| **Google 限流** | 免费账户每日 50 次查询 |
| **需手动上传文档** | 必须先上传到 NotebookLM |
| **需分享 Notebook** | Notebook 必须设置为公开链接 |

---

## 故障排除

### 认证失败
```bash
# 重置认证
python3 scripts/run.py auth_manager.py clear
# 重新设置
python3 scripts/run.py auth_manager.py setup
```

### 浏览器崩溃
```bash
python3 scripts/run.py cleanup_manager.py --preserve-library
```

### 依赖问题
```bash
cd ~/.claude/skills/notebooklm
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 本地数据存储

```
~/.claude/skills/notebooklm/data/
├── library.json          # Notebook 库（包含元数据）
├── auth_info.json        # 认证状态
└── browser_state/        # Cookie 和会话数据
```

**安全提示**：`data/` 目录包含敏感数据，已通过 `.gitignore` 保护，请勿分享。

---

## 与 MCP Server 对比

| 特性 | NotebookLM Skill | NotebookLM MCP |
|------|------------------|----------------|
| 协议 | Claude Skills | Model Context Protocol |
| 安装 | Git clone | `claude mcp add` |
| 会话 | 每次新浏览器 | 持久化聊天 |
| 兼容性 | 仅本地 Claude Code | Claude Code/Codex/Cursor 等 |
| 语言 | Python | TypeScript |

---

## 总结

**没有这个 Skill**：
1. 打开 NotebookLM 网页
2. 手动输入问题
3. 复制回答
4. 粘贴到 Claude Code
5. 重复上述步骤...

**有了这个 Skill**：
1. 直接向 Claude 提问
2. Claude 自动查询 NotebookLM
3. 立即获取答案并编写代码

停止复制粘贴，开始精准问答。
