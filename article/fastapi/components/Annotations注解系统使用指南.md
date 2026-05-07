# Annotations 注解系统使用指南

Annotations 模块提供装饰器风格的业务增强能力，支持接口缓存、接口限流、操作日志等功能，基于 Redis 存储，与项目统一响应格式兼容。

## 1. 核心概念

### 1.1 为什么需要注解系统？

在企业级 FastAPI 项目中，以下业务增强能力是常见的：

- **接口缓存**：减少数据库查询，提升响应速度
- **接口限流**：防止恶意请求，保护系统稳定性
- **操作日志**：记录用户行为，便于审计与排查

使用装饰器风格可以：
- 将业务增强逻辑与核心业务逻辑分离
- 通过声明式配置简化代码
- 灵活组合多种增强能力

### 1.2 模块组成

| 文件 | 类 | 职责 |
|------|-----|------|
| `cache.py` | `ApiCache`, `ApiCacheEvict` | 接口缓存与缓存失效 |
| `rate_limit.py` | `ApiRateLimit`, `ApiRateLimitPreset` | 接口限流与预设配置 |
| `log.py` | `Log`, `log_operation` | 操作日志记录 |

---

## 2. 接口缓存（ApiCache）

### 2.1 基础用法

```python
from fastapi import Request
from app.annotations import ApiCache

@ApiCache(namespace='users', expire_seconds=60)
async def get_user(request: Request, user_id: int):
    # 业务逻辑
    return {'id': user_id, 'name': 'Alice'}
```

### 2.2 缓存命中机制

缓存注解仅对 **GET 请求** 生效：
- 第一次请求：执行业务逻辑，结果写入 Redis
- 后续请求：直接返回缓存结果，不执行业务逻辑
- 缓存过期后：重新执行并更新缓存

### 2.3 按用户隔离缓存

```python
@ApiCache(namespace='user_profile', expire_seconds=300, vary_by_user=True)
async def get_user_profile(request: Request):
    # 不同用户的缓存独立
    user = RequestContext.get_current_user()
    return {'profile': user['profile']}
```

### 2.4 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `namespace` | str | - | 缓存命名空间（必填） |
| `expire_seconds` | int | 60 | 缓存过期时间（秒） |
| `vary_by_user` | bool | False | 是否按用户隔离缓存 |
| `cache_response_codes` | Set[int] | {200} | 允许缓存的业务响应码 |

### 2.5 缓存键生成规则

缓存键由以下因素决定：
- 请求方法（GET）
- 请求路径
- 查询参数
- 请求体哈希
- 用户标识（vary_by_user=True 时）

---

## 3. 缓存失效（ApiCacheEvict）

### 3.1 基础用法

```python
from app.annotations import ApiCacheEvict

@ApiCacheEvict(namespaces=['users'])
async def update_user(request: Request, user_id: int, name: str):
    # 更新用户后，清理 users 命名空间下的所有缓存
    return {'success': True}
```

### 3.2 批量清理多个命名空间

```python
@ApiCacheEvict(namespaces=['users', 'user_profile', 'user_permissions'])
async def delete_user(request: Request, user_id: int):
    # 删除用户后，清理多个相关缓存
    return {'success': True}
```

### 3.3 按前缀清理

```python
@ApiCacheEvict(namespace_prefixes=['user'])
async def batch_update_users(request: Request):
    # 清理所有以 'user' 开头的命名空间缓存
    # 如：user, user_profile, user_permissions
    return {'success': True}
```

### 3.4 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `namespaces` | Sequence[str] | - | 需失效的命名空间列表 |
| `namespace_prefixes` | Sequence[str] | - | 需失效的命名空间前缀列表 |
| `evict_response_codes` | Set[int] | {200} | 触发失效的业务响应码 |

> 注意：`namespaces` 和 `namespace_prefixes` 至少需要指定一个。

---

## 4. 缓存管理（ApiCacheManager）

### 4.1 手动清理缓存

```python
from app.annotations import ApiCacheManager
from app.core.redis import RedisUtil

redis = RedisUtil.get_redis()

# 清理单个命名空间
deleted_count = await ApiCacheManager.clear_namespace(redis, 'users')

# 批量清理多个命名空间
deleted_count = await ApiCacheManager.clear_namespaces(redis, ['users', 'articles'])

# 按前缀清理
deleted_count = await ApiCacheManager.clear_namespace_prefix(redis, 'user')

# 清理所有接口缓存
deleted_count = await ApiCacheManager.clear_all(redis)
```

