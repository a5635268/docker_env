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