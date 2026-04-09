# ZCF 系列命令使用指南

> 项目自定义命令集合，提供 Git 工作流、项目管理、AI 辅助开发等功能。

---

## 命令总览

| 命令 | 类型 | 说明 |
|------|------|------|
| `/zcf:git-worktree` | Git | 管理 Git worktree，支持智能默认、IDE 集成和内容迁移 |
| `/zcf:bmad-init` | 工具 | 初始化 BMad-Method 框架 |
| `/zcf:workflow` | AI 助手 | 专业 AI 编程助手，结构化六阶段开发工作流 |
| `/zcf:feat` | 开发 | 用于新增功能开发的命令，支持完整的开发流程 |
| `/zcf:init-project` | 项目 | 初始化项目 AI 上下文，生成/更新 CLAUDE.md 索引 |
| `/zcf:git-commit` | Git | 自动生成 conventional commit 提交信息 |
| `/zcf:git-cleanBranches` | Git | 安全清理已合并或过期的 Git 分支 |
| `/zcf:git-rollback` | Git | 交互式回滚 Git 分支到历史版本 |

---

## 命令详解

### 1. `/zcf:git-worktree` - Git Worktree 管理

**使用场景**：
- 需要并行开发多个功能分支
- 需要在不同分支间快速切换而不丢失当前工作
- 需要在 worktree 之间迁移未提交的改动
- 临时调试某个分支问题

**基本用法**：

```bash
# 创建新 worktree（从 main/master 创建同名分支）
/zcf:git-worktree add feature-ui

# 创建并指定分支名
/zcf:git-worktree add feature-ui -b my-feature

# 创建并直接用 IDE 打开
/zcf:git-worktree add feature-ui -o

# 查看所有 worktree
/zcf:git-worktree list

# 删除 worktree
/zcf:git-worktree remove feature-ui

# 清理无效引用
/zcf:git-worktree prune

# 迁移未提交改动
/zcf:git-worktree migrate feature-ui --from main

# 迁移 stash 内容
/zcf:git-worktree migrate hotfix --stash
```

**常用选项**：

| 选项 | 说明 |
|------|------|
| `add <path>` | 在 `../.zcf/项目名/<path>` 添加新 worktree |
| `-b <branch>` | 创建新分支并检出到 worktree |
| `-o, --open` | 创建后直接用 IDE 打开 |
| `--track` | 设置新分支跟踪远程分支 |
| `--detach` | 创建分离 HEAD 的 worktree |
| `--lock` | 创建后锁定 worktree |
| `migrate <target>` | 迁移内容到指定 worktree |
| `--from <source>` | 指定迁移源路径 |
| `--stash` | 迁移当前 stash 内容 |

**目录结构**：
```
parent-directory/
├── your-project/            # 主项目
│   ├── .git/
│   └── src/
└── .zcf/                    # worktree 管理
    └── your-project/        # 项目 worktree
        ├── feature-ui/      # 功能分支
        ├── hotfix/          # 修复分支
        └── debug/           # 调试 worktree
```

---

### 2. `/zcf:bmad-init` - BMad-Method 初始化

**使用场景**：
- 首次在项目中引入 BMad-Method 开发框架
- 升级现有 BMad-Method 到最新版本
- 需要使用 BMad 工作流和代理命令

**用法**：
```bash
/zcf:bmad-init
```

**执行流程**：
1. 检查 `.bmad-core/install-manifest.yaml` 是否存在
2. 如已安装，对比当前版本与最新版本
3. 如未安装或版本过旧，执行安装命令
4. 提示重启 Claude Code 以加载 BMad 扩展

**安装后位置**：
- 代理和任务命令：`.claude/commands/BMad/`

**首次使用**：
```bash
/BMad:agents:bmad-orchestrator *help
```

**Git 配置建议**（将以下内容添加到 `.gitignore`）：
```
.bmad-core
.claude/commands/BMad
docs/
```

---

### 3. `/zcf:workflow` - 专业 AI 编程助手

**使用场景**：
- 需要结构化地开发新功能
- 复杂任务需要分阶段执行
- 需要代码质量保证和优化建议
- 需要完整的开发文档记录

**用法**：
```bash
/zcf:workflow <任务描述>
```

**六阶段工作流**：

| 阶段 | 模式标签 | 说明 |
|------|----------|------|
| 1. 研究 | `[模式：研究]` | 理解需求，进行完整性评分 (0-10 分) |
| 2. 构思 | `[模式：构思]` | 提供至少两种可行方案及评估 |
| 3. 计划 | `[模式：计划]` | 细化为详尽、有序、可执行的步骤清单 |
| 4. 执行 | `[模式：执行]` | 按计划编码实施，存储计划至 `.zcf/plan/current/` |
| 5. 优化 | `[模式：优化]` | 自动分析代码，识别冗余和低效，提出优化建议 |
| 6. 评审 | `[模式：评审]` | 对照计划评估执行结果，报告问题与建议 |

**输出结构**：
```
project/
├── .zcf/
│   └── plan/
│       ├── current/              # 当前进行中的任务
│       │   └── 任务名.md
│       └── history/              # 已完成的历史任务
│           └── [完成时间]任务名.md
├── src/
└── tests/
```

---

### 4. `/zcf:feat` - 功能开发命令

**使用场景**：
- 新增功能开发
- 需求规划与讨论
- 规划确认后的实施执行

**用法**：
```bash
/zcf:feat <任务描述>
```

**分类处理机制**：

| 类型 | 触发条件 | 执行动作 |
|------|----------|----------|
| **需求规划** | 新功能需求、项目构想 | 启用 Planner Agent，生成详细 markdown 规划文档至 `./.claude/plan` |
| **讨论迭代** | 继续讨论、修改已有规划 | 检索上次规划文件，更新并重新组织优先级 |
| **执行实施** | 确认规划完成，开始执行 | 按规划文档顺序执行，前端任务先进行 UI 设计 |

**执行流程**：
1. 类型判断并告知用户
2. 分类处理（规划/讨论/执行）
3. 前端任务特殊处理（检查 UI 设计）
4. 状态管理与更新

---

### 5. `/zcf:init-project` - 项目 AI 上下文初始化

**使用场景**：
- 新项目初始化 AI 上下文
- 更新现有项目的 CLAUDE.md 索引
- 需要生成项目架构可视化图表

**用法**：
```bash
/zcf:init-project <项目摘要或名称>
```

**执行策略**：

| 阶段 | 说明 |
|------|------|
| 阶段 A：全仓清点 | 快速统计文件与目录，识别模块根 |
| 阶段 B：模块优先扫描 | 对每个模块做定点读取与样本抽取 |
| 阶段 C：深度补捞 | 按需扩大读取面 |

**输出内容**：
- 根级 `CLAUDE.md`：高层愿景、架构总览、模块索引、Mermaid 结构图
- 模块级 `CLAUDE.md`：接口、依赖、入口、测试、关键文件、导航面包屑

**覆盖率度量**：
- 已扫描文件数 / 估算总文件数
- 已覆盖模块占比
- 被忽略/跳过原因
- 建议下一步深挖的子路径

---

### 6. `/zcf:git-commit` - Git 提交助手

**使用场景**：
- 自动生成符合 Conventional Commits 规范的提交信息
- 需要拆分多个独立变更的提交
- 需要在提交中包含 emoji

**用法**：
```bash
# 基本用法
/zcf:git-commit

# 暂存所有改动并提交
/zcf:git-commit --all

# 跳过 Git 钩子
/zcf:git-commit --no-verify

# 包含 emoji
/zcf:git-commit --emoji

# 指定作用域和类型
/zcf:git-commit --scope ui --type feat

# 修补上次提交并签名
/zcf:git-commit --amend --signoff
```

**常用选项**：

| 选项 | 说明 |
|------|------|
| `--no-verify` | 跳过本地 Git 钩子 |
| `--all` | 暂存区为空时自动 `git add -A` |
| `--amend` | 修补上一次提交 |
| `--signoff` | 附加 Signed-off-by 行 |
| `--emoji` | 包含 emoji 前缀 |
| `--scope <scope>` | 指定提交作用域 |
| `--type <type>` | 强制提交类型 |

**Type 与 Emoji 映射**：

