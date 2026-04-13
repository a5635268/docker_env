# 飞书 CLI 使用指南

## 概述

飞书 CLI 是飞书官方在 2026 年 3 月开源的命令行工具，用 Go 语言编写，MIT 协议。它将飞书的核心业务能力全部拆成可供命令行调用的接口，覆盖文档、日历、消息、表格、任务等 **11 个业务域，200+ 条命令**。

**核心优势：**
- ✅ 官方开源，持续维护
- ✅ 原生支持 **Markdown 与飞书文档双向无损转换**
- ✅ 标题、列表、代码块、表格、图片等 **40+ 种内容块** 保留
- ✅ 与 Claude Code 深度集成（官方 Skills）
- ✅ 扫码授权，无需手动审核

---

## 两种飞书工具对比

| 工具 | 类型 | 主要用途 | 安装方式 |
|------|------|----------|----------|
| **`@larksuite/cli`** | CLI 工具 | 命令行直接操作，Markdown 同步 | `npm install -g @larksuite/cli` |
| `@larksuiteoapi/lark-mcp` | MCP Server | AI 工具自动调用 | `npx @larksuiteoapi/lark-mcp` |

**推荐使用飞书 CLI**，因为它原生支持 Markdown 转换，更适合本地笔记同步场景。

---

## 使用场景

### 1. 📝 一键同步本地 Markdown 到飞书

```bash
# 同步单个 Markdown 文件
lark-cli docs create \
  --title "我的文档标题" \
  --markdown "$(cat /path/to/your/file.md)"

# 指定同步到特定文件夹
lark-cli docs create \
  --title "文档标题" \
  --markdown "$(cat ./notes/example.md)" \
  --folder "fldxxxxxxxx"
```

### 2. 🔄 批量同步脚本

```bash
#!/bin/bash
# sync-to-feishu.sh
# 批量同步指定目录下的所有 Markdown 文件

SOURCE_DIR="$1"  # 本地 markdown 文件夹
FOLDER_TOKEN="$2" # 飞书目标文件夹 token

for file in "$SOURCE_DIR"/*.md; do
    filename=$(basename "$file" .md)
    echo "正在同步: $filename"
    lark-cli docs create \
        --title "$filename" \
        --markdown "$(cat "$file")" \
        --folder "$FOLDER_TOKEN"
done
```

### 3. 🤖 AI 自动同步（推荐）

安装飞书 Skills 后，直接用自然语言操作：

```
"帮我把本地的 ~/notes/项目方案.md 同步到飞书「工作文档」文件夹里"
```

AI 会自动调用 CLI 完成同步，并返回文档链接。

### 4. 📂 其他常用场景

| 场景 | 命令 |
|------|------|
| 列出文件夹 | `lark-cli drive folder list` |
| 查看日程 | `lark-cli calendar +agenda` |
| 发送消息 | `lark-cli im message create` |
| 查看任务 | `lark-cli task list` |
| 搜索用户 | `lark-cli contact +search-user --query "John"` |

---

## 安装配置

### 步骤 1：安装飞书 CLI

```bash
npm install -g @larksuite/cli
```

### 步骤 2：初始化配置（扫码授权）

```bash
lark-cli config init --new
```

会弹出二维码，用飞书 App 扫码授权即可完成配置。

### 步骤 3：安装飞书 Skills（用于 Claude Code）

```bash
npx skills add larksuite/cli -g -y
```

这会安装 **22 个 Skills**，覆盖飞书所有业务域。

---

## 已安装的飞书 Skills

| Skill | 功能 | 命令示例 |
|-------|------|----------|
| `lark-doc` | 📄 文档操作 | 创建、读取、编辑飞书文档 |
| `lark-drive` | 📁 云空间 | 上传、下载、管理文件 |
| `lark-wiki` | 📚 知识库 | 创建和管理知识库节点 |
| `lark-sheets` | 📊 电子表格 | 读写表格数据 |
| `lark-slides` | 🎞️ 演示文稿 | 创建幻灯片 |
| `lark-calendar` | 📅 日历 | 管理日程和会议 |
| `lark-im` | 💬 消息 | 发送消息和创建群聊 |
| `lark-task` | ✅ 任务 | 管理任务和待办 |
| `lark-base` | 📋 多维表格 | 操作多维表格数据 |
| `lark-mail` | 📧 邮件 | 管理邮件和文件夹 |
| `lark-vc` | 📹 视频会议 | 创建和管理会议 |
| `lark-whiteboard` | 🎨 白板 | 创建和编辑白板 |
| `lark-approval` | ✅ 审批 | 管理审批流程 |
| `lark-contact` | 👥 联系人 | 搜索和管理联系人 |
| `lark-event` | 📅 事件 | 事件订阅管理 |
| `lark-minutes` | 📝 会议纪要 | 获取会议纪要 |
| `lark-workflow-meeting-summary` | 📋 工作流 | 会议摘要工作流 |
| `lark-workflow-standup-report` | 📋 工作流 | 站会报告工作流 |

