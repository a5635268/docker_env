# Core 核心模块使用指南

Core 模块是 fastapi-tp6 项目的基础设施层，提供全项目共享的核心能力：配置管理、安全认证、统一响应格式、请求上下文、Redis 连接管理、常量定义。

## 1. 核心概念

### 1.1 为什么需要 Core 模块？

在企业级 FastAPI 项目中，以下基础设施是必需的：

- **配置管理**：统一管理环境变量，支持开发/生产环境切换
- **安全认证**：JWT 令牌签发与验证，密码哈希处理
- **统一响应**：API 返回格式标准化，错误码统一管理
- **请求上下文**：请求级数据隔离，用户信息传递
- **Redis 管理**：连接池管理，健康检查，生命周期控制
- **常量定义**：HTTP 状态码、业务类型、Redis 键名等

### 1.2 模块组成

| 文件 | 类/函数 | 职责 |
|------|---------|------|
| `config.py` | `Settings`, `settings` | Pydantic 配置管理，MySQL/PostgreSQL 自动切换 |
| `security.py` | `create_access_token`, `verify_password` | JWT 认证、密码哈希 |
| `response.py` | `ResponseBuilder`, `ApiException` | 统一响应封装、错误码管理 |
| `context.py` | `RequestContext` | ContextVar 请求级数据隔离 |
| `redis.py` | `RedisUtil`, `get_redis` | Redis 连接池管理 |
| `constants.py` | `HttpStatusConstant`, `BusinessType` | 常量与枚举定义 |

---

## 2. 配置管理（config.py）

### 2.1 基础用法

```python
from app.core.config import settings

# 访问配置项
app_name = settings.APP_NAME          # "FastAPI Enterprise"
debug = settings.DEBUG                # True
jwt_secret = settings.JWT_SECRET      # JWT 密钥

# 获取 Tortoise ORM 配置
tortoise_config = settings.TORTOISE_ORM
```

### 2.2 数据库自动切换

配置类支持通过 `DATABASE_URL` 的 scheme 自动切换数据库引擎：

```bash
# MySQL 配置（.env）
DATABASE_URL=mysql://root:password@127.0.0.1:3306/mydb

# PostgreSQL 配置（.env）
DATABASE_URL=postgres://user:password@127.0.0.1:5432/mydb
```

切换数据库只需修改 `.env` 文件，无需修改代码。

### 2.3 配置参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `APP_NAME` | str | "FastAPI Enterprise" | 应用名称 |
| `DEBUG` | bool | True | 调试模式 |
| `DATABASE_URL` | str | mysql://... | 数据库连接 URL |
| `DB_POOL_MIN` | int | 1 | 最小连接数 |
| `DB_POOL_MAX` | int | 10 | 最大连接数 |
| `JWT_SECRET` | str | - | JWT 密钥（生产必须修改） |
| `JWT_ALGORITHM` | str | "HS256" | JWT 算法 |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | int | 30 | Token 过期时间（分钟） |
| `REDIS_HOST` | str | "localhost" | Redis 主机 |
| `REDIS_PORT` | int | 6379 | Redis 端口 |
| `REDIS_POOL_SIZE` | int | 10 | Redis 连接池大小 |

---

## 3. 安全认证（security.py）

### 3.1 密码哈希

```python
from app.core.security import get_password_hash, verify_password

# 生成密码哈希
hashed = get_password_hash("plain_password")

# 验证密码
is_valid = verify_password("plain_password", hashed)  # True
```

### 3.2 JWT 令牌

```python
from app.core.security import create_access_token, decode_token, verify_token
from datetime import timedelta

# 创建 JWT Token（默认过期时间）
token = create_access_token(subject="user_id_123")

# 创建 JWT Token（自定义过期时间）
token = create_access_token(
    subject="user_id_123",
    expires_delta=timedelta(hours=2),
    additional_claims={"role": "admin"}
)

# 解码 Token（抛异常版本）
try:
    payload = decode_token(token)
    user_id = payload.get('sub')
except ExpiredSignatureError:
    # Token 已过期
except JWTError:
    # Token 无效

# 验证 Token（不抛异常版本）
payload = verify_token(token)
if payload:
    user_id = payload.get('sub')
else:
    # Token 无效或过期
```

### 3.3 参数说明

| 函数 | 参数 | 说明 |
|------|------|------|
| `create_access_token` | `subject` | Token 主体（通常是用户 ID） |
| | `expires_delta` | 过期时间增量 |
| | `additional_claims` | 额外的 JWT claims |
| `decode_token` | `token` | JWT 令牌字符串 |
| `verify_token` | `token` | JWT 令牌字符串 |

