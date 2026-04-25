---
name: harness-plan
description: Harness 规划 Skill - 生成任务清单和设计文档
---

# Harness Plan

## 概述

生成和管理任务清单 (feature_list.json) 及设计文档，支持三种模式：
- **交互式录入**: 逐个对话录入任务 + 生成任务级设计
- **文档导入**: 解析现有文档生成任务 + 生成任务级设计
- **AI 拆解**: 输入高层目标自动拆解 + 生成整体架构 + 任务级设计

## 文件结构

```
.harness/
├── CLAUDE.md              # 项目上下文（harness-init 生成）
├── architecture.md        # 整体架构设计（新系统 AI 拆解时生成）
├── feature_list.json      # 任务清单
├── design/                # 任务级设计文档
│   ├── feat-001.md        # 每个任务的实现指导
│   ├── feat-002.md
│   └── ...
└── progress.txt
```

## 执行流程

### 模式选择

```bash
prompt_plan_mode
echo ""
echo "A. 交互式录入 - 逐个对话录入任务"
echo "B. 文档导入   - 解析现有文档生成任务"
echo "C. AI 拆解    - 输入高层目标自动拆解（新系统生成架构文档）"
echo ""
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
  6. 提问：实现思路？（生成 design/<task-id>.md）
  7. 确认 → 追加到 feature_list.json + 生成设计文档
  8. 继续？是 → 循环；否 → 结束
```

### 模式 B: 文档导入

```
1. 提问：文档路径？
2. 读取并解析文档
3. AI 提取需求转换为任务结构
4. 展示任务列表供确认/调整
5. 为每个任务生成 design/<task-id>.md
6. 写入 feature_list.json
```

### 模式 C: AI 拆解

```
1. 提问：高层目标？
2. 读取 .harness/CLAUDE.md 作为上下文
3. AI 分析并拆解功能单元
4. 新系统：生成 architecture.md（整体架构设计）
5. 为每个任务生成 design/<task-id>.md
6. 展示结果供确认/调整
7. 写入 feature_list.json
```

## 任务数据结构（扩展）

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
  "design_file": "design/feat-001.md",
  "passes": false
}
```

**新增字段说明**：

| 字段 | 类型 | 说明 |
|------|------|------|
| design_file | string | 任务级设计文档路径 |

## 任务级设计文档生成

```bash
generate_task_design() {
    local task_id="$1"
    local description="$2"
    local tech_points="${3:-待补充}"
    local notes="${4:-待补充}"
    local ref_files="${5:-无}"
    
    # 读取项目上下文
    local context=""
    if [[ -f ".harness/CLAUDE.md" ]]; then
        context=$(cat .harness/CLAUDE.md)
    fi
    
    # 旧系统：读取相关现有代码
    local existing_code_analysis=""
    if [[ -f ".harness/config.json" ]]; then
        project_status=$(python3 -c "import json; print(json.load(open('.harness/config.json'))['project_status'])")
        if [[ "$project_status" == "legacy" ]]; then
            existing_code_analysis="（请参考现有代码结构，保持一致性）"
        fi
    fi
    
    cat > ".harness/design/$task_id.md" << EOF
# $task_id - $description

> 创建日期: $(date '+%Y-%m-%d')

## 功能描述

$description

## 验证步骤

$(printf '%s\n' "${steps[@]}" | sed 's/^/- /')

## 实现思路

### 关键技术点

$tech_points

### 注意事项

$notes

## 相关文件

$ref_files

$existing_code_analysis

## 项目上下文参考

（来自 .harness/CLAUDE.md）
EOF
    
    write_progress "Generated design/$task_id.md"
}
```

## 读写时机

| 会话启动时读取 | 任务完成后更新 |
|---------------|---------------|
| `.harness/CLAUDE.md` | `.harness/progress.txt` |
| `.harness/architecture.md`（新系统） | `.harness/design/<task-id>.md`（可选补充） |
| `.harness/design/<current-task>.md` | `.harness/feature_list.json`（passes 字段） |
| `.harness/feature_list.json` | Git commit |

## 完成标志

- feature_list.json 已更新（包含 design_file 字段）
- design/<task-id>.md 已生成（每个任务）
- architecture.md 已生成（新系统 AI 拆解模式）
- progress.txt 已追加记录