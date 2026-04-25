---
name: harness-init
description: Harness 初始化 Skill - 创建 .harness/ 目录、上下文文件和初始文件
---

# Harness Init

## 概述

创建用户项目的 Harness 环境，包括：
- .harness/ 目录结构
- CLAUDE.md 项目上下文（**区分旧系统/新系统**）
- config.json 配置文件
- init.sh 启动脚本
- feature_list.json 骨架
- design/ 目录（任务级设计文档）
- progress.txt 首条记录
- Git 初始化（若需要）

## 执行流程

```
1. 检测状态 → 若已初始化则询问是否重新初始化
2. 检测项目类型 → 旧系统（已有代码）或 新系统（全新项目）
3. 创建 .harness/ 目录结构
4. 交互式对话（根据项目类型调整）
5. 生成 CLAUDE.md（区分策略）
6. 生成 init.sh
7. 生成 config.json
8. 创建 design/ 目录
9. 初始化 Git（若尚未初始化）
10. 创建 .harness/.gitignore
11. 创建空的 feature_list.json 骨架
12. 创建 progress.txt 第一条记录
13. Git commit："Initialize harness for [项目名]"
```

## 项目类型检测

```bash
# 检测是否为旧系统（已有代码）
detect_project_type() {
    local has_code=false
    local has_claude_md=false
    
    # 检测常见代码目录
    if [[ -d "src" ]] || [[ -d "app" ]] || [[ -d "lib" ]] || [[ -f "package.json" ]] || [[ -f "composer.json" ]] || [[ -f "go.mod" ]]; then
        has_code=true
    fi
    
    # 检测根目录 CLAUDE.md
    if [[ -f "CLAUDE.md" ]]; then
        has_claude_md=true
    fi
    
    if [[ "$has_code" == true ]]; then
        echo "legacy"  # 旧系统
    else
        echo "new"     # 新系统
    fi
}
```

## 交互式对话（区分策略）

### 旧系统（Legacy）

```bash
echo "检测到已有代码项目（旧系统）"
echo ""

# 基础信息（自动填充优先）
project_name=$(basename $(pwd))
read -p "项目名称 [$project_name]: " input_name
project_name=${input_name:-$project_name}

# 自动检测技术栈
auto_tech_stack=""
if [[ -f "package.json" ]]; then
    auto_tech_stack="Node.js"
elif [[ -f "composer.json" ]]; then
    auto_tech_stack="PHP"
elif [[ -f "go.mod" ]]; then
    auto_tech_stack="Go"
elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
    auto_tech_stack="Python"
elif [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]]; then
    auto_tech_stack="Java"
fi

read -p "技术栈 [$auto_tech_stack]: " tech_stack
tech_stack=${tech_stack:-$auto_tech_stack}
tech_stack=${tech_stack:-"Mixed"}

# 启动命令（自动检测）
auto_start=""
if [[ -f "package.json" ]]; then
    auto_start="npm run dev"
elif [[ -f "artisan" ]]; then
    auto_start="php artisan serve"
elif [[ -f "main.go" ]]; then
    auto_start="go run main.go"
elif [[ -f "app.py" ]]; then
    auto_start="python app.py"
fi

read -p "启动命令 [$auto_start]: " start_command
start_command=${start_command:-$auto_start}

# CLAUDE.md 处理策略
if [[ -f "CLAUDE.md" ]]; then
    echo ""
    echo "检测到根目录已有 CLAUDE.md"
    read -p "处理方式? [link=链接引用/analyze=分析补充]: " claude_action
    claude_action=${claude_action:-link}
else
    echo ""
    echo "未检测到 CLAUDE.md，将自动分析项目结构生成"
    claude_action="analyze"
fi
```

### 新系统（New）

