# Middlewares 中间件使用指南

Middlewares 模块提供 FastAPI 应用级别的中间件，包括 CORS 跨域配置、GZIP 响应压缩、上下文清理等功能。

## 1. 核心概念

### 1.1 为什么需要中间件？

中间件在请求处理链中扮演重要角色：

- **CORS 跨域**：解决前后端分离架构的跨域请求问题
- **GZIP 压缩**：减少网络传输量，提升 API 响应速度
- **上下文清理**：确保请求级数据隔离，防止上下文泄漏

### 1.2 模块组成

| 文件 | 函数/类 | 职责 |
|------|---------|------|
| `cors_middleware.py` | `add_cors_middleware` | CORS 跨域中间件 |
| `gzip_middleware.py` | `add_gzip_middleware` | GZIP 响应压缩 |
| `context_cleanup_middleware.py` | `add_context_cleanup_middleware` | 上下文清理 |

---

## 2. CORS 跨域中间件

### 2.1 基础用法

```python
from fastapi import FastAPI
from app.middlewares import add_cors_middleware

app = FastAPI()

# 使用环境变量配置
add_cors_middleware(app)
```

### 2.2 自定义配置

```python
# 指定具体域名（推荐生产环境）
add_cors_middleware(
    app,
    allow_origins=['https://example.com', 'https://admin.example.com'],
    allow_methods=['GET', 'POST', 'PUT', 'DELETE'],
    allow_headers=['*'],
    expose_headers=['x-custom-header'],
    allow_credentials=True,
    max_age=600,
)
```

### 2.3 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `allow_origins` | List[str] | ['*'] | 允许的来源列表 |
| `allow_methods` | List[str] | ['*'] | 允许的 HTTP 方法 |
| `allow_headers` | List[str] | ['*'] | 允许的请求头 |
| `expose_headers` | List[str] | [] | 暴露给客户端的响应头 |
| `allow_credentials` | bool | True | 是否允许携带凭证 |
| `max_age` | int | 600 | 预检请求缓存时间（秒） |

### 2.4 安全校验机制

中间件内置安全校验：

**阻止危险组合：**
```
allow_origins=['*'] + allow_credentials=True  → 浏览器拒绝请求
```

中间件会自动检测并发出警告，将 `allow_credentials` 设为 `False`。

**URL 格式校验：**
- origin 必须以 `http://` 或 `https://` 开头
- 特殊值 `*` 表示允许所有来源

### 2.5 环境变量配置

```bash
# .env 文件
CORS_ORIGINS=https://example.com,https://admin.example.com
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE
CORS_ALLOW_HEADERS=*
CORS_MAX_AGE=600
```

### 2.6 获取当前配置

```python
from app.middlewares import cors_middleware

config = cors_middleware.get_default_cors_config()
# {
#     'allow_origins': ['https://example.com'],
#     'allow_credentials': True,
#     'allow_methods': ['*'],
#     'allow_headers': ['*'],
#     'expose_headers': [],
#     'max_age': 600
# }
```

---

## 3. GZIP 压缩中间件

### 3.1 基础用法

```python
from fastapi import FastAPI
from app.middlewares import add_gzip_middleware

app = FastAPI()

# 使用默认配置
add_gzip_middleware(app)
```

### 3.2 自定义配置

```python
add_gzip_middleware(
    app,
    minimum_size=1000,   # 大于 1KB 的响应才压缩
    compresslevel=6,     # 压缩级别 1-9
)
```

### 3.3 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `minimum_size` | int | 1000 | 触发压缩的最小响应体大小（字节） |
| `compresslevel` | int | 6 | 压缩级别（1-9） |

### 3.4 压缩级别选择

| 级别 | 速度 | 压缩率 | 适用场景 |
|------|------|--------|----------|
| 1 | 最快 | 最低 | 实时性要求高 |
| 6 | 平衡 | 中等 | 推荐 API 服务器 |
| 9 | 最慢 | 最高 | 带宽受限场景 |

### 3.5 工作原理

- 客户端需发送 `Accept-Encoding: gzip` 头才会触发压缩
- 小于 `minimum_size` 的响应不压缩（避免开销大于收益）
- 响应头会添加 `Content-Encoding: gzip`

### 3.6 获取当前配置

```python
from app.middlewares import gzip_middleware

config = gzip_middleware.get_default_gzip_config()
# {
#     'minimum_size': 1000,
#     'compresslevel': 6
# }
```

---

## 4. 上下文清理中间件

### 4.1 基础用法

