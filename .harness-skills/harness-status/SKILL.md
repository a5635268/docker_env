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