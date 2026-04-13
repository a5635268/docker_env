#!/bin/bash
set -euo pipefail

# 创建共享网络 shared-network
# 用法：./scripts/init-network.sh

NETWORK_NAME="shared-network"

# 检查网络是否已存在（精确匹配）
if docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo "✓ 网络 $NETWORK_NAME 已存在"
else
    echo "创建网络 $NETWORK_NAME..."
    docker network create "$NETWORK_NAME"
    echo "✓ 网络 $NETWORK_NAME 创建成功"
fi

echo ""
echo "网络信息："
docker network inspect "$NETWORK_NAME" --format='{{.Name}} ({{.Driver}}): {{range .IPAM.Config}}{{.Subnet}}{{end}}'