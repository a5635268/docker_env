# Harness Skills 使用指南

> **创建日期**: 2026-04-25
> **全局安装**: `~/.claude/skills/`

---

## 概述

Harness 系统是基于 Anthropic 文章 [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) 实现的 Claude Code Skills 框架，解决 AI Agent 跨上下文窗口持续工作的挑战。

**核心解决的问题**：
- Agent 倾向一次性尝试过多任务（one-shot）
- Agent 过早宣布任务完成
- 缺乏有效的进度传递机制

---

## 全局安装位置

```
~/.claude/skills/
├── harness-core/SKILL.md      # 核心框架
├── harness-init/SKILL.md      # 初始化 Skill
├── harness-plan/SKILL.md      # 规划 Skill
├── harness-run/SKILL.md       # 执行 Skill
├── harness-status/SKILL.md    # 状态 Skill
└── templates/                  # 模板文件
    ├── feature_list.json
    ├── config.json
    └── init.sh
```

---

## 可用命令

| 命令 | 功能 | 状态要求 |
|------|------|----------|
| `/harness-init` | 初始化项目 Harness 环境 | 无前置条件 |
| `/harness-plan` | 任务规划（三种模式） | 已初始化 |
| `/harness-run` | 状态驱动的任务执行循环 | 自动处理前置条件 |
| `/harness-status` | 查看进度和状态 | 已初始化 |

---

## 使用流程

### 1. 初始化项目

在任意项目目录中调用：

```
/harness-init
```

**交互式问答**：
1. 项目名称？（默认：当前目录名）
2. 项目类型？（web/api/cli/library/other）
3. 技术栈？（Node.js/Python/PHP/Go/Java/Mixed/Custom）
4. 启动命令？

**生成文件**：

```
项目/.harness/
├── feature_list.json    # 任务清单（空骨架）
├── progress.txt         # 进度日志
├── init.sh              # 启动脚本
├── config.json          # Harness 配置
└── .gitignore           # 排除临时文件
```

---

### 2. 任务规划

```
/harness-plan
```

**三种模式**：

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **A. 交互式录入** | 逐个对话录入任务 | 小型项目、手动定义 |
| **B. 文档导入** | 解析现有文档生成任务 | 有需求文档的项目 |
| **C. AI 拆解** | 输入高层目标自动拆解 | 快速启动新项目 |

**任务数据结构**：

```json
{
  "id": "feat-001",
  "category": "functional",
  "description": "功能描述",
  "steps": ["步骤1", "步骤2"],
  "priority": 2,
  "depends_on": [],
  "passes": false
}
```

**字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 任务标识，格式 feat-XXX |
| category | string | 分类：functional/ui/api/security/other |
| description | string | 功能描述 |
| steps | array | 验证步骤列表 |
| priority | integer | 优先级 1-5，1最高 |
| depends_on | array | 依赖任务 ID 列表 |
| passes | boolean | 是否完成验证 |

---

### 3. 执行任务

```
/harness-run
```

**状态驱动入口**（自动处理前置条件）：

| 当前状态 | 自动操作 |
|----------|----------|
| not_initialized | 执行 harness-init → harness-plan(AI拆解) |
| initialized | 执行 harness-plan(AI拆解) |
| planned/running | 继续正常流程 |

**执行流程**：

1. **定位阶段**
   - pwd（确认工作目录）
   - read_progress(3)（最近进展）
   - git_log_oneline(5)（Git 历史）

2. **选任务**
   - 最高优先级 + 依赖满足 + passes=false

3. **启环境**
   - 执行 init.sh

4. **开发**
   - 按步骤实现
   - **一次只处理一个任务**

5. **测试引导**
   - 提供测试指令
   - 用户确认结果（pass/fail）

6. **更新状态**
   - 通过 → passes=true + git commit + progress update
   - 失败 → 保持 passes=false

7. **继续选择**
   - 用户决定继续或结束

**关键约束**：
- ✅ 一次只处理一个任务
- ✅ 仅修改 passes 字段
- ❌ 不允许删除或编辑其他任务字段
- ❌ 不允许跳过测试验证

---

### 4. 查看状态

```
/harness-status
```

**展示内容**：

1. **项目概览**：名称、类型、技术栈、创建时间、阶段
2. **任务统计**：总数、已完成、待办、完成率
3. **任务列表**：
   - ✓ 已完成任务
   - ○ 待办任务（按优先级）
4. **最近进展**：progress.txt 最近 5 条
5. **Git 历史**：最近 5 条 commit

**可选操作**：

| 操作 | 说明 |
|------|------|
| A. 导出报告 | 生成 Markdown 进度报告 |
| B. 重置任务 | 所有 passes 重置为 false |
| C. 清理记录 | 清空 progress.txt |
| D. 继续 | 开始下一个任务 |
| E. 退出 | 结束当前会话 |

---

## 状态阶段定义

| 阶段 | 条件 | 可执行操作 |
|------|------|-----------|
| not_initialized | .harness/ 不存在 | 只能执行 harness-init |
| initialized | .harness/ 存在，无任务 | 可执行 harness-plan |
| planned | 有任务列表 | 可执行 harness-run、harness-status |
| running | 存在未完成任务 | 可执行 harness-run、harness-status |
| completed | 所有任务完成 | 可执行 harness-status、重置任务 |

---

## 典型工作流程

```
# 新项目启动
/harness-init       → 初始化环境
/harness-plan       → AI 拆解任务（模式 C）
/harness-run        → 自动执行任务循环

# 已有项目继续
/harness-run        → 自动定位并继续未完成任务

# 查看进度
/harness-status     → 展示完整状态

# 重做所有任务
/harness-status → B（重置任务）
/harness-run        → 重新执行
```

---

## 设计文件位置

| 文件 | 路径 |
|------|------|
| 设计规范 | `docs/superpowers/specs/2026-04-24-harness-system-design.md` |
| 实施计划 | `docs/superpowers/plans/2026-04-24-harness-system.md` |
| 原文翻译 | `docs/ai编程/长时间运行-Agent-的有效Harness设计.md` |

---

## 参考资源

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK Quickstart](https://github.com/anthropics/claude-agent-sdk-quickstart)