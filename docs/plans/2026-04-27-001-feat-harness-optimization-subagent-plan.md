---
title: feat: Harness 框架优化与子 Agent 功能扩展
type: feat
status: active
date: 2026-04-27
origin: 用户请求分析现有 harness 框架的优化空间和子 Agent 功能
---

# Harness 框架优化与子 Agent 功能扩展计划

## Overview

基于现有 Harness 框架的全面分析，识别优化空间并设计子 Agent 架构，实现专用 Agent 协同工作模式。

---

## Problem Frame

### 当前架构优势

1. **状态驱动设计**：5 阶段自动流转（not_initialized → initialized → planned → running → completed）
2. **持久化机制**：feature_list.json + progress.txt + git history 跨会话传递状态
3. **约束规则**："一次只处理一个任务"、"仅修改 passes 字段"防止 Agent 过度乐观
4. **新旧系统区分**：Legacy（已有代码）和 New（全新项目）不同处理策略
5. **设计文档层级**：CLAUDE.md（项目级）+ architecture.md（整体架构）+ design/（任务级）

### 当前限制（原文指出）

```
原文："未来方向 - 未解决问题：
1. 单 Agent vs 多 Agent 架构
   - 单一通用 Coding Agent 是否最优？
   - 专用 Agent（测试、QA、代码清理）可能表现更好？
"
```

**具体限制**：
- 单 Agent 执行所有工作，无分工协作
- 任务只能串行执行，无并行能力
- 测试失败只能暂停，无智能恢复机制
- 依赖分析简化（只返回第一个 passes=false）
- 用户手动确认测试结果，无自动化
- 完成后无代码审查机制
- 无任务预估或复杂度分析
- 无回滚机制

---

## Requirements Trace

- R1. 分析现有框架的优化空间
- R2. 设计子 Agent 架构（测试、QA、清理等）
- R3. 提出具体实现方案（不立即编码）
- R4. 评估与现有系统的集成方式

---

## Scope Boundaries

### Deferred to Follow-Up Work

- 具体代码实现（本计划为分析阶段）
- 子 Agent 与 Claude Agent SDK 的深度集成
- 多项目协调机制

---

## Context & Research

### 现有文件结构

```
.harness-skills/
├── harness-core/
│   ├── SKILL.md           # 核心框架
│   └── lib/
│       ├── state.sh       # 状态检测
│       ├── validate.sh    # 数据验证
│       ├── io.sh          # 文件读写
│       ├── git.sh         # Git 操作
│       └── prompt.sh      # 交互模板
├── harness-init/SKILL.md  # 初始化
├── harness-plan/SKILL.md  # 规划
├── harness-run/SKILL.md   # 执行（核心循环）
├── harness-status/SKILL.md # 状态
└── templates/             # 模板文件
```

### 原文关键洞察

> "专用 Agent（测试、QA、代码清理）可能表现更好？"

这是 Anthropic 官方文章留下的开放问题，也是本次优化的核心目标。

---

## Key Technical Decisions

### 决策 1：子 Agent 采用 Claude Code Agent 工具实现

**理由**：
- Claude Code 提供 Agent 工具可创建专用 subagent
- 子 Agent 可在后台运行，不污染主上下文
- 子 Agent 可并行执行独立任务

### 决策 2：保持 Shell 脚本基础，Agent 为增强层

**理由**：
- 现有 Shell 脚本已验证有效
- Agent 处理复杂决策和自动化
- 避免过度依赖 AI 导致不稳定

---

## 子 Agent 功能设计

### 1. 测试 Agent（Test Agent）

**职责**：
- 自动执行端到端测试（使用 Playwright MCP）
- 截图验证功能状态
- 生成测试报告

**触发时机**：
- 任务开发完成后自动触发
- 用户输入 "test" 时手动触发

**输入**：
- task_id + steps（验证步骤）
- 项目启动命令

**输出**：
- test_result: pass/fail
- screenshots: 测试截图列表
- errors: 失败详情