```bash
echo "检测到全新项目"
echo ""

read -p "项目名称: " project_name
project_name=${project_name:-$(basename $(pwd))}

read -p "项目类型 [web/api/cli/library/other]: " project_type
project_type=${project_type:-web}

read -p "技术栈 [Node.js/Python/PHP/Go/Java/Mixed/Custom]: " tech_stack
tech_stack=${tech_stack:-Node.js}

read -p "启动命令: " start_command
start_command=${start_command:-npm run dev}

# 新系统额外收集架构信息
echo ""
echo "=== 项目架构配置 ==="
read -p "架构模式 [monolith/microservice/modular/serverless]: " architecture
architecture=${architecture:-monolith}

read -p "关键技术约定 (如: REST API, GraphQL, SSR): " conventions
conventions=${conventions:-REST API}

read -p "代码风格偏好 [functional/oop/mixed]: " style
style=${style:-mixed}

read -p "测试框架 (如: Jest, PHPUnit, pytest): " test_framework
test_framework=${test_framework:-Jest}
```

## CLAUDE.md 生成策略

### 旧系统 - Link 模式

```bash
# 链接引用根目录 CLAUDE.md
cat > .harness/CLAUDE.md << EOF
# 项目上下文

> 此文件引用根目录 CLAUDE.md，作为 Harness 工作上下文

## 主文档

请参考项目根目录的 [CLAUDE.md](../CLAUDE.md) 获取完整项目上下文。

## Harness 补充信息

- 技术栈: $tech_stack
- 项目类型: Legacy（已有代码）
- 启动命令: $start_command
EOF
```

### 旧系统 - Analyze 模式

```bash
# 自动分析项目结构生成
analyze_project_structure() {
    local output_file=".harness/CLAUDE.md"
    
    echo "# 项目上下文" > "$output_file"
    echo "" >> "$output_file"
    echo "> 自动分析生成，请根据实际情况补充" >> "$output_file"
    echo "" >> "$output_file"
    
    # 技术栈
    echo "## 技术栈" >> "$output_file"
    echo "- $tech_stack" >> "$output_file"
    echo "" >> "$output_file"
    
    # 目录结构分析
    echo "## 目录结构" >> "$output_file"
    if [[ -d "src" ]]; then
        echo "- src/ - 源代码目录" >> "$output_file"
    fi
    if [[ -d "tests" ]] || [[ -d "test" ]]; then
        echo "- tests/ - 测试目录" >> "$output_file"
    fi
    if [[ -d "config" ]]; then
        echo "- config/ - 配置目录" >> "$output_file"
    fi
    
    echo "" >> "$output_file"
    echo "## 待补充" >> "$output_file"
    echo "- 架构模式" >> "$output_file"
    echo "- 关键技术约定" >> "$output_file"
    echo "- 代码风格" >> "$output_file"
}
```

### 新系统 - 交互式生成

```bash
cat > .harness/CLAUDE.md << EOF
# 项目上下文

> 创建日期: $(date '+%Y-%m-%d')
> 项目类型: New（全新项目）

## 基本信息

- 项目名称: $project_name
- 项目类型: $project_type
- 技术栈: $tech_stack

## 架构配置

- 架构模式: $architecture
- 技术约定: $conventions
- 代码风格: $style
- 测试框架: $test_framework

## 启动命令

\`\`\`bash
$start_command
\`\`\`

## 目录结构（规划）

\`\`\`
$project_name/
├── src/           # 源代码
├── tests/         # 测试文件
├── config/        # 配置文件
├── docs/          # 文档
└── .harness/      # Harness 系统文件
\`\`\`

## 开发约定

（待后续补充）
EOF
```

## 生成文件模板

### .harness/ 目录结构

```
.harness/
├── CLAUDE.md              # 项目上下文
├── feature_list.json      # 任务清单骨架
├── progress.txt           # 进度日志
├── init.sh                # 启动脚本
├── config.json            # Harness 配置
├── design/                # 任务级设计文档目录
│   └── .gitkeep           # 保持目录存在
└── .gitignore             # 排除临时文件
```

### config.json（扩展）

```json
{
  "project_name": "{project_name}",
  "project_type": "{project_type}",
  "tech_stack": "{tech_stack}",
  "project_status": "{legacy|new}",
  "architecture": "{architecture}",
  "conventions": "{conventions}",
  "created_at": "{date}",
  "harness_version": "1.1.0"
}
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
- CLAUDE.md 已生成（旧系统 link/analyze，新系统交互式）
- design/ 目录已创建
- 所有必要文件已创建
- Git commit 已完成（若有 Git）