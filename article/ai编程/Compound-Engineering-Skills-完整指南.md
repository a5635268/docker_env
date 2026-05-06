# Compound Engineering Skills 完整指南

> CE 技能全集参考文档，30+ 专为 AI 编程助手优化的技能，覆盖开发全生命周期

---

## 概述

Compound Engineering（CE）提供了一套**复利式工程**技能体系，核心特点：

- ✅ **知识沉淀** - 每次开发产出可复用资产
- ✅ **闭环流程** - Plan → Work → Review → Compound → Repeat
- ✅ **多 Agent 协作** - 交叉审查、并行任务
- ✅ **AI 优先设计** - 输出紧凑，Token 高效

---

## Skills 分类总览

| 分类 | Skills 数量 | 核心用途 |
|------|------------|----------|
| **Session 管理** | 3 | 搜索、发现、提取历史会话 |
| **设计与创意** | 3 | UI 设计、创意生成、迭代优化 |
| **Review 与 Debug** | 3 | 调试、代码审查、文档审查 |
| **Git 工作流** | 4 | 提交、PR、任务执行、Worktree |
| **规划与 Brainstorm** | 2 | 结构化规划、协作式头脑风暴 |
| **知识管理** | 2 | 沉淀解决方案、刷新知识库 |
| **证据与协作** | 2 | 演示录制、协作编辑 |
| **领域特定** | 3 | Slack 搜索、Rails 风格、图片生成 |
| **实用工具** | 4 | 分支清理、PR 反馈、浏览器测试、架构设计 |

---

## 1. Session 管理 Skills

### ce-sessions

**用途**：搜索历史会话记录，获取上下文

**核心功能**：
- 搜索 Claude Code、Codex、Cursor 的历史 session
- 按时间范围查询
- 支持 "same repo" / "same file" 模式

**使用语法**：
```bash
/ce-sessions <query>
/ce-sessions --repo=<repo-name>
/ce-sessions --time="last 7 days"
```

**参数说明**：

| 参数 | 说明 | 示例 |
|------|------|------|
| `query` | 搜索关键词 | `"authentication bug"` |
| `--repo` | 按仓库名过滤 | `--repo=myproject` |
| `--time` | 时间范围 | `--time="last 30 days"` |

**典型场景**：
1. 查找之前解决过的类似问题
2. 了解项目的开发历史
3. 获取上下文避免重复踩坑

---

### ce-session-inventory

**用途**：发现并列出所有可用 session 文件

**核心功能**：
- 跨平台搜索（Claude Code、Codex、Cursor）
- 显示 session 元数据（时间、repo、tokens）
- 按时间窗口过滤

**使用语法**：
```bash
/ce-session-inventory
/ce-session-inventory --from=<date> --to=<date>
```

**输出格式**：
```
Session ID    | Repo         | Date       | Tokens | Path
------------- | ------------ | ---------- | ------ | ------
sess-001      | myproject    | 2026-04-25 | 12K    | ~/.claude/sessions/...
```

---

### ce-session-extract

**用途**：提取会话骨架或错误签名

**核心功能**：
- 解析 JSONL 格式 session 文件
- 提取关键对话节点
- 生成错误签名用于诊断

**使用语法**：
```bash
/ce-session-extract <session-id>
/ce-session-extract --error-only
```

---

## 2. 设计与创意 Skills

### ce-frontend-design

**用途**：创建生产级 Web UI

**核心功能**：
- 自动检测项目设计系统
- 4 种工作模式（A/B/C/D）
- Tailwind、React、Vue 支持

**工作模式**：

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **A** | 全自动设计 | 快速原型 |
| **B** | 交互式设计 | 需用户确认 |
| **C** | 设计系统优先 | 已有设计系统 |
| **D** | 代码优先 | 从现有代码改进 |

**使用语法**：
```bash
/ce-frontend-design "创建登录页面"
/ce-frontend-design --mode=B "优化首页布局"
```

---

### ce-ideate

**用途**：生成并评估创意方案

**核心功能**：
- 6 框架发散式创意生成
- 自动批判性评估
- 支持 "Product" 子模式

**创意框架**：
1. **Analogy** - 类比借鉴
2. **Combination** - 组合创新
3. **Inversion** - 反向思考
4. **Constraint** - 约束驱动
5. **Random** - 随机刺激
6. **Market** - 市场导向

**使用语法**：
```bash
/ce-ideate "如何提升用户留存"
/ce-ideate --product "电商优惠券方案"
```

---

### ce-optimize

**用途**：指标驱动的迭代优化

**核心功能**：
- 定义 Hard/Judge 指标
- 自动实验记录
- 收敛检测

**指标类型**：

| 类型 | 说明 | 示例 |
|------|------|------|
| **Hard Metric** | 可量化指标 | 加载时间 < 2s |
| **Judge Metric** | 人工评估 | UI 美观度 |

**使用语法**：
```bash
/ce-optimize "优化首页性能" --hard="load_time<2s"
```

---

## 3. Review 与 Debug Skills

### ce-debug

**用途**：系统化调试和根因分析

**核心功能**：
- 4 阶段调试流程
- 测试优先纪律
- 自动错误签名提取

**调试流程**：
```
Phase 1: Observe → 观察现象
Phase 2: Orient → 分析可能原因
Phase 3: Decide → 选择解决方案
Phase 4: Act → 执行并验证
```

**使用语法**：
```bash
/ce-debug "测试失败: auth test"
```

---

### ce-code-review

**用途**：结构化多维度代码审查

**核心功能**：
- 18 种审查角色（Persona）
- P0-P3 严重度分级
- 自动路由规则

**审查角色**：

| 优先级 | 角色 | 检查重点 |
|--------|------|----------|
| P0 | ce-correctness-reviewer | 逻辑错误、边界情况 |
| P0 | ce-maintainability-reviewer | 过度抽象、命名 |
| P1 | ce-security-reviewer | 安全漏洞（仅安全相关改动） |
| P1 | ce-performance-reviewer | 性能瓶颈（仅性能相关改动） |
| P2 | ce-testing-reviewer | 测试覆盖 |
| P3 | ce-pattern-recognition-specialist | 设计模式匹配 |

**使用语法**：
```bash
/ce-code-review
/ce-code-review --diff=<file>
```

---

### ce-doc-review

**用途**：需求文档和计划审查

**核心功能**：
- 多角色分析
- 5 种条件性审查视角

**审查视角**：

| 视角 | 触发条件 | 检查重点 |
|------|----------|----------|
| ce-product-lens-reviewer | 产品需求 | 战略一致性 |
| ce-security-lens-reviewer | 安全相关 | 威胁模型 |
| ce-feasibility-reviewer | 技术方案 | 实施可行性 |
| ce-scope-guardian-reviewer | 复杂方案 | 范围控制 |
| ce-design-lens-reviewer | UI/UX 方案 | 信息架构 |

**使用语法**：
```bash
/ce-doc-review docs/specs/feature.md
```

---

## 4. Git 工作流 Skills

### ce-commit

**用途**：创建规范的 Git 提交

**核心功能**：
- 自动分析改动
- Conventional Commits 格式
- 逻辑分组提交

**使用语法**：
```bash
/ce-commit
/ce-commit --amend
```

---

### ce-commit-push-pr

**用途**：一键提交、推送、创建 PR

**核心功能**：
- 3 种风味（Quick/Standard/Full）
- Demo Reel 集成
- 自适应 PR 描述

**风味类型**：

| 风味 | 说明 |
|------|------|
| Quick | 快速提交，简洁 PR |
| Standard | 标准流程，详细描述 |
| Full | 完整流程，含 Demo |

**使用语法**：
```bash
/ce-commit-push-pr
/ce-commit-push-pr --flavor=full
```

---

### ce-work

**用途**：高效执行开发任务

**核心功能**：
- Phase 0-2 工作流
- 子代理策略
- 自动状态跟踪