**实现要点**：
```markdown
在 harness-run SKILL.md 中：
测试引导 → 改为：
- 调用 Agent(subagent_type=general-purpose, prompt="执行端到端测试...")
- Agent 使用 Playwright MCP 工具
- 返回结构化测试报告
```

### 2. QA Agent（代码审查 Agent）

**职责**：
- 审查已完成任务的代码质量
- 检查代码风格、最佳实践、潜在 bug
- 生成审查报告和建议

**触发时机**：
- 任务 passes=true 后自动触发
- 可配置为可选（用户选择启用）

**输入**：
- task_id
- git diff（当前任务变更）
- 项目 CLAUDE.md（代码规范）

**输出**：
- review_result: approve/request_changes
- issues: 问题列表
- suggestions: 改进建议

**实现要点**：
```markdown
新增 harness-review SKILL.md：
- 在 update_task_passes 后调用
- 使用 ce-code-review agent type
- 结果写入 design/<task-id>-review.md
```

### 3. 清理 Agent（Cleanup Agent）

**职责**：
- 代码整理（格式化、移除死代码）
- 重构建议（识别重复代码）
- 技术债务标记

**触发时机**：
- 多个任务完成后批量触发
- 用户手动请求

**输入**：
- 当前所有变更文件
- 项目代码风格配置

**输出**：
- cleanup_actions: 建议操作列表
- tech_debt_items: 技术债务标记

### 4. 并行 Worker Agents

**职责**：
- 处理无依赖关系的独立任务
- 提高整体执行效率

**触发时机**：
- 当 feature_list 中存在多个无依赖的任务时
- 由主 Agent 协调调度

**实现要点**：
```markdown
在 harness-run 中增加并行调度逻辑：
- 分析任务 DAG
- 识别无依赖的独立任务
- 使用 Agent 工具并行启动多个 worker
- 收集结果并更新状态
```

---

## 其他优化方向

### 优化 1：智能错误恢复

**当前行为**：测试失败 → 暂停 → 用户干预

**优化后**：
```
测试失败 → 失败诊断 Agent → 
  - 分析错误类型
  - 尝试自动修复（简单错误）
  - 记录失败模式到 failure-patterns.md
  - 复杂错误 → 暂停 + 详细诊断报告
```

### 优化 2：增强依赖分析

**当前实现**：
```bash
# 简化实现：返回第一个 passes=false 的任务
grep -m1 '"passes": false' ...
```

**优化后**：
- 完整 DAG 分析（Python 实现）
- 检测循环依赖
- 支持并行任务调度
- 可视化依赖图

### 优化 3：自动测试集成

**当前**：用户手动确认 pass/fail

**优化后**：
- 集成 Playwright MCP 自动测试
- 测试 Agent 执行验证步骤
- 用户可选手动确认或全自动模式

### 优化 4：回滚机制

**新增功能**：
- 每个任务开始前记录当前 commit SHA
- 测试失败可选择 rollback
- failure-patterns.md 记录历史失败模式

### 优化 5：进度可视化

**新增功能**：
- 生成进度图表（SVG）
- 任务时间预估
- 预计完成时间

---

## Implementation Units

### U1. **测试 Agent 集成**

**Goal**: 将手动测试验证改为 Agent 自动执行

**Requirements**: R2

**Dependencies**: 无

**Files:**
- Modify: `.harness-skills/harness-run/SKILL.md`
- Create: `.harness-skills/harness-test/SKILL.md`

**Approach:**
- 在 harness-run 的测试引导阶段调用 Agent 工具
- Agent 使用 Playwright MCP 执行验证步骤
- 返回结构化结果替代用户手动输入

**Test scenarios:**
- Integration: 开发完成 → 自动触发测试 Agent → 返回 pass/fail

**Verification:**
- 测试 Agent 可自动执行验证步骤
- 结果可靠地反映功能状态

---

### U2. **QA Agent（代码审查）**

**Goal**: 任务完成后自动进行代码审查

**Requirements**: R2

**Dependencies**: U1

**Files:**
- Create: `.harness-skills/harness-review/SKILL.md`
- Modify: `.harness-skills/harness-run/SKILL.md`

