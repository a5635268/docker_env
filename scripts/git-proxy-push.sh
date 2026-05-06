#!/bin/bash
# Git 推送脚本 - 自动适配代理环境
# 用法: ./git-proxy-push.sh <repo-url> <branch>

set -e

REPO_URL="${1:-}"
BRANCH="${2:-main}"
PROXY_PORT="${PROXY_PORT:-7890}"

if [[ -z "$REPO_URL" ]]; then
    echo "用法: $0 <repo-url> [branch]"
    echo "示例: $0 git@github.com:a5635268/harness-skill.git main"
    exit 1
fi

# 检测代理是否可用
check_proxy() {
    if curl -x socks5://127.0.0.1:$PROXY_PORT --connect-timeout 3 -s https://github.com > /dev/null 2>&1; then
        echo "socks5"
    elif curl -x http://127.0.0.1:$PROXY_PORT --connect-timeout 3 -s https://github.com > /dev/null 2>&1; then
        echo "http"
    else
        echo "none"
    fi
}

# 配置 SSH 代理
setup_ssh_proxy() {
    local proxy_type="$1"
    local ssh_config="$HOME/.ssh/config"
    local github_block

    if [[ "$proxy_type" == "socks5" ]]; then
        github_block="Host github.com
    HostName github.com
    User git
    ProxyCommand nc -X 5 -x 127.0.0.1:$PROXY_PORT %h %p"
    elif [[ "$proxy_type" == "http" ]]; then
        github_block="Host github.com
    HostName github.com
    User git
    ProxyCommand nc -X connect -x 127.0.0.1:$PROXY_PORT %h %p"
    else
        github_block="Host github.com
    HostName github.com
    User git"
    fi

    # 移除旧的 GitHub 配置块
    if grep -q "^Host github.com" "$ssh_config" 2>/dev/null; then
        # 使用 sed 删除 GitHub 配置块
        sed -i.bak '/^Host github.com$/,/^Host /{ /^Host github.com$/!{ /^Host /!d; }; }' "$ssh_config" 2>/dev/null || true
    fi

    # 添加新配置
    echo "$github_block" >> "$ssh_config"
    echo "已更新 SSH 配置（代理类型: $proxy_type）"
}

# 检测当前代理状态
proxy_type=$(check_proxy)
echo "检测到代理状态: $proxy_type"

# 配置 SSH
setup_ssh_proxy "$proxy_type"

# 执行推送
echo "正在推送 $BRANCH 到 $REPO_URL ..."
git push "$REPO_URL" "$BRANCH"

echo "推送完成！"