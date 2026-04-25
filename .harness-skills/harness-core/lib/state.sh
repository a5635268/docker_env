#!/bin/bash
# Harness 状态检测脚本
# 用途：检测 .harness/ 目录状态和当前阶段

set -e

# 检测 .harness/ 目录是否存在
harness_exists() {
    local project_root="${1:-$(pwd)}"
    [[ -d "$project_root/.harness" ]]
}

# 检测当前阶段
harness_get_stage() {
    local project_root="${1:-$(pwd)}"
    local harness_dir="$project_root/.harness"

    if ! harness_exists "$project_root"; then
        echo "not_initialized"
        return
    fi

    local feature_list="$harness_dir/feature_list.json"

    if [[ ! -f "$feature_list" ]]; then
        echo "initialized"
        return
    fi

    # 解析 feature_list.json 检查任务状态
    local passes_count=$(grep -c '"passes": true' "$feature_list" 2>/dev/null || echo "0")
    local total_tasks=$(grep -c '"id"' "$feature_list" 2>/dev/null || echo "0")

    if [[ "$total_tasks" -eq 0 ]]; then
        echo "initialized"
        return
    fi

    if [[ "$passes_count" -eq "$total_tasks" ]]; then
        echo "completed"
        return
    fi

    if [[ "$passes_count" -gt 0 ]]; then
        echo "running"
        return
    fi

    echo "planned"
}

# 检测文件完整性
harness_validate_files() {
    local project_root="${1:-$(pwd)}"
    local harness_dir="$project_root/.harness"
    local missing=()

    if ! harness_exists "$project_root"; then
        echo "not_initialized"
        return
    fi

    [[ -f "$harness_dir/feature_list.json" ]] || missing+="feature_list.json"
    [[ -f "$harness_dir/progress.txt" ]] || missing+="progress.txt"
    [[ -f "$harness_dir/init.sh" ]] || missing+="init.sh"
    [[ -f "$harness_dir/config.json" ]] || missing+="config.json"

    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "complete"
    else
        echo "missing: ${missing[*]}"
    fi
}

# 检测项目是否有 Git
git_exists() {
    local project_root="${1:-$(pwd)}"
    [[ -d "$project_root/.git" ]]
}

# 获取下一个待执行任务
harness_get_next_task() {
    local project_root="${1:-$(pwd)}"
    local feature_list="$project_root/.harness/feature_list.json"

    if [[ ! -f "$feature_list" ]]; then
        echo ""
        return
    fi

    # 找到 passes=false 且依赖满足的最高优先级任务
    # 简化实现：返回第一个 passes=false 的任务 id
    grep -m1 '"passes": false' "$feature_list" -B5 | grep '"id"' | head -1 | sed 's/.*"id": *"\([^"]*\)".*/\1/'
}