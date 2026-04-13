# 滴答清单 MCP 使用指南

> 在 Claude Code 中通过 MCP 协议连接滴答清单，实现 AI 智能任务管理

---

## 概述

滴答清单 MCP 是目前最简单的官方 MCP 接入方案之一：
- ✅ 无需安装依赖（Node.js/Python）
- ✅ 无需申请 API Key
- ✅ 一行命令配置
- ✅ 官方托管服务

---

## 快速开始

### 前置要求

| 项目 | 说明 |
|------|------|
| Claude Code | `claude --version` 验证安装 |
| 滴答清单账号 | 访问 [dida365.com](https://dida365.com) 或 [ticktick.com](https://ticktick.com) 注册 |

### 配置步骤

**步骤 1：添加 MCP 服务器**

```bash
claude mcp add --transport http --scope user dida365 https://mcp.dida365.com
```

**参数说明：**

| 参数 | 说明 |
|------|------|
| `--transport http` | 使用 HTTP 传输协议（Streamable HTTP） |
| `--scope user` | 全局配置，所有项目可用（推荐） |
| `--scope local` | 仅当前工作目录可用 |
| `dida365` | 服务器名称（可自定义） |
| URL | 滴答清单官方 MCP 地址 |

**步骤 2：OAuth 授权**

```bash
claude          # 启动 Claude Code
/mcp            # 触发授权流程
```

授权流程：
1. 浏览器自动打开 → 滴答清单授权页面
2. 登录账号（如未登录）
3. 确认授权信息
4. 完成后返回终端

---

## 验证连接

**检查 MCP 服务器列表**
```bash
/mcp list
```

**测试功能**
```bash
请列出我今天的所有任务
```

---

## 使用场景

### 场景 1：创建新任务

```bash
# 简单任务
帮我在"工作"项目中创建一个任务：完成项目报告，截止日期是明天

# 带优先级
帮我在"工作"清单中创建任务：完成报告，截止日期明天下午 3 点，优先级设为高

# 带子任务
帮我创建"学习 Python"任务，并添加子任务：
1. 学习基础语法
2. 完成练习题
3. 做一个小项目
4. 复习和总结
```

### 场景 2：查看待办

```bash
# 今日任务
显示我今天需要完成的所有任务

# 特定日期
列出明天到期的任务

# 高优先级
显示所有高优先级任务
```

### 场景 3：任务管理

```bash
# 完成任务
标记"完成报告"为已完成

# 批量完成
完成"工作"清单中的所有今日任务

# 更新任务
把"项目报告"的截止日期改到周五

# 移动任务
把"买咖啡"移动到"个人"清单
```

### 场景 4：批量操作

```bash
# 批量创建
把这个开发计划拆成任务同步到滴答清单

# 批量更新
把所有下周的任务优先级改为中
```

### 场景 5：任务报告

```bash
# 每日报告
帮我生成一份今日任务报告，包括：
1. 今日到期任务
2. 高优先级任务
3. 已逾期任务
并给出优先级建议

# 周度总结
总结我本周完成的任务
```

---

## 可用工具（17 个）

### 查询任务（6 个）

| 工具 | 说明 |
|------|------|
| `search_task` | 关键词搜索任务 |
| `get_task_by_id` | 根据 ID 获取任务详情 |
| `list_undone_tasks_by_time_query` | 查询时间段未完成任务（today/last24hour/last7day/tomorrow 等） |
| `list_undone_tasks_by_date` | 查询日期范围内未完成任务（最大 14 天） |
| `list_completed_tasks_by_date` | 查询指定清单已完成任务 |
| `filter_tasks` | 多条件组合查询（日期/清单/优先级/标签/状态） |

### 清单查询（4 个）

| 工具 | 说明 |
|------|------|
| `list_projects` | 获取所有清单列表 |
| `get_project_by_id` | 根据 ID 获取清单详情 |
| `get_project_with_undone_tasks` | 获取清单及未完成的任务 |
| `get_task_in_project` | 获取指定清单中的特定任务 |

> ⚠️ **注意**：清单目前仅支持查询，不支持创建/修改/删除清单

### 任务管理（7 个）

| 工具 | 说明 |
|------|------|
| `create_task` | 创建任务（支持标题/描述/日期/优先级/清单/标签） |
| `batch_add_tasks` | 批量创建任务 |
| `complete_task` | 完成指定任务 |
| `complete_tasks_in_project` | 批量完成清单中任务（每次最多 20 个） |
| `update_task` | 修改任务属性 |
| `move_task` | 将任务移动到其他清单 |
| `batch_update_tasks` | 批量修改多个任务属性 |

---

## 暂不支持的功能

以下功能目前在滴答清单 MCP 中**暂不支持**：

- ❌ 清单（项目）的创建、修改和删除
- ❌ 番茄钟功能
- ❌ 日历视图
- ❌ 习惯打卡
- ❌ 协作功能（分享、评论等）

如需使用这些功能，请在滴答清单应用中操作。

---

## 常见问题

### 问题 1：添加 MCP 服务器时提示错误

**可能原因：**
- Claude Code 版本过旧
- 命令格式不正确
- 网络连接问题

**解决方案：**
1. 更新 Claude Code：`claude --version`
2. 检查命令格式，确保包含 `--transport http`
3. 确认网络可访问 `https://mcp.dida365.com`
4. 检查代理设置（如使用代理）

### 问题 2：OAuth 授权失败

**可能原因：**
- 浏览器被系统安全设置阻止
- 网络连接问题
- 防火墙拦截

**解决方案：**
1. 手动复制终端中的授权 URL 到浏览器
2. 检查防火墙设置
3. 尝试不同浏览器
4. Windows 用户尝试以管理员身份运行终端

### 问题 3：授权后仍无法使用

**解决方案：**
1. 运行 `claude mcp list` 检查状态
2. 运行 `claude mcp get dida365` 查看详细配置
3. 重启 Claude Code 会话
4. 删除后重新添加：
   ```bash
   claude mcp remove dida365
   claude mcp add --transport http --scope user dida365 https://mcp.dida365.com
   ```

### 问题 4：Token 过期

**解决方案：**
1. 重新运行 `/mcp` 命令
2. OAuth 支持 Token 自动刷新，正常情况下无需重复登录

### 问题 5：AI 操作不符合预期

**解决方案：**
1. **更详细描述**：指定清单名称、截止时间、优先级
2. **分步操作**：复杂操作分成多个简单步骤
3. **检查反馈**：仔细查看 AI 返回的结果

---

## 进阶技巧

### 技巧 1：每日任务报告工作流

每天早上运行：
```bash
帮我生成一份今日任务报告，包括：
1. 今日到期任务
2. 高优先级任务
3. 已逾期任务
并给出优先级建议
```

### 技巧 2：与其他 MCP 配合

同时配置多个 MCP 服务器：
- GitHub MCP：管理代码仓库
- TickTick MCP：管理任务
- Notion MCP：管理笔记

让 Claude 在不同工具间协调工作。

### 技巧 3：团队配置

在团队项目中，将 MCP 配置添加到 `.mcp.json` 文件：

```json
{
  "mcpServers": {
    "dida365": {
      "url": "https://mcp.dida365.com",
      "transport": "http"
    }
  }
}
```

---

## 配置文件位置

| 配置类型 | 文件路径 |
|----------|----------|
| 用户配置（全局） | `~/.claude.json` |
| 项目配置（局部） | `项目根目录/.mcp.json` |

**查看配置：**
```bash
claude mcp list
claude mcp get dida365
```

---

## 第三方方案（可选）

如果客户端不支持 Streamable HTTP 协议，可考虑社区方案：

| 项目 | 特点 |
|------|------|
| `jacepark12/ticktick-mcp` | 支持 stdio 传输，功能完整 |
| `Code-MonkeyZhang/ticktick-mcp-enhanced` | 增强版本 |
| `ZH1754629545/dida365-mcp-servers` | 基于官方文档开发 |

> ⚠️ **注意**：第三方方案需要自行搭建服务器、申请 API Key，配置较复杂。**推荐优先使用官方方案**。

---

## 参考资源

- [滴答清单 MCP 官方文档](https://mcp.dida365.com)
- [滴答清单官网（国内）](https://dida365.com)
- [TickTick 官网（国际）](https://ticktick.com)
- [Claude Code 官方文档](https://claude.ai/code)
- [MCP 协议官网](https://modelcontextprotocol.io)

---

*文档生成时间：2026-04-09*
