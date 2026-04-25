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