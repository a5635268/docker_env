[根目录](../CLAUDE.md) > **local**

# local 模块文档

## 模块职责

PHP 本地开发环境模块，采用"宿主机中间件 + 容器 PHP"的混合架构模式。为每个 PHP 项目创建独立的 PHP-FPM 容器，实现多项目隔离，同时利用宿主机上已有的 Nginx/MySQL/Redis 服务。

## 入口与启动

### 配置项目列表

编辑 `projects.conf`，按格式添加项目：

```bash
# 格式："容器名:端口:项目路径:日志子目录"
PROJECTS=(
    "project1-php:9001:/Users/mac/wwwroot/project1:project1"
    "project2-php:9002:/Users/mac/wwwroot/project2:project2"
)
```

### 使用管理脚本

```bash
cd local
./manage.sh              # 交互式菜单
./manage.sh start        # 启动所有项目
./manage.sh start <name> # 启动指定项目
./manage.sh stop         # 停止所有项目
./manage.sh status       # 查看状态
./manage.sh logs <name>  # 查看日志
```

### 交互式菜单

```
========================================
  PHP74 Docker 项目管理工具 (local)
========================================
1) 启动所有项目
2) 停止所有项目
3) 重启所有项目
4) 查看项目状态
5) 查看项目日志
6) 添加新项目
7) 删除项目
0) 退出
========================================
```

## 对外接口

### 容器端口映射

每个项目映射到宿主机的不同端口：

- 项目 1: `127.0.0.1:9001` → 容器 `9000`
- 项目 2: `127.0.0.1:9002` → 容器 `9000`
- 项目 N: `127.0.0.1:900N` → 容器 `9000`

### 宿主机 Nginx 配置

Nginx 配置要点：

```nginx
server {
    listen 80;
    server_name myproject.test;
    root /Users/mac/wwwroot/myproject/public;  # 指向项目 public 目录

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9001;  # 对应 projects.conf 中的端口
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

详细配置请参考 `NGINX-CONFIG-GUIDE.md`。

### 容器访问宿主机服务

PHP 容器通过 `host.docker.internal` 访问宿主机服务：

```php
// 连接宿主机 Redis
$redis = new Redis();
$redis->connect('host.docker.internal', 6379);
$redis->auth('devredis123');

// 连接宿主机 MySQL
$pdo = new PDO(
    'mysql:host=host.docker.internal;port=3306;dbname=yourdb',
    'user',
    'pass'
);
```

### 与 middleware 的关系

local 模块与 middleware 模块可以协同使用：

- **方案 A**: 宿主机运行 MySQL/Redis（推荐用于开发环境）
- **方案 B**: 连接 middleware 容器中的 MySQL/Redis

```php
// 连接 middleware MySQL 8
$pdo = new PDO(
    'mysql:host=mysql8;port=3306;dbname=default',
    'devuser',
    'devpassword'
);

// 连接 middleware Redis
$redis = new Redis();
$redis->connect('redis', 6379);
$redis->auth('devredis123');
```

> 注意：如需连接 middleware 容器，需将 PHP 容器加入 `shared-network` 网络。

## 关键依赖与配置

### 系统依赖

- Docker Desktop（Mac）或 Docker Engine
- Nginx（宿主机）
- MySQL/Redis（宿主机或 middleware 容器）

### 配置文件

```
local/
├── manage.sh                    # 核心管理脚本
├── projects.conf                # 项目配置列表
├── php74local/
│   ├── Dockerfile              # PHP 7.4 镜像构建文件
│   ├── conf/
│   │   └── php.ini             # PHP 配置
│   ├── php-fpm.d/
│   │   └── zzz-custom-pool.conf  # FPM 配置
│   └── logs/                    # 日志目录（按项目分隔）
├── README.md                    # 使用说明
└── NGINX-CONFIG-GUIDE.md        # Nginx 配置指南
```

### PHP 镜像说明

当前使用 PHP 7.4 FPM Alpine 镜像，包含以下扩展：

**内置扩展**：
- pdo_mysql, mysqli
- gd, mbstring, curl, zip
- intl, opcache, bcmath
- calendar, exif, gettext
- sockets, sysvmsg, sysvsem, sysvshm

**PECL 扩展**：
- redis 5.3.7
- seaslog 2.2.0

**Deprecation 警告**：
> PHP 7.4 已于 2022年11月 EOL，仅用于遗留项目，新项目请使用 PHP 8.2+

### 添加 PHP 8.2 支持

如需使用 PHP 8.2+，可创建新的 Dockerfile：

```dockerfile
# php82local/Dockerfile
FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev icu-dev curl-dev oniguruma-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mysqli gd mbstring zip intl opcache

