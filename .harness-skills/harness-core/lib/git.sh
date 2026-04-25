#!/bin/bash
# Harness Git 操作封装
# 用途：Git 相关操作的统一封装

set -e

# 检查是否有未提交的更改
git_has_changes() {
    local project_root="${1:-$(pwd)}"
    cd "$project_root"

    if [[ -d ".git" ]]; then
        git diff --quiet HEAD 2>/dev/null || git status --porcelain | grep -q .
    else
        return 1
    fi
}

# 获取最近 N 条 commit
git_log_oneline() {
    local limit="${1:-5}"
    local project_root="${2:-$(pwd)}"

    if [[ -d "$project_root/.git" ]]; then
        cd "$project_root" && git log --oneline -n "$limit"
    else
        echo "No git repository found"
    fi
}

# 提交更改
git_commit() {
    local message="$1"
    local project_root="${2:-$(pwd)}"

    cd "$project_root"

    if [[ -d ".git" ]]; then
        git add -A
        git commit -m "$message"
        echo "Committed: $message"
    else
        echo "No git repository, skipping commit"
    fi
}

# 检查 Git 状态
git_status() {
    local project_root="${1:-$(pwd)}"

    if [[ -d "$project_root/.git" ]]; then
        cd "$project_root" && git status --short
    else
        echo "No git repository"
    fi
}

# 初始化 Git（若不存在）
git_init_if_needed() {
    local project_root="${1:-$(pwd)}"
    cd "$project_root"

    if [[ ! -d ".git" ]]; then
        git init
        echo "Git repository initialized"
    else
        echo "Git repository already exists"
    fi
}

# 创建 .gitignore
git_create_harness_gitignore() {
    local harness_dir="${1:-.harness}"
    echo "# Harness 系统生成的临时文件" > "$harness_dir/.gitignore"
    echo "# 注意：feature_list.json 和 progress.txt 应被版本控制" >> "$harness_dir/.gitignore"
    echo "*.tmp" >> "$harness_dir/.gitignore"
    echo "*.log" >> "$harness_dir/.gitignore"
}