---

## 5. 接口限流（ApiRateLimit）

### 5.1 基础用法

```python
from app.annotations import ApiRateLimit

@ApiRateLimit(namespace='api', limit=100, window_seconds=60)
async def api_endpoint(request: Request):
    return {'data': 'ok'}
```

### 5.2 使用预设配置

```python
from app.annotations import ApiRateLimit, ApiRateLimitPreset

# 登录接口限流（10次/分钟）
@ApiRateLimit(namespace='login', preset=ApiRateLimitPreset.ANON_AUTH_LOGIN)
async def login(request: Request, username: str):
    return {'token': 'xxx'}

# 注册接口限流（5次/2分钟）
@ApiRateLimit(namespace='register', preset=ApiRateLimitPreset.ANON_AUTH_REGISTER)
async def register(request: Request):
    return {'success': True}

# 用户修改接口限流（20次/分钟）
@ApiRateLimit(namespace='update', preset=ApiRateLimitPreset.USER_COMMON_MUTATION)
async def update_profile(request: Request):
    return {'success': True}
```

### 5.3 覆盖预设参数

```python
@ApiRateLimit(
    namespace='login',
    preset=ApiRateLimitPreset.ANON_AUTH_LOGIN,
    limit=5,           # 覆盖预设的 limit
    window_seconds=30  # 覆盖预设的窗口时长
)
async def login(request: Request):
    return {'token': 'xxx'}
```

### 5.4 限流作用域

```python
# IP 维度限流（默认）
@ApiRateLimit(namespace='api', limit=100, scope='ip')
async def public_api(request: Request):
    return {'data': 'ok'}

# 用户维度限流（需登录）
@ApiRateLimit(namespace='api', limit=50, scope='user')
async def user_api(request: Request):
    return {'data': 'ok'}

# 用户或 IP 维度（登录用户按用户限流，未登录按 IP）
@ApiRateLimit(namespace='api', limit=30, scope='user_or_ip')
async def mixed_api(request: Request):
    return {'data': 'ok'}
```

### 5.5 Redis 故障策略

```python
# 放行策略：Redis 不可用时允许请求通过（推荐非关键接口）
@ApiRateLimit(namespace='api', limit=100, fail_strategy='open')

# 关闭策略：Redis 不可用时直接拦截（推荐关键接口）
@ApiRateLimit(namespace='api', limit=100, fail_strategy='closed')

# 本地降级：使用进程内存限流（单实例兜底）
@ApiRateLimit(namespace='api', limit=100, fail_strategy='local_fallback')
```

### 5.6 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `namespace` | str | - | 限流命名空间（必填） |
| `limit` | int | - | 窗口内最大请求次数 |
| `window_seconds` | int | - | 限流窗口时长（秒） |
| `scope` | Literal['ip', 'user', 'user_or_ip'] | 'ip' | 限流作用域 |
| `algorithm` | Literal['fixed_window', 'sliding_window'] | 'fixed_window' | 限流算法 |
| `fail_strategy` | Literal['open', 'closed', 'local_fallback'] | 'open' | Redis 故障策略 |
| `message` | str | - | 限流提示信息 |
| `preset` | ApiRateLimitPresetConfig | - | 预设配置 |

---

## 6. 限流预设配置

### 6.1 匿名接口预设

| 预设名称 | limit | window_seconds | scope | 说明 |
|----------|-------|----------------|-------|------|
| `ANON_AUTH_LOGIN` | 10 | 60 | ip | 登录接口 |
| `ANON_AUTH_REGISTER` | 5 | 120 | ip | 注册接口 |
| `ANON_AUTH_CAPTCHA` | 30 | 60 | ip | 验证码接口 |

### 6.2 用户接口预设

| 预设名称 | limit | window_seconds | scope | 说明 |
|----------|-------|----------------|-------|------|
| `USER_COMMON_MUTATION` | 20 | 60 | user | 普通修改操作 |
| `USER_SECURITY_MUTATION` | 10 | 60 | user | 安全敏感操作 |
| `USER_DESTRUCTIVE_MUTATION` | 5 | 60 | user | 删除类操作 |

### 6.3 通用接口预设

| 预设名称 | limit | window_seconds | scope | 说明 |
|----------|-------|----------------|-------|------|
| `COMMON_UPLOAD` | 10 | 60 | user_or_ip | 上传接口 |
| `COMMON_EXPORT` | 15 | 60 | user | 导出接口 |

