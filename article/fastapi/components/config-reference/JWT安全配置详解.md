# JWT 安全配置详解

本文档详细介绍 fastapi-tp6 项目中 JWT（JSON Web Token）的配置项、安全最佳实践以及密钥管理。

## 1. 环境变量配置

### 1.1 配置项说明

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `JWT_SECRET` | str | "your-secret-key..." | JWT 签名密钥 |
| `JWT_ALGORITHM` | str | "HS256" | JWT 签名算法 |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | int | 30 | Token 过期时间（分钟） |

### 1.2 .env 配置示例

```bash
# 开发环境（弱密钥，仅用于开发）
JWT_SECRET=dev-secret-key-not-for-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 生产环境（强密钥）
JWT_SECRET=your-very-secure-secret-key-at-least-32-characters-long
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

---

## 2. JWT 基础概念

### 2.1 JWT 结构

JWT 由三部分组成：

```
Header.Payload.Signature
```

**Header**：
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload**：
```json
{
  "sub": "user_id",
  "exp": 1707475200,
  "iat": 1707474000
}
```

**Signature**：
使用密钥对 Header + Payload 签名

### 2.2 JWT 特点

- **无状态**：服务端不存储 Token
- **自包含**：Payload 携带用户信息
- **可验证**：签名防篡改
- **有过期**：exp 字段控制有效期

---

## 3. 密钥安全规范

### 3.1 密钥长度要求

| 算法 | 推荐密钥长度 |
|------|--------------|
| HS256 | >= 32 字符 |
| HS384 | >= 48 字符 |
| HS512 | >= 64 字符 |

### 3.2 密钥生成方式

```bash
# 随机生成 32 字符密钥
openssl rand -base64 32

# Python 生成
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 3.3 密钥存储安全

- **禁止**硬编码在代码中
- **禁止**提交到 Git 仓库
- **推荐**使用环境变量
- **推荐**使用密钥管理服务（AWS KMS、Vault）

---

## 4. Token 签发与验证

### 4.1 签发 Token

```python
from app.core.security import create_access_token
from datetime import timedelta

# 默认过期时间
token = create_access_token(subject="user_123")

# 自定义过期时间
token = create_access_token(
    subject="user_123",
    expires_delta=timedelta(hours=2)
)

# 附加 claims
token = create_access_token(
    subject="user_123",
    additional_claims={"role": "admin", "permissions": ["read", "write"]}
)
```

### 4.2 验证 Token

```python
from app.core.security import decode_token, verify_token

# 解码（抛异常版本）
try:
    payload = decode_token(token)
    user_id = payload.get('sub')
except ExpiredSignatureError:
    # Token 已过期
    pass
except JWTError:
    # Token 无效
    pass

# 验证（不抛异常版本）
payload = verify_token(token)
if payload:
    user_id = payload.get('sub')
else:
    # Token 无效或过期
    pass
```

---

## 5. 过期策略

### 5.1 过期时间配置

根据业务场景选择：

| 场景 | 推荐过期时间 |
|------|--------------|
| 普通用户 | 30-60 分钟 |
| 管理后台 | 60-120 分钟 |
| 移动应用 | 7-30 天 |
| 单次操作 | 5-15 分钟 |

### 5.2 Token 刷新策略

推荐使用双 Token 机制：

- **Access Token**：短期有效（30分钟）
- **Refresh Token**：长期有效（7天）

用户 Access Token 过期后，用 Refresh Token 获取新 Token。

---

## 6. Payload 标准字段

### 6.1 Registered Claims

| 字段 | 名称 | 说明 |
|------|------|------|
| `sub` | Subject | Token 主体（通常是用户 ID） |
| `exp` | Expiration | 过期时间（Unix 时间戳） |
| `iat` | Issued At | 签发时间 |
| `nbf` | Not Before | 生效时间 |
| `iss` | Issuer | 签发者 |
| `aud` | Audience | 接收者 |

### 6.2 自定义 Claims

```python
additional_claims={
    "role": "admin",
    "permissions": ["read", "write"],
    "tenant_id": "123"
}
```

---

## 7. 安全最佳实践

### 7.1 密钥管理

- 生产环境必须使用强密钥（>=32字符）
- 密钥定期更换（建议每季度）
- 多服务共享密钥需统一管理
- 使用密钥轮换机制支持新旧密钥共存

### 7.2 Token 传输

- 使用 HTTPS 传输
- 存储在 Cookie（推荐 HttpOnly）
- 或存储在 Authorization 头
- 禁止存储在 localStorage（XSS 风险）

### 7.3 Token 验证

- 每次请求验证 Token
- 检查过期时间
- 验证签名有效性
- 检查必要字段

---

## 8. 常见问题

**Q: 密钥泄露后如何处理？**

立即更换密钥，所有已签发的 Token 将失效。

**Q: Token 过期后如何续期？**

使用 Refresh Token 机制，或重新登录。

**Q: 如何实现 Token 撤销？**

JWT 无状态设计不支持撤销。可采用：
- 短过期时间
- 黑名单机制（Redis）
- 版本号机制

**Q: 多服务共享 Token 如何配置？**

所有服务使用相同的 JWT_SECRET 和 JWT_ALGORITHM。

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |