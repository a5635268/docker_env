# CORS 配置详解

本文档详细介绍 fastapi-tp6 项目中 CORS 跨域中间件的配置项、安全校验机制以及生产环境最佳实践。

## 1. 环境变量配置

### 1.1 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `CORS_ORIGINS` | str | "" | 允许的来源（逗号分隔） |
| `CORS_ALLOW_CREDENTIALS` | bool | True | 是否允许携带凭证 |
| `CORS_ALLOW_METHODS` | str | "*" | 允许的 HTTP 方法 |
| `CORS_ALLOW_HEADERS` | str | "*" | 允许的请求头 |
| `CORS_MAX_AGE` | int | 600 | 预检请求缓存时间（秒） |

### 1.2 .env 配置示例

```bash
# 开发环境
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://127.0.0.1:3000
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=*
CORS_ALLOW_HEADERS=*
CORS_MAX_AGE=600

# 生产环境
CORS_ORIGINS=https://example.com,https://admin.example.com
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE
CORS_ALLOW_HEADERS=Authorization,Content-Type,X-Requested-With
CORS_MAX_AGE=3600
```

---

## 2. CORS 基础概念

### 2.1 什么是 CORS

CORS（Cross-Origin Resource Sharing）是一种浏览器安全机制，控制跨域 HTTP 请求：

- **同源**：协议 + 域名 + 端口完全相同
- **跨域**：三者任一不同即为跨域

### 2.2 CORS 请求类型

| 类型 | 特点 | 处理方式 |
|------|------|----------|
| **简单请求** | GET/POST/HEAD，无自定义头 | 直接发送，响应头决定是否允许 |
| **预检请求** | PUT/DELETE，自定义头 | 先发送 OPTIONS，通过后才发实际请求 |

---

## 3. 配置项详解

### 3.1 allow_origins

指定允许跨域访问的来源：

```python
# 环境变量方式（逗号分隔）
CORS_ORIGINS=https://example.com,https://admin.example.com

# 代码配置方式
add_cors_middleware(
    app,
    allow_origins=['https://example.com', 'https://admin.example.com']
)
```

**注意**：
- 必须以 `http://` 或 `https://` 开头
- 特殊值 `*` 表示允许所有来源
- 生产环境不建议使用 `*`

### 3.2 allow_credentials

是否允许携带凭证（Cookie、Authorization 头）：

```python
# 允许携带凭证
CORS_ALLOW_CREDENTIALS=true

# 需要配合具体域名（不能用 *）
CORS_ORIGINS=https://example.com
```

**安全警告**：
- `allow_origins=['*']` + `allow_credentials=True` = 浏览器拒绝
- 中间件会自动检测并修正

### 3.3 allow_methods

允许的 HTTP 方法：

```python
# 允许所有方法
CORS_ALLOW_METHODS=*

# 允许特定方法
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE
```

### 3.4 allow_headers

允许的请求头：

```python
# 允许所有头
CORS_ALLOW_HEADERS=*

# 允许特定头
CORS_ALLOW_HEADERS=Authorization,Content-Type,X-Custom-Header
```

### 3.5 expose_headers

暴露给客户端的响应头：

```python
# 默认不暴露
expose_headers=[]

# 暴露自定义头
expose_headers=['X-Total-Count', 'X-Page-Size']
```

### 3.6 max_age

预检请求缓存时间：

```python
# 缓存 600 秒（10 分钟）
CORS_MAX_AGE=600

# 缓存 3600 秒（1 小时）
CORS_MAX_AGE=3600
```

---

## 4. 安全校验机制

### 4.1 URL 格式校验

```python
# 有效格式
https://example.com
http://localhost:3000
*

# 无效格式（会报错）
example.com          # 缺少协议
ftp://example.com    # 非HTTP协议
```

### 4.2 危险组合检测

```python
# 检测到危险组合时
allow_origins=['*'] + allow_credentials=True

# 自动处理
1. 输出警告日志
2. 将 allow_credentials 设为 False
3. 继续运行
```

---

## 5. 生产环境配置

### 5.1 推荐配置

```bash
# .env
CORS_ORIGINS=https://yourdomain.com,https://admin.yourdomain.com
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE
CORS_ALLOW_HEADERS=Authorization,Content-Type
CORS_MAX_AGE=3600
```

### 5.2 多环境配置

```bash
# 开发环境
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# 测试环境
CORS_ORIGINS=https://test.example.com

# 生产环境
CORS_ORIGINS=https://example.com,https://admin.example.com
```

---

## 6. 预检请求处理

### 6.1 预检请求流程

```
浏览器 → OPTIONS 请求 → CORS 中间件检查 → 返回预检响应
↓
通过后发送实际请求 → CORS 中间件检查 → 返回实际响应
```

### 6.2 预检缓存

- `max_age` 时间内，浏览器不重复发送 OPTIONS
- 减少 CORS 检查开销
- 推荐设置较长缓存时间

---

## 7. 常见问题排查

### 7.1 CORS 错误排查

| 错误信息 | 可能原因 | 解决方案 |
|----------|----------|----------|
| "No 'Access-Control-Allow-Origin'" | origin 未配置 | 添加到 CORS_ORIGINS |
| "Credentials not supported" | `*` + credentials | 配置具体域名 |
| "Method not allowed" | 方法未配置 | 添加到 CORS_ALLOW_METHODS |
| "Header not allowed" | 头未配置 | 添加到 CORS_ALLOW_HEADERS |

### 7.2 调试技巧

```bash
# 查看预检请求响应头
curl -X OPTIONS \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST" \
  http://api.example.com/

# 应返回
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
```

---

## 8. 常见问题

**Q: 为什么不能用 `*` 允许所有来源？**

使用 `*` 时无法携带凭证（Cookie），浏览器会拒绝请求。

**Q: 如何支持多个前端域名？**

在 `CORS_ORIGINS` 中用逗号分隔多个域名。

**Q: 预检请求会影响性能吗？**

设置 `max_age` 缓存预检结果，减少 OPTIONS 请求次数。

**Q: WebSocket 需要配置 CORS 吗？**

WebSocket 使用独立机制，不通过 HTTP CORS 中间件。

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |