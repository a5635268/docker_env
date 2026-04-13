# 飞书 MCP 使用指南

## 概述

飞书 MCP（Model Context Protocol）是飞书官方提供的 AI 集成工具，让 Claude Code 等 AI 助手能够直接操作飞书平台的文档、云空间、消息等功能。

**核心优势：**
- ✅ 官方支持，稳定可靠
- ✅ 支持文档读写、云空间管理、消息发送
- ✅ 与 Claude Code 无缝集成
- ✅ 支持用户身份和企业身份两种模式

---

## 使用场景

### 1. 📄 文档同步与管理

**场景描述**：将本地 Markdown 笔记同步到飞书文档

| 功能 | 命令示例 |
|------|----------|
| 创建飞书文档 | "在飞书创建一篇关于 AI 编程的文档" |
| 读取飞书文档 | "读取飞书文档 [链接]" |
| 更新飞书文档 | "将我的笔记更新到飞书文档 [链接]" |
| 导入 Markdown | "将本地 Markdown 文件同步到飞书" |

### 2. 📁 云空间操作

**场景描述**：管理飞书云空间中的文件和文件夹

| 功能 | 命令示例 |
|------|----------|
| 列出文件夹内容 | "列出飞书云空间文件夹 [路径]" |
| 上传文件 | "上传本地文件到飞书云空间" |
| 下载文件 | "下载飞书云空间文件到本地" |
| 创建文件夹 | "在飞书云空间创建文件夹 [名称]" |

### 3. 📚 知识库管理

**场景描述**：管理飞书知识库节点和内容

| 功能 | 命令示例 |
|------|----------|
| 查看知识库结构 | "查看飞书知识库 [链接]" |
| 创建知识库节点 | "在知识库中创建新节点" |
| 搜索知识库内容 | "搜索飞书知识库中关于 [主题] 的内容" |

### 4. 💬 消息与协作

**场景描述**：发送消息、管理日程

| 功能 | 命令示例 |
|------|----------|
| 发送消息 | "发送飞书消息给 [用户]" |
| 创建日程 | "创建飞书日程会议" |
| 查看日程 | "查看我今天的飞书日程" |

### 5. 🔄 自动化工作流

**场景描述**：结合 Claude Code 实现自动化

| 场景 | 描述 |
|------|------|
| 项目文档管理 | 自动将项目 README 同步到飞书知识库 |
| 会议纪要整理 | 将会议记录自动整理并上传飞书 |
| 技术文档归档 | 代码注释和文档自动同步飞书 |
| 团队协作 | 自动推送更新通知到飞书群聊 |

---

## 安装配置

### 前置条件

- Node.js >= 16.20.0
- 飞书开放平台应用（App ID + App Secret）

### 步骤 1：创建飞书应用

