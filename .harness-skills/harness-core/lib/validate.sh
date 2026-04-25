#!/bin/bash
# Harness 数据验证脚本
# 用途：验证 JSON 结构和字段完整性

set -e

# 验证 feature_list.json 结构
validate_feature_list() {
    local file="${1:-.harness/feature_list.json}"

    if [[ ! -f "$file" ]]; then
        echo '{"valid": false, "errors": ["file not found"]}'
        return
    fi

    local errors=()

    # 检查 JSON 是否可解析
    if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        errors+="invalid JSON syntax"
    fi

    # 检查必要字段
    if ! grep -q '"tasks"' "$file"; then
        errors+="missing 'tasks' array"
    fi

    if ! grep -q '"metadata"' "$file"; then
        errors+="missing 'metadata' object"
    fi

    if [[ ${#errors[@]} -eq 0 ]]; then
        echo '{"valid": true, "errors": []}'
    else
        echo "{\"valid\": false, \"errors\": [\"${errors[*]}\"]}"
    fi
}

# 验证单个任务结构
validate_task() {
    local task_json="$1"
    local required_fields=("id" "category" "description" "steps" "priority" "passes")
    local errors=()

    for field in "${required_fields[@]}"; do
        if ! echo "$task_json" | grep -q "\"$field\""; then
            errors+="missing field: $field"
        fi
    done

    if [[ ${#errors[@]} -eq 0 ]]; then
        echo '{"valid": true}'
    else
        echo "{\"valid\": false, \"errors\": [\"${errors[*]}\"]}"
    fi
}

# 验证 config.json 结构
validate_config() {
    local file="${1:-.harness/config.json}"

    if [[ ! -f "$file" ]]; then
        echo '{"valid": false, "errors": ["file not found"]}'
        return
    fi

    local required_fields=("project_name" "project_type" "tech_stack")
    local errors=()

    for field in "${required_fields[@]}"; do
        if ! grep -q "\"$field\"" "$file"; then
            errors+="missing field: $field"
        fi
    done

    if [[ ${#errors[@]} -eq 0 ]]; then
        echo '{"valid": true, "errors": []}'
    else
        echo "{\"valid\": false, \"errors\": [\"${errors[*]}\"]}"
    fi
}

# 验证 init.sh 是否可执行
validate_init_script() {
    local file="${1:-.harness/init.sh}"

    if [[ ! -f "$file" ]]; then
        echo '{"valid": false, "errors": ["file not found"]}'
        return
    fi

    if [[ ! -x "$file" ]]; then
        echo '{"valid": false, "errors": ["not executable"]}'
        return
    fi

    echo '{"valid": true}'
}