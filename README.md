# Docker 开发环境

基于 Docker 的 Mac 开发环境，提供统一的中间件服务和多语言项目示例。

## 架构概览

所有中间件与各项目容器都加入同一 Docker 网络 `shared-network`，通过服务名互相访问。

```
docker-env/
├── middleware/                    # 公共中间件
│   ├── docker-compose.yml
│   ├── mysql57/                   # MySQL 5.7 数据与配置
│   ├── mysql8/                    # MySQL 8 数据与配置
│   ├── pgsql/                     # PostgreSQL 数据
│   ├── redis/                     # Redis 配置与数据
│   ├── rabbitmq/                  # RabbitMQ 数据
│   ├── mongo/                     # MongoDB 数据
│   ├── elasticsearch/             # Elasticsearch 配置与数据
│   └── nginx/                     # Nginx 配置
├── local/                     # 宿主机中间件 + 容器 PHP 本地开发环境
├── examples/                      # 各语言项目示例
│   ├── php/
│   ├── java/
│   ├── python/
│   └── go/
├── scripts/
│   └── init-network.sh
└── README.md
```

## 快速开始

### 1. 配置环境变量

```bash
cd middleware
cp .env.example .env
# 根据需要修改 .env 中的密码
```

### 2. 创建共享网络

```bash
# 方法 1：使用脚本
./scripts/init-network.sh

# 方法 2：手动创建
docker network create shared-network
```

### 3. 启动中间件

```bash
cd middleware
docker-compose up -d
```

```bash
# PHP 多项目（推荐使用管理脚本）
cd examples/php
./manage.sh          # 进入交互式菜单管理多个 PHP 项目

# 也可以使用命令行模式：
./manage.sh start    # 启动所有已配置项目
./manage.sh status   # 查看项目状态
```

其他语言示例仍然可以使用各自目录下的 `docker-compose` 启动：

```bash
# Java 项目
cd examples/java
docker-compose up -d

# Python 项目
cd examples/python
docker-compose up -d

# Go 项目
cd examples/go
docker-compose up -d
```

### 4. 启动项目示例

`local` 目录是在根目录下提供的一套适合本机开发的 PHP74 环境，架构模式为：

- 本机（macOS）运行 **Nginx / MySQL / Redis** 等服务
- 通过 `local/php74local` 构建 **PHP-FPM 容器**，仅将 PHP 运行时容器化
- Nginx 直接读取本机代码目录（如 `/Users/mac/wwwroot/...`），通过 `fastcgi_pass 127.0.0.1:900X` 转发到对应的 PHP 容器端口
- PHP 容器内通过 `host.docker.internal` 访问宿主机上的 MySQL / Redis 等服务

相关文件与说明：

- `local/manage.sh`：统一管理多个 PHP 项目的容器（启动、停止、状态、日志等）
- `local/php74local/`：PHP74 Dockerfile、`php.ini`、FPM 配置、日志目录等
- `local/NGINX-CONFIG-GUIDE.md`：本地 Nginx 配置示例与多项目虚拟主机配置说明
- `local/README.md`：PHP 多项目环境的详细使用文档

> 补充：`examples/php` 目录仍然保留一整套相同模式的示例配置，可作为参考或备份，但推荐日常直接使用根目录下的 `local`。

典型 Nginx 与 PHP 容器组合示例（简化）：

```nginx
server {
    listen 80;
    server_name myproject.test;
    root /Users/mac/wwwroot/myproject;

    location ~ \.php$ {
        # 端口需与 manage.sh / projects.conf 中的项目端口一致
        fastcgi_pass 127.0.0.1:9003;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

容器内访问宿主机 MySQL / Redis 示例：

```php
// Redis
$redis = new Redis();
$redis->connect('host.docker.internal', 6379);