RUN pecl install redis && docker-php-ext-enable redis
```

然后在 `manage.sh` 中添加镜像选择逻辑。

## 数据模型

本模块为基础设施模块，不涉及业务数据模型。

项目数据存储在宿主机项目目录中，通过卷挂载到容器：

```
-v "/Users/mac/wwwroot/project1:/Users/mac/wwwroot/project1"
```

## 测试与质量

### 健康检查

查看容器状态：

```bash
./manage.sh status
docker ps | grep php
```

测试 PHP-FPM 连接：

```bash
# 使用 cgi-fcgi 测试
cgi-fcgi -bind -connect 127.0.0.1:9001
```

### 日志管理

每个项目的日志存储在独立的子目录：

```
php74local/logs/
├── project1/
│   ├── seaslog.log
│   └── ...
└── project2/
    └── ...
```

查看日志：

```bash
./manage.sh logs project1-php
# 或直接查看文件
tail -f php74local/logs/project1/seaslog.log
```

## 常见问题 (FAQ)

### 1. 容器无法启动？

检查以下几点：
- 端口是否被占用：`lsof -i :9001`
- 项目路径是否存在
- 镜像是否构建成功：`docker images | grep php74-fpm`

### 2. Nginx 502 Bad Gateway？

- 检查 PHP 容器是否运行：`docker ps | grep <container-name>`
- 检查端口映射：`docker port <container-name>`
- 检查 Nginx 配置中的 `fastcgi_pass` 端口

### 3. 文件权限错误？

容器以当前用户运行（`--user $(id -u):$(id -g)`），确保项目目录权限正确：

```bash
sudo chown -R $(whoami):staff /Users/mac/wwwroot/project1
```

### 4. 无法连接宿主机 MySQL/Redis？

使用 `host.docker.internal` 而非 `localhost`：

```php
// 错误
$redis->connect('localhost', 6379);

// 正确
$redis->connect('host.docker.internal', 6379);
```

### 5. 如何切换到 middleware 容器服务？

需要修改 `manage.sh` 中的 `docker run` 命令，添加网络连接：

```bash
docker run -d \
  --name "$container_name" \
  --network shared-network \  # 添加网络
  ...
```

然后在 PHP 代码中使用服务名连接：

```php
$pdo = new PDO('mysql:host=mysql8;port=3306;dbname=default', ...);
```

### 6. 如何调试 PHP 代码？

方法 1：查看容器日志

```bash
./manage.sh logs <container-name>
```

方法 2：进入容器调试

```bash
docker exec -it <container-name> sh
php -v
php -m
```

方法 3：使用 Xdebug

在 Dockerfile 中安装 Xdebug：

```dockerfile
RUN pecl install xdebug && docker-php-ext-enable xdebug
```

## 相关文件清单

- `manage.sh` - 核心管理脚本
- `projects.conf` - 项目配置列表
- `php74local/Dockerfile` - PHP 7.4 镜像构建
- `php74local/conf/php.ini` - PHP 配置
- `php74local/php-fpm.d/zzz-custom-pool.conf` - FPM 配置
- `README.md` - 使用说明
- `NGINX-CONFIG-GUIDE.md` - Nginx 配置指南

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档
- 添加架构说明和 FAQ