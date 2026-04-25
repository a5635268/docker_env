---
name: harness-run
description: Harness 执行 Skill - 状态驱动的自动任务执行循环
---

# Harness Run

## 概述

执行单一任务的增量开发循环。采用状态驱动设计，自动处理前置条件，**自动连续执行直到所有任务完成或用户中断**。

## 自动循环模式

**默认行为**：完成任务后自动继续下一个任务，无需手动确认。

**中断方式**：
- 输入 `stop` 或 `停止` - 结束当前会话
- 输入 `pause` 或 `暂停` - 暂停后可手动决定
- 测试失败时自动暂停，等待修复

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
        # 继续正常流程（自动循环）
        ;;
    "completed")
        echo "所有任务已完成"
        exit 0
        ;;
esac
```

## 自动执行流程

```
循环开始 ────────────────────────────────────────────
│
│  1. 定位阶段
│     - pwd（确认工作目录）
│     - read_progress(3)（最近进展）
│     - git_log_oneline(5)（Git 历史）
│
│  2. 选任务
│     - 最高优先级 + 依赖满足 + passes=false
│     - 无任务 → 自动结束循环
│
│  3. 启环境
│     - 执行 init.sh（若需要）
│
│  4. 开发
│     - 按步骤实现
│     - 一次只处理一个任务
│
│  5. 测试引导
│     - 提供测试指令
│     - 用户确认结果
│
│  6. 更状态
│     - 通过 → passes=true + git commit + progress update → 自动回到步骤1
│     - 失败 → 暂停循环，引导修复
│     - 用户输入 stop → 结束循环
│
└────────────────────────────────────────────────────
循环结束
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
echo ""
echo "自动循环模式（输入 'stop' 结束）"
echo "=========================================="
```

## 任务选择实现

```bash
# 获取下一个任务
task_id=$(harness_get_next_task)

if [[ -z "$task_id" ]]; then
    echo ""
    echo "=========================================="
    echo "所有任务已完成！"
    echo "=========================================="
    exit 0
fi

echo ""
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
- ✅ 完成后自动继续下一个任务
- ❌ 不允许一次性尝试完成多个任务
- ❌ 不允许删除或编辑其他任务的字段
- ❌ 不允许跳过测试验证步骤

## 测试引导实现

```bash
steps=$(echo "$task_json" | python3 -c "import sys,json; t=json.load(sys.stdin); print('\n'.join(t['steps']))")
prompt_test_guidance "$task_id" "$steps"

echo ""
echo "请输入测试结果:"
echo "  - 'pass' 或 '通过' : 任务完成，自动继续下一个"
echo "  - 'fail' 或 '失败' : 暂停循环，需要修复"
echo "  - 'stop' 或 '停止' : 结束当前会话"
echo ""

read -p "测试结果: " result

case "$result" in
    pass|通过)
        update_task_passes "$task_id" true
        git_commit "Complete $task_id: $description"
        write_progress "Completed $task_id - auto continue"
        echo ""
        echo "✓ 任务完成，自动继续下一个任务..."
        # 自动回到循环开始（通过 while 循环实现）
        ;;
    fail|失败)
        echo ""
        echo "=========================================="
        echo "测试失败，循环暂停"
        echo "修复后请再次调用 /harness-run 继续"
        echo "=========================================="
        write_progress "Failed $task_id - paused for fix"
        exit 1
        ;;
    stop|停止|pause|暂停)
        echo ""
        echo "=========================================="
        echo "会话已暂停/停止"
        echo "需要继续时请调用 /harness-run"
        echo "=========================================="
        write_progress "Session paused at $task_id"
        exit 0
        ;;
    *)
        echo "未知输入，默认视为失败"
        write_progress "Failed $task_id - needs fix"
        exit 1
        ;;
esac
```

## 自动循环实现（完整脚本）

```bash
#!/bin/bash
# harness-run 自动循环实现

source .harness-skills/harness-core/lib/state.sh
source .harness-skills/harness-core/lib/io.sh
source .harness-skills/harness-core/lib/git.sh

# 状态检测和自动处理前置条件
stage=$(harness_get_stage)

case "$stage" in
    "not_initialized"|"initialized")
        echo "前置条件未满足，请先调用 /harness-init 和 /harness-plan"
        exit 1
        ;;
    "completed")
        echo "所有任务已完成"
        exit 0
        ;;
esac

# 自动循环
while true; do
    # 定位
    echo "=========================================="
    pwd
    read_progress 3
    git_log_oneline 5
    
    # 选任务
    task_id=$(harness_get_next_task)
    if [[ -z "$task_id" ]]; then
        echo "所有任务已完成！"
        break
    fi
    
    echo "执行任务: $task_id"
    
    # 开发 + 测试（由 Agent 执行）
    # ...
    
    # 测试结果由 Agent 根据用户输入决定
    # pass → continue (循环)
    # fail/stop → exit
    
    read -p "测试结果 (pass/fail/stop): " result
    
    if [[ "$result" == "pass" ]]; then
        update_task_passes "$task_id" true
        git_commit "Complete $task_id"
        write_progress "Completed $task_id"
        echo "✓ 继续下一个任务..."
        continue  # 自动回到循环开始
    elif [[ "$result" == "stop" ]]; then
        echo "会话已停止"
        break
    else
        echo "测试失败，暂停"
        break
    fi
done

echo "=========================================="
echo "Harness 会话结束"
echo "=========================================="
```

## 完成标志

- 任务 passes 字段已更新
- Git commit 已完成
- progress.txt 已追加记录
- 自动继续或用户中断退出