// MySQL
$pdo = new PDO('mysql:host=host.docker.internal;port=3306;dbname=yourdb', 'user', 'pass');
```

## 中间件服务一览

| 服务 | 容器名 | 宿主机端口 | 容器内连接 | 用户名/密码 |
|------|--------|------------|-----------|-------------|
| MySQL 5.7 | mysql57 | 127.0.0.1:3307 | `mysql57:3306` | 见 .env |
| MySQL 8 | mysql8 | 127.0.0.1:3308 | `mysql8:3306` | 见 .env |
| PostgreSQL | postgres | 127.0.0.1:5432 | `postgres:5432` | 见 .env |
| Redis | redis | 127.0.0.1:6379 | `redis:6379` | 见 .env (需密码) |
| RabbitMQ | rabbitmq | 127.0.0.1:5672, 127.0.0.1:15672 | `rabbitmq:5672` | 见 .env |
| Elasticsearch | elasticsearch | 127.0.0.1:9200, 127.0.0.1:9300 | `elasticsearch:9200` | 见 .env (需密码) |
| MongoDB | mongodb | 127.0.0.1:27017 | `mongodb:27017` | 见 .env |
| Nginx | nginx | 127.0.0.1:80, 127.0.0.1:8080 | `nginx:80` | - |

> 所有端口仅绑定到 127.0.0.1，确保本地开发安全。
> 凭据统一通过 `middleware/.env` 管理，请勿直接编辑 docker-compose.yml。

## 连接示例

### PHP 连接 MySQL 5.7

```php
$pdo = new PDO(
    'mysql:host=mysql57;port=3306;dbname=default',
    'devuser',
    'devpassword',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);
```

### PHP 连接 Redis（需密码）

```php
$redis = new Redis();
$redis->connect('redis', 6379);
$redis->auth('devredis123');  // 密码见 .env
```

### Java (Spring Boot) 连接 MySQL 8

```properties
spring.datasource.url=jdbc:mysql://mysql8:3306/default?useSSL=false&serverTimezone=Asia/Shanghai
spring.datasource.username=devuser
spring.datasource.password=devpassword
```

### Python 连接 Redis（需密码）

```python
import redis
r = redis.Redis(host='redis', port=6379, password='devredis123', db=0)
```

### Python 连接 PostgreSQL

```python
from psycopg2 import connect
conn = connect(
    host='postgres',
    port=5432,
    database='default',
    user='devuser',
    password='postgres123456'
)
```

### Go 连接 Redis（需密码）

```go
import "github.com/go-redis/redis/v8"

rdb := redis.NewClient(&redis.Options{
    Addr:     "redis:6379",
    Password: "devredis123",
})
```

### 连接 Elasticsearch（需密码）

```bash
curl -u elastic:dev_es_123 http://127.0.0.1:9200
```

```python
from elasticsearch import Elasticsearch
es = Elasticsearch(["http://elasticsearch:9200"], basic_auth=("elastic", "dev_es_123"))
```

## Mac 优化建议

### 1. 启用 VirtioFS

在 Docker Desktop 中：
- 打开 Docker Desktop → Settings → General
- 勾选 **"Use VirtioFS for optimized file sharing"**
- 重启 Docker Desktop

这可以显著提升挂载卷的 I/O 性能。

### 2. MySQL 5.7 兼容性

MySQL 5.7 在 Mac M1/M2/M3 上需要 `platform: linux/amd64`，已在配置中默认包含。

## 常见问题

### 容器无法启动

1. 检查 Docker Desktop 是否正常运行
2. 检查端口是否被占用：`lsof -i :3307` 等
3. 查看容器日志：`docker-compose logs <service_name>`

### 配置文件未生效

确保在 `docker-compose up` 之前已创建好配置文件（如 `my.cnf`、`redis.conf`），否则 Docker 会将挂载路径创建为空目录。

### 网络不通

1. 确认 `shared-network` 已创建：`docker network ls`
2. 确认容器都加入了同一网络：`docker network inspect shared-network`
3. 项目内使用服务名（如 `mysql57`）而非 `localhost`

## 停止与清理

```bash
# 停止中间件
cd middleware
docker-compose down

# 停止项目
cd examples/<language>
docker-compose down

# 删除网络（可选）
docker network rm shared-network
```

## 数据持久化

所有中间件的数据都挂载在本地目录：

- MySQL 5.7: `middleware/mysql57/data`
- MySQL 8: `middleware/mysql8/data`
- PostgreSQL: `middleware/pgsql/data`
- Redis: `middleware/redis/data`
- RabbitMQ: `middleware/rabbitmq/data`
- MongoDB: `middleware/mongo/data`
- Elasticsearch: `middleware/elasticsearch/data`

删除这些目录将清空对应数据。

## 自定义配置

### 修改中间件版本

编辑 `middleware/docker-compose.yml` 中的镜像版本：

```yaml
# 例如将 PHP 改为 8.4
php:
  image: php:8.4-fpm

# 例如将 JDK 改为 11
java-app:
  image: eclipse-temurin:11-jdk
```

### 添加新的中间件

在 `middleware/docker-compose.yml` 中添加新的 service，并确保：

1. 加入 `shared-network`
2. 配置合适的端口映射
3. 创建必要的配置文件和数据目录
