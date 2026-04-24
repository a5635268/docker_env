# Harness 系统设计文档

> **创建日期**: 2026-04-24
> **设计目标**: 实现长时间运行 Agent 的有效 Harness 系统

---

## 1. 概述

### 1.1 背景

基于 Anthropic 文章 [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)，构建一套 Claude Code Skills 系统，解决 AI Agent 跨上下文窗口持续工作的挑战。

### 1.2 核心问题

- Agent 必须在离散会话中工作，新会话无之前记忆
- Agent 倾向一次性尝试过多任务（one-shot）
- Agent 过早宣布任务完成
- 缺乏有效的进度传递机制

### 1.3 解决方案

通过外部持久化存储（feature_list.json + progress.txt + git history）配合状态驱动的 Skills，实现 Agent 跨会话的持续有效工作。

---

## 2. 系统架构

### 2.1 架构图

```
用户调用                    Skills 层                    核心框架层                    数据层
─────────                  ─────────                   ─────────────                ────────

/harness-init  ────────►  harness-init/SKILL.md  ───►  harness-core/SKILL.md  ───►  .harness/
                                                      │                              ├── feature_list.json
/harness-plan  ────────►  harness-plan/SKILL.md  ───►  ├── 状态检测                   ├── progress.txt
                                                      │   ├── 检测 .harness/          ├── init.sh
/harness-run   ────────►  harness-run/SKILL.md   ───►  │   ├── 验证文件完整性         ├── config.json
                                                      │   ├── 解析 feature_list       └── .gitignore
/harness-status ───────►  harness-status/SKILL.md ───► │   ├── 解析 progress
                                                      │
                                                      ├── 共享操作
                                                      │   ├── 读写 JSON/文本文件
                                                      │   ├── Git 操作封装
                                                      │   ├── 交互式对话流程
                                                      │
                                                      └── 管道执行
                                                          ├── init 管道
                                                          ├── plan 管道
                                                          ├── run 管道
                                                          └── status 管道
```

### 2.2 Skills 目录结构

```
.harness-skills/
├── harness-core/
│   ├── SKILL.md           # 核心框架 skill
│   └── lib/
│       ├── state.sh       # 状态检测（是否存在、是否完整、当前阶段）
│       ├── validate.sh    # 数据验证（JSON 结构、字段完整性）
│       ├── io.sh          # 文件读写封装
│       ├── git.sh         # Git 操作封装
│       └── prompt.sh      # 交互式对话模板
│
├── harness-init/
│   └── SKILL.md           # 初始化 skill
│
├── harness-plan/
│   └── SKILL.md           # 规划 skill
│
├── harness-run/
│   └── SKILL.md           # 执行 skill
│
├── harness-status/
│   └── SKILL.md           # 状态 skill
│
└── templates/
    ├── feature_list.json  # feature_list 模板
    ├── config.json        # config 模板
    └── init.sh            # init.sh 模板
```

### 2.3 用户项目目录结构

```
用户项目/
├── .harness/
│   ├── feature_list.json  # 任务清单
│   ├── progress.txt       # 进度日志
│   ├── init.sh            # 启动脚本
│   ├── config.json        # Harness 配置
│   └── .gitignore         # 排除敏感文件
│
├── src/                   # 用户项目源码
├── tests/
└── .git/
```

---

## 3. 核心框架设计

### 3.1 状态阶段定义

| 阶段 | 条件 | 可执行操作 |
|------|------|-----------|
| not_initialized | .harness/ 不存在 | 只能执行 harness-init |
| initialized | .harness/ 存在，无任务 | 可执行 harness-plan |
| planned | 有任务列表 | 可执行 harness-run、harness-status |
| running | 存在未完成任务 | 可执行 harness-run、harness-status |
| completed | 所有任务完成 | 可执行 harness-status、重置任务 |

### 3.2 lib/ 脚本设计

#### state.sh

```bash
# 检测 .harness/ 目录是否存在
harness_exists() → 返回 true/false

# 检测当前阶段
harness_get_stage() → 返回：
  # - "not_initialized"    （目录不存在）
  # - "initialized"        （目录存在，但无任务）
  # - "planned"            （有任务列表）
  # - "running"            （存在未完成任务）
  # - "completed"          （所有任务完成）

# 检测文件完整性
harness_validate_files() → 返回缺失文件列表

# 检测项目是否有 Git
git_exists() → 返回 true/false
```

#### validate.sh

```bash
# 验证 feature_list.json 结构
validate_feature_list() → 返回：
  # - valid: true/false
  # - errors: []

# 验证单个任务结构
validate_task(task_json) → 返回验证结果

# 验证 config.json 结构
validate_config() → 返回验证结果

# 验证 init.sh 是否可执行
validate_init_script() → 返回验证结果
```

#### io.sh