---

## 4. 统一响应格式（response.py）

### 4.1 响应格式标准

所有 API 返回统一格式：

```json
{
  "code": 0,
  "msg": "调用成功",
  "time": 1707475200,
  "data": {}
}
```

分页响应：

```json
{
  "code": 0,
  "msg": "调用成功",
  "time": 1707475200,
  "data": [],
  "total": 100,
  "page": 1,
  "page_size": 10,
  "pages": 10
}
```

### 4.2 ResponseBuilder 用法

```python
from app.core.response import ResponseBuilder

# 成功响应
return ResponseBuilder.success(data={"user": user_info}, msg="获取成功")

# 分页响应
return ResponseBuilder.paginated(
    data=items,
    total=100,
    page=1,
    page_size=10,
    msg="查询成功"
)

# 错误响应
return ResponseBuilder.error(code=1, msg="操作失败")

# 参数验证错误
return ResponseBuilder.validate_error(msg="用户名不能为空")

# 未授权
return ResponseBuilder.unauthorized(msg="Token 已过期")

# 资源不存在
return ResponseBuilder.not_found(msg="用户不存在")

# 限流响应（HTTP 429）
return ResponseBuilder.too_many_requests(msg="请求过于频繁")
```

### 4.3 ApiException 业务异常

```python
from app.core.response import ApiException

# 抛出业务异常（自动转换为统一响应）
raise ApiException(code=12, msg="资源不存在")

# 带附加数据
raise ApiException(code=1, msg="操作失败", data={"errors": ["字段A错误"]})
```

### 4.4 错误码管理

```python
from app.core.response import ErrorCodeManager

# 获取错误消息
msg = ErrorCodeManager.get_msg(1)  # "调用失败"

# 获取 HTTP 状态码
http_status = ErrorCodeManager.get_http_status(2)  # 401

# 动态注册错误码
ErrorCodeManager.register(
    code=3001,
    msg="业务特定错误",
    http_status=400
)

# 获取所有错误码
all_codes = ErrorCodeManager.get_all_codes()
```

### 4.5 预定义错误码

| 错误码 | 消息 | HTTP 状态 |
|--------|------|-----------|
| 0 | 调用成功 | 200 |
| 1 | 调用失败 | 500 |
| 2 | token认证失败 | 401 |
| 3 | 请求太频繁 | 429 |
| 6 | 数据不能为空 | 400 |
| 12 | 没有该内容 | 404 |
| 21 | 参数错误 | 400 |

---

## 5. 请求上下文（context.py）

### 5.1 基础用法

```python
from app.core.context import RequestContext

# 设置当前用户（在认证中间件中）
token = RequestContext.set_current_user({'id': 1, 'name': 'admin'})

# 获取当前用户（抛异常版本）
user = RequestContext.get_current_user()
user_id = user['id']

# 获取当前用户（不抛异常版本）
user = RequestContext.get_current_user_optional()
if user:
    user_id = user['id']

# 设置请求元数据
token = RequestContext.set_request_meta({'request_id': 'xxx', 'ip': '127.0.0.1'})

# 获取请求元数据
meta = RequestContext.get_request_meta()

# 清理上下文（请求结束时）
RequestContext.clear_all()
```

### 5.2 注意事项

> **推荐使用 `request.state` 替代 ContextVar**
>
> ContextVar 存在 BaseHTTPMiddleware 清理问题，新代码推荐使用：
>
> ```python
> # 在中间件中
> request.state.user = {'id': 1, 'name': 'admin'}
>
> # 在路由中
> user = request.state.user
> ```

---

## 6. Redis 连接管理（redis.py）

### 6.1 生命周期管理

```python
from fastapi import FastAPI
from app.core.redis import init_redis_lifecycle

app = FastAPI()

# 注册 Redis 生命周期（启动时创建连接，关闭时释放）
init_redis_lifecycle(app)
```

### 6.2 依赖注入

```python
from fastapi import Depends
from app.core.redis import get_redis
from redis import asyncio as aioredis

@router.get("/cached")
async def cached_endpoint(redis: aioredis.Redis = Depends(get_redis)):
    # 使用 Redis
    value = await redis.get('cache_key')
    return {"value": value}
```

### 6.3 手动管理

```python
from app.core.redis import RedisUtil

# 创建连接池
redis = await RedisUtil.create_redis_pool()

# 健康检查
is_ok = await RedisUtil.check_redis_connection(redis)

# 获取连接
redis = RedisUtil.get_redis()

# 关闭连接
await RedisUtil.close_redis_pool(app)
```

