[根目录](../../CLAUDE.md) > **middleware**

# middleware 模块文档

## 模块职责

提供统一的中间件服务，包括 MySQL、Redis、PostgreSQL、RabbitMQ、Elasticsearch、MongoDB、Nginx 等，供所有开发项目共享使用。所有中间件容器加入 `shared-network` 网络，可通过服务名互相访问。

## 入口与启动

### 初始化配置

```bash
cd middleware
cp .env.example .env     # 复制环境变量模板
# 根据需要修改 .env 中的密码
```

### 初始化网络

```bash
# 方法 1：使用脚本
./scripts/init-network.sh

# 方法 2：手动创建
docker network create shared-network
```

### 启动/停止服务

```bash
cd middleware
docker-compose up -d           # 启动所有中间件
docker-compose down            # 停止所有中间件
docker-compose logs <service>  # 查看服务日志
docker-compose ps              # 查看运行状态
```

### 单独启动服务

```bash
docker-compose up -d mysql57   # 仅启动 MySQL 5.7
docker-compose up -d redis     # 仅启动 Redis
```

## 对外接口

### 服务端口映射

| 服务 | 容器名 | 宿主机端口 | 容器内连接 | 认证 |
|------|--------|------------|-----------|------|
| MySQL 5.7 | mysql57 | 127.0.0.1:3307 | `mysql57:3306` | 见 .env |
| MySQL 8 | mysql8 | 127.0.0.1:3308 | `mysql8:3306` | 见 .env |
| PostgreSQL | postgres | 127.0.0.1:5432 | `postgres:5432` | 见 .env |
| Redis | redis | 127.0.0.1:6379 | `redis:6379` | 密码认证 |
| RabbitMQ | rabbitmq | 127.0.0.1:5672, 127.0.0.1:15672 | `rabbitmq:5672` | 见 .env |
| Elasticsearch | elasticsearch | 127.0.0.1:9200, 127.0.0.1:9300 | `elasticsearch:9200` | 密码认证 |
| MongoDB | mongodb | 127.0.0.1:27017 | `mongodb:27017` | 见 .env |
| Nginx | nginx | 127.0.0.1:80, 127.0.0.1:8080 | `nginx:80` | - |

> 所有端口仅绑定到 127.0.0.1，确保本地开发安全。

### 连接示例

#### PHP 连接 MySQL 5.7

```php
$pdo = new PDO(
    'mysql:host=mysql57;port=3306;dbname=default',
    'devuser',
    'devpassword',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);
```

#### PHP 连接 Redis（需密码）

```php
$redis = new Redis();
$redis->connect('redis', 6379);
$redis->auth('devredis123');
```

#### Java (Spring Boot) 连接 MySQL 8

```properties
spring.datasource.url=jdbc:mysql://mysql8:3306/default?useSSL=false&serverTimezone=Asia/Shanghai
spring.datasource.username=devuser
spring.datasource.password=devpassword
```

#### Python 连接 PostgreSQL

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

#### 连接 Elasticsearch

```bash
curl -u elastic:dev_es_123 http://127.0.0.1:9200
```

## 关键依赖与配置

### 系统依赖

- Docker Desktop（Mac）或 Docker Engine
- docker-compose（通常随 Docker Desktop 安装）
- Mac M1/M2/M3 需要启用 VirtioFS 优化性能

### 配置文件

```
middleware/
├── docker-compose.yml          # 主编排文件
├── .env.example                # 环境变量模板
├── .env                        # 环境变量（不入库）
├── mysql57/
│   ├── conf/my.cnf            # MySQL 5.7 配置
│   ├── data/                  # 数据目录（不入库）
│   └── logs/                  # 日志目录
├── mysql8/
│   ├── conf/my.cnf            # MySQL 8 配置
│   ├── data/                  # 数据目录（不入库）
│   └── logs/                  # 日志目录
├── pgsql/
│   └── data/                  # PostgreSQL 数据（不入库）
├── redis/
│   ├── conf/redis.conf        # Redis 配置
│   └── data/                  # 数据目录（不入库）
├── rabbitmq/
│   └── data/                  # 数据目录（不入库）
├── mongo/
│   └── data/                  # MongoDB 数据（不入库）
├── elasticsearch/
│   ├── config/elasticsearch.yml  # ES 配置
│   └── data/                  # 数据目录（不入库）
└── nginx/
    └── conf/default.conf      # Nginx 配置
```

### 凭据管理

所有凭据统一在 `.env` 文件中管理，不要直接编辑 `docker-compose.yml`。

## 数据模型

本模块为中间件服务，不涉及业务数据模型。各服务数据持久化到本地目录：

- MySQL 5.7: `mysql57/data/`
- MySQL 8: `mysql8/data/`
- PostgreSQL: `pgsql/data/`
- Redis: `redis/data/`
- RabbitMQ: `rabbitmq/data/`
- MongoDB: `mongo/data/`
- Elasticsearch: `elasticsearch/data/`

删除对应目录将清空服务数据。

## 测试与质量

### 健康检查

所有服务在 `docker-compose.yml` 中配置了健康检查：

- MySQL: `mysqladmin ping`
- PostgreSQL: `pg_isready`
- Redis: `redis-cli ping`
- RabbitMQ: `rabbitmq-diagnostics check_running`
- Elasticsearch: `_cluster/health` API
- MongoDB: `mongosh --eval "db.adminCommand('ping')"`
- Nginx: `wget spider check`

### 资源限制

每个服务配置了内存限制，防止资源耗尽：

- MySQL: 512M-1G
- PostgreSQL: 256M-512M
- Redis: 128M-512M
- RabbitMQ: 256M-512M
- Elasticsearch: 1G-2G
- MongoDB: 256M-1G
- Nginx: 32M-128M

## 常见问题 (FAQ)

### 1. MySQL 5.7 在 Mac M1/M2/M3 上无法启动？

已在 `docker-compose.yml` 中配置 `platform: linux/amd64`，确保兼容性。

### 2. 配置文件未生效？

确保在 `docker-compose up` 之前已创建好配置文件（如 `my.cnf`、`redis.conf`），否则 Docker 会将挂载路径创建为空目录。

### 3. 网络不通？

1. 确认 `shared-network` 已创建：`docker network ls`
2. 确认容器都加入了同一网络：`docker network inspect shared-network`
3. 项目内使用服务名（如 `mysql57`）而非 `localhost`

### 4. Elasticsearch 启动失败？

1. 检查内存设置（`.env` 中的 `ES_JAVA_OPTS`）
2. 如需重置密码，清空 `elasticsearch/data/` 目录后重启

### 5. 如何清空某个数据库？

删除对应服务的 `data` 目录，例如：
```bash
rm -rf middleware/mysql57/data/*
docker-compose restart mysql57
```

## 相关文件清单

- `docker-compose.yml` - 主编排文件
- `.env.example` - 环境变量模板
- `mysql57/conf/my.cnf` - MySQL 5.7 配置
- `mysql8/conf/my.cnf` - MySQL 8 配置
- `redis/conf/redis.conf` - Redis 配置
- `elasticsearch/config/elasticsearch.yml` - Elasticsearch 配置
- `nginx/conf/default.conf` - Nginx 配置

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档
- 记录所有中间件服务配置
- 添加连接示例和常见问题