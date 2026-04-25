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