| Type | Emoji | 说明 |
|------|-------|------|
| `feat` | ✨ | 新增功能 |
| `fix` | 🐛 | 缺陷修复 |
| `docs` | 📝 | 文档与注释 |
| `style` | 🎨 | 风格/格式 |
| `refactor` | ♻️ | 重构 |
| `perf` | ⚡️ | 性能优化 |
| `test` | ✅ | 测试 |
| `chore` | 🔧 | 构建/工具/杂务 |
| `ci` | 👷 | CI/CD |
| `revert` | ⏪️ | 回滚提交 |

---

### 7. `/zcf:git-cleanBranches` - 分支清理

**使用场景**：
- 清理已合并到主分支的功能分支
- 清理长期未更新的过期分支
- 清理远程已合并的分支

**用法**：
```bash
# 预览将要清理的分支（默认安全模式）
/zcf:git-cleanBranches --dry-run

# 清理已合并到 main 且超过 90 天未动的本地分支
/zcf:git-cleanBranches --stale 90

# 清理已合并到指定分支的本地与远程分支
/zcf:git-cleanBranches --base release/v2.1 --remote --yes

# 强制删除未合并的本地分支
/zcf:git-cleanBranches --force outdated-feature
```

**常用选项**：

| 选项 | 说明 |
|------|------|
| `--base <branch>` | 指定基准分支（默认 main/master） |
| `--stale <days>` | 清理超过指定天数未提交的分支 |
| `--remote` | 同时清理远程已合并/过期分支 |
| `--dry-run` | 只读预览，不执行删除 |
| `--yes` | 跳过确认直接删除 |
| `--force` | 强制删除未合并分支 |

**保护分支配置**：
```bash
# 保护 develop 分支
git config --add branch.cleanup.protected develop

# 保护所有 release/开头的分支
git config --add branch.cleanup.protected 'release/*'

# 查看已配置的保护分支
git config --get-all branch.cleanup.protected
```

---

### 8. `/zcf:git-rollback` - Git 回滚

**使用场景**：
- 回滚分支到历史某个版本或 Tag
- 热修复上线后发现问题需要回退
- 生成反向提交而非改变历史

**用法**：
```bash
# 全交互模式（预览）
/zcf:rollback

# 指定分支，其他交互
/zcf:rollback --branch feature/calculator

# 指定分支与目标，硬回滚执行
/zcf:rollback --branch main --target v1.2.0 --mode reset --yes

# 生成反向提交（非破坏式）
/zcf:rollback --branch release/v2.1 --target v2.0.5 --mode revert --dry-run
```

**常用选项**：

| 选项 | 说明 |
|------|------|
| `--branch <branch>` | 要回滚的分支 |
| `--target <rev>` | 目标版本（commit hash/tag） |
| `--mode reset\|revert` | reset：硬回滚；revert：反向提交 |
| `--depth <n>` | 交互模式下列出最近 n 个版本 |
| `--dry-run` | 只读预览（默认开启） |
| `--yes` | 跳过确认直接执行 |

**回滚模式对比**：

| 模式 | 特点 | 适用场景 |
|------|------|----------|
| `reset` | 改变历史，需强推 | 紧急回退、本地分支 |
| `revert` | 保留历史，生成新提交 | 共享分支、审计要求 |

---

## 最佳实践

### Git Worktree
- 使用 `../.zcf/项目名/` 统一管理 worktree
- 创建后使用 `-o` 直接在 IDE 中打开
- 定期使用 `prune` 清理无效引用

### Git Commit
- 保持提交的原子性，一次只做一件事
- 使用 `--emoji` 增加可读性
- 大改动前先分组再提交

### Git 分支管理
- 先用 `--dry-run` 预览再执行清理
- 配置保护分支防止误删
- 定期运行保持仓库清爽

### 开发工作流
- 使用 `/zcf:workflow` 进行复杂功能开发
- 使用 `/zcf:feat` 快速启动新功能
- 定期使用 `/zcf:init-project` 更新项目文档

---

## 命令路径

所有命令位于：`/Users/mac/.claude/commands/zcf/`

```
.zcf/commands/zcf/
├── git-worktree.md
├── bmad-init.md
├── workflow.md
├── feat.md
├── init-project.md
├── git-commit.md
├── git-cleanBranches.md
└── git-rollback.md
```

---

*文档生成时间：2026-04-09*
