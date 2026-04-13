# AI 协同开发实战指南：Claude Code + OpenSpec + Superpowers

> 原文：[Claude Code + OpenSpec + Superpowers：AI 协同开发实战指南](https://zhuanlan.zhihu.com/p/2020917177901924410) - 微风吹过
>
> 本文档整理了原文的核心工作流内容，归档于 doc 目录供团队参考。

---

## 核心工作流：从需求到上线

完整流程分为 5 个阶段，结合了 OpenSpec 的规格管理和 Superpowers 的七阶段流水线：

```
┌─────────────────────────────────────────────────────────────────┐
│  阶段 1          阶段 2           阶段 3           阶段 4        │
│  OpenSpec    →  Superpowers   →  Superpowers   →  Superpowers   │
│  需求对齐       Brainstorming    Writing Plans    执行          │
│                                                               │
│                      阶段 5                                     │
│                  OpenSpec Archive                               │
└─────────────────────────────────────────────────────────────────┘
```

---

### 阶段 1：OpenSpec 需求对齐

**场景**：老板说"加个用户登录功能"

#### 步骤 1：创建变更提案

```bash
claude
> /opsx:propose 用户登录功能
```

AI 会生成四个文档：

```
openspec/changes/add-user-login/
├── proposal.md      # 为什么做？范围是什么？
├── specs/           # 系统行为变更（Delta Spec）
│   └── auth/
│       └── spec.md
├── design.md        # 技术方案、架构决策
└── tasks.md         # 实现清单（Checklist）
```

**proposal.md 示例：**

```markdown
# 用户登录功能提案

## 背景
当前系统无认证机制，需要添加用户登录功能以保护敏感数据。

## 目标
- 支持邮箱 + 密码登录
- 颁发 JWT Token
- 支持 Token 刷新

## 范围（In Scope）
- [x] 用户登录 API
- [x] JWT 颁发与验证
- [x] Token 刷新机制

## 范围外（Out of Scope）
- [ ] 第三方登录（Google/GitHub）
- [ ] 双因素认证（2FA）
- [ ] 密码找回功能

## 风险
- JWT 密钥管理需要安全存储
- Token 过期策略需要权衡用户体验与安全性
```

> **关键点**：明确写出 **Out of Scope**，防止 AI"过度帮助"。

#### 步骤 2：Review 提案

打开 `proposal.md`，检查：
- 目标是否清晰？
- 范围是否合理？
- 有没有遗漏的边界情况？

**修改方式 1：直接编辑文件**
```bash
vim openspec/changes/add-user-login/proposal.md
# 修改后保存
```

**修改方式 2：让 AI 修改**
```bash
claude
> 修改 proposal.md，增加"密码强度校验"需求
```

---

### 阶段 2：Superpowers Brainstorming

提案确认后，Superpowers 自动激活 **brainstorming** skill。

**AI 会问（Socratic 提问）：**

```
好的，我来帮你细化这个登录功能的设计。先确认几个问题：

1. **用户存储**：用户信息存在哪里？
   - 现有 PostgreSQL 数据库
   - 还是新的用户服务？

2. **密码加密**：使用什么算法？
   - bcrypt（推荐，但慢）
   - argon2（更安全，需要额外依赖）

3. **JWT 过期策略**：
   - Access Token 多久过期？（15 分钟？1 小时？）
   - Refresh Token 多久过期？（7 天？30 天？）

4. **错误处理**：
   - 登录失败几次后锁定账户？
   - 是否需要防暴力破解机制？
```

**逐一回答**，AI 会记录到 `design.md`：

```markdown
# 登录功能设计文档

## 架构决策

### 决策 1：用户存储
- **选择**：现有 PostgreSQL 数据库
- **理由**：减少系统复杂度，避免数据同步问题
- **表结构**：新增 `users` 表

### 决策 2：密码加密
- **选择**：bcrypt（cost=12）
- **理由**：成熟稳定，团队熟悉，性能可接受

### 决策 3：JWT 策略
- **Access Token**：15 分钟
- **Refresh Token**：7 天
- **理由**：平衡安全性与用户体验

### 决策 4：安全防护
- **失败锁定**：5 次失败后锁定 15 分钟
- **防暴力破解**：IP 级别限流（10 次/分钟）
```

---

### 阶段 3：Superpowers Writing Plans

Brainstorming 完成后，Superpowers 自动进入 **writing-plans** skill。

**生成 `tasks.md`：**

```markdown
# 实现任务清单

## 任务 1：数据库迁移（预计 5 分钟）
- [ ] 创建 `users` 表迁移文件
- [ ] 字段：id, email, password_hash, created_at, updated_at
- [ ] 添加唯一索引：email
- [ ] 运行迁移并验证

## 任务 2：密码工具函数（预计 5 分钟）
- [ ] 创建 `src/utils/password.ts`
- [ ] 实现 `hashPassword(password: string): Promise<string>`
- [ ] 实现 `verifyPassword(password, hash): Promise<boolean>`
- [ ] 编写单元测试

## 任务 3：JWT 工具函数（预计 5 分钟）
- [ ] 创建 `src/utils/jwt.ts`
- [ ] 实现 `generateToken(userId, email): string`
- [ ] 实现 `verifyToken(token): Payload | null`
- [ ] 实现 `refreshToken(oldToken): string | null`
- [ ] 编写单元测试

## 任务 4：登录 API（预计 10 分钟）
- [ ] 创建 `src/routes/auth.ts`
- [ ] 实现 `POST /api/login` 端点
- [ ] 验证邮箱格式
- [ ] 验证密码
- [ ] 返回 JWT Token
- [ ] 编写集成测试

## 任务 5：Token 刷新 API（预计 5 分钟）
- [ ] 实现 `POST /api/refresh` 端点
- [ ] 验证 Refresh Token
- [ ] 颁发新的 Access Token
- [ ] 编写集成测试

## 任务 6：中间件与文档（预计 5 分钟）
- [ ] 创建认证中间件 `authMiddleware`
- [ ] 更新 API 文档
- [ ] 更新 .env.example
```

---

### 阶段 4：Superpowers + Claude Code 执行

确认后，Superpowers 激活 **subagent-driven-development** skill。

**执行流程：**

```
[Task 1/6] 数据库迁移
├─ 创建子 Agent
├─ 执行任务
├─ 运行测试 → 通过 ✓
├─ Code Review → 通过 ✓
└─ 提交代码

[Task 2/6] 密码工具函数
├─ 创建子 Agent
├─ 执行任务
├─ 运行测试 → 失败 ✗
│  └─ 错误：bcrypt 未安装
├─ 自动修复：安装 bcrypt
├─ 重新测试 → 通过 ✓
├─ Code Review → 通过 ✓
└─ 提交代码

...（自动继续）
```

**关键特性：**

1. **TDD 强制执行**：先写测试，再写代码

2. **两阶段 Review**：
   - Spec 合规性检查（是否按 tasks.md 执行）
   - 代码质量检查（命名、结构、复杂度）

3. **自动修复**：测试失败时自动调试

4. **进度追踪**：实时更新 tasks.md 的 Checkboxes

---

### 阶段 5：OpenSpec Archive

所有任务完成后，归档变更：

```bash
> /opsx:archive
```

**Archive 做的事：**

1. **合并 Delta Spec**：将 `changes/add-user-login/specs/` 合并到 `specs/`
2. **移动文件夹**：`changes/add-user-login/` → `changes/archive/2026-03-27-add-user-login/`
3. **更新 AGENTS.md**：记录本次变更摘要

**合并后的 `specs/auth/spec.md`：**

```markdown
# 认证规范

## 目的
用户认证和会话管理。

## 需求

### 需求：用户登录
系统应在用户成功登录后颁发 JWT Token。

#### 场景：有效凭证
- GIVEN 用户有有效凭证
- WHEN 用户提交登录表单
- THEN 返回 JWT Token
- AND 重定向到仪表盘

#### 场景：无效凭证
- GIVEN 无效凭证
- WHEN 用户提交登录表单
- THEN 显示错误消息
- AND 不颁发 Token

### 需求：Token 刷新
系统应支持使用 Refresh Token 获取新的 Access Token。

#### 场景：有效的 Refresh Token
- GIVEN 用户有未过期的 Refresh Token
- WHEN 调用 `/api/refresh`
- THEN 返回新的 Access Token

### 需求：账户锁定
系统应在连续 5 次登录失败后锁定账户 15 分钟。

#### 场景：多次失败
- GIVEN 用户连续失败 5 次
- WHEN 第 6 次尝试登录
- THEN 返回"账户已锁定"错误
- AND 15 分钟内不允许登录
```

> **价值**：Spec 成为 **可执行的文档**，下次新增功能时 AI 会自动读取。

---

## 进阶技巧

### 1. 并行开发多个功能

OpenSpec 的 **Delta Spec** 机制支持并行开发：

```bash
# 终端 1：开发登录功能
claude
> /opsx:propose 用户登录

# 终端 2：开发暗黑模式
claude
> /opsx:propose 暗黑模式

# 两个变更独立进行，互不冲突
```

**目录结构：**

```
openspec/changes/
├── add-user-login/
│   ├── proposal.md
│   └── specs/...
└── add-dark-mode/
    ├── proposal.md
    └── specs/...
```

### 2. 自定义工作流 Schema

可以通过配置文件自定义工作流行为：

```yaml
# .superpowers/config.yaml
workflow:
  skipBrainstorm: false
  enforceTDD: true
  requireReview: true
  parallelAgents: 3
```

### 3. 验证实现与 Spec 的一致性

在 CI/CD 中集成验证：

```bash
# 提交前验证
openspec verify

# 如果发现不符合，会列出：
# - 缺失的测试用例
# - 未实现的接口
# - 与规格不符的实现
```

### 4. 使用 Git Worktrees 隔离开发

对于大型变更，使用 Git Worktrees：

```bash
# 创建新的 worktree 开发功能
git worktree add -b feature/login ../login-feature

# 在 worktree 中开发
cd ../login-feature
claude
> /opsx:propose 用户登录

# 完成后返回主分支
cd ..
git worktree remove login-feature
```

---

## 避坑指南

### OpenSpec 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| Spec 过于模糊 | 没有明确验收标准 | 使用 GIVEN/WHEN/THEN 格式 |
| 范围蔓延 | Out of Scope 不清晰 | 明确列出排除项 |
| 归档冲突 | 多人修改同一 Spec | 先合并主分支再归档 |

### Superpowers 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| TDD 卡壳 | 测试依赖缺失 | 先安装依赖再写测试 |
| 子代理冲突 | 多个 Agent 改同一文件 | 使用 Git Worktrees 隔离 |
| Review 过于严格 | 默认配置太严格 | 调整 config.yaml |

### Claude Code 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| 幻觉代码 | 没有读取现有代码 | 先用 `/explore` 了解代码库 |
| 过度修改 | 需求理解偏差 | 先写 Spec 确认再执行 |
| 测试遗漏 | 边界情况未覆盖 | Brainstorming 阶段多问"如果...会怎样" |

---

## 总结：三者协同的价值

| 工具 | 职责 | 产出物 |
|------|------|--------|
| **OpenSpec** | 规格管理、变更追踪 | proposal.md, specs/, tasks.md |
| **Superpowers** | 流程控制、质量保障 | design.md, 测试用例，Code Review |
| **Claude Code** | 代码执行、任务完成 | 实际代码、测试文件 |

### 适用场景

✅ **推荐使用**：
- 生产环境功能开发
- 多人协作项目
- 复杂业务逻辑实现
- 需要长期维护的代码

⚠️ **谨慎使用**：
- 简单脚本（太繁琐）
- 一次性原型（可能过度设计）
- 紧急修复（流程太长）

---

## 快速开始

```bash
# 1. 安装工具
npm install -g @fission-ai/openspec
/plugin marketplace add superpowers-marketplace
/plugin install using-superpowers@superpowers-marketplace

# 2. 初始化项目
openspec init

# 3. 开始第一个功能
claude
> /opsx:propose 我的第一个功能
```
