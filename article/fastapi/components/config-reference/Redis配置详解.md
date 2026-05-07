# Redis 配置详解

本文档详细介绍 fastapi-tp6 项目中 Redis 的配置项、连接池管理、以及注解系统的 Redis 键名规范。

## 1. 环境变量配置

### 1.1 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `REDIS_HOST` | str | localhost | Redis 主机地址 |
| `REDIS_PORT` | int | 6379 | Redis 端口 |
| `REDIS_DATABASE` | int | 0 | Redis 数据库号（0-15） |
| `REDIS_PASSWORD` | str | None | Redis 密码（无密码时留空） |
| `REDIS_USERNAME` | str | None | Redis 用户名（Redis 6.0+ ACL） |
| `REDIS_POOL_SIZE` | int | 10 | 连接池最大连接数 |
| `REDIS_POOL_MIN` | int | 1 | 连接池最小连接数 |
| `REDIS_SOCKET_TIMEOUT` | int | 5 | Socket 操作超时（秒） |
| `REDIS_CONNECT_TIMEOUT` | int | 5 | 连接超时（秒） |

### 1.2 .env 配置示例

```bash
# Redis 基础配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DATABASE=0

# Redis 认证（如有密码）
REDIS_PASSWORD=your_redis_password
REDIS_USERNAME=default

# 连接池配置
REDIS_POOL_SIZE=20
REDIS_POOL_MIN=5

# 超时配置
REDIS_SOCKET_TIMEOUT=5
REDIS_CONNECT_TIMEOUT=5
```

### 1.3 生产环境推荐配置

```bash
# 生产环境
REDIS_HOST=redis.production.internal
REDIS_PORT=6379
REDIS_DATABASE=0
REDIS_PASSWORD=strong_password_here
REDIS_POOL_SIZE=30
REDIS_POOL_MIN=10
REDIS_SOCKET_TIMEOUT=10
REDIS_CONNECT_TIMEOUT=10
```

---

## 2. 连接池管理

### 2.1 连接池创建

```python
from app.core.redis import RedisUtil

# 创建连接池
redis = await RedisUtil.create_redis_pool()

# 配置来源：settings.REDIS_* 系列配置
```

### 2.2 生命周期管理

```python
from fastapi import FastAPI
from app.core.redis import init_redis_lifecycle

app = FastAPI()

# 注册生命周期（启动创建，关闭释放）
init_redis_lifecycle(app)
```

### 2.3 连接池参数详解

| 参数 | 来源配置 | 说明 |
|------|----------|------|
| `max_connections` | `REDIS_POOL_SIZE` | 最大并发连接数 |
| `encoding` | 固定 'utf-8' | 编码格式 |
| `decode_responses` | 固定 True | 自动解码为字符串 |
| `socket_timeout` | `REDIS_SOCKET_TIMEOUT` | 操作超时 |
| `socket_connect_timeout` | `REDIS_CONNECT_TIMEOUT` | 连接超时 |

---

## 3. Redis 键名规范

### 3.1 系统内置键名

在 `constants.py` 中定义：

```python
class RedisInitKeyConfig(Enum):
    ACCESS_TOKEN = {'key': 'access_token', 'remark': '登录令牌信息'}
    API_CACHE = {'key': 'api_cache', 'remark': '接口响应缓存'}
    API_RATE_LIMIT = {'key': 'api_rate_limit', 'remark': '接口限流'}
    CAPTCHA_CODES = {'key': 'captcha_codes', 'remark': '图片验证码'}
    ACCOUNT_LOCK = {'key': 'account_lock', 'remark': '用户锁定'}
    PASSWORD_ERROR_COUNT = {'key': 'password_error_count', 'remark': '密码错误次数'}
    SMS_CODE = {'key': 'sms_code', 'remark': '短信验证码'}
```

### 3.2 键名格式规范

```
{prefix}:{namespace}:{identifier}
```

示例：
- `api_cache:users:abc123` - 接口缓存
- `api_rate_limit:login:xyz789:123456` - 限流计数
- `access_token:user:1` - 用户 Token

---

## 4. 接口缓存键结构

### 4.1 ApiCache 键格式

```
api_cache:{namespace}:{hash}
```

其中 hash 由以下因素生成：
- 请求方法（GET）
- 请求路径
- 查询参数（排序后）
- 请求体哈希（SHA256）
- 用户标识（vary_by_user=True 时）

### 4.2 键名示例

```
api_cache:article_detail:7f8a9b0c
api_cache:user_profile:3d2e1f0a:user:1
```

---

## 5. 限流键结构

### 5.1 ApiRateLimit 键格式

```
rate_limit:{namespace}:{hash}:{window_bucket}
```

其中：
- hash：由 namespace + path + scope + scope_value 生成
- window_bucket：时间窗口编号

### 5.2 键名示例

```
rate_limit:login:a1b2c3d4:1707475200
rate_limit:api:e5f6g7h8:user:123:1707475300
```

---

## 6. 连接健康检查

### 6.1 自动健康检查

```python
# create_redis_pool 时自动检查
is_ok = await RedisUtil.check_redis_connection(redis)
# 输出日志：Redis 连接成功 / Redis 连接失败
```

### 6.2 错误类型处理

| 错误类型 | 说明 | 日志输出 |
|----------|------|----------|
| `AuthenticationError` | 用户名/密码错误 | Redis 用户名或密码错误 |
| `RedisTimeoutError` | 连接超时 | Redis 连接超时 |
| `RedisError` | 其他错误 | Redis 连接错误 |

---

## 7. 依赖注入使用

### 7.1 路由中使用

```python
from fastapi import Depends
from app.core.redis import get_redis
from redis import asyncio as aioredis

@router.get("/cached")
async def cached_endpoint(redis: aioredis.Redis = Depends(get_redis)):
    value = await redis.get('key')
    return {'value': value}
```

### 7.2 异常处理

```python
redis = RedisUtil.get_redis()
if redis is None:
    # Redis 未初始化
    raise RuntimeError('Redis 连接未初始化')
```

---

## 8. 生产环境建议

### 8.1 连接池大小

根据并发量配置：
- 低并发（<100）：`POOL_SIZE=10`
- 中并发（100-500）：`POOL_SIZE=20`
- 高并发（>500）：`POOL_SIZE=30+`

### 8.2 超时设置

- 内网：`SOCKET_TIMEOUT=5`
- 跨网段：`SOCKET_TIMEOUT=10`
- 不稳定网络：`SOCKET_TIMEOUT=15`

### 8.3 安全配置

- 启用 Redis 密码认证
- 使用 Redis ACL 控制权限
- 配置防火墙规则

---

## 9. 常见问题

**Q: Redis 连接池最大连接数如何确定？**

根据应用并发量和 Redis 服务器配置。一般设置为最大并发数的 10-20%。

**Q: 如何测试 Redis 连接是否正常？**

```python
is_ok = await RedisUtil.check_redis_connection(redis)
```

**Q: Redis 未初始化时注解系统如何降级？**

自动降级为直接执行原函数，输出警告日志。

**Q: 如何清理特定类型的缓存？**

```python
from app.annotations import ApiCacheManager
await ApiCacheManager.clear_namespace(redis, 'users')
```

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |