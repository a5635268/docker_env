# 长时间运行 Agent 的有效 Harness 设计

> **原文**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
> **作者**: Justin Young (Anthropic)
> **翻译日期**: 2026-04-24

---

## 核心挑战

随着 AI Agent 能力增强，开发者越来越多地要求它们承担需要跨越数小时甚至数天的复杂任务。然而，让 Agent 在多个上下文窗口中保持持续进展仍是一个开放性问题。

**问题本质**：Agent 必须在离散的会话中工作，每个新会话开始时都没有之前工作的记忆。想象一个软件项目由轮班工程师组成，每位新工程师到达时都不知道上一班发生了什么。

---

## Agent 失败模式

### 模式一：一次性尝试过多

Agent 倾向于尝试一次性完成整个任务（one-shot）。这导致：
- 在实现过程中耗尽上下文
- 下一个会话开始时功能半完成且未文档化
- Agent 需要猜测发生了什么，花费大量时间恢复基础功能

### 模式二：过早宣布完成

项目进行一段时间后，Agent 看到已有进展就宣布任务完成，实际上还有很多功能未实现。

---

## 双重解决方案

Anthropic 开发了两部分解决方案：

| Agent 类型 | 职责 | 输出产物 |
|-----------|------|---------|
| **Initializer Agent** | 设置初始环境 | init.sh、claude-progress.txt、初始 git commit |
| **Coding Agent** | 增量推进 | 结构化更新、git commit、进度记录 |

**核心洞察**：通过 `claude-progress.txt` 文件配合 git 历史，让 Agent 在新上下文窗口启动时快速理解工作状态。

---

## 环境管理关键组件

### 1. Feature List（功能清单）

解决 Agent 一次性尝试过多或过早宣布完成的问题。

```json
{
  "category": "functional",
  "description": "New chat button creates a fresh conversation",
  "steps": [
    "Navigate to main interface",
    "Click the 'New Chat' button",
    "Verify a new conversation is created",
    "Check that chat area shows welcome state",
    "Verify conversation appears in sidebar"
  ],
  "passes": false
}
```

**设计要点**：
- 使用 JSON 格式（比 Markdown 更不容易被 Agent 错误修改）
- 所有功能初始标记为 `passes: false`
- Coding Agent 只允许修改 `passes` 字段
- 强指令约束："不允许删除或编辑测试，这会导致功能缺失或错误"

### 2. Incremental Progress（增量进展）

**关键原则**：一次只处理一个功能。

每个会话结束时必须：
- 提交 git commit（描述性消息）
- 更新 progress 文件
- 保持环境"干净状态"（无重大 bug、代码有序、文档完善）

**干净状态定义**：适合合并到主分支的代码状态，新开发者可以轻松开始新功能而不需要先清理无关问题。

### 3. Testing（测试验证）

Agent 倾向于标记功能完成但未进行端到端测试。

**解决方案**：
- 显式要求使用浏览器自动化工具（如 Puppeteer MCP）
- 按人类用户方式测试所有功能
- 通过截图验证功能正常

**效果**：Agent 能识别并修复代码层面不明显的 bug。

**遗留问题**：
- Agent 视觉能力限制
- 浏览器自动化工具无法识别原生 alert modal
- 依赖 modal 的功能容易出 bug

---

## 快速启动流程

每个 Coding Agent 会话启动时的步骤：

| 步骤 | 命令/操作 | 目的 |
|-----|----------|------|
| 1 | `pwd` | 确认工作目录 |
| 2 | 读取 git log 和 progress 文件 | 了解最近工作 |
| 3 | 读取 feature list | 选择最高优先级未完成功能 |
| 4 | 执行 init.sh | 启动开发服务器 |
| 5 | 基础端到端测试 | 验证现有功能正常 |

**典型会话启动示例**：

```
[Assistant] I'll start by getting my bearings...
[Tool Use] pwd
[Tool Use] read claude-progress.txt
[Tool Use] read feature_list.json
[Assistant] Let me check git log...
[Tool Use] git log --oneline -20
[Assistant] Now let me start the servers...
[Tool Use] ./init.sh
[Assistant] Excellent! Now let me verify fundamental features...
[Tests basic functionality]
[Assistant] Based on my verification, core features are working...
[Starts work on new feature]
```

---

## 失败模式与解决方案对照表

| 失败模式 | Initializer Agent 行为 | Coding Agent 行为 |
|---------|----------------------|------------------|
| **过早宣布项目完成** | 创建结构化功能清单文件（JSON） | 会话开始读取清单，选择单一功能工作 |
| **留下 bug 或未文档化状态** | 创建 git repo 和进度笔记文件 | 开始时读取进度文件和 git log，运行基础测试；结束时写 git commit 和进度更新 |
| **过早标记功能完成** | 创建功能清单 | 自验证所有功能，仅在严格测试后标记 passing |
| **花费时间理解如何运行** | 编写 init.sh 启动脚本 | 会话开始时读取 init.sh |

---

## 最佳实践总结

### 环境设置（Initializer Agent）

```
项目根目录/
├── init.sh              # 启动开发服务器脚本
├── claude-progress.txt  # 进度日志
├── feature_list.json    # 功能清单（JSON 格式）
└── .git/                # Git 仓库（初始 commit）
```

### Coding Agent 会话循环

```
1. 定位 → pwd
2. 回顾 → git log + progress file
3. 选任务 → feature_list.json（最高优先级未完成）
4. 启环境 → init.sh
5. 验现状 → 基础端到端测试
6. 开发 → 单一功能增量实现
7. 清理 → git commit + progress update
```

### 关键指令约束

- ✅ "一次只处理一个功能"
- ✅ "仅修改 passes 字段"
- ✅ "使用浏览器自动化工具端到端测试"
- ❌ "不允许删除或编辑测试"
- ❌ "不允许一次性尝试完成整个项目"

---

## 未来方向

### 未解决问题

1. **单 Agent vs 多 Agent 架构**
   - 单一通用 Coding Agent 是否最优？
   - 专用 Agent（测试、QA、代码清理）可能表现更好？

2. **领域泛化**
   - 当前优化针对全栈 Web 开发
   - 科学研究、金融建模等其他领域适用性待验证

---

## 核心启示

| 问题 | 解决思路 |
|-----|---------|
| 上下文窗口有限 | 外部持久化存储（progress file + git） |
| Agent 无记忆 | 结构化启动流程快速定位 |
| 倾向过度乐观 | 功能清单约束 + 强指令 |
| 验证不充分 | 强制端到端测试 |

**一句话总结**：通过结构化环境初始化 + 增量进展约束 + 强制测试验证，实现 Agent 跨上下文窗口的持续有效工作。

---

## 相关资源

[Claude Agent SDK Quickstart](https://github.com/anthropics/claude-quickstarts)

[Claude 4 Prompting Guide](https://docs.anthropic.com/claude/docs/prompting-guide)