1. 访问 [飞书开放平台](https://open.feishu.cn/app)
2. 点击「创建企业自建应用」
3. 填写应用信息：
   - 应用名称：如 `AI 笔记同步`
   - 应用描述：如 `用于 Claude Code 同步 Markdown 笔记`
4. 获取凭证：
   - **App ID**：如 `cli_xxxxxx`
   - **App Secret**：如 `xxxxxx`

### 步骤 2：配置权限

在应用控制台「权限管理」页面开启以下权限：

| 权限名称 | 权限代码 | 用途 |
|----------|----------|------|
| 读取文档 | `docx:document:readonly` | 读取飞书文档内容 |
| 创建、编辑文档 | `docx:document` | 创建和编辑飞书文档 |
| 读取云空间 | `drive:drive:readonly` | 查看文件列表 |
| 云空间操作 | `drive:drive` | 上传、下载文件 |
| 读取知识库 | `wiki:wiki:readonly` | 读取知识库内容 |
| 知识库操作 | `wiki:wiki` | 创建和管理知识库节点 |

### 步骤 3：配置 Claude Code

在 `~/.claude/settings.json` 中添加 MCP 配置：

```json
{
  "mcpServers": {
    "lark-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@larksuiteoapi/lark-mcp",
        "mcp",
        "-a", "cli_xxxxxx",       // 替换为你的 App ID
        "-s", "xxxxxx"            // 替换为你的 App Secret
      ]
    }
  }
}
```

### 步骤 4：重启 Claude Code

配置生效需要重启 Claude Code CLI。

---

## 身份模式说明

### 应用身份（默认）

- 使用 `tenant_access_token`
- 适合操作企业共享资源
- 无需用户登录

### 用户身份（需要 OAuth）

- 使用 `user_access_token`
- 适合操作用户私有资源
- 需要用户登录授权

**启用用户身份模式：**

```bash
# 1. 登录授权
npx -y @larksuiteoapi/lark-mcp login -a cli_xxxxx -s xxxxxx

# 2. 更新配置
{
  "mcpServers": {
    "lark-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "@larksuiteoapi/lark-mcp",
        "mcp",
        "-a", "cli_xxxxxx",
        "-s", "xxxxxx",
        "--oauth",
        "--token-mode", "user_access_token"
      ]
    }
  }
}
```

---

## 常用命令

### 文档操作

| 场景 | Claude Code 命令 |
|------|------------------|
| 创建文档 | "创建飞书文档 [标题]，内容为..." |
| 读取文档 | "读取飞书文档 https://xxx.feishu.cn/docx/xxx" |
| 更新文档 | "更新飞书文档 [链接]，添加以下内容..." |
| 查看文档列表 | "列出飞书云空间中的文档" |

### 云空间操作

| 场景 | Claude Code 命令 |
|------|------------------|
| 创建文件夹 | "在飞书云空间创建文件夹 [名称]" |
| 上传文件 | "上传本地文件 [路径] 到飞书云空间" |
| 下载文件 | "下载飞书文件 [链接] 到本地 [路径]" |
| 移动文件 | "将飞书文件 [链接] 移动到文件夹 [路径]" |

### 知识库操作

| 场景 | Claude Code 命令 |
|------|------------------|
| 查看知识库 | "查看飞书知识库 https://xxx.feishu.cn/wiki/xxx" |
| 创建节点 | "在知识库 [链接] 创建新节点 [标题]" |
| 搜索内容 | "搜索飞书知识库中关于 [关键词] 的内容" |

---

## 最佳实践

### 1. Markdown 同步工作流

```mermaid
graph LR
    A[本地 Markdown] --> B[Claude Code]
    B --> C[飞书 MCP]
    C --> D[飞书文档]
    D --> E[团队共享]
```

**推荐流程：**
1. 本地编写 Markdown 笔记
2. Claude Code 解析内容
3. 通过飞书 MCP 创建/更新飞书文档
4. 团队成员实时查看更新

### 2. 项目文档管理

**建议结构：**
```
飞书知识库/
├── 项目概览/
│   ├── README（自动同步）
│   └── 需求文档
├── 技术文档/
│   ├── API 文档
│   └── 架构设计
└── 会议纪要/
    └── 自动整理上传
```

### 3. 安全建议

- 🔐 使用专用飞书应用，不要使用主账号
- 🔐 定期检查权限配置
- 🔐敏感文档使用用户身份模式
- 🔐 限制应用的访问范围

---

## 故障排除

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 权限不足 | 未开启对应权限 | 在飞书开放平台申请权限 |
| 文档无法读取 | 文档未共享给应用 | 将文档共享给应用或使用用户身份 |
| MCP 连接失败 | Node.js 版本过低 | 升级到 Node.js >= 16.20.0 |
| 登录超时 | OAuth 回调地址错误 | 设置回调地址为 `http://localhost:3000/callback` |

### 调试命令

```bash
# 检查 MCP 是否正常
npx -y @larksuiteoapi/lark-mcp --help

# 查看当前用户会话
npx -y @larksuiteoapi/lark-mcp whoami

# 重新登录
npx -y @larksuiteoapi/lark-mcp login -a cli_xxxxx -s xxxxxx
```

---

## 相关链接

- [飞书开放平台](https://open.feishu.cn/)
- [官方 GitHub 仓库](https://github.com/larksuite/lark-openapi-mcp)
- [官方文档](https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/mcp_integration/mcp_introduction)
- [权限列表参考](https://open.feishu.cn/document/home/introduction-to-scope-and-authorization/availability-of-permissions-for-different-app-types)

---

## 与其他方案对比

| 方案 | 类型 | 优势 | 劣势 |
|------|------|------|------|
| **飞书官方 MCP** | MCP Server | 官方支持、功能全面 | 需要创建应用 |
| **lark-skills** | MCP + Skills | 包含 AI 指令、更易用 | 非官方、功能有限 |
| **feishu2md** | CLI 工具 | 简单直接 | 仅导出、无 AI 集成 |

---

## 总结

飞书 MCP 是连接 Claude Code 与飞书平台的最佳方式，适合：
- 📝 Markdown 笔记同步到飞书
- 📂 项目文档自动化管理
- 🤝 团队协作与知识共享
- 🔄 自动化工作流集成

**一句话总结：** Claude Code + 飞书 MCP = 本地笔记自动同步团队知识库。