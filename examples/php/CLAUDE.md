[根目录](../../CLAUDE.md) > [examples](..) > **php**

# examples/php 模块文档

## 模块职责

PHP 8.2 FPM 示例项目，演示如何在 Docker 容器中运行 PHP 应用并连接到 middleware 提供的 MySQL 和 Redis 服务。

## 入口与启动

### 启动项目

```bash
cd examples/php
docker-compose up -d
```

### 停止项目

```bash
cd examples/php
docker-compose down
```

### 查看日志

```bash
docker-compose logs -f php-app
```

## 对外接口

### 容器配置

- **容器名**: `php-app`
- **镜像**: `php:8.2.16-fpm`
- **工作目录**: `/var/www/html`
- **端口**: PHP-FPM 默认端口 9000（容器内部）

### 依赖服务

- **MySQL 8**: 容器内连接地址 `mysql8:3306`
- **Redis**: 容器内连接地址 `redis:6379`

> 注意：本示例容器通过 `shared-network` 连接到 middleware 服务。

### 网络架构

```
┌─────────────┐         ┌─────────────┐
│  php-app    │─────────│   MySQL 8   │
│  (PHP-FPM)  │         │  (mysql8)   │
└─────────────┘         └─────────────┘
       │                       │
       │                       │
       └───────────────────────┘
           shared-network
```

## 关键依赖与配置

### 依赖服务

本示例依赖 middleware 提供的服务，启动前需确保：

1. `shared-network` 网络已创建
2. middleware 的 MySQL 8 和 Redis 服务已启动

### 配置文件

```
examples/php/
└── docker-compose.yml    # 容器编排配置
```

### 源代码

源代码应放置在 `src/` 目录下，将自动挂载到容器的 `/var/www/html`：

```php
// src/index.php 示例
<?php
// 连接 MySQL 8
$pdo = new PDO(
    'mysql:host=mysql8;port=3306;dbname=default',
    'devuser',
    'devpassword'
);

// 连接 Redis
$redis = new Redis();
$redis->connect('redis', 6379);
$redis->auth('devredis123');
```

## 数据模型

本示例项目暂无业务数据模型，仅作为连接演示。

## 测试与质量

当前为空示例项目，无测试文件。建议添加：

- PHPUnit 单元测试
- PHP CodeSniffer 代码规范检查
- PHPStan 静态分析

## 常见问题 (FAQ)

### 1. 如何添加 PHP 扩展？

修改 `docker-compose.yml`，添加自定义 Dockerfile：

```dockerfile
FROM php:8.2.16-fpm
RUN docker-php-ext-install pdo_mysql mysqli
RUN pecl install redis && docker-php-ext-enable redis
```

### 2. 如何连接到宿主机服务？

使用 `host.docker.internal`：

```php
$redis->connect('host.docker.internal', 6379);
```

### 3. 与 local 模块的区别？

- `examples/php`: 完全容器化方案，PHP 和中间件都在容器中
- `local`: 混合方案，PHP 在容器中，中间件在宿主机或 middleware 容器

## 相关文件清单

- `docker-compose.yml` - 容器编排配置

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档