---

## Claude Code 使用方法

安装 Skills 后，直接用自然语言操作：

### 文档同步

```
"帮我把本地的 README.md 同步到飞书"
```

```
"创建飞书文档「技术笔记」，内容如下..."
```

```
"读取飞书文档 https://xxx.feishu.cn/docx/xxx"
```

### 云空间管理

```
"列出飞书云空间中的文件夹"
```

```
"上传本地文件 ./report.pdf 到飞书云空间"
```

### 知识库操作

```
"查看飞书知识库 https://xxx.feishu.cn/wiki/xxx"
```

```
"在知识库中创建新节点「API文档」"
```

---

## CLI 命令参考

### 文档操作

```bash
# 创建文档（Markdown 内容）
lark-cli docs create --title "标题" --markdown "$(cat file.md)"

# 创建文档（指定文件夹）
lark-cli docs create --title "标题" --markdown "内容" --folder "fldxxx"

# 读取文档
lark-cli docs content get --doc_id "docxxx"

# 更新文档
lark-cli docs content patch --doc_id "docxxx" --markdown "新内容"
```

### 云空间操作

```bash
# 列出文件夹
lark-cli drive folder list

# 创建文件夹
lark-cli drive folder create --name "新文件夹"

# 上传文件
lark-cli drive file upload --file "./local.pdf" --folder "fldxxx"

# 下载文件
lark-cli drive file download --file_id "filxxx" --output "./local.pdf"
```

### 知识库操作

```bash
# 列出知识库
lark-cli wiki space list

# 创建节点
lark-cli wiki node create --space_id "spaxxx" --title "新节点"
```

---

## 飞书 vs 其他平台对比

| 对比项 | 飞书 CLI | 国内其他平台 |
|--------|----------|-------------|
| **官方 CLI 支持** | ✅ 官方开源，持续维护 | 大多无官方 CLI |
| **Markdown 转换** | ✅ 原生支持，无损转换 | 需第三方工具 |
| **AI Agent 集成** | ✅ 官方提供 Skills，自然语言操作 | 基本没有 |
| **权限管理** | ✅ 扫码授权，无需手动审核 | 流程复杂 |
| **生态覆盖** | 文档、表格、日历、消息、任务全支持 | 功能碎片化 |

---

## 完整工作流示例

假设你本地有一个 `docs/` 文件夹，里面全是 Markdown 笔记，想要一键同步到飞书：

```bash
# 1. 获取目标文件夹 ID（让 AI 帮你做）
# 在 Claude Code 中说：「帮我找到飞书里叫「技术笔记」的文件夹 ID」

# 2. 一键同步
for file in ./docs/*.md; do
    lark-cli docs create \
        --title "$(basename "$file" .md)" \
        --markdown "$(cat "$file")" \
        --folder "fldxxxxxxxx"
done
```

---

## 配置文件位置

```
/Users/mac/.lark-cli/config.json
```

查看当前配置：
```bash
lark-cli config show
```

---

## 故障排除

### 常见问题

| 问题 | 解决方案 |
|------|----------|
| 未授权 | `lark-cli config init --new` 重新扫码授权 |
| 权限不足 | 在飞书开放平台申请对应权限 |
| 找不到文件夹 | 使用 `lark-cli drive folder list` 查看文件夹列表 |

### 调试命令

```bash
# 检查 CLI 健康状态
lark-cli doctor

# 查看配置
lark-cli config show

# 查看 API 方法参数
lark-cli schema docs.create
```

---

## 相关链接

- [官方 GitHub](https://github.com/larksuite/cli)
- [飞书开放平台](https://open.feishu.cn/)
- [官方文档](https://open.feishu.cn/document/)
- [Skills 详情](https://skills.sh/larksuite/cli)

---

## 总结

**飞书 CLI 是目前国内平台中，对「本地 Markdown 一键同步」需求支持最完善的选择。**

- 📝 原生支持 Markdown 无损转换
- 🤖 与 Claude Code 深度集成
- 🔐 扫码授权，无需手动审核
- 🆓 完全免费，MIT 协议

**一句话总结：飞书 CLI + Claude Code Skills = 本地 Markdown 自动同步飞书知识库。**