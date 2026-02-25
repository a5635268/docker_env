#!/bin/bash

# PHP74 Docker 多项目管理脚本（根目录 local 版本）
# 为每个项目创建独立的容器，提供最佳的隔离性和灵活性

set -e

NO_COLOR_FLAG=0

# 路径和配置（基于当前脚本所在目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/projects.conf"
PHP_INI_PATH="$SCRIPT_DIR/php74local/conf/php.ini"
LOGS_BASE_PATH="$SCRIPT_DIR/php74local/logs"
IMAGE_NAME="php74-fpm:custom"

# 解析全局参数（目前仅支持 --no-color）
if [[ "$1" == "--no-color" ]]; then
    NO_COLOR_FLAG=1
    shift
elif [[ -n "$NO_COLOR" ]]; then
    NO_COLOR_FLAG=1
fi

# 根据是否是 TTY / NO_COLOR 设置颜色
if [[ $NO_COLOR_FLAG -eq 0 && -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

print_info() { echo -e "${BLUE}[信息]${NC} $1"; }
print_success() { echo -e "${GREEN}[成功]${NC} $1"; }
print_error() { echo -e "${RED}[错误]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[警告]${NC} $1"; }

declare -a PROJECTS=()

# 加载配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        # 默认示例项目（可按需修改）
        PROJECTS=(
            "mengdada-php:9001:/Users/mac/wwwroot/www.mengdada.club:mengdada"
        )
        save_config
    fi
}

# 保存配置
save_config() {
    cat > "$CONFIG_FILE" <<EOF
# PHP74 Docker 多项目配置
# 格式："容器名:端口:项目路径:日志子目录"

PROJECTS=(
$(for p in "\${PROJECTS[@]}"; do echo "    \"\$p\""; done)
)
EOF
}

# 停止并删除容器
stop_container() {
    local container_name="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        print_info "停止并删除容器：$container_name"
        docker stop "$container_name" >/dev/null 2>&1 || true
        docker rm "$container_name" >/dev/null 2>&1 || true
    fi
}

# 启动单个项目
start_project() {
    local config="$1"
    IFS=':' read -r container_name port project_path log_subdir <<< "$config"
    
    print_info "启动项目：$container_name (端口：$port)"
    
    if [[ ! -d "$project_path" ]]; then
        print_error "项目目录不存在：$project_path"
        return 1
    fi
    
    local log_path="$LOGS_BASE_PATH/$log_subdir"
    mkdir -p "$log_path"
    
    if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGE_NAME$"; then
        print_warning "镜像不存在：$IMAGE_NAME，开始构建..."
        docker build -t "$IMAGE_NAME" "$SCRIPT_DIR/php74local" || {
            print_error "镜像构建失败"
            return 1
        }
    fi
    
    stop_container "$container_name"
    
    docker run -d \
      --name "$container_name" \
      -p "$port:9000" \
      -v "$PHP_INI_PATH:/usr/local/etc/php/php.ini" \
      -v "$project_path:$project_path" \
      -v "$log_path:/var/www/logs" \
      --add-host=host.docker.internal:host-gateway \
      --user $(id -u):$(id -g) \
      "$IMAGE_NAME" >/dev/null
    
    print_success "容器已启动"
}

# 显示所有项目状态
show_status() {
    echo ""
    printf "%-25s %-10s %-15s %s\n" "容器名称" "端口" "状态" "项目路径"
    printf "%-25s %-10s %-15s %s\n" "--------" "----" "----" "----------"
    
    for config in "${PROJECTS[@]}"; do
        IFS=':' read -r container_name port project_path log_subdir <<< "$config"
        if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
            status="${GREEN}运行中${NC}"
        elif docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
            status="${YELLOW}已停止${NC}"
        else
            status="${RED}未创建${NC}"
        fi
        printf "%-25s %-10s %-24s %s\n" "$container_name" "$port" "$status" "$project_path"
    done
    echo ""
}

# 停止所有
stop_all() {
    print_info "停止所有项目容器..."
    for config in "${PROJECTS[@]}"; do
        IFS=':' read -r container_name _ _ _ <<< "$config"
        stop_container "$container_name"
    done
    print_success "所有容器已停止"
}

# 添加项目
add_project() {
    echo ""
    print_info "添加新项目"
    read -p "容器名称 (例: myproject-php): " container_name
    read -p "分配端口 (例: 9003): " port
    read -p "项目路径 (绝对路径): " project_path
    read -p "日志子目录 (例: myproject): " log_subdir
    
    if [[ -z "$container_name" || -z "$port" || -z "$project_path" || -z "$log_subdir" ]]; then
        print_error "参数不能为空"
        return 1
    fi
    
    project_path="${project_path/#\~/$HOME}"
    if [[ ! -d "$project_path" ]]; then
        read -p "项目目录不存在，是否创建？(y/n): " create
        if [[ "$create" =~ ^[Yy]$ ]]; then
            mkdir -p "$project_path"
        else
            return 1
        fi
    fi
    
    PROJECTS+=("$container_name:$port:$project_path:$log_subdir")
    save_config
    print_success "项目已保存"
    
    read -p "是否立即启动？(y/n): " start_now
    if [[ "$start_now" =~ ^[Yy]$ ]]; then
        start_project "$container_name:$port:$project_path:$log_subdir"
    fi
}

# 删除项目
remove_project() {
    echo ""
    print_info "删除项目"
    if [[ ${#PROJECTS[@]} -eq 0 ]]; then
        print_warning "没有可删除的项目"
        return
    fi
    
    for i in "${!PROJECTS[@]}"; do
        IFS=':' read -r container_name _ _ _ <<< "${PROJECTS[$i]}"
        echo "[$i] $container_name"
    done
    
    read -p "请输入要删除的项目编号 (回车取消): " idx
    if [[ -n "$idx" && "$idx" -ge 0 && "$idx" -lt ${#PROJECTS[@]} ]]; then
        IFS=':' read -r container_name _ _ _ <<< "${PROJECTS[$idx]}"
        stop_container "$container_name"
        unset 'PROJECTS[$idx]'
        PROJECTS=("${PROJECTS[@]}")
        save_config
        print_success "项目已删除并停止相关容器"
    fi
}

show_menu() {
    echo "========================================"
    echo "  PHP74 Docker 项目管理工具 (local)"
    echo "========================================"
    echo "1) 启动所有项目"
    echo "2) 停止所有项目"
    echo "3) 重启所有项目"
    echo "4) 查看项目状态"
    echo "5) 查看项目日志"
    echo "6) 添加新项目"
    echo "7) 删除项目"
    echo "0) 退出"
    echo "========================================"
}

main() {
    load_config
    while true; do
        show_menu
        read -p "请选择操作 [0-7]: " choice
        case $choice in
            1) for c in "${PROJECTS[@]}"; do start_project "$c"; done ;;
            2) stop_all ;;
            3) stop_all; for c in "${PROJECTS[@]}"; do start_project "$c"; done ;;
            4) show_status ;;
            5)
                echo ""
                for i in "${!PROJECTS[@]}"; do
                    IFS=':' read -r name _ _ _ <<< "${PROJECTS[$i]}"
                    echo "[$i] $name"
                done
                read -p "选择查看日志的项目编号: " idx
                if [[ -n "$idx" && "$idx" -ge 0 && "$idx" -lt ${#PROJECTS[@]} ]]; then
                    IFS=':' read -r name _ _ _ <<< "${PROJECTS[$idx]}"
                    docker logs -f "$name"
                fi
                ;;
            6) add_project ;;
            7) remove_project ;;
            0) print_info "退出"; exit 0 ;;
            *) print_error "无效选择" ;;
        esac
        echo ""
    done
}

if [[ $# -eq 0 ]]; then
    main
else
    load_config
    case "$1" in
        start)
            if [[ -n "$2" ]]; then
                for c in "${PROJECTS[@]}"; do
                    if [[ "${c%%:*}" == "$2" ]]; then start_project "$c"; exit 0; fi
                done
                print_error "未找到项目: $2"
            else
                for c in "${PROJECTS[@]}"; do start_project "$c"; done
            fi
            ;;
        stop) stop_all ;;
        restart) stop_all; for c in "${PROJECTS[@]}"; do start_project "$c"; done ;;
        status) show_status ;;
        logs) [[ -n "$2" ]] && docker logs -f "$2" || print_error "请指定容器名" ;;
        *) echo "命令: [--no-color] start [name], stop, restart, status, logs <name>"; exit 1 ;;
    esac
fi