```bash
# 读取 JSON 文件并解析
read_json(file_path) → 返回 JSON 对象

# 写入 JSON 文件（格式化输出）
write_json(file_path, json_object)

# 追加任务到 feature_list
append_task(task_json)

# 更新任务的 passes 字段
update_task_passes(task_id, passes_value)

# 读取 progress.txt 最近 N 条记录
read_progress(limit) → 返回记录数组

# 写入 progress 记录
write_progress(message)

# 创建文件（若不存在）
ensure_file(file_path, default_content)
```

#### git.sh

```bash
# 检查是否有未提交的更改
git_has_changes() → 返回 true/false

# 获取最近 N 条 commit
git_log_oneline(limit) → 返回 commit 列表

# 提交更改
git_commit(message)

# 检查 Git 状态
git_status() → 返回状态摘要

# 初始化 Git（若不存在）
git_init_if_needed()
```

#### prompt.sh

```bash
# 初始化对话模板
prompt_init_questions() → 返回问题列表

# 规划模式选择模板
prompt_plan_mode() → 返回选项

# 任务录入模板
prompt_task_questions() → 返回问题列表

# 测试引导模板
prompt_test_guidance(task_steps) → 返回测试指令

# 状态确认模板
prompt_status_actions() → 返回可选操作
```

---

## 4. 数据结构设计

### 4.1 feature_list.json

```json
{
  "tasks": [
    {
      "id": "feat-001",
      "category": "functional",
      "description": "New chat button creates a fresh conversation",
      "steps": [
        "Navigate to main interface",
        "Click the 'New Chat' button",
        "Verify a new conversation is created",
        "Check that chat area shows welcome state",
        "Verify conversation appears in sidebar"
      ],
      "priority": 2,
      "depends_on": [],
      "passes": false
    },
    {
      "id": "feat-002",
      "category": "ui",
      "description": "Chat input supports multiline text",
      "steps": [
        "Open chat interface",
        "Type text with Enter key for new line",
        "Submit multiline message",
        "Verify message displays correctly"
      ],
      "priority": 3,
      "depends_on": ["feat-001"],
      "passes": false
    }
  ],
  "metadata": {
    "total_tasks": 2,
    "completed": 0,
    "pending": 2,
    "last_updated": "2026-04-24"
  }
}
```

**字段说明**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 是 | 任务标识，格式 feat-XXX |
| category | string | 是 | 分类：functional / ui / api / security / other |
| description | string | 是 | 功能描述 |
| steps | array | 是 | 验证步骤列表 |
| priority | integer | 是 | 优先级 1-5，1最高 |
| depends_on | array | 否 | 依赖任务 ID 列表 |
| passes | boolean | 是 | 是否完成验证 |

### 4.2 config.json

```json
{
  "project_name": "my-web-app",
  "project_type": "web",
  "tech_stack": "Node.js",
  "created_at": "2026-04-24",
  "harness_version": "1.0.0"
}
```

### 4.3 progress.txt

```
2026-04-24 15:30 Session #5 - Completed feat-002 (Chat input multiline)
2026-04-24 14:00 Session #5 - Started feat-002
2026-04-24 10:00 Session #4 - Completed feat-001 (New chat button)
2026-04-23 16:00 Session #3 - Added 3 tasks to feature list
2026-04-23 10:00 Session #2 - Harness initialized for my-web-app
```

### 4.4 init.sh

```bash
#!/bin/bash
# Harness init script for my-web-app
# Generated: 2026-04-24

set -e

echo "Starting my-web-app development environment..."

# 启动命令（用户自定义）
npm run dev
```

---

## 5. Skills 功能设计

### 5.1 harness-init

**职责**：创建 .harness/ 目录和初始文件

**执行流程**：

```
1. 检测状态 → 若已初始化则提示用户是否重新初始化
2. 创建 .harness/ 目录
3. 交互式对话：
   - 项目名称？（默认：当前目录名）
   - 项目类型？（web/api/cli/library/other）
   - 技术栈？（Node.js/Python/PHP/Go/Java/Mixed/Custom）
   - 启动命令？
4. 生成 init.sh
5. 生成 config.json
6. 初始化 Git（若尚未初始化）
7. 创建 .harness/.gitignore
8. 创建空的 feature_list.json 骨架
9. 创建 progress.txt 第一条记录
10. Git commit："Initialize harness for [项目名]"
```

### 5.2 harness-plan

**职责**：生成和管理 feature_list.json

**三种生成模式**：

| 模式 | 输入 | 流程 |
|------|------|------|
| 交互式 | 无 | 逐个对话录入任务 |
| 文档导入 | 文档路径 | 解析现有文档生成任务 |
| AI拆解 | 高层目标 | AI 自动拆解功能单元 |

**交互式模式流程**：

```
循环：
  1. 提问：功能描述？
  2. 提问：验证步骤？
  3. 提问：优先级（1-5）？
  4. 提问：依赖任务？（可选）
  5. 确认 → 追加到 feature_list.json
  6. 继续？是 → 循环；否 → 结束
```

**文档导入模式流程**：

```
1. 提问：文档路径？
2. 读取并解析文档
3. AI 提取需求转换为任务结构
4. 展示任务列表供确认/调整
5. 写入 feature_list.json
```

