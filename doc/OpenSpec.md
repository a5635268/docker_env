# OpenSpec 规格驱动开发指南

`@fission-ai/openspec` 是由 Fission AI 开发的一款轻量级 **规格驱动开发（Spec-Driven Development, SDD）** 框架。它的核心理念是"**先对齐规格，再编写代码**"，通过在代码库中维护一套 Markdown 格式的规格文档，让开发者和 AI 编码助手（如 Claude Code、Cursor、Windsurf 等）对"什么是完成"达成共识。

---

## 目录

1. [快速开始](#1-快速开始)
2. [核心工作流](#2-核心工作流-core-profile)
3. [使用场景详解](#3-使用场景详解)
4. [高级用法](#4-高级用法-expanded-profile)
5. [最佳实践](#5-最佳实践)
6. [常见问题](#6-常见问题)

---

## 1. 快速开始

### 安装

```bash
npm install -g @fission-ai/openspec@latest
```

### 初始化

进入项目根目录执行：

```bash
openspec init
```

初始化过程中会询问你使用的 AI 工具（如 Claude Code、Cursor、Windsurf 等），它会自动配置对应的 **Slash Commands**（斜杠命令）。

### 目录结构

初始化后，项目中会增加以下结构：

```
your-project/
├── openspec/
│   ├── specs/           # 主规格库（系统当前状态的完整描述）
│   ├── changes/         # 进行中的变更规格
│   ├── archive/         # 已归档的历史变更
│   └── config.json      # 配置文件
└── ...
```

---

## 2. 核心工作流 (Core Profile)

OpenSpec 将开发流程分为四个核心步骤：

### 第一步：提出变更 (`/opsx:propose`)

当你有一个新需求或 Bug 修复时，告诉 AI 你的意图。

**用法：**
```
/opsx:propose <需求描述>
```

**示例：**
```
/opsx:propose 添加用户登录功能，支持邮箱和密码认证
```

**发生什么：** AI 会在 `openspec/changes/<change-name>/` 下创建：

| 文件 | 作用 |
|------|------|
| `proposal.md` | 解释"为什么"和"做什么"，业务背景 |
| `specs/` | 定义具体的需求差异（Delta Specs） |
| `design.md` | 描述技术实现方案、架构决策 |
| `tasks.md` | 自动生成的实施清单 |

### 第二步：评审规格

在代码编写前，查看生成的 `proposal.md`、`specs/` 和 `design.md`。

**如果 AI 理解有误：** 直接通过对话让它修正规格文档，而不是修改代码。

**评审要点：**
- [ ] 需求是否完整覆盖了边界情况？
- [ ] 技术方案是否合理？
- [ ] 是否有遗漏的测试场景？

### 第三步：执行开发 (`/opsx:apply`)

规格对齐后，让 AI 开始干活。

**用法：**
```
/opsx:apply
```

**发生什么：** AI 会读取 `tasks.md`，按部就班地：
1. 修改代码、创建文件
2. 运行测试
3. 自动在任务列表上打勾 `[x]`

### 第四步：归档变更 (`/opsx:archive`)

开发完成并通过验证后，合并规格。

**用法：**
```
/opsx:archive
```

**发生什么：**
1. 将本次变更的规格（Delta）合并到主规格库 `openspec/specs/` 中
2. 将变更记录移至 `archive/`
3. 此时，规格库反映了系统的最新真实状态

---

## 3. 使用场景详解

### 场景 1：新功能开发

**情境：** 你需要在现有 API 服务中添加一个新的用户注册接口。

```
/opsx:propose 添加用户注册 API，包含邮箱验证和密码强度校验
```

**生成的规格包含：**
- 接口定义（POST /api/auth/register）
- 请求参数格式（email, password, confirmPassword）
- 响应格式（成功/错误码）
- 验证规则（邮箱格式、密码长度 8-20 位、必须包含字母和数字）
- 数据库表变更（users 表新增字段）

**为什么有效：** 在写代码前，你先和 AI 对齐了接口契约，避免了"写到一半发现需求理解不一致"的问题。

---

### 场景 2：Bug 修复

**情境：** 用户报告在高并发场景下，订单状态偶尔会出现不一致。

```
/opsx:propose 修复订单状态并发更新导致的数据不一致问题
```

**生成的规格包含：**
- 问题复现步骤
- 根本原因分析（缺少分布式锁）
- 修复方案（引入 Redis 锁机制）
- 测试场景（模拟并发请求）

**为什么有效：** 强制 AI 先分析根因再提出方案，而不是直接"试错式"修改代码。

---

### 场景 3：重构现有代码

**情境：** 某个模块的代码耦合严重，需要重构为独立服务。

```
/opsx:propose 将用户认证模块从单体应用中拆分为独立微服务
```

**生成的规格包含：**
- 当前架构问题分析
- 目标架构图
- 拆分步骤（数据库迁移、接口适配、服务发现）
- 回滚方案

**为什么有效：** 重构前明确"完成"的定义，避免重构过程中迷失方向。

---

### 场景 4：技术栈迁移

**情境：** 将项目从 Webpack 迁移到 Vite。

```
/opsx:propose 将前端构建工具从 Webpack 迁移到 Vite 5.x
```

**生成的规格包含：**
- 迁移原因（构建速度、热更新性能）
- 配置差异对比
- 需要修改的文件清单
- 兼容性测试项

**为什么有效：** 迁移类任务容易遗漏细节，规格文档确保所有变更点都被覆盖。

---

### 场景 5：添加集成测试

**情境：** 为新开发的支付模块添加端到端测试。

```
/opsx:propose 为支付流程添加 E2E 测试，覆盖成功支付、失败重试、退款场景
```

**生成的规格包含：**
- 测试框架选择（Playwright/Cypress）
- 测试用例清单
- Mock 数据定义
- CI/CD 集成方式

---

### 场景 6：API 版本升级

**情境：** 将第三方 API 从 v1 升级到 v2。

```
/opsx:propose 升级 Stripe API 从 v1 到 v2，适配新的认证方式和响应格式
```

**生成的规格包含：**
- API 差异对比表
- 受影响的代码位置
- 向后兼容策略
- 灰度发布计划

---

### 场景 7：性能优化

**情境：** 首页加载速度慢，需要优化。

```
/opsx:propose 优化首页加载性能，目标 LCP < 2.5s
```

**生成的规格包含：**
- 当前性能分析（Lighthouse 报告）
- 瓶颈识别（图片未压缩、接口响应慢）
- 优化措施（WebP 转换、Redis 缓存、代码分割）
- 验收标准

---

### 场景 8：文档驱动开发

**情境：** 为新团队成员准备项目文档。

```
/opsx:propose 生成项目架构文档和开发环境搭建指南
```

**生成的规格包含：**
- 系统架构图
- 组件依赖关系
- 环境配置步骤
- 常见问题 FAQ

---

## 4. 高级用法 (Expanded Profile)

如果你需要更精细的控制，可以开启 **Expanded Profile**（扩展配置）：

| 命令 | 用途 | 使用场景 |
|------|------|----------|
| `/opsx:explore` | 在正式提出变更前，让 AI 深入分析代码库并回答可行性问题 | 评估技术可行性、了解代码结构 |
| `/opsx:verify` | 自动检查当前代码实现是否符合 `specs/` 中定义的场景 | CI/CD 集成、代码评审 |
| `/opsx:onboard` | **推荐新手使用**。一个 15 分钟的交互式教程，带你走完一遍完整流程 | 团队培训、新项目上手 |
| `/opsx:ff` | "快进"模式，一次性生成所有规划文档（Proposal, Specs, Tasks） | 简单变更、时间紧迫 |

### `/opsx:explore` 示例

```
/opsx:explore 我们的认证系统是如何处理 JWT 过期的？
```

AI 会：
1. 搜索相关代码文件
2. 分析认证流程
3. 生成分析报告
4. 回答你的问题

### `/opsx:verify` 示例

在 CI 流水线中：

```bash
# 验证当前代码是否符合规格
openspec verify

# 如果发现不符合，会列出：
# - 缺失的测试用例
# - 未实现的接口
# - 与规格不符的实现
```

---

## 5. 最佳实践

### 规格撰写原则

1. **原子性**：每个变更只关注一个功能点，避免"大爆炸"式变更
2. **可验证**：每条规格都应该有明确的验收标准
3. **可追溯**：使用有意义的变更名称，如 `feat-user-login` 而非 `change-1`

### 团队协作

```bash
# 评审同事的规格变更
git diff openspec/changes/

# 规格也应该 Code Review
# 在 PR 中先评审规格，再评审代码
```

### Git 集成

```bash
# 推荐将 openspec/ 提交到 Git
git add openspec/
git commit -m "feat: 添加用户登录规格"

# 归档后更新主规格库
git commit -m "docs: 合并用户登录到主规格库"
```

### 与现有流程集成

| 现有流程 | OpenSpec 集成点 |
|----------|-----------------|
| Jira/Linear | 将 `proposal.md` 链接附在任务卡片 |
| GitHub Issues | 在 Issue 中引用 `specs/` 文件 |
| Confluence | 定期将 `archive/` 同步到知识库 |

---

## 6. 常见问题

### Q: OpenSpec 适合小项目吗？

**A:** 适合。即使是单人项目，规格文档也能帮助你：
- 理清思路后再动手
- 未来回顾"当时为什么这么设计"
- 与未来 AI 助手高效协作

### Q: 规格变更频繁怎么办？

**A:** 这正是 OpenSpec 要解决的问题。如果需求在开发过程中频繁变化：
1. 先更新规格文档
2. 重新评审
3. 再执行 `/opsx:apply`

规格文档的变化历史本身就是需求演进的记录。

### Q: 可以和多个 AI 工具一起用吗？

**A:** 可以。OpenSpec 支持 20+ 种 AI 工具，包括：
- Claude Code
- Cursor
- Windsurf
- GitHub Copilot Chat
- Continue

切换工具后，重新运行 `openspec init` 配置对应的 Slash Commands。

### Q: 规格文档会泄露敏感信息吗？

**A:** OpenSpec 的设计原则是**离线优先**：
- 所有数据存储在本地 `openspec/` 目录
- 不强制上传云端
- 可选择性地将敏感规格加入 `.gitignore`

### Q: 如何管理大型项目的规格？

**A:** 使用子目录组织：

```
openspec/
├── specs/
│   ├── auth/       # 认证相关
│   ├── payment/    # 支付相关
│   └── api/        # API 规范
├── changes/
│   ├── feat-user-login/
│   └── fix-order-bug/
└── archive/
```

---

## 资源

- **官方文档**: [https://openspec.dev](https://openspec.dev)
- **GitHub**: [https://github.com/fission-ai/openspec](https://github.com/fission-ai/openspec)
- **演示视频**: [I Found the Simplest AI Dev Tool Ever](https://www.youtube.com/watch?v=cQv3ocbsKHY)

---

## 总结

OpenSpec 的核心价值在于**建立开发者与 AI 之间的共同语言**。通过规格文档：

| 传统开发 | Spec 驱动开发 |
|----------|---------------|
| 需求在对话中口头描述 | 需求以结构化文档呈现 |
| AI 直接写代码，可能理解偏差 | AI 先写规格，确认后再编码 |
| 完成后发现"这不是我想要的" | 开发前就对"完成"达成共识 |
| 知识分散在聊天记录中 | 知识沉淀在 Git 仓库中 |

**开始使用的最小步骤：**

```bash
npm install -g @fission-ai/openspec
openspec init
/opsx:onboard  # 花 15 分钟体验完整流程
```
