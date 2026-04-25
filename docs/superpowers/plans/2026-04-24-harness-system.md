# Harness 系统实施计划

> **目标**: 实现 Claude Code Skills Harness 系统，支持长时间运行 Agent 的跨会话持续工作
> **创建日期**: 2026-04-24
> **预计时长**: 2-3 小时

---

## 1. 架构概述

### 目标结构

```
.harness-skills/
├── harness-core/
│   ├── SKILL.md           # 核心框架 skill (状态检测、共享操作)
│   └── lib/
│       ├── state.sh       # 状态检测脚本
│       ├── validate.sh    # 数据验证脚本
│       ├── io.sh          # 文件读写封装
│       ├── git.sh         # Git 操作封装
│       └── prompt.sh      # 交互式对话模板
│
├── harness-init/
│   └── SKILL.md           # 初始化 skill
│
├── harness-plan/
│   └── SKILL.md           # 规划 skill (三种模式)
│
├── harness-run/
│   └── SKILL.md           # 执行 skill (状态驱动入口)
│
├── harness-status/
│   └── SKILL.md           # 状态 skill
│
└── templates/
    ├── feature_list.json  # 空骨架模板
    ├── config.json        # 配置模板
    └── init.sh            # 启动脚本模板
```

### 用户项目 .harness/ 结构

```
用户项目/.harness/
├── feature_list.json  # 任务清单
├── progress.txt       # 进度日志
├── init.sh            # 启动脚本
├── config.json        # Harness 配置
└── .gitignore         # 排除敏感文件
```

---

## 2. 实施阶段

### Phase 1: 核心框架 (harness-core)

**Commit Point**: `git commit -m "feat(harness): add core framework with state detection and shared operations"`

---

### Phase 2: 管道 Skills

**Commit Point**: `git commit -m "feat(harness): add init, plan, run, status pipeline skills"`

---

### Phase 3: 模板文件

**Commit Point**: `git commit -m "feat(harness): add template files for feature_list, config, init.sh"`

---

## 3. 详细任务清单

### Task 1.1: 创建目录结构

**文件**: 无 (目录创建)
**时长**: 1分钟

```bash
mkdir -p .harness-skills/harness-core/lib
mkdir -p .harness-skills/harness-init
mkdir -p .harness-skills/harness-plan
mkdir -p .harness-skills/harness-run
mkdir -p .harness-skills/harness-status
mkdir -p .harness-skills/templates
```

---

### Task 1.2: 创建 state.sh

**文件**: `.harness-skills/harness-core/lib/state.sh`
**时长**: 3分钟

```bash
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
```

---

### Task 1.3: 创建 validate.sh

**文件**: `.harness-skills/harness-core/lib/validate.sh`
**时长**: 3分钟

```bash
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
```

---

### Task 1.4: 创建 io.sh

**文件**: `.harness-skills/harness-core/lib/io.sh`
**时长**: 3分钟

```bash
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
```

---

### Task 1.5: 创建 git.sh

**文件**: `.harness-skills/harness-core/lib/git.sh`
**时长**: 3分钟

```bash
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
```

---

### Task 1.6: 创建 prompt.sh

**文件**: `.harness-skills/harness-core/lib/prompt.sh`
**时长**: 3分钟

