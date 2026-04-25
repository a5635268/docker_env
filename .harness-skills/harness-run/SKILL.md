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