**工作阶段**：

| 阶段 | 说明 |
|------|------|
| Phase 0 | 理解任务，确认依赖 |
| Phase 1 | 执行核心任务 |
| Phase 2 | 验证、清理、总结 |

**使用语法**：
```bash
/ce-work <task-id>
```

---

### ce-worktree

**用途**：创建隔离的 Git Worktree

**核心功能**：
- `.worktrees/` 目录管理
- 自动 `.env` 复制
- 独立分支工作

**使用语法**：
```bash
/ce-worktree <branch-name>
/ce-worktree --clean
```

---

## 5. 规划与 Brainstorm Skills

### ce-plan

**用途**：创建结构化实施计划

**核心功能**：
- 7 阶段规划流程
- 3 种深度级别
- 自动风险分析

**深度级别**：

| 级别 | 说明 | 适用场景 |
|------|------|----------|
| Lightweight | 轻量规划 | 简单任务 |
| Standard | 标准规划 | 常规开发 |
| Deep | 深度规划 | 复杂系统 |

**使用语法**：
```bash
/ce-plan "添加用户认证系统"
/ce-plan --depth=deep "重构支付模块"
```

---

### ce-brainstorm

**用途**：协作式需求探索

**核心功能**：
- Product 子模式
- 需求文档输出
- 交互式对话

**使用语法**：
```bash
/ce-brainstorm "电商优惠券系统需求"
/ce-brainstorm --product
```

---

## 6. 知识管理 Skills

### ce-compound

**用途**：沉淀解决方案和经验

**核心功能**：
- Full/Lightweight 模式
- Bug vs Knowledge 路线
- 结构化存储

**输出格式**：
```
Problem    : <问题描述>
What Didn't Work : <失败尝试>
Solution   : <最终方案>
Prevention : <预防措施>
```

**使用语法**：
```bash
/ce-compound
/ce-compound --lightweight
```

---

### ce-compound-refresh

**用途**：维护和更新知识库

**核心功能**：
- 5 种处理结果
- 自动合并/替换/删除

**处理结果**：

| 结果 | 说明 |
|------|------|
| Keep | 保持原样 |
| Update | 更新内容 |
| Consolidate | 合并相似文档 |
| Replace | 替换过时内容 |
| Delete | 删除冗余 |

**使用语法**：
```bash
/ce-compound-refresh
```

---

## 7. 证据与协作 Skills

### ce-demo-reel

**用途**：录制演示视频或 GIF

**核心功能**：
- 4 种录制层级
- 自动上传流程

**录制层级**：

| 层级 | 说明 | 输出格式 |
|------|------|----------|
| Browser | 浏览器演示 | GIF/WebM |
| Terminal | 终端录制 | GIF |
| Screenshot | 截图 | PNG |
| Static | 静态图片 | PNG/JPG |

**使用语法**：
```bash
/ce-demo-reel --tier=Screenshot
```

---

### ce-proof

**用途**：协作式 Markdown 编辑

**核心功能**：
- Web API + Local Bridge
- HITL（Human-in-the-loop）审查模式

**使用语法**：
```bash
/ce-proof docs/specs/feature.md
```

---

## 8. 领域特定 Skills

### ce-slack-research

**用途**：搜索 Slack 获取组织上下文

**核心功能**：
- 频道过滤
- 日期范围过滤
- 消化格式输出

**使用语法**：
```bash
/ce-slack-research "讨论过 OAuth"
/ce-slack-research --channel=#engineering
```

---

### ce-dhh-rails-style

**用途**：遵循 DHH/Rails 风格开发

**核心功能**：
- Vanilla Rails 原则
- 避免过度设计
- 37signals 模式

**核心原则**：
- 优先使用 Rails 内置功能
- 避免 React/SPA 过度使用
- 保持控制器简洁
- 视图使用 ERB/HAML

**使用语法**：
```bash
/ce-dhh-rails-style
```

---

### ce-gemini-imagegen

**用途**：使用 Gemini 生成图片