```bash
#!/bin/bash
# Harness 交互式对话模板
# 用途：生成用户交互的问题和选项

set -e

# 初始化对话问题
prompt_init_questions() {
    echo "请回答以下问题以初始化 Harness:"
    echo ""
    echo "1. 项目名称? (默认: 当前目录名)"
    echo "2. 项目类型? (web/api/cli/library/other)"
    echo "3. 技术栈? (Node.js/Python/PHP/Go/Java/Mixed/Custom)"
    echo "4. 启动命令? (如: npm run dev, python app.py)"
}

# 规划模式选择
prompt_plan_mode() {
    echo "选择任务规划模式:"
    echo ""
    echo "A. 交互式录入 - 逐个对话录入任务"
    echo "B. 文档导入   - 解析现有文档生成任务"
    echo "C. AI 拆解    - 输入高层目标自动拆解"
}

# 任务录入问题
prompt_task_questions() {
    echo "录入新任务:"
    echo ""
    echo "1. 功能描述?"
    echo "2. 验证步骤? (每行一个步骤)"
    echo "3. 优先级? (1-5, 1最高)"
    echo "4. 分类? (functional/ui/api/security/other)"
    echo "5. 依赖任务? (可选，逗号分隔 ID)"
}

# 测试引导
prompt_test_guidance() {
    local task_id="$1"
    local steps_file="${2:-}"

    echo "=========================================="
    echo "测试引导 - 任务: $task_id"
    echo "=========================================="
    echo ""
    echo "请按以下步骤验证功能:"
    echo ""

    if [[ -n "$steps_file" && -f "$steps_file" ]]; then
        cat "$steps_file"
    else
        echo "(未提供具体步骤，请手动验证)"
    fi

    echo ""
    echo "验证完成后，请告诉我结果:"
    echo "- 通过: 输入 'pass' 或 '通过'"
    echo "- 失败: 输入 'fail' 或描述问题"
    echo "=========================================="
}

# 状态确认操作
prompt_status_actions() {
    echo "可选操作:"
    echo ""
    echo "A. 导出报告 - 生成 Markdown 进度报告"
    echo "B. 重置任务 - 所有 passes 重置为 false"
    echo "C. 清理记录 - 清空 progress.txt"
    echo "D. 继续     - 开始下一个任务"
    echo "E. 退出     - 结束当前会话"
}

# 继续确认
prompt_continue() {
    echo ""
    echo "是否继续下一个任务?"
    echo "- 继续: 输入 'y' 或 'yes'"
    echo "- 结束: 输入 'n' 或 'no'"
}

# 错误提示
prompt_error() {
    local error_type="$1"
    local detail="$2"

    echo "=========================================="
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M')"
    echo "Type: $error_type"
    echo "Detail: $detail"
    echo "=========================================="
}
```

---

### Task 1.7: 创建 harness-core/SKILL.md

**文件**: `.harness-skills/harness-core/SKILL.md`
**时长**: 5分钟

```markdown
---
name: harness-core
description: Harness 核心框架 - 提供状态检测和共享操作
---

# Harness Core Framework

## 概述

本 Skill 提供 Harness 系统的核心功能：
- 状态检测（阶段判断）
- 文件操作封装
- Git 操作封装
- 交互式对话模板

## 状态阶段

| 阶段 | 条件 | 可执行操作 |
|------|------|-----------|
| not_initialized | .harness/ 不存在 | 只能执行 harness-init |
| initialized | .harness/ 存在，无任务 | 可执行 harness-plan |
| planned | 有任务列表 | 可执行 harness-run、harness-status |
| running | 存在未完成任务 | 可执行 harness-run、harness-status |
| completed | 所有任务完成 | 可执行 harness-status、重置任务 |

## 核心函数

### 状态检测 (lib/state.sh)

```bash
# 检测 Harness 是否存在
harness_exists(project_root) → true/false

# 获取当前阶段
harness_get_stage(project_root) → not_initialized|initialized|planned|running|completed

# 验证文件完整性
harness_validate_files(project_root) → complete|missing: file1 file2

# 检测 Git 是否存在
git_exists(project_root) → true/false

# 获取下一个待执行任务
harness_get_next_task(project_root) → task_id
```

### 文件读写 (lib/io.sh)

```bash
# JSON 操作
read_json(file) → content
write_json(file, content)
append_task(task_json)
update_task_passes(task_id, passes_value)

# Progress 操作
read_progress(limit) → records
write_progress(message)
get_current_session() → session_number

# 文件创建
ensure_file(file, default_content)
```

### Git 操作 (lib/git.sh)

```bash
git_has_changes(project_root) → true/false
git_log_oneline(limit, project_root) → commits
git_commit(message, project_root)
git_status(project_root) → status
git_init_if_needed(project_root)
git_create_harness_gitignore(harness_dir)
```

### 验证 (lib/validate.sh)

```bash
validate_feature_list(file) → {valid, errors}
validate_task(task_json) → {valid, errors}
validate_config(file) → {valid, errors}
validate_init_script(file) → {valid, errors}
```

## 使用方式

其他 Skills 通过 source 引入：

```bash
source .harness-skills/harness-core/lib/state.sh
source .harness-skills/harness-core/lib/io.sh
source .harness-skills/harness-core/lib/git.sh
source .harness-skills/harness-core/lib/validate.sh
source .harness-skills/harness-core/lib/prompt.sh
```

## 设计原则

1. **单一职责**: 每个脚本只处理一类操作
2. **参数化**: 所有函数接受 project_root 参数
3. **幂等性**: 重复调用不会产生副作用
4. **错误处理**: 使用 set -e 确保脚本失败时立即停止
```