---

## 7. 操作日志（Log）

### 7.1 基础用法

```python
from app.annotations import Log
from app.core.constants import BusinessType

@Log(title='用户登录', business_type=BusinessType.OTHER)
async def login(request: Request, username: str):
    return {'token': 'xxx'}
```

### 7.2 记录请求参数

```python
@Log(title='创建用户', business_type=BusinessType.INSERT, save_request=True)
async def create_user(request: Request, user_data: dict):
    # 自动记录请求参数（已脱敏）
    return {'id': 1}
```

### 7.3 记录响应结果

```python
@Log(title='查询用户', business_type=BusinessType.OTHER, save_response=True)
async def get_user(request: Request, user_id: int):
    # 自动记录响应结果（已脱敏）
    return {'id': user_id, 'name': 'Alice'}
```

### 7.4 快捷装饰器

```python
from app.annotations import log_operation
from app.core.constants import BusinessType

@log_operation('查询用户列表', BusinessType.OTHER)
async def get_users(request: Request):
    return {'users': []}
```

### 7.5 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `title` | str | '' | 日志标题 |
| `business_type` | BusinessType | OTHER | 业务类型 |
| `save_request` | bool | True | 是否记录请求参数 |
| `save_response` | bool | False | 是否记录响应结果 |
| `log_level` | int | logging.INFO | 日志级别 |

### 7.6 自动脱敏

日志注解自动脱敏以下敏感字段：

- `password`, `passwd`, `pwd`
- `token`, `access_token`, `refresh_token`
- `secret`, `secret_key`, `api_key`
- `credential`, `authorization`
- `session`, `cookie`
- `card_number`, `ssn`

---

## 8. 配置说明

### 8.1 Redis 配置

缓存与限流依赖 Redis，配置在 `.env` 中：

```bash
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DATABASE=0
REDIS_PASSWORD=
REDIS_POOL_SIZE=10
REDIS_SOCKET_TIMEOUT=5
REDIS_CONNECT_TIMEOUT=5
```

### 8.2 Redis 键名配置

在 `constants.py` 中定义：

```python
class RedisInitKeyConfig(Enum):
    API_CACHE = {'key': 'api_cache', 'remark': '接口响应缓存'}
    API_RATE_LIMIT = {'key': 'api_rate_limit', 'remark': '接口限流'}
```

---

## 9. 最佳实践

### 9.1 缓存策略

- 仅缓存 GET 请求
- 设置合理的过期时间（热点数据 60s，冷数据 300s）
- 写操作后及时清理相关缓存
- 用户个性化数据使用 `vary_by_user=True`

### 9.2 限流策略

- 登录/注册接口使用 `ANON_AUTH_LOGIN` / `ANON_AUTH_REGISTER` 预设
- 删除操作使用 `USER_DESTRUCTIVE_MUTATION` 预设
- 非关键接口使用 `fail_strategy='open'`
- 关键接口使用 `fail_strategy='local_fallback'`

### 9.3 日志策略

- 重要操作记录请求参数（`save_request=True`）
- 避免记录响应结果（数据量过大）
- 使用合适的业务类型便于审计

---

## 10. 常见问题 (FAQ)

**Q: 缓存注解对非 GET 请求生效吗？**

不生效。非 GET 请求直接执行原函数，不缓存结果。

**Q: 如何清理特定命名空间的缓存？**

```python
from app.annotations import ApiCacheManager
await ApiCacheManager.clear_namespace(redis, 'users')
```

**Q: 限流的 fail_strategy 有什么区别？**

- `open`: Redis 不可用时放行请求
- `closed`: Redis 不可用时直接拦截
- `local_fallback`: 使用进程内存降级限流

**Q: 日志注解如何脱敏敏感字段？**

自动脱敏 password、token、secret 等字段，替换为 `***`。

**Q: 如何组合使用多个注解？**

```python
@ApiRateLimit(namespace='api', preset=ApiRateLimitPreset.USER_COMMON_MUTATION)
@ApiCache(namespace='api', expire_seconds=60)
@Log(title='查询数据', business_type=BusinessType.OTHER)
async def get_data(request: Request):
    return {'data': 'ok'}
```

---

## 11. 相关依赖

| 依赖包 | 用途 |
|--------|------|
| `redis` (aioredis) | 缓存与限流存储 |
| `fastapi` | Request 对象解析 |
| `app.core.redis` | Redis 连接池管理 |
| `app.core.context` | 请求上下文管理 |

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |