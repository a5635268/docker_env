# Git Worktree 与 Claude Subagent 协同开发实战指南

## 核心概念

### 双重隔离机制

将 Git Worktree 与 Claude Subagent 结合使用，构建开发的双重隔离：

| 隔离类型 | 机制 | 作用 |
|---------|------|------|
| **物理隔离** | Git Worktree | 多分支独立目录，代码修改互不干扰 |
| **上下文隔离** | Claude Subagent | AI 层面任务隔离，避免 Token 污染 |

**典型场景**：将 ThinkPHP/Spring Boot 接口重构迁移到 FastAPI + LangChain 架构。

---

## Git Worktree 实操

### 创建隔离工作区

```bash
# 创建新分支并检出到独立目录
git worktree add ../refactor-fastapi -b refactor-fastapi

# 或在项目内创建 .worktrees 目录
git worktree add .worktrees/refactor-fastapi -b refactor-fastapi
```

### ⚠️ 关键注意事项

**必须作为独立项目打开，切勿在当前窗口直接编辑**

| 操作方式 | 结果 |
|---------|------|
| ❌ 当前窗口展开 `.worktrees` | AI 认知混乱、搜索结果重复、Git GUI 失效、代码泄漏风险 |
| ✅ 新窗口独立打开 | 物理隔离完整、AI 上下文纯净、Git 环境独立、运行环境独立 |

**正确流程**：
1. 主项目 `.gitignore` 添加 `.worktrees/`
2. 创建 Worktree
3. `Cmd + Shift + N` 新窗口打开 `.worktrees/refactor-fastapi`

### 清理工作区

```bash
# 不满意：彻底删除
git worktree remove ../refactor-fastapi

# 满意：合并后清理
cd ../refactor-fastapi
git add .
git commit -m "feat: 完成重构"
cd ../主项目
git merge refactor-fastapi
git worktree remove ../refactor-fastapi
```

**避坑**：永远使用 `git worktree remove`，禁止 `rm -rf` 暴力删除。误删后用 `git worktree prune` 修复。

---

## Claude Subagent 配置

### 手动配置流程

```bash
# 启动 Claude Code
claude

# 调出子代理管理
/agents

# 创建专属代理
# - Name: fastapi-tester
# - Description: 负责为 FastAPI 路由编写自动化测试
# - System Prompt: 高级 Python 测试工程师，使用 pytest 编写单元测试
```

### 实战联动模式

| 主代理职责 | Subagent 聘派 |
|-----------|--------------|
| 核心业务逻辑开发 | 测试用例编写 |
| 架构设计与调试 | 代码审查 |
| 接口对接 | 依赖配置 |

**触发指令**：*"请使用 fastapi-tester 代理扫描 api/chat.py 生成测试文件"*

Subagent 在独立上下文运行，仅返回精简总结，保持主对话窗口整洁。

---

## Superpowers 自动化框架

### 安装配置

```bash
# 注册市场并安装
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

### 自动化工作流

| 阶段 | 技能 | 执行内容 |
|-----|------|---------|
| 1. 头脑风暴 | `/brainstorming` | 确认边界条件，生成架构设计文档 |
| 2. 物理隔离 | `using-git-worktrees` | 自动创建隔离工作区 |
| 3. 任务拆解 | `/writing-plans` | 生成 Markdown 任务树，TDD 节点规划 |
| 4. 自动执行 | `/executing-plans` | 子代理驱动开发循环 |

### 核心优势

- **计划即路由**：Markdown 任务文件作为总控台
- **自动上下文匹配**：系统自动判断何时派发 Subagent
- **静默执行与收敛**：闭环推进，主对话仅收高层汇报

**角色转变**：从"微观管理者"变为"项目经理"，把控架构设计与技术选型。

---

## 跨平台支持

| 平台 | Superpowers 支持 | 使用方式 |
|-----|-----------------|---------|
| **Claude Code CLI** | ✅ 原生支持 | `/plugin` 安装 |
| **Cursor IDE** | ✅ 完全支持 | `/add-plugin superpowers` 或读取本地配置 |
| **Codex CLI** | ✅ 支持 | 侧边栏 Plugins 或终端加载 |

**统一体验**：三平台均享受相同的 14 项核心技能和自动化工作流。

---

## 最佳实践清单

### Worktree 使用

- [ ] 主项目 `.gitignore` 添加 `.worktrees/`
- [ ] 使用 `git worktree add` 创建，而非手动 mkdir
- [ ] 新窗口独立打开工作区
- [ ] 清理使用 `git worktree remove`

### Subagent 调度

- [ ] 核心逻辑留在主对话
- [ ] 测试/审查类任务派发 Subagent
- [ ] 明确指定代理名称和任务范围

### Superpowers 应用

- [ ] 复杂重构优先使用 `/brainstorming`
- [ ] 任务拆解粒度控制在 2-5 分钟代码量
- [ ] 关键里程碑节点确认后再继续

---

## 快速参考命令

```bash
# Worktree 操作
git worktree add <路径> -b <分支名>    # 创建
git worktree list                      # 查看列表
git worktree remove <路径>             # 清理
git worktree prune                     # 修复损坏链接

# Claude Code
claude                                  # 启动
/agents                                 # 子代理管理
/brainstorming                          # 头脑风暴
/writing-plans                          # 编写计划
/executing-plans                        # 执行计划
```

---

## 总结

| 场景 | 推荐方案 |
|-----|---------|
| 简单修改 | 原生 Claude Code + 手动 Subagent |
| 复杂重构 | Superpowers 自动化流水线 |
| 多项目并行 | Git Worktree + 多窗口 IDE |

**核心价值**：双重隔离机制让试错成本极低，自动化框架让开发效率极高。