---

### Task 2.1: 创建 harness-init/SKILL.md

**文件**: `.harness-skills/harness-init/SKILL.md`
**时长**: 5分钟

```markdown
---
name: harness-init
description: Harness 初始化 Skill - 创建 .harness/ 目录和初始文件
---

# Harness Init

## 概述

创建用户项目的 Harness 环境，包括：
- .harness/ 目录结构
- config.json 配置文件
- init.sh 启动脚本
- feature_list.json 骨架
- progress.txt 首条记录
- Git 初始化（若需要）

## 执行流程

```
1. 检测状态 → 若已初始化则询问是否重新初始化
2. 创建 .harness/ 目录
3. 交互式对话：
   - 项目名称？（默认：当前目录名）
   - 项目类型？（web/api/cli/library/other）
   - 技术栈？（Node.js/Python/PHP/Go/Java/Mixed/Custom）
   - 启动命令？
4. 生成 init.sh
5. 生成 config.json
6. 初始化 Git（若尚未初始化）
7. 创建 .harness/.gitignore
8. 创建空的 feature_list.json 骨架
9. 创建 progress.txt 第一条记录
10. Git commit："Initialize harness for [项目名]"
```

## 交互对话示例

```bash
prompt_init_questions

read -p "项目名称: " project_name
project_name=${project_name:-$(basename $(pwd))}

read -p "项目类型 [web/api/cli/library/other]: " project_type
project_type=${project_type:-web}

read -p "技术栈 [Node.js/Python/PHP/Go/Java/Mixed/Custom]: " tech_stack
tech_stack=${tech_stack:-Node.js}

read -p "启动命令: " start_command
start_command=${start_command:-npm run dev}
```

## 生成文件模板

### init.sh

根据项目类型生成不同的启动脚本：

```bash
#!/bin/bash
# Harness init script for {project_name}
# Generated: {date}

set -e

echo "Starting {project_name} development environment..."

# 启动命令
{start_command}
```

### config.json

```json
{
  "project_name": "{project_name}",
  "project_type": "{project_type}",
  "tech_stack": "{tech_stack}",
  "created_at": "{date}",
  "harness_version": "1.0.0"
}
```

### feature_list.json 骨架

```json
{
  "tasks": [],
  "metadata": {
    "total_tasks": 0,
    "completed": 0,
    "pending": 0,
    "last_updated": "{date}"
  }
}
```

### progress.txt 首条记录

```
{date} Session #1 - Harness initialized for {project_name}
```

## 状态检查

```bash
source .harness-skills/harness-core/lib/state.sh

if harness_exists; then
    echo "Harness 已存在，是否重新初始化？"
    read -p "继续? [y/N]: " confirm
    if [[ "$confirm" != "y" ]]; then
        exit 0
    fi
    rm -rf .harness
fi
```

## 完成标志

- .harness/ 目录存在
- 所有必要文件已创建
- Git commit 已完成（若有 Git）
```

---

### Task 2.2: 创建 harness-plan/SKILL.md

**文件**: `.harness-skills/harness-plan/SKILL.md`
**时长**: 8分钟

```markdown
---
name: harness-plan
description: Harness 规划 Skill - 生成和管理 feature_list.json
---

# Harness Plan

## 概述

生成和管理任务清单 (feature_list.json)，支持三种模式：
- **交互式录入**: 逐个对话录入任务
- **文档导入**: 解析现有文档生成任务
- **AI 拆解**: 输入高层目标自动拆解功能单元

## 执行流程

### 模式选择

```bash
prompt_plan_mode
read -p "选择模式 [A/B/C]: " mode
```

### 模式 A: 交互式录入

```
循环：
  1. 提问：功能描述？
  2. 提问：验证步骤？（每行一个）
  3. 提问：优先级（1-5）？
  4. 提问：分类？
  5. 提问：依赖任务？（可选）
  6. 确认 → 追加到 feature_list.json
  7. 继续？是 → 循环；否 → 结束