**AI拆解模式流程**：

```
1. 提问：高层目标？
2. AI 分析并拆解功能单元
3. 展示结果供确认/调整
4. 写入 feature_list.json
```

### 5.3 harness-run

**职责**：执行单一任务的增量开发循环

**状态驱动入口**：

```
检测阶段：
  - not_initialized → 自动执行 harness-init → harness-plan(AI拆解)
  - initialized → 自动执行 harness-plan(AI拆解)
  - planned/running → 继续正常流程
```

**正常执行流程**：

```
1. 定位：pwd + read_progress(3) + git_log_oneline(5)
2. 选任务：最高优先级 + 依赖满足 + passes=false
3. 启环境：执行 init.sh
4. 验现状：可选，检查已有功能
5. 开发：按步骤实现，一次只处理当前任务
6. 测试引导：提供测试指令，用户确认结果
7. 更状态：测试通过 → passes=true + git commit + progress update
8. 继续：用户选择继续或结束
```

### 5.4 harness-status

**职责**：展示当前进度和任务状态

**展示内容**：

```
1. 项目概览：名称、类型、技术栈、创建时间、阶段
2. 任务统计：总数、已完成、待办、完成率
3. 任务列表：
   - 已完成（带 ✓ 标记）
   - 待办（按优先级，显示依赖）
4. 最近进展：progress.txt 最近 5 条
5. Git 历史：最近 5 条 commit
```

**可选操作**：

| 操作 | 说明 |
|------|------|
| 导出报告 | 生成 Markdown 进度报告 |
| 重置任务 | 所有 passes 重置为 false |
| 清理记录 | 清空 progress.txt |

---

## 6. 数据流设计

### 6.1 完整数据流

```
/harness-run 调用
    │
    ▼
状态检测 (state.sh)
    │
    ├─ not_initialized → 自动执行 harness-init
    ├─ initialized → 自动执行 harness-plan
    └─ planned/running → 继续
    │
    ▼
定位阶段
    ├─ pwd
    ├─ read_progress(3)
    └─ git_log_oneline(5)
    │
    ▼
选任务阶段
    ├─ read_json(feature_list.json)
    ├─ 筛选：passes=false + 依赖满足 + priority升序
    └─ 选择第一个
    │
    ▼
启环境
    └─ 执行 init.sh
    │
    ▼
开发阶段
    ├─ 执行任务步骤
    ├─ 代码变更
    └─ 运行测试
    │
    ▼
测试引导
    ├─ prompt_test_guidance(steps)
    └─ 用户确认结果
    │
    ├─ 测试通过 → update_task_passes + git_commit + write_progress
    └─ 测试失败 → 保持 passes=false，引导修复
    │
    ▼
继续选择
    ├─ 继续 → 回到选任务阶段
    └─ 结束 → 保持干净状态
```

---

## 7. 错误处理设计

### 7.1 错误分类

| 类型 | 场景 | 处理 |
|------|------|------|
| 前置条件缺失 | 未初始化、文件缺失 | 自动修复或提示 |
| 文件格式错误 | JSON 解析失败 | 提示详情，引导修复 |
| 环境启动失败 | init.sh 执行失败 | 检查脚本，提示修正 |
| 依赖未满足 | 依赖任务未完成 | 自动跳过，选下一个 |
| 测试失败 | 验证不通过 | 保持 false，引导重试 |
| Git 操作失败 | 有未提交更改 | 提示处理后继续 |
| 用户中断 | 取消操作 | 保持干净状态 |

### 7.2 错误记录格式

```
[ERROR] 2026-04-24 15:30
Type: [错误类型]
Action: [处理方式]
```

---

## 8. 设计约束

### 8.1 关键指令约束

- ✅ 一次只处理一个任务
- ✅ 仅修改 passes 字段
- ✅ 测试引导不强制阻塞
- ✅ 状态驱动自动处理前置条件
- ❌ 不允许一次性尝试完成多个任务
- ❌ 不允许删除或编辑其他任务的字段
- ❌ 不允许跳过测试验证步骤

### 8.2 数据约束

- feature_list.json 使用 JSON 格式（避免 AI 错误修改）
- 所有任务初始 passes: false
- progress.txt 使用纯文本格式
- 所有 Harness 文件位于 .harness/ 目录

### 8.3 与其他系统关系

- Harness 系统独立运作，不与 .spec-workflow 集成
- Git 历史作为辅助状态来源

---

## 9. 未来扩展

### 9.1 可选增强

- 任务锁定机制（防止并发冲突）
- 多会话并行支持
- 任务预估时间跟踪
- 自动测试脚本生成

### 9.2 专用 Agent 扩展

- 测试 Agent（专职端到端验证）
- QA Agent（代码质量检查）
- 清理 Agent（代码整理和重构）

---

## 10. 参考资源

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK Quickstart](https://github.com/anthropics/claude-agent-sdk-quickstart)