**Approach:**
- 任务 passes=true 后触发 review Agent
- 使用 ce-code-review agent type
- 审查结果写入 design/<task-id>-review.md

**Test scenarios:**
- Integration: 任务完成 → QA Agent 审查 → 生成报告

**Verification:**
- QA Agent 能识别代码问题
- 审查报告有价值

---

### U3. **并行 Worker 调度**

**Goal**: 支持多个独立任务并行执行

**Requirements**: R2

**Dependencies**: 无

**Files:**
- Modify: `.harness-skills/harness-run/SKILL.md`
- Modify: `.harness-skills/harness-core/lib/state.sh`

**Approach:**
- 分析任务 DAG，识别并行机会
- 使用 Agent 工具创建多个并行 worker
- 收集结果并更新状态

**Test scenarios:**
- Integration: 多个无依赖任务 → 并行执行 → 状态正确更新

**Verification:**
- 并行执行效率提升
- 状态同步无冲突

---

### U4. **智能错误恢复**

**Goal**: 测试失败时自动诊断和尝试修复

**Requirements**: R1

**Dependencies**: U1

**Files:**
- Create: `.harness-skills/harness-recovery/SKILL.md`
- Create: `.harness-skills/harness-core/lib/failure-analysis.sh`

**Approach:**
- 失败时启动诊断 Agent
- 分析错误类型（编译错误、逻辑错误、环境问题）
- 简单错误自动修复尝试
- 记录失败模式供后续参考

**Test scenarios:**
- Error path: 测试失败 → 诊断 → 尝试修复 → 重试

**Verification:**
- 简单错误可自动恢复
- 复杂错误提供详细诊断

---

### U5. **增强依赖分析**

**Goal**: 完整 DAG 分析替代简化实现

**Requirements**: R1

**Dependencies**: 无

**Files:**
- Modify: `.harness-skills/harness-core/lib/state.sh`
- Create: `.harness-skills/harness-core/lib/dag.py`

**Approach:**
- Python DAG 分析脚本
- 检测循环依赖
- 支持并行调度决策
- 可选生成依赖图可视化

**Test scenarios:**
- Edge case: 循环依赖检测
- Integration: 并行调度正确识别独立任务

**Verification:**
- DAG 分析准确
- 循环依赖报警

---

### U6. **回滚机制**

**Goal**: 失败时可恢复到任务开始前状态

**Requirements**: R1

**Dependencies**: 无

**Files:**
- Modify: `.harness-skills/harness-run/SKILL.md`
- Modify: `.harness-skills/harness-core/lib/git.sh`

**Approach:**
- 任务开始前记录 commit SHA
- 失败时提供 rollback 选项
- 支持 `harness-rollback` 命令

**Test scenarios:**
- Error path: 失败 → rollback → 状态恢复

**Verification:**
- rollback 可恢复到正确状态

---

## System-Wide Impact

- **Agent 调用**: 需要使用 Agent 工具 API
- **上下文管理**: 子 Agent 结果需汇总到主上下文
- **状态同步**: 并行任务需要状态同步机制
- **Git 操作**: rollback 需要安全的 git reset

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| 子 Agent 增加复杂度 | 保持可选，用户可选择启用 |
| 并行任务状态冲突 | 使用文件锁或顺序写入 |
| Agent 调用失败 | 提供降级到手动模式 |
| 回滚误用 | 需要用户明确确认 |

---

## 建议实施顺序

**Phase 1（核心增强）**：
- U1 测试 Agent 集成
- U5 增强依赖分析

**Phase 2（质量保障）**：
- U2 QA Agent
- U4 智能错误恢复

**Phase 3（效率提升）**：
- U3 并行 Worker
- U6 回滚机制

---

## Sources & References

- **Origin document**: docs/superpowers/specs/2026-04-24-harness-system-design.md
- **原文翻译**: docs/ai编程/长时间运行-Agent-的有效Harness设计.md
- **使用指南**: docs/自定义skills/Harness-Skills-使用指南.md
- **External docs**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)