```

示例代码：

```bash
while true; do
    prompt_task_questions

    read -p "功能描述: " description
    if [[ -z "$description" ]]; then
        break
    fi

    echo "验证步骤（每行一个，空行结束）:"
    steps=()
    while read -r step && [[ -n "$step" ]]; do
        steps+=("$step")
    done

    read -p "优先级 [1-5]: " priority
    priority=${priority:-3}

    read -p "分类 [functional/ui/api/security/other]: " category
    category=${category:-functional}

    read -p "依赖任务 (逗号分隔): " depends_on
    depends_on=${depends_on:-[]}

    # 生成任务 ID
    task_count=$(python3 -c "import json; print(len(json.load(open('.harness/feature_list.json'))['tasks']))")
    task_id="feat-$(printf '%03d' $((task_count + 1)))"

    # 构建任务 JSON
    task_json=$(cat << EOF
{
  "id": "$task_id",
  "category": "$category",
  "description": "$description",
  "steps": $(printf '%s\n' "${steps[@]}" | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))"),
  "priority": $priority,
  "depends_on": $(echo "$depends_on" | python3 -c "import sys,json; s=sys.stdin.read().strip(); print(json.dumps(s.split(',') if s else []))"),
  "passes": false
}
EOF
)

    # 追加任务
    append_task "$task_json"

    # 更新 progress
    write_progress "Added task $task_id: $description"

    read -p "继续录入? [y/N]: " continue
    if [[ "$continue" != "y" ]]; then
        break
    fi
done
```

### 模式 B: 文档导入

```
1. 提问：文档路径？
2. 读取并解析文档
3. AI 提取需求转换为任务结构
4. 展示任务列表供确认/调整
5. 写入 feature_list.json
```

### 模式 C: AI 拆解

```
1. 提问：高层目标？
2. AI 分析并拆解功能单元
3. 展示结果供确认/调整
4. 写入 feature_list.json
```

## 任务数据结构

```json
{
  "id": "feat-001",
  "category": "functional",
  "description": "功能描述",
  "steps": [
    "步骤1",
    "步骤2"
  ],
  "priority": 2,
  "depends_on": [],
  "passes": false
}
```

## 完成标志

- feature_list.json 已更新
- progress.txt 已追加记录
```

---

### Task 2.3: 创建 harness-run/SKILL.md

**文件**: `.harness-skills/harness-run/SKILL.md`
**时长**: 8分钟

```markdown
---
name: harness-run
description: Harness 执行 Skill - 状态驱动的任务执行循环
---

# Harness Run

## 概述

执行单一任务的增量开发循环。采用状态驱动设计，自动处理前置条件。

## 状态驱动入口

```bash
source .harness-skills/harness-core/lib/state.sh

stage=$(harness_get_stage)

case "$stage" in
    "not_initialized")
        echo "Harness 未初始化，自动执行 harness-init..."
        # 调用 harness-init
        # 然后调用 harness-plan (AI 拆解模式)
        ;;
    "initialized")
        echo "Harness 已初始化但无任务，自动执行 harness-plan..."
        # 调用 harness-plan (AI 拆解模式)
        ;;
    "planned"|"running")
        # 继续正常流程
        ;;
    "completed")
        echo "所有任务已完成"
        exit 0
        ;;
esac
```

## 正常执行流程

```
1. 定位阶段
   - pwd
   - read_progress(3)
   - git_log_oneline(5)

2. 选任务阶段
   - read_json(feature_list.json)
   - 筛选：passes=false + 依赖满足 + priority升序
   - 选择第一个

3. 启环境
   - 执行 init.sh

4. 验现状（可选）
   - 检查已有功能

5. 开发阶段
   - 按步骤实现
   - 一次只处理当前任务

6. 测试引导
   - prompt_test_guidance(steps)
   - 用户确认结果

7. 更状态
   - 测试通过 → passes=true + git commit + progress update
   - 测试失败 → 保持 passes=false，引导修复

8. 继续
   - prompt_continue
   - 用户选择继续或结束
```

## 定位阶段实现

```bash
echo "=========================================="
echo "Harness Run - Session #$(get_current_session)"
echo "=========================================="
echo ""

echo "当前目录: $(pwd)"
echo ""
echo "最近进展:"
read_progress 3
echo ""
echo "Git 历史:"
git_log_oneline 5
```

## 任务选择实现

```bash
# 获取下一个任务
task_id=$(harness_get_next_task)

if [[ -z "$task_id" ]]; then
    echo "没有待执行任务"
    exit 0
fi

echo "选中任务: $task_id"

# 解析任务详情
task_json=$(python3 -c "
import json
with open('.harness/feature_list.json') as f:
    data = json.load(f)
for t in data['tasks']:
    if t['id'] == '$task_id':
        print(json.dumps(t))
")
```

## 开发约束

**关键指令**：
- ✅ 一次只处理一个任务
- ✅ 仅修改 passes 字段
- ✅ 测试引导不强制阻塞
- ❌ 不允许一次性尝试完成多个任务
- ❌ 不允许删除或编辑其他任务的字段
- ❌ 不允许跳过测试验证步骤

## 测试引导实现

```bash
steps=$(echo "$task_json" | python3 -c "import sys,json; t=json.load(sys.stdin); print('\n'.join(t['steps']))")
prompt_test_guidance "$task_id" "$steps"

read -p "测试结果: " result

case "$result" in
    pass|通过)
        update_task_passes "$task_id" true
        git_commit "Complete $task_id: $description"
        write_progress "Completed $task_id"
        ;;
    fail|失败|*)
        echo "测试失败，保持 passes=false"
        write_progress "Failed $task_id - needs fix"
        ;;
esac
```

## 完成标志

- 任务 passes 字段已更新
- Git commit 已完成
- progress.txt 已追加记录
```

---

### Task 2.4: 创建 harness-status/SKILL.md

**文件**: `.harness-skills/harness-status/SKILL.md`
**时长**: 5分钟

```markdown
---
name: harness-status
description: Harness 状态 Skill - 展示当前进度和任务状态
---

# Harness Status

## 概述

展示当前 Harness 系统的完整状态，包括：
- 项目概览
- 任务统计
- 任务列表（已完成/待办）
- 最近进展
- Git 历史

## 执行流程

```
1. 检测状态 → 确认 Harness 已初始化
2. 读取 config.json → 项目概览
3. 读取 feature_list.json → 任务统计
4. 展示任务列表
5. 读取 progress.txt → 最近进展
6. 读取 git log → Git 历史
7. 提供可选操作
```

## 项目概览

```bash
config=$(read_json .harness/config.json)

project_name=$(echo "$config" | python3 -c "import sys,json; print(json.load(sys.stdin)['project_name'])")
project_type=$(echo "$config" | python3 -c "import sys,json; print(json.load(sys.stdin)['project_type'])")
tech_stack=$(echo "$config" | python3 -c "import sys,json; print(json.load(sys.stdin)['tech_stack'])")
created_at=$(echo "$config" | python3 -c "import sys,json; print(json.load(sys.stdin)['created_at'])")

stage=$(harness_get_stage)

echo "=========================================="
echo "Harness Status - $project_name"
echo "=========================================="
echo ""
echo "项目类型: $project_type"
echo "技术栈: $tech_stack"
echo "创建日期: $created_at"
echo "当前阶段: $stage"
```

## 任务统计

```bash
feature_list=$(read_json .harness/feature_list.json)

total=$(echo "$feature_list" | python3 -c "import sys,json; print(json.load(sys.stdin)['metadata']['total_tasks'])")
completed=$(echo "$feature_list" | python3 -c "import sys,json; print(json.load(sys.stdin)['metadata']['completed'])")
pending=$(echo "$feature_list" | python3 -c "import sys,json; print(json.load(sys.stdin)['metadata']['pending'])")

echo ""
echo "任务统计:"
echo "  总数: $total"
echo "  已完成: $completed"
echo "  待办: $pending"
echo "  完成率: $((completed * 100 / total))%"
```

## 任务列表

```bash
echo ""
echo "已完成任务:"
python3 << EOF
import json
with open('.harness/feature_list.json') as f:
    data = json.load(f)
for t in data['tasks']:
    if t['passes']:
        print(f"  ✓ {t['id']}: {t['description']}")
EOF

echo ""
echo "待办任务 (按优先级):"
python3 << EOF
import json
with open('.harness/feature_list.json') as f:
    data = json.load(f)
pending = sorted([t for t in data['tasks'] if not t['passes']], key=lambda x: x['priority'])
for t in pending:
    deps = ', '.join(t.get('depends_on', [])) if t.get('depends_on') else '-'
    print(f"  ○ {t['id']} (P{t['priority']}, deps: {deps}): {t['description']}")
EOF
```

## 最近进展

```bash
echo ""
echo "最近进展:"
read_progress 5
```

## Git 历史

```bash
echo ""
echo "Git 历史:"
git_log_oneline 5
```

## 可选操作

```bash
prompt_status_actions
read -p "选择操作 [A/B/C/D/E]: " action

case "$action" in
    A)
        # 导出报告
        python3 << EOF
import json, datetime
with open('.harness/feature_list.json') as f:
    data = json.load(f)
with open('.harness/config.json') as f:
    config = json.load(f)
report = f"# {config['project_name']} Progress Report\n\n"
report += f"Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"
report += "## Completed\n"
for t in data['tasks']:
    if t['passes']:
        report += f"- {t['id']}: {t['description']}\n"
report += "\n## Pending\n"
for t in data['tasks']:
    if not t['passes']:
        report += f"- {t['id']}: {t['description']}\n"
with open('.harness/progress_report.md', 'w') as f:
    f.write(report)
EOF
        echo "报告已生成: .harness/progress_report.md"
        ;;
    B)
        # 重置任务
        python3 << EOF
import json
with open('.harness/feature_list.json') as f:
    data = json.load(f)
for t in data['tasks']:
    t['passes'] = False
data['metadata']['completed'] = 0
data['metadata']['pending'] = len(data['tasks'])
with open('.harness/feature_list.json', 'w') as f:
    json.dump(data, f, indent=2)
EOF
        write_progress "Reset all tasks to pending"
        echo "所有任务已重置"
        ;;
    C)
        # 清理记录
        rm .harness/progress.txt
        write_progress "Progress cleared"
        echo "progress.txt 已清空"
        ;;
    D)
        # 继续
        echo "请调用 /harness-run 继续执行"
        ;;
    E)
        # 退出
        exit 0
        ;;
esac
```

## 完成标志

- 状态信息完整展示
- 用户选择的操作已执行
```

---

### Task 3.1: 创建 templates/feature_list.json

**文件**: `.harness-skills/templates/feature_list.json`
**时长**: 1分钟

```json
{
  "tasks": [],
  "metadata": {
    "total_tasks": 0,
    "completed": 0,
    "pending": 0,
    "last_updated": ""
  }
}
```

---

### Task 3.2: 创建 templates/config.json

**文件**: `.harness-skills/templates/config.json`
**时长**: 1分钟

```json
{
  "project_name": "",
  "project_type": "web",
  "tech_stack": "Node.js",
  "created_at": "",
  "harness_version": "1.0.0"
}
```

---

### Task 3.3: 创建 templates/init.sh

**文件**: `.harness-skills/templates/init.sh`
**时长**: 1分钟

```bash
#!/bin/bash
# Harness init script template
# Generated: {date}

set -e

echo "Starting development environment..."

# 启动命令 (根据项目类型调整)
# Node.js: npm run dev
# Python: python app.py
# PHP: php -S localhost:8000
# Go: go run main.go

{start_command}
```

---

## 4. Commit 计划

| Commit | 内容 | 文件数 |
|--------|------|--------|
| Commit 1 | 核心框架 + lib 脚本 + harness-core SKILL.md | 6 |
| Commit 2 | 管道 Skills (init/plan/run/status) | 4 |
| Commit 3 | 模板文件 | 3 |

---

## 5. 验证清单

完成后验证：

- [ ] 所有文件已创建
- [ ] 脚本可执行 (chmod +x)
- [ ] SKILL.md 格式正确
- [ ] 模板文件完整
- [ ] Git commit 完成

---

## 6. 下一步

计划完成后，选择执行方式：

- **Subagent-Driven**: 启动专用 Agent 按计划执行
- **Inline Execution**: 在当前会话逐步执行