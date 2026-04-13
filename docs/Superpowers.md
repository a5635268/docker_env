# Superpowers 代理技能框架指南

## 概述

Superpowers 是在 2026 年 AI 辅助开发领域非常火热的一个**代理技能（Agentic Skills）** 框架。

简单来说，如果你把 Claude Code 或 Cursor 这样的 AI 助手比作一个"新员工"，那么 **Superpowers** 就是给这个员工的一套**标准作业程序（SOP）和特种工具包**。它强制 AI 遵循严谨的工程规范，而不是随意的"意识流编程（Vibe Coding）"。

**注意：** 本文档已根据最新版本的 Superpowers 技能更新。旧版本中的 `/superpowers:start` 等命令已废弃，改为直接调用技能工具。

---

## 目录

1. [快速开始](#1-快速开始)
2. [核心工作流：七阶段流水线](#2-核心工作流七阶段流水线)
3. [使用场景详解](#3-使用场景详解)
4. [与 OpenSpec 对比](#4-与-openspec-对比)
5. [最佳实践](#5-最佳实践)
6. [常见问题](#6-常见问题)
7. [废弃命令迁移指南](#7-废弃命令迁移指南)
8. [如何升级/迁移](#8-如何升级迁移)
9. [TDD 与子代理专项场景](#9-tdd 与子代理专项场景)

---

## 1. 快速开始

### 当前可用技能命令

Superpowers 技能已集成到 Claude Code 环境中，可直接调用以下技能：

**核心工作流技能：**

| 技能 | 用途 | 调用时机 |
|------|------|----------|
| `superpowers:using-superpowers` | 获取完整使用指南 | 首次使用或需要参考时，类似以前的start |
| `superpowers:brainstorming` | 需求讨论、风险评估 | 任何创意/功能开发前 |
| `superpowers:writing-plans` | 编写详细计划 | 有需求后、编码前 |
| `superpowers:executing-plans` | 执行计划（带评审检查点） | 有书面计划后 |
| `superpowers:test-driven-development` | TDD 测试驱动开发 | 实现任何功能/修复前 |
| `superpowers:subagent-driven-development` | 子代理并行开发 | 有独立任务需要并行处理 |
| `superpowers:requesting-code-review` | 请求代码评审 | 完成任务或重大功能后 |
| `superpowers:receiving-code-review` | 接收评审反馈 | 收到评审意见后 |
| `superpowers:verification-before-completion` | 完成前验证 | 声称工作完成前 |
| `superpowers:finishing-a-development-branch` | 完成开发分支 | 实现完成后决定如何集成 |

**辅助技能：**

| 技能 | 用途 |
|------|------|
| `superpowers:systematic-debugging` | 系统调试（遇到 bug 时） |
| `superpowers:dispatching-parallel-agents` | 并行代理分发（2+ 独立任务） |
| `superpowers:writing-skills` | 编写或修改技能 |
| `superpowers:using-git-worktrees` | Git 工作树隔离开发 |

### 调用方式

在 Claude Code 对话中，使用 `Skill` 工具调用相应技能：

```
Skill({ skill: "superpowers:brainstorming", args: "..." })
```

或在对话中直接说明使用哪个技能，AI 会自动调用。

**重要：** 所有技能都可以**单独调用**，不需要按固定顺序使用。你可以根据任务需求灵活选择：

- **快速修复**: 直接调用 `superpowers:systematic-debugging`
- **小功能开发**: 只调用 `superpowers:test-driven-development`
- **完整项目**: 按顺序调用多个技能（brainstorming → writing-plans → executing-plans → ...）

---

## 2. 核心工作流：七阶段流水线

当你在 AI 助手中启用 Superpowers 后，它会自动引导（或强制）AI 按照以下顺序工作：

```
┌─────────────────┐
│ 1. Brainstorm   │ → 使用 superpowers:brainstorming
│    头脑风暴     │   需求讨论、风险评估、边界情况挖掘
└────────┬────────┘
         ↓
┌─────────────────┐
│ 2. Spec         │ → 编写 Markdown 规格文档
│    规格定义     │   明确"什么是完成"
└────────┬────────┘
         ↓
┌─────────────────┐
│ 3. Plan         │ → 使用 superpowers:writing-plans
│    计划         │   生成详细的任务清单（Tasks.md）
└────────┬────────┘
         ↓
┌─────────────────┐
│ 4. TDD          │ → 使用 superpowers:test-driven-development
│    测试驱动     │   ⭐ 关键环节！先写失败的测试，再写业务代码
└────────┬────────┘
         ↓
┌─────────────────┐
│ 5. Subagent     │ → 使用 superpowers:subagent-driven-development
│    子代理开发   │   主 AI 派生子代理（UI/数据/测试等）
└────────┬────────┘
         ↓
┌─────────────────┐
│ 6. Review       │ → 使用 superpowers:requesting-code-review
│    评审         │   AI 内部自检 + 人工反馈
└────────┬────────┘
         ↓
┌─────────────────┐
│ 7. Finalize     │ → 使用 superpowers:finishing-a-development-branch
│    完成         │   合并代码、更新规格库、清理环境
└─────────────────┘
```

### 各阶段详细说明

| 阶段 | 输入 | 输出 | 关键活动 |
|------|------|------|----------|
| **Brainstorm** | 用户需求 | 问题分析报告 | 需求澄清、风险识别、依赖分析 |
| **Spec** | 问题分析 | 规格文档 | 接口定义、数据结构、验收标准 |
| **Plan** | 规格文档 | 任务清单 | 任务拆解、优先级排序、依赖关系 |
| **TDD** | 任务清单 | 测试用例 + 实现代码 | 红 - 绿 - 重构循环 |
| **Subagent Dev** | 实现代码 | 功能模块 | 专业化分工、并行开发 |
| **Review** | 功能模块 | 评审报告 | 代码质量、性能、安全性检查 |
| **Finalize** | 评审通过 | 可交付成果 | 文档更新、规格归档 |

---

## 3. 使用场景详解

### 场景 1：新功能从零开发

**情境：** 需要在电商系统中添加"优惠券"功能。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能开始头脑风暴
```

**或启用完整工作流：**
```
使用 `superpowers:using-superpowers` 技能获取完整指南
```

**七阶段执行过程：**

| 阶段 | AI 产出 |
|------|--------|
| Brainstorm | 识别出需要关注的点：叠加规则、有效期、使用门槛、库存扣减 |
| Spec | 定义三种优惠券类型的数据结构、API 接口、使用规则 |
| Plan | 拆解为：数据库设计 → 模型层 → 服务层 → API 层 → 前端页面 |
| TDD | 先写测试：创建优惠券、领取优惠券、使用优惠券、过期处理 |
| Subagent Dev | 主代理写后端，子代理写前端，另一个子代理写文档 |
| Review | 检查：边界条件、并发场景、SQL 注入风险 |
| Finalize | 合并代码到 main，更新 API 文档 |

**为什么有效：** 强制 AI 在写代码前想清楚所有边界情况，避免"写到一半发现设计缺陷"。

---

### 场景 2：遗留系统重构

**情境：** 一个 3 年前的老模块，代码混乱、没有测试，需要重构。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能分析重构策略
使用 `superpowers:test-driven-development` 技能建立保护性测试
```

**七阶段执行过程：**

1. **Brainstorm**：分析现有代码的问题（单例滥用、全局状态、硬编码）
2. **Spec**：定义重构后的接口契约（保持向后兼容）
3. **Plan**：制定分步重构计划（先加测试 → 提取接口 → 逐步替换）
4. **TDD**：为现有行为编写"保护性测试"，确保重构不破坏功能
5. **Subagent Dev**：一个子代理负责提取接口，另一个负责迁移调用方
6. **Review**：检查：是否有行为变化、性能是否下降
7. **Finalize**：删除旧代码，更新文档

**为什么有效：** 对于没有测试的老代码，TDD 阶段强制先建立"安全网"，再动手重构。

---

### 场景 3：Bug 修复与回归预防

**情境：** 用户报告"在大促期间，库存偶尔会变成负数"。

**当前可用命令：**
```
使用 `superpowers:systematic-debugging` 技能调试问题
使用 `superpowers:test-driven-development` 技能编写并发测试
```

**七阶段执行过程：**

1. **Brainstorm**：分析可能的原因（并发竞争、事务隔离级别、缓存不一致）
2. **Spec**：定义正确的库存扣减逻辑（原子操作、悲观锁/乐观锁选择）
3. **Plan**：复现问题 → 定位根因 → 编写修复 → 添加压力测试
4. **TDD**：**先写并发测试**，模拟 100 个用户同时购买同一商品
5. **Subagent Dev**：一个代理修复代码，另一个代理编写压力测试脚本
6. **Review**：检查：是否还有其他并发风险点
7. **Finalize**：将并发测试加入 CI 常规测试集

**为什么有效：** 不仅仅是"修好这个 bug"，而是通过 TDD 确保此类 bug 不会再发生。

---

### 场景 4：API 集成开发

**情境：** 需要集成 Stripe 支付 API。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能识别集成风险点
使用 `superpowers:test-driven-development` 技能编写测试用例
```

**七阶段执行过程：**

1. **Brainstorm**：识别关键点：webhook 处理、幂等性、错误重试、测试模式
2. **Spec**：定义内部支付接口、Stripe 事件处理逻辑、回调流程
3. **Plan**：环境配置 → SDK 集成 → 支付创建 → webhook 接收 → 状态同步
4. **TDD**：使用 Stripe 的测试密钥编写测试用例（成功支付、失败、退款）
5. **Subagent Dev**：一个代理处理支付逻辑，另一个处理 webhook
6. **Review**：检查：安全性（密钥管理）、幂等性处理
7. **Finalize**：将测试密钥配置写入 `.env.example`，更新部署文档

**为什么有效：** 第三方集成容易遗漏边界情况（如 webhook 重复推送），Spec 阶段强制考虑这些场景。

---

### 场景 5：微服务拆分

**情境：** 将单体应用中的"通知服务"拆分为独立微服务。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能识别依赖关系
使用 `superpowers:dispatching-parallel-agents` 技能并行处理多个子任务
```

**七阶段执行过程：**

1. **Brainstorm**：识别依赖：哪些模块在调用通知功能？数据如何迁移？
2. **Spec**：定义服务边界、API 契约、消息队列协议、数据同步策略
3. **Plan**：创建新服务 → 双写过渡 → 切换调用方 → 下线旧代码
4. **TDD**：编写契约测试（Contract Test），确保接口兼容
5. **Subagent Dev**：主代理拆后端，子代理拆数据库，另一个更新调用方
6. **Review**：检查：分布式事务、超时重试、监控告警
7. **Finalize**：更新服务发现配置，添加监控面板

**为什么有效：** 微服务拆分涉及面广，七阶段流程确保每个环节都被考虑到。

---

### 场景 6：性能优化项目

**情境：** 首页加载时间超过 5 秒，需要优化到 2 秒以内。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能分析性能瓶颈
使用 `superpowers:test-driven-development` 技能定义性能测试
```

**七阶段执行过程：**

1. **Brainstorm**：分析瓶颈（图片过大、接口慢、JS  Bundle 太大）
2. **Spec**：定义性能指标、测量方法、验收标准
3. **Plan**：图片优化 → 接口缓存 → 代码分割 → CDN 部署
4. **TDD**：编写性能测试脚本，设定性能预算（Performance Budget）
5. **Subagent Dev**：一个代理优化图片，一个代理优化接口，一个代理拆分代码
6. **Review**：运行 Lighthouse，对比优化前后数据
7. **Finalize**：将性能测试加入 CI，设置性能回归告警

**为什么有效：** 性能优化容易"凭感觉"，TDD 阶段强制定义可量化的指标。

---

### 场景 7：安全加固

**情境：** 安全团队要求对所有用户输入进行严格校验。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能识别所有输入点
使用 `superpowers:test-driven-development` 技能编写攻击测试用例
```

**七阶段执行过程：**

1. **Brainstorm**：识别所有用户输入点（表单、API、文件上传）
2. **Spec**：定义验证规则（白名单、长度限制、类型检查）
3. **Plan**：后端验证 → 前端验证 → 数据库层防护 → 安全测试
4. **TDD**：编写攻击测试用例（SQL 注入 payload、XSS 脚本）
5. **Subagent Dev**：一个代理加固后端，一个代理加固前端
6. **Review**：运行 OWASP ZAP 扫描，人工渗透测试
7. **Finalize**：更新安全规范文档，加入代码审查清单

**为什么有效：** 安全不是"加点验证"就完事，TDD 阶段的攻击测试确保防护有效。

---

### 场景 8：数据迁移项目

**情境：** 将用户表从 MySQL 迁移到 PostgreSQL。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能识别迁移风险
使用 `superpowers:dispatching-parallel-agents` 技能并行处理迁移任务
```

**七阶段执行过程：**

1. **Brainstorm**：识别风险：数据一致性、停机时间、回滚方案
2. **Spec**：定义迁移策略（双写、增量同步、切换流量）
3. **Plan**： schema 转换 → 数据同步 → 验证 → 切换 → 清理
4. **TDD**：编写数据一致性校验测试、回滚测试
5. **Subagent Dev**：一个代理写同步脚本，一个代理改应用层
6. **Review**：模拟故障场景（同步中断、数据冲突）
7. **Finalize**：更新运维手册，添加监控告警

**为什么有效：** 数据迁移是高风险操作，Spec 阶段强制定义回滚方案。

---

### 场景 9：CI/CD 流水线建设

**情境：** 为新项目搭建完整的 CI/CD 流程。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能规划流水线需求
使用 `superpowers:subagent-driven-development` 技能并行配置各环境
```

**七阶段执行过程：**

1. **Brainstorm**：识别需求：测试类型、部署环境、审批流程
2. **Spec**：定义流水线阶段、触发条件、通知机制
3. **Plan**：单元测试 → 集成测试 → 构建镜像 → 部署测试环境 → 生产
4. **TDD**：编写流水线测试（模拟提交触发全流程）
5. **Subagent Dev**：一个代理写 CI 配置，一个代理写部署脚本
6. **Review**：模拟失败场景（测试失败、部署回滚）
7. **Finalize**：更新运维文档，团队培训

---

### 场景 10：技术债务清理

**情境：** 清理项目中过时的依赖和废弃的代码。

**当前可用命令：**
```
使用 `superpowers:brainstorming` 技能扫描技术债务
使用 `superpowers:subagent-driven-development` 技能并行清理
```

**七阶段执行过程：**

1. **Brainstorm**：扫描项目，列出过时依赖、废弃 API、死代码
2. **Spec**：定义清理范围、更新策略（一次性/分批次）、回归测试
3. **Plan**：依赖审计 → 制定更新计划 → 分批执行 → 回归测试
4. **TDD**：确保现有测试覆盖关键功能，必要时补充测试
5. **Subagent Dev**：一个代理更新依赖，一个代理清理代码
6. **Review**：运行全量测试，检查是否有行为变化
7. **Finalize**：更新 CHANGELOG，通知团队

---

### 场景 11：TDD 测试驱动开发（单独使用）

**情境：** 需要开发一个复杂的业务逻辑模块，希望确保代码质量和测试覆盖。

**使用技能：**
```
使用 `superpowers:test-driven-development` 技能
```

**典型应用场景：**

| 场景类型 | 具体案例 |
|----------|----------|
| 核心业务逻辑 | 订单计算、优惠券叠加规则、库存扣减 |
| 边界条件复杂 | 时区处理、闰年计算、货币转换 |
| 并发敏感 | 秒杀、抢购、分布式锁 |
| 数据校验 | 表单验证、API 参数校验、业务规则检查 |
| 算法实现 | 搜索算法、排序优化、路径计算 |

**TDD 执行流程（红 - 绿 - 重构）：**

```
1. 红：编写一个失败的测试
   - 定义输入和期望输出
   - 运行测试 → 失败（预期）

2. 绿：编写最小实现代码
   - 只写能让测试通过的代码
   - 运行测试 → 通过

3. 重构：优化代码结构
   - 保持测试通过
   - 消除重复、改善命名、提取方法

4. 重复：回到步骤 1，直到功能完成
```

**调用方式示例：**
```
使用 superpowers:test-driven-development 技能，实现用户注册功能
- 邮箱格式校验
- 密码强度要求
- 邮箱唯一性检查
```

**为什么有效：** 
- 测试覆盖率达到 100%
- 代码设计更合理（为可测试性而设计）
- 重构时有安全保障
- 文档即测试（测试即文档）

---

### 场景 12：子代理并行开发（单独使用）

**情境：** 有一个大型任务包含多个独立子任务，需要并行开发提高效率。

**使用技能：**
```
使用 `superpowers:subagent-driven-development` 技能
```

**典型应用场景：**

| 场景类型 | 主代理职责 | 子代理分工 |
|----------|------------|------------|
| 全栈功能开发 | 协调任务、API 设计 | UI 代理 + 后端代理 + 测试代理 |
| 多模块重构 | 架构设计、接口定义 | 模块 A 代理 + 模块 B 代理 + 数据迁移代理 |
| 多语言项目 | 技术选型、代码评审 | Go 代理 + Python 代理 + 前端代理 |
| 文档 + 代码 | 代码审查、质量把控 | 代码实现代理 + 文档编写代理 |
| 多环境部署 | 部署策略制定 | 开发环境代理 + 测试环境代理 + 生产环境代理 |

**执行流程：**

```
1. 任务分解
   - 主代理分析任务依赖关系
   - 识别可并行执行的子任务

2. 子代理创建
   - 为每个独立子任务分配子代理
   - 明确每个子代理的职责边界

3. 并行开发
   - 各子代理独立工作
   - 主代理协调进度、解决冲突

4. 集成合并
   - 汇总各子代理成果
   - 解决集成冲突
   - 统一代码风格
```

**调用方式示例：**
```
使用 superpowers:subagent-driven-development 技能，开发完整的用户管理系统
- 主代理：负责 API 设计和代码审查
- 子代理 1（UI）：React 组件开发
- 子代理 2（Backend）：后端业务逻辑
- 子代理 3（Test）：单元测试和集成测试
- 子代理 4（Docs）：API 文档和用户手册
```

**为什么有效：**
- 并行开发，效率提升 2-4 倍
- 专业化分工，每个代理聚焦特定领域
- 主代理统筹，避免重复工作和冲突
- 适合大型项目或紧急交付

---

## 4. 与 OpenSpec 对比

Superpowers 和 OpenSpec 都是规格驱动开发框架，但有不同的侧重点：

| 维度 | Superpowers | OpenSpec |
|------|-------------|----------|
| **核心理念** | 工程纪律优先，强制执行 TDD | 规格对齐优先，先写规格再编码 |
| **工作流** | 7 阶段固定流水线 | 4 步核心流程（Propose → Apply → Archive） |
| **测试策略** | 强制 TDD，测试不通过不能提交 | 测试是任务的一部分，但不强制 |
| **适用场景** | 生产级项目、复杂系统、遗留重构 | 新功能开发、API 设计、团队协作 |
| **灵活性** | 较低，流程固定 | 较高，可选择 Core/Expanded Profile |
| **学习曲线** | 较陡峭，需要适应 TDD | 较平缓，容易上手 |
| **与 AI 工具集成** | 深度集成，技能包形式 | 轻量级，Slash Commands |

### 如何选择

| 你的情况 | 推荐框架 |
|----------|----------|
| 生产环境项目，质量要求高 | Superpowers |
| 快速原型开发 | OpenSpec |
| 遗留系统重构，需要建立测试 | Superpowers |
| 新功能开发，需求明确 | 两者皆可 |
| 团队多人协作，需要规格沉淀 | OpenSpec |
| 单人开发，需要自律 | Superpowers |

---

## 5. 最佳实践

### 启动工作流的时机

| 场景 | 建议 |
|------|------|
| 新需求开发 | ✅ 使用 `superpowers:brainstorming` + `superpowers:writing-plans` |
| 小 Bug 修复 | ⚠️ 可简化流程，使用 `superpowers:systematic-debugging` |
| 简单脚本 | ❌ 不要用，太繁琐 |
| 重构老代码 | ✅ 强烈建议使用 `superpowers:test-driven-development` |

### TDD 实践技巧

```
使用 `superpowers:test-driven-development` 技能：

1. 先写"最小失败测试"
2. 看到测试失败（红色）后，再写实现代码
3. 测试通过（绿色）后，重构代码
4. 重复上述步骤，直到功能完成
```

### 子代理使用策略

使用 `superpowers:subagent-driven-development` 或 `superpowers:dispatching-parallel-agents`：

主代理负责任务协调，子代理负责专业化工作：

| 子代理类型 | 职责 |
|------------|------|
| UI Agent | 前端界面、组件开发 |
| Backend Agent | 业务逻辑、API 实现 |
| Test Agent | 测试用例编写、压力测试 |
| Docs Agent | 文档编写、注释更新 |

### 与 Git 工作流集成

使用 `superpowers:using-git-worktrees` 技能进行隔离开发：

```bash
# 每个阶段完成后提交
git add .
git commit -m "spec: 完成优惠券规格定义"

git add .
git commit -m "test: 添加优惠券测试用例"

git add .
git commit -m "feat: 实现优惠券功能"
```

---

## 6. 常见问题

### Q: Superpowers 会让开发变慢吗？

**A:** 短期来看，是的——因为增加了思考和测试的环节。但长期来看：
- 减少了返工（需求理解错误导致的重写）
- 减少了 Bug（TDD 确保代码质量）
- 减少了维护成本（规格文档帮助理解）

**经验法则：** 对于预计超过 1 天工作量的任务，使用 Superpowers 通常能节省总体时间。

### Q: 可以在中途退出工作流吗？

**A:** 可以。如果确实需要暂停当前任务，可以告知 AI 当前状态。
下次继续时，从上一个完成的阶段 resume。

### Q: 如何配置自定义工作流？

**A:** Superpowers 技能会根据任务自动调整流程。
你可以通过调用不同技能来控制流程：

- 需要更严格的 TDD：使用 `superpowers:test-driven-development`
- 需要跳过头脑风暴：直接开始 `superpowers:writing-plans`
- 需要强制评审：使用 `superpowers:requesting-code-review`

### Q: 和 OpenSpec 可以同时使用吗？

**A:** 可以。两者不是互斥的：
- 用 OpenSpec 管理规格文档
- 用 Superpowers 执行开发流程

事实上，很多团队会同时使用两者。

### Q: AI 不遵守流程怎么办？

**A:** Superpowers 技能会引导 AI 遵循流程：

- 如果 AI 试图跳过 TDD，提醒它使用 `superpowers:test-driven-development`
- 如果 AI 试图直接写代码，提醒它先使用 `superpowers:brainstorming` 或 `superpowers:writing-plans`

你可以这样说：
```
请使用 superpowers:test-driven-development 技能，先写测试
```

---

## 7. 废弃命令迁移指南

### 已废弃的命令

以下命令在新版本中已废弃，请使用对应的技能调用：

| 废弃命令 | 替代方案 |
|----------|----------|
| `/superpowers:start` | `superpowers:using-superpowers` 或 `superpowers:brainstorming` |
| `/superpowers:test-first` | `superpowers:test-driven-development` |
| `/stop` | 直接告知 AI 暂停意图 |

### 迁移示例

**旧方式：**
```bash
/superpowers:start 添加用户登录功能
```

**新方式：**
```
使用 superpowers:brainstorming 技能讨论用户登录功能需求
```

或完整流程：
```
1. superpowers:brainstorming - 需求分析
2. superpowers:writing-plans - 编写计划
3. superpowers:test-driven-development - 测试驱动开发
4. superpowers:subagent-driven-development - 并行开发
5. superpowers:requesting-code-review - 代码评审
```

---

## 8. 如何升级/迁移

### 无需任何安装

Superpowers 技能已内置于 Claude Code 环境中，**无需安装**，直接使用即可。

### 迁移步骤

**步骤 1：更新使用习惯**

| 旧习惯 | 新方式 |
|--------|--------|
| 输入 `/superpowers:start xxx` | 直接在对话中说"使用 superpowers:brainstorming 技能" |
| 输入 `/superpowers:test-first xxx` | 直接说"使用 superpowers:test-driven-development 技能" |
| 输入 `/stop` | 直接说"暂停当前任务" |

**步骤 2：查看可用技能**

在对话中询问："有哪些 superpowers 技能可用？"

**步骤 3：开始使用**

最简单的方式：
```
使用 superpowers:using-superpowers 技能
```

这会显示完整的使用指南。

### 快速参考卡片

```
┌─────────────────────────────────────────────────────────┐
│  Superpowers 技能快速参考                               │
├─────────────────────────────────────────────────────────┤
│  开始新任务      →  superpowers:brainstorming           │
│  编写计划        →  superpowers:writing-plans           │
│  执行计划        →  superpowers:executing-plans         │
│  测试驱动开发    →  superpowers:test-driven-development │
│  并行开发        →  superpowers:subagent-driven-...     │
│  代码评审        →  superpowers:requesting-code-review  │
│  完成前验证      →  superpowers:verification-before-... │
│  系统调试        →  superpowers:systematic-debugging    │
│  完整指南        →  superpowers:using-superpowers       │
└─────────────────────────────────────────────────────────┘
```

---

## 9. TDD 与子代理专项场景

详细场景说明见 [场景 11](#场景 11tdd 测试驱动开发单独使用) 和 [场景 12](#场景 12子代理并行开发单独使用)。

---

## 资源

- **官方文档**: 请参考项目中的 `.spec-workflow/` 目录
- **技能列表**: 在 Claude Code 中查看可用的 superpowers 技能

---

## 总结

Superpowers 的核心价值在于**给 AI 开发加上"护栏"**。通过七阶段流水线：

| 传统 AI 开发 | Superpowers 开发 |
|--------------|------------------|
| 直接写代码，可能遗漏边界 | Brainstorm 阶段先识别风险 |
| 规格在对话中，容易忘记 | Spec 阶段沉淀为文档 |
| 写完再测，测试覆盖不全 | TDD 强制先测后写 |
| 单一代理，效率有限 | Subagent 专业化分工 |
| 没有自检，质量参差不齐 | Review 阶段强制审查 |

**开始使用的最小步骤：**

1. 使用 `superpowers:using-superpowers` 技能获取完整指南
2. 使用 `superpowers:brainstorming` 技能开始一个新需求
3. 使用 `superpowers:test-driven-development` 技能体验 TDD 流程

**记住：** 如果你只是想写个**简单的脚本**，**不要用它**，因为它太繁琐了。但如果你在开发一个**生产环境的 App**，或者在维护复杂的旧代码库，**强烈建议使用**。它能帮你建立起一套 AI 无法逾越的"质量防火墙"。
