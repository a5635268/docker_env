# gh GitHub CLI 使用指南

> GitHub 官方命令行工具，让 AI Agent 无缝操作 GitHub

---

## 概述

gh 是 GitHub 官方推出的 CLI 工具，支持完整的 GitHub 操作：

- ✅ **认证管理** - 安全的 OAuth/Token 认证
- ✅ **仓库操作** - 创建、克隆、管理仓库
- ✅ **PR 管理** - 创建、查看、合并 Pull Request
- ✅ **Issue 管理** - 创建、搜索、管理 Issue
- ✅ **Actions** - 查看、管理 GitHub Actions
- ✅ **API 访问** - 直接调用 GitHub REST/GraphQL API

---

## 安装

```bash
# Homebrew 安装 (macOS)
brew install gh

# 验证安装
gh --version
```

---

## 认证配置

### 首次认证

```bash
# 交互式认证
gh auth login

# 选择认证方式：
# 1. GitHub.com 或 GitHub Enterprise
# 2. HTTPS 或 SSH
# 3. 浏览器登录或 Token
```

### 认证状态

```bash
# 查看认证状态
gh auth status

# 查看当前用户
gh api user --jq '.login'
```

### Token 管理

```bash
# 刷新 Token
gh auth refresh

# 添加额外权限
gh auth refresh -h github.com -s repo,workflow
```

---

## 核心命令

### 仓库操作 (repo)

| 命令 | 说明 | 示例 |
|------|------|------|
| `repo create` | 创建仓库 | `gh repo create myapp --public` |
| `repo clone` | 克隆仓库 | `gh repo clone owner/repo` |
| `repo view` | 查看仓库 | `gh repo view owner/repo` |
| `repo fork` | Fork 仓库 | `gh repo fork owner/repo` |
| `repo delete` | 删除仓库 | `gh repo delete owner/repo` |
| `repo list` | 列出仓库 | `gh repo list owner --limit 50` |

### PR 管理 (pr)

| 命令 | 说明 | 示例 |
|------|------|------|
| `pr create` | 创建 PR | `gh pr create --title "feat: add X" --body "描述"` |
| `pr list` | 列出 PR | `gh pr list --state open` |
| `pr view` | 查看 PR | `gh pr view 123` |
| `pr checkout` | 检出 PR | `gh pr checkout 123` |
| `pr merge` | 合并 PR | `gh pr merge 123 --squash` |
| `pr close` | 关闭 PR | `gh pr close 123` |
| `pr review` | 审核 PR | `gh pr review 123 --approve` |

### Issue 管理 (issue)

| 命令 | 说明 | 示例 |
|------|------|------|
| `issue create` | 创建 Issue | `gh issue create --title "Bug: X" --body "描述"` |
| `issue list` | 列出 Issue | `gh issue list --state open` |
| `issue view` | 查看 Issue | `gh issue view 456` |
| `issue close` | 关闭 Issue | `gh issue close 456` |
| `issue edit` | 编辑 Issue | `gh issue edit 456 --title "新标题"` |

### Actions 操作 (run)

| 命令 | 说明 | 示例 |
|------|------|------|
| `run list` | 列出运行 | `gh run list --limit 10` |
| `run view` | 查看运行 | `gh run view 789` |
| `run watch` | 监控运行 | `gh run watch` |
| `run download` | 下载产物 | `gh run download 789` |

---

## 使用场景

### 1. 快速创建 PR

```bash
# 创建分支并提交
git checkout -b feature-x
git add .
git commit -m "feat: add feature X"

# 推送并创建 PR
git push -u origin feature-x
gh pr create --title "feat: add feature X" \
             --body "实现功能 X，详见..." \
             --label "enhancement"
```

### 2. 查看仓库状态

```bash
# 查看当前仓库
gh repo view

# 查看开放 PR 数量
gh pr list --state open --json number,title,author

# 查看 CI 状态
gh run list --limit 5 --json status,conclusion
```

### 3. 批量处理 Issue

```bash
# 搜索特定标签的 Issue
gh issue list --label "bug" --state open

# 批量关闭已完成 Issue
gh issue list --label "done" --json number --jq '.[].number' | \
  xargs -I {} gh issue close {}
```

### 4. API 数据提取

```bash
# 获取仓库统计
gh api repos/owner/repo/stats/participation

# 查询贡献者
gh api repos/owner/repo/contributors --jq '.[].login'

# GraphQL 查询
gh api graphql -f query='
  query($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      issues(states: OPEN) { totalCount }
    }
  }
' -f owner=owner -f repo=repo
```

---

## AI Agent 工作流

### PR 创建流程

```bash
# 1. 检出分支
gh pr checkout 123

# 2. 查看变更
gh pr view 123 --json files,additions,deletions

# 3. 查看评论
gh pr view 123 --comments

# 4. 审核通过
gh pr review 123 --approve --body "LGTM"

# 5. 合并 PR
gh pr merge 123 --squash --delete-branch
```

### Issue 分析流程

```bash
# 搜索相关 Issue
gh search issues "关键词" --repo owner/repo --state open

# 查看 Issue 详情
gh issue view 456 --json title,body,labels,assignees

# 添加评论
gh issue comment 456 --body "分析结果..."
```

---

## 输出格式控制

### JSON 输出

```bash
# JSON 格式输出
gh pr list --json number,title,author,state

# jq 过滤
gh pr list --json number,title | jq '.[] | select(.title | contains("bug"))'
```

### 表格输出

```bash
# 表格格式
gh issue list --format table

# 自定义列
gh pr list --json number,title,author | \
  jq -r '["Number","Title","Author"], (.[] | [.number, .title, .author.login]) | @tsv'
```

---

## 高级功能

### 别名设置

```bash
# 创建命令别名
gh alias set co "pr checkout"
gh alias set pv "pr view"

# 使用别名
gh co 123
```

### 扩展安装

```bash
# 安装扩展
gh extension install owner/gh-extension

# 列出扩展
gh extension list
```

### Web 浏览器跳转

```bash
# 在浏览器中打开
gh repo view --web
gh pr view 123 --web
gh issue view 456 --web
```

---

## 常见问题

### Q: 认证失败？

重新认证并确保权限正确：
```bash
gh auth refresh -h github.com -s repo,workflow,admin
```

### Q: 大仓库操作慢？

使用 `--limit` 限制结果数量：
```bash
gh pr list --limit 20
```

### Q: GraphQL 查询复杂？

使用 `-f` 参数简化：
```bash
gh api graphql -f query='...' -f var=value
```

---

## 参考链接

- [GitHub CLI 官网](https://cli.github.com/)
- [官方文档](https://docs.github.com/en/github-cli)
- [手册页](https://cli.github.com/manual/)