#!/bin/bash
# Harness 文件读写封装
# 用途：读写 JSON/文本文件的封装操作

set -e

HARNESS_DIR=".harness"

# 读取 JSON 文件并解析
read_json() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cat "$file"
    else
        echo "{}"
    fi
}

# 写入 JSON 文件（格式化输出）
write_json() {
    local file="$1"
    local content="$2"
    echo "$content" | python3 -m json.tool > "$file"
}

# 追加任务到 feature_list
append_task() {
    local harness_dir="${HARNESS_DIR}"
    local task_json="$1"
    local feature_list="$harness_dir/feature_list.json"

    python3 << EOF
import json
with open('$feature_list', 'r') as f:
    data = json.load(f)
data['tasks'].append($task_json)
data['metadata']['total_tasks'] = len(data['tasks'])
data['metadata']['pending'] = sum(1 for t in data['tasks'] if not t.get('passes', False))
with open('$feature_list', 'w') as f:
    json.dump(data, f, indent=2)
EOF
}

# 更新任务的 passes 字段
update_task_passes() {
    local task_id="$1"
    local passes_value="${2:-true}"
    local harness_dir="${HARNESS_DIR}"
    local feature_list="$harness_dir/feature_list.json"

    python3 << EOF
import json
with open('$feature_list', 'r') as f:
    data = json.load(f)
for task in data['tasks']:
    if task['id'] == '$task_id':
        task['passes'] = $passes_value
data['metadata']['completed'] = sum(1 for t in data['tasks'] if t.get('passes', False))
data['metadata']['pending'] = len(data['tasks']) - data['metadata']['completed']
with open('$feature_list', 'w') as f:
    json.dump(data, f, indent=2)
EOF
}

# 读取 progress.txt 最近 N 条记录
read_progress() {
    local limit="${1:-5}"
    local harness_dir="${HARNESS_DIR}"
    local progress_file="$harness_dir/progress.txt"

    if [[ -f "$progress_file" ]]; then
        tail -n "$limit" "$progress_file"
    else
        echo "No progress records found"
    fi
}

# 写入 progress 记录
write_progress() {
    local message="$1"
    local harness_dir="${HARNESS_DIR}"
    local progress_file="$harness_dir/progress.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M')

    echo "$timestamp $message" >> "$progress_file"
}

# 创建文件（若不存在）
ensure_file() {
    local file="$1"
    local default_content="${2:-}"
    local harness_dir="${HARNESS_DIR}"

    mkdir -p "$harness_dir"

    if [[ ! -f "$harness_dir/$file" ]]; then
        echo "$default_content" > "$harness_dir/$file"
    fi
}

# 获取当前会话编号（从 progress.txt 计算）
get_current_session() {
    local harness_dir="${HARNESS_DIR}"
    local progress_file="$harness_dir/progress.txt"

    if [[ ! -f "$progress_file" ]]; then
        echo "1"
        return
    fi

    grep -c "Session #" "$progress_file" 2>/dev/null || echo "0"
    local count=$(grep "Session #" "$progress_file" | tail -1 | sed 's/Session #\([0-9]*\)/\1/')
    echo "$((count + 1))"
}