# Git Quick Push Skill 使用指南

一键 Git commit 和 push 到远程仓库，支持代理切换。

## 功能特性

- ✅ 自动 `git add .` 暂存所有改动
- ✅ 自动生成 commit message（基于改动统计）
- ✅ `pull --rebase` 拉取远程更新（避免冲突）
- ✅ 推送到远程仓库（默认 origin + 当前分支）
- ✅ HTTP_PROXY 代理切换（默认端口 7890）
- ✅ 支持自定义 commit message
- ✅ Dry-run 模式预览

## 安装位置

```
~/.claude/skills/git-quick-push/
├── SKILL.md           # Skill 配置文件
└── scripts/
    └── git-quick-push.sh  # 执行脚本
```

## 使用方式

### 基本用法（默认走代理）

```bash
# 默认模式，使用代理 HTTP_PROXY=http://127.0.0.1:7890
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh
```

执行流程：
```
1. git add .                → 暂存所有改动
2. 自动生成 message         → 基于改动文件数/行数
3. git commit               → 提交
4. git pull --rebase        → 拉取远程更新
5. git push                 → 推送
```

### 不走代理模式

```bash
# 不使用代理
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh --no-proxy
```

### 自定义 Commit Message

```bash
# 自定义提交信息
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh -m "fix: 修复登录 bug"
```

### 指定分支和远程仓库

```bash
# 指定推送分支
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh -b feature/auth

# 指定远程仓库
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh -r upstream
```

### Dry-run 模式（预览命令）

```bash
# 仅显示将要执行的命令，不实际执行
~/.claude/skills/git-quick-push/scripts/git-quick-push.sh --dry-run
```

输出示例：
```
🌐 使用代理: http://127.0.0.1:7890

📋 执行计划:
  分支: master
  远程: origin
  代理: true

⚠️  Dry-run 模式 - 仅显示命令，不执行:

  git add .
  git commit -m "[自动生成的 message]"
  git pull --rebase origin master
  git push origin master
```

## 参数说明

| 参数 | 说明 |
|------|------|
| `--proxy` | 使用代理（默认） |
| `--no-proxy` | 不使用代理 |
| `-m, --msg` | 自定义 commit message |
| `-b, --branch` | 指定推送分支（默认当前分支） |
| `-r, --remote` | 指定远程仓库（默认 origin） |
| `--dry-run` | 仅显示命令，不执行 |
| `-h, --help` | 显示帮助信息 |

## Commit Message 自动生成规则

| 场景 | Message 格式 |
|------|-------------|
| 单文件改动 | `update: filename` |
| 多文件改动 | `update: N files (+X -Y lines)` |
| 有新文件 | `add: N new files, update M files` |

## 代理配置

代理端口固定为 **7890**：
- 默认使用代理 → 设置 `HTTP_PROXY=http://127.0.0.1:7890`
- 关闭代理 → `--no-proxy` 清除代理环境变量

## 注意事项

1. **必须先进入 git 仓库目录**再执行
2. **pull 使用 --rebase** 保持提交历史线性
3. 如有冲突需手动解决后重新执行
4. 空改动（无文件修改）会自动跳过
5. 手机与电脑不要同时编辑同一文件（易产生冲突）

## 触发方式

用户可能的请求方式（Claude 自动识别）：
- "帮我 push 代码到远程"
- "一键提交当前改动"
- "走代理 push 到 github"
- "git commit 和 push 一起做"
- "快速推送代码"
- "不走代理 push"

## 完整帮助信息

```bash
$ ~/.claude/skills/git-quick-push/scripts/git-quick-push.sh --help

用法: git-quick-push [选项]

选项:
  --proxy        使用代理 (默认) HTTP_PROXY=http://127.0.0.1:7890
  --no-proxy     不使用代理
  -m, --msg      自定义 commit message
  -b, --branch   指定推送分支 (默认当前分支)
  -r, --remote   指定远程仓库 (默认 origin)
  --dry-run      仅显示将要执行的命令，不实际执行
  -h, --help     显示帮助信息

流程:
  1. git add . (暂存所有改动)
  2. 自动生成 commit message (或使用自定义)
  3. git commit
  4. git pull --rebase (拉取远程更新)
  5. git push
```

## 与 Obsidian Git 插件的对比

| 功能 | Obsidian Git 插件 | git-quick-push |
|------|------------------|----------------|
| 自动暂存 | ✅ | ✅ |
| 自动 commit | ✅ 定时触发 | ✅ 手动触发 |
| Pull on start | ✅ | ❌ |
| 代理支持 | ❌ | ✅ 可切换 |
| 自定义 message | ❌ 自动生成 | ✅ 支持自定义 |
| 适用范围 | Obsidian 笔记库 | 任意 git 仓库 |

**推荐组合使用：**
- Obsidian Git 插件：自动同步笔记库
- git-quick-push：手动推送代码项目（支持代理切换）