```python
from fastapi import FastAPI
from app.middlewares import add_context_cleanup_middleware

app = FastAPI()

# 添加上下文清理中间件
add_context_cleanup_middleware(app)
```

### 4.2 工作原理

中间件在每个请求处理完成后调用 `RequestContext.clear_all()`：

```python
# 请求处理前
RequestContext.set_current_user({'id': 1, 'name': 'admin'})

# 请求处理后（自动清理）
RequestContext.clear_all()
```

### 4.3 纯 ASGI 实现

中间件使用纯 ASGI 实现而非 `BaseHTTPMiddleware`：

> **为什么要用纯 ASGI？**
>
> `BaseHTTPMiddleware` 在某些边界情况（后台任务、WebSocket）下可能无法正确触发清理。
> 纯 ASGI 中间件确保清理逻辑可靠执行。

---

## 5. 中间件注册顺序

### 5.1 推荐顺序

在 `app/main.py` 中按以下顺序注册：

```python
from fastapi import FastAPI
from app.middlewares import (
    add_context_cleanup_middleware,
    add_cors_middleware,
    add_gzip_middleware,
)

app = FastAPI()

# 1. 上下文清理中间件（最早注册，最后执行）
add_context_cleanup_middleware(app)

# 2. CORS 中间件
add_cors_middleware(app)

# 3. GZIP 中间件
add_gzip_middleware(app)

# 4. 注册路由（最后）
from app.routers import hello
app.include_router(hello.router)
```

### 5.2 执行顺序说明

FastAPI 中间件执行顺序：**最早注册 → 最后执行**

```
请求 → GZIP → CORS → 上下文清理 → 路由处理 → 上下文清理 → CORS → GZIP → 响应
```

上下文清理中间件需要最后执行，确保其他中间件执行完毕后才清理上下文。

---

## 6. 配置说明

### 6.1 CORS 配置项

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `CORS_ORIGINS` | str | "" | 允许的来源（逗号分隔） |
| `CORS_ALLOW_CREDENTIALS` | bool | True | 是否允许凭证 |
| `CORS_ALLOW_METHODS` | str | "*" | 允许的方法 |
| `CORS_ALLOW_HEADERS` | str | "*" | 允许的请求头 |
| `CORS_MAX_AGE` | int | 600 | 预检缓存时间（秒） |

### 6.2 环境变量示例

```bash
# 开发环境
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
CORS_ALLOW_CREDENTIALS=true

# 生产环境
CORS_ORIGINS=https://example.com,https://admin.example.com
CORS_ALLOW_CREDENTIALS=true
CORS_MAX_AGE=3600
```

---

## 7. 最佳实践

### 7.1 CORS 配置

- **开发环境**：允许 localhost 来源
- **生产环境**：指定具体域名，避免使用 `*`
- **凭证场景**：必须指定具体域名，不能使用 `*`

### 7.2 GZIP 配置

- **API 服务器**：使用 `compresslevel=6`（平衡速度与压缩率）
- **大响应场景**：降低 `minimum_size` 阈值
- **静态资源**：建议在 Nginx 层压缩，不在应用层

### 7.3 中间件顺序

- 上下文清理必须最后执行（最早注册）
- CORS 和 GZIP 可以按任意顺序注册

---

## 8. 常见问题 (FAQ)

**Q: CORS 配置 `allow_origins=['*']` 有什么安全问题？**

当 `allow_credentials=True` 时，浏览器会拒绝请求。中间件会自动检测并发出警告。

**Q: 如何在生产环境配置 CORS？**

```bash
CORS_ORIGINS=https://yourdomain.com,https://admin.yourdomain.com
CORS_ALLOW_CREDENTIALS=true
```

**Q: GZIP 压缩级别如何选择？**

推荐 `compresslevel=6`，平衡压缩速度与压缩率。实时性要求高用 1，带宽受限用 9。

**Q: 上下文清理中间件为什么使用纯 ASGI？**

`BaseHTTPMiddleware` 在某些边界情况（后台任务、WebSocket）可能无法正确触发清理。纯 ASGI 确保可靠。

**Q: 中间件注册顺序为什么重要？**

中间件执行顺序与注册顺序相反。上下文清理需要最后执行，确保其他中间件完成后再清理。

---

## 9. 相关依赖

| 依赖包 | 用途 |
|--------|------|
| `fastapi` | FastAPI 应用实例 |
| `starlette.middleware.gzip` | GZIP 中间件基类 |
| `app.core.config` | CORS 配置项 |
| `app.core.context` | RequestContext 上下文 |

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |