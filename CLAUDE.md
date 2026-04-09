# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 Docker 的 Mac 开发环境，提供统一的中间件服务和多语言项目示例。采用 `shared-network` Docker 网络实现容器间通信。

## 目录结构

```
docker_env/
├── middleware/          # 公共中间件 (MySQL/Redis/PostgreSQL/RabbitMQ/ES/MongoDB/Nginx)
├── local/               # 宿主机中间件 + 容器 PHP 本地开发环境
├── examples/            # 各语言项目示例 (php/java/python/go)
├── scripts/             # 工具脚本
└── .spec-workflow/      # Spec 工作流模板
```

## 核心命令

### 初始化网络
```bash
./scripts/init-network.sh
# 或手动创建
docker network create shared-network
```

### 中间件管理
```bash
cd middleware
docker-compose up -d           # 启动所有中间件
docker-compose down            # 停止所有中间件
docker-compose logs <service>  # 查看服务日志
```

### PHP 多项目管理 (local)
```bash
cd local
./manage.sh                    # 交互式菜单
./manage.sh start              # 启动所有项目
./manage.sh start <container>  # 启动指定项目
./manage.sh stop               # 停止所有项目
./manage.sh status             # 查看状态
./manage.sh logs <container>   # 查看日志
```

### 示例项目
```bash
cd examples/<php|java|python|go>
docker-compose up -d
docker-compose down
```

## 中间件服务端口

| 服务 | 容器名 | 宿主机端口 | 容器内连接 | 用户名/密码 |
|------|--------|------------|-----------|-------------|
| MySQL 5.7 | mysql57 | 3307 | `mysql57:3306` | root/root123456, devuser/devpassword |
| MySQL 8 | mysql8 | 3308 | `mysql8:3306` | root/root123456, devuser/devpassword |
| PostgreSQL | postgres | 5432 | `postgres:5432` | devuser/postgres123456 |
| Redis | redis | 6379 | `redis:6379` | 无密码 |
| RabbitMQ | rabbitmq | 5672, 15672 | `rabbitmq:5672` | guest/guest |
| Elasticsearch | elasticsearch | 9200, 9300 | `elasticsearch:9200` | 无认证 |
| MongoDB | mongodb | 27017 | `mongodb:27017` | root/root123456 |

## 架构模式

### 1. 容器内项目访问中间件

使用服务名连接：
```php
// PHP 示例
$redis = new Redis();
$redis->connect('redis', 6379);

$pdo = new PDO('mysql:host=mysql57;port=3306;dbname=default', 'devuser', 'devpassword');
```

### 2. 容器访问宿主机服务

使用 `host.docker.internal`：
```php
$redis->connect('host.docker.internal', 6379);  // 宿主机 Redis
```

### 3. 宿主机 Nginx + 容器 PHP (local 模式)

Nginx 配置要点：
```nginx
server {
    root /Users/mac/wwwroot/xxx/public;  # 指向项目 public 目录
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:900X;     # 对应 projects.conf 中端口
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

## 配置文件

- `local/projects.conf` - PHP 多项目配置（容器名：端口：项目路径：日志目录）
- `local/php74local/Dockerfile` - PHP74 镜像构建（含 GD/Redis/Seaslog 等扩展）
- `middleware/docker-compose.yml` - 中间件编排配置

## Spec 工作流

项目使用 `.spec-workflow/` 目录管理开发流程，包含：
- 需求文档模板 (`requirements-template.md`)
- 设计文档模板 (`design-template.md`)
- 任务列表模板 (`tasks-template.md`)
- 产品/技术/结构文档模板

## Mac 特定配置

- MySQL 5.7 需要 `platform: linux/amd64` 以支持 M1/M2/M3
- 推荐在 Docker Desktop 中启用 VirtioFS 优化文件共享性能
- 日志和数据持久化在 `middleware/<service>/data` 目录

## 常见问题

- 配置文件需在 `docker-compose up` 前创建，否则挂载路径会被创建为空目录
- 删除 `middleware/<service>/data` 目录会清空对应服务数据
- 容器网络问题先确认 `shared-network` 存在且容器已加入