**核心功能**：
- 多分辨率支持（1K/2K/4K）
- 宽高比设置
- 多轮迭代优化

**使用语法**：
```bash
/ce-gemini-imagegen "生成产品 Logo"
/ce-gemini-imagegen --resolution=2K --ratio=16:9
```

---

## 9. 实用工具 Skills

### ce-clean-gone-branches

**用途**：清理已合并/过期分支

**核心功能**：
- 自动发现过期分支
- Worktree 同步清理

**使用语法**：
```bash
/ce-clean-gone-branches
```

---

### ce-resolve-pr-feedback

**用途**：处理 PR 审查反馈

**核心功能**：
- Full/Targeted 模式
- 并行子代理处理

**使用语法**：
```bash
/ce-resolve-pr-feedback
/ce-resolve-pr-feedback --targeted=<comment-id>
```

---

### ce-test-browser

**用途**：E2E 浏览器测试

**核心功能**：
- `agent-browser` CLI 集成
- 路线映射
- 管道模式

**使用语法**：
```bash
/ce-test-browser
```

---

### ce-agent-native-architecture

**用途**：设计 Agent 优先系统

**核心功能**：
- 5 大核心原则
- 架构检查清单

**核心原则**：
1. **Agent 可执行性** - 任何用户操作都可由 Agent 完成
2. **工具优先** - UI 是可选的，工具是必需的
3. **状态透明** - Agent 可理解系统状态
4. **错误自愈** - Agent 可诊断并修复问题
5. **迭代加速** - Agent 可加速开发迭代

**使用语法**：
```bash
/ce-agent-native-architecture
```

---

## 使用场景矩阵

| 场景 | 推荐技能组合 | 说明 |
|------|-------------|------|
| **新功能开发** | `ce-plan` → `ce-work` → `ce-code-review` → `ce-commit-push-pr` → `ce-compound` | 完整 CE 流程 |
| **Bug 修复** | `ce-debug` → `ce-work` → `ce-code-review` → `ce-commit` → `ce-compound` | 调试优先 |
| **UI 开发** | `ce-frontend-design` → `ce-work` → `ce-demo-reel` | 设计驱动 |
| **PR 审查** | `ce-code-review` → `ce-resolve-pr-feedback` | 多 Agent 交叉审查 |
| **历史查询** | `ce-sessions` → `ce-session-extract` | 获取上下文 |
| **知识维护** | `ce-compound-refresh` | 定期维护知识库 |
| **创意方案** | `ce-ideate` → `ce-optimize` | 迭代优化 |

---

## 快速参考表

### 核心流程技能

| 命令 | 功能 | 替代 Superpowers |
|------|------|------------------|
| `/ce-plan` | 结构化规划 | `brainstorm` + `plan` |
| `/ce-work` | 执行开发 | `execute` |
| `/ce-code-review` | 代码审查 | `review` |
| `/ce-compound` | 知识沉淀 | **新增环节** |

### 辅助技能

| 命令 | 功能 |
|------|------|
| `/ce-debug` | 系统化调试 |
| `/ce-ideate` | 创意生成 |
| `/ce-optimize` | 迭代优化 |
| `/ce-demo-reel` | 演示录制 |
| `/ce-proof` | 协作编辑 |

### 工具技能

| 命令 | 功能 |
|------|------|
| `/ce-commit` | Git 提交 |
| `/ce-worktree` | 创建 Worktree |
| `/ce-clean-gone-branches` | 清理分支 |
| `/ce-test-browser` | 浏览器测试 |

---

## 相关文档

- [Compound Engineering 复利式工程](./Compound-Engineering-复利式工程.md) - 原理详解
- [Compound Engineering Tools 使用总览](./Compound-Engineering-Tools-使用总览.md) - CLI 工具清单
- [Superpowers](./Superpowers.md) - 对比参考
- [AI 协同开发实战指南](./AI 协同开发实战指南.md) - 实战案例

---

## 更新记录

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-05-02 | 1.0 | 初始版本，覆盖 30+ Skills |