---

## 7. 常量定义（constants.py）

### 7.1 HTTP 状态码常量

```python
from app.core.constants import HttpStatusConstant

HttpStatusConstant.SUCCESS          # 200
HttpStatusConstant.CREATED          # 201
HttpStatusConstant.BAD_REQUEST      # 400
HttpStatusConstant.UNAUTHORIZED     # 401
HttpStatusConstant.FORBIDDEN        # 403
HttpStatusConstant.NOT_FOUND        # 404
HttpStatusConstant.TOO_MANY_REQUESTS  # 429
HttpStatusConstant.ERROR            # 500
```

### 7.2 业务类型枚举

```python
from app.core.constants import BusinessType

BusinessType.OTHER      # 0 - 其它
BusinessType.INSERT     # 1 - 新增
BusinessType.UPDATE     # 2 - 修改
BusinessType.DELETE     # 3 - 删除
BusinessType.GRANT      # 4 - 授权
BusinessType.EXPORT     # 5 - 导出
BusinessType.IMPORT     # 6 - 导入
```

### 7.3 Redis 键名配置

```python
from app.core.constants import RedisInitKeyConfig

# 获取键名
RedisInitKeyConfig.API_CACHE.key        # "api_cache"
RedisInitKeyConfig.API_RATE_LIMIT.key   # "api_rate_limit"

# 获取说明
RedisInitKeyConfig.API_CACHE.remark     # "接口响应缓存"
```

---

## 8. 配置说明

### 8.1 环境变量配置

在项目根目录创建 `.env` 文件：

```bash
# 应用配置
APP_NAME=FastAPI Enterprise
DEBUG=true

# 数据库配置
DATABASE_URL=mysql://root:password@127.0.0.1:3306/mydb
DB_POOL_MIN=1
DB_POOL_MAX=10

# JWT 配置（生产环境必须修改）
JWT_SECRET=your-very-secure-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DATABASE=0
REDIS_PASSWORD=
REDIS_POOL_SIZE=10

# CORS 配置
CORS_ORIGINS=https://example.com,https://admin.example.com
CORS_ALLOW_CREDENTIALS=true
```

### 8.2 配置加载机制

- 使用 `pydantic-settings` 从 `.env` 加载
- `lru_cache` 确保配置只加载一次
- 忽略未定义字段（`extra = "ignore"`）

---

## 9. 最佳实践

### 9.1 配置管理

- 生产环境必须修改 `JWT_SECRET`
- 使用环境变量区分开发/生产配置
- 不要在代码中硬编码敏感信息

### 9.2 统一响应

- 所有 API 使用 `ResponseBuilder` 返回
- 业务异常使用 `ApiException` 抛出
- 自定义错误码通过 `ErrorCodeManager.register()` 注册

### 9.3 请求上下文

- 推荐使用 `request.state` 替代 `ContextVar`
- 请求结束必须清理上下文（使用中间件）

### 9.4 Redis 连接

- 使用依赖注入 `Depends(get_redis)`
- 注册生命周期 `init_redis_lifecycle(app)`
- 生产环境配置连接池大小

---

## 10. 常见问题 (FAQ)

**Q: 如何切换数据库类型？**

修改 `.env` 中的 `DATABASE_URL`：
- MySQL: `mysql://user:pass@host:3306/dbname`
- PostgreSQL: `postgres://user:pass@host:5432/dbname`

**Q: 如何添加新的错误码？**

```python
from app.core.response import ErrorCodeManager
ErrorCodeManager.register(3001, "业务特定错误", 400)
```

**Q: RequestContext 和 request.state 有什么区别？**

- `RequestContext` 使用 ContextVar，存在清理问题
- `request.state` 更安全，推荐新代码使用

**Q: Redis 连接池如何配置？**

在 `.env` 中配置：
- `REDIS_POOL_SIZE`: 最大连接数
- `REDIS_POOL_MIN`: 最小连接数
- `REDIS_SOCKET_TIMEOUT`: Socket 超时
- `REDIS_CONNECT_TIMEOUT`: 连接超时

---

## 11. 相关依赖

| 依赖包 | 版本要求 | 用途 |
|--------|----------|------|
| `pydantic-settings` | - | 配置管理 |
| `python-jose` | - | JWT 编解码 |
| `passlib[bcrypt]` | - | 密码哈希 |
| `redis` | - | Redis asyncio |

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |