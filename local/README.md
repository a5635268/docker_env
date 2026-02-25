# PHP74 Docker 本地开发环境（根目录 local 版）

本目录提供了一个基于 Docker 的多项目 PHP74 运行环境，为每个项目创建独立的容器，实现宿主机中间件 + 容器 PHP 的开发模式。

> 说明：`examples/php` 目录仍保留完整示例，用于参考；实际日常使用推荐直接在根目录下的 `local` 中操作。

## 核心特性

- 多项目隔离：每个项目运行在独立的 PHP-FPM 容器中
- 宿主机中间件：MySQL / Redis 等仍运行在宿主机或 `middleware` 容器中
- Nginx 在宿主机：Nginx 直接读宿主机代码目录，通过端口转发到对应 PHP 容器
- 日志分离：每个项目拥有独立的日志目录

## 目录结构

- `manage.sh`：项目核心管理脚本（推荐入口）
- `projects.conf`：项目配置文件
- `php74local/`：PHP74 Dockerfile 与 FPM 配置
  - `php74local/Dockerfile`
  - `php74local/conf/php.ini`
  - `php74local/php-fpm.d/zzz-custom-pool.conf`
- `NGINX-CONFIG-GUIDE.md`：本地 Nginx 配置与多项目虚拟主机指南

## 快速开始

### 1. 配置项目列表

编辑 `projects.conf`，按如下格式添加项目（或直接用默认示例）：

```bash
PROJECTS=(
    "mengdada-php:9001:/Users/mac/wwwroot/www.mengdada.club:mengdada"
    # "container-name:port:project-path:log-subdir"
)
```

### 2. 启动管理工具

```bash
cd local
./manage.sh
```

菜单会提供：

1. 启动所有项目
2. 停止所有项目
3. 重启所有项目
4. 查看项目状态
5. 查看项目日志
6. 添加新项目
7. 删除项目

也可以使用命令行模式：

```bash
./manage.sh start           # 启动所有项目
./manage.sh start mengdada-php
./manage.sh stop
./manage.sh status
./manage.sh logs mengdada-php
```

### 3. 配置宿主机 Nginx

参考本目录下的 `NGINX-CONFIG-GUIDE.md`，在本机的 Nginx 中为每个项目配置虚拟主机：

- `root` 指向项目 `public` 目录
- `fastcgi_pass 127.0.0.1:900X`，端口与 `projects.conf` 中保持一致

### 4. 容器中访问宿主机中间件

容器通过 `host.docker.internal` 访问宿主机上的 MySQL / Redis 等服务，例如：

```php
$redis = new Redis();
$redis->connect('host.docker.internal', 6379);

$pdo = new PDO('mysql:host=host.docker.internal;port=3306;dbname=yourdb', 'user', 'pass');
```

## 与 `examples/php` 的关系

- `local`：**推荐的日常使用入口**，放在仓库根目录，与 `middleware` 同级，更符合“宿主机中间件 + 容器 PHP” 的整体架构。
- `examples/php`：保留为**示例代码和历史配置**，结构与 `local` 类似，可用于参考和对比。

