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