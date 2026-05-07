[根目录](../../CLAUDE.md) > [examples](..) > **python**

# examples/python 模块文档

## 模块职责

Python 3.12 示例项目，演示如何在 Docker 容器中运行 Python 应用并连接到 middleware 提供的 Redis 和 PostgreSQL 服务。

## 入口与启动

### 启动项目

```bash
cd examples/python
docker-compose up -d
```

### 停止项目

```bash
cd examples/python
docker-compose down
```

### 进入容器

```bash
docker exec -it python-app bash
```

## 对外接口

### 容器配置

- **容器名**: `python-app`
- **镜像**: `python:3.12.2-slim`
- **工作目录**: `/app`
- **启动命令**: `tail -f /dev/null`（保持容器运行，需手动启动应用）

### 依赖服务

- **Redis**: 容器内连接地址 `redis:6379`
- **PostgreSQL**: 容器内连接地址 `postgres:5432`

> 注意：本示例容器通过 `shared-network` 连接到 middleware 服务。

## 关键依赖与配置

### 依赖服务

本示例依赖 middleware 提供的服务，启动前需确保：

1. `shared-network` 网络已创建
2. middleware 的 Redis 和 PostgreSQL 服务已启动

### 配置文件

```
examples/python/
└── docker-compose.yml    # 容器编排配置
```

### 源代码

源代码应放置在 `src/` 目录下，将自动挂载到容器的 `/app`。

#### Redis 连接示例

```python
# src/main.py
import redis

r = redis.Redis(
    host='redis',
    port=6379,
    password='devredis123',
    db=0
)

r.set('key', 'value')
print(r.get('key'))
```

#### PostgreSQL 连接示例

```python
# src/main.py
from psycopg2 import connect

conn = connect(
    host='postgres',
    port=5432,
    database='default',
    user='devuser',
    password='postgres123456'
)

cursor = conn.cursor()
cursor.execute('SELECT version()')
print(cursor.fetchone())
```

#### FastAPI 示例

```python
# src/main.py
from fastapi import FastAPI
import redis

app = FastAPI()
r = redis.Redis(host='redis', port=6379, password='devredis123')

@app.get("/")
async def root():
    return {"message": "Hello World"}
```

### 依赖管理

建议在 `src/` 目录下添加 `requirements.txt`：

```txt
redis==5.0.0
psycopg2-binary==2.9.9
fastapi==0.109.0
uvicorn==0.27.0
```

安装依赖：

```bash
docker exec -it python-app pip install -r /app/requirements.txt
```

## 数据模型

本示例项目暂无业务数据模型，仅作为连接演示。

## 测试与质量

当前为空示例项目，无测试文件。建议添加：

- pytest 单元测试
- mypy 类型检查
- black 代码格式化
- flake8 代码检查

## 常见问题 (FAQ)

### 1. 如何安装 Python 依赖？

```bash
# 方法 1：直接安装
docker exec -it python-app pip install package-name

# 方法 2：使用 requirements.txt
docker exec -it python-app pip install -r /app/requirements.txt
```

### 2. 如何运行 Python 脚本？

```bash
docker exec -it python-app python /app/main.py
```

### 3. 如何连接到宿主机服务？

使用 `host.docker.internal`：

```python
import redis
r = redis.Redis(host='host.docker.internal', port=6379, password='devredis123')
```

### 4. 如何使用虚拟环境？

修改 `docker-compose.yml` 添加卷挂载：

```yaml
volumes:
  - ./src:/app
  - venv:/app/venv
```

## 相关文件清单

- `docker-compose.yml` - 容器编排配置

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档