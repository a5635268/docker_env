# 公共组件文档

本目录包含 fastapi-tp6 项目所有公共组件的使用指南、最佳实践和配置详解。

## 模块使用指南

| 文档 | 模块 | 说明 |
|------|------|------|
| [Core核心模块使用指南.md](Core核心模块使用指南.md) | app/core/ | 配置管理、安全认证、统一响应、请求上下文、Redis 连接、常量定义 |
| [Annotations注解系统使用指南.md](Annotations注解系统使用指南.md) | app/annotations/ | 接口缓存、接口限流、操作日志装饰器 |
| [Middlewares中间件使用指南.md](Middlewares中间件使用指南.md) | app/middlewares/ | CORS 跨域、GZIP 压缩、上下文清理中间件 |
| [Utils工具模块使用指南.md](Utils工具模块使用指南.md) | app/utils/ | 分页查询、字符串处理、时间格式化、命名转换、Excel 导入导出 |

## 最佳实践

位于 `best-practices/` 目录：

| 文档 | 主题 | 说明 |
|------|------|------|
| [统一响应最佳实践.md](best-practices/统一响应最佳实践.md) | API 响应格式 | ResponseBuilder 使用规范、错误码管理 |
| [缓存策略最佳实践.md](best-practices/缓存策略最佳实践.md) | ApiCache | 命名空间设计、过期时间配置、缓存失效 |
| [限流配置最佳实践.md](best-practices/限流配置最佳实践.md) | ApiRateLimit | 预设配置使用、故障策略选择 |
| [分页查询最佳实践.md](best-practices/分页查询最佳实践.md) | PageUtil | ORM 分页 vs 内存分页、响应封装 |

## 配置详解

位于 `config-reference/` 目录：

| 文档 | 主题 | 说明 |
|------|------|------|
| [Redis配置详解.md](config-reference/Redis配置详解.md) | Redis 连接 | 连接池配置、键名规范、健康检查 |
| [CORS配置详解.md](config-reference/CORS配置详解.md) | CORS 跨域 | 环境变量配置、安全校验、生产环境建议 |
| [JWT安全配置详解.md](config-reference/JWT安全配置详解.md) | JWT 认证 | 密钥管理、Token 签发验证、安全最佳实践 |

## 文档导航

```
components/
├── README.md                                 # 本文档
├── Core核心模块使用指南.md
├── Annotations注解系统使用指南.md
├── Middlewares中间件使用指南.md
├── Utils工具模块使用指南.md
├── best-practices/
│   ├── 统一响应最佳实践.md
│   ├── 缓存策略最佳实践.md
│   ├── 限流配置最佳实践.md
│   └── 分页查询最佳实践.md
└── config-reference/
    ├── Redis配置详解.md
    ├── CORS配置详解.md
    └── JWT安全配置详解.md
```

## 快速查找

### 按功能查找

- **配置管理** → [Core核心模块使用指南.md](Core核心模块使用指南.md#2-配置管理)
- **JWT 认证** → [Core核心模块使用指南.md](Core核心模块使用指南.md#3-安全认证) | [JWT安全配置详解.md](config-reference/JWT安全配置详解.md)
- **API 响应** → [Core核心模块使用指南.md](Core核心模块使用指南.md#4-统一响应格式) | [统一响应最佳实践.md](best-practices/统一响应最佳实践.md)
- **接口缓存** → [Annotations注解系统使用指南.md](Annotations注解系统使用指南.md#2-接口缓存) | [缓存策略最佳实践.md](best-practices/缓存策略最佳实践.md)
- **接口限流** → [Annotations注解系统使用指南.md](Annotations注解系统使用指南.md#5-接口限流) | [限流配置最佳实践.md](best-practices/限流配置最佳实践.md)
- **分页查询** → [Utils工具模块使用指南.md](Utils工具模块使用指南.md#2-分页工具) | [分页查询最佳实践.md](best-practices/分页查询最佳实践.md)

### 按配置项查找

- **Redis** → [Redis配置详解.md](config-reference/Redis配置详解.md)
- **CORS** → [CORS配置详解.md](config-reference/CORS配置详解.md)
- **JWT 密钥** → [JWT安全配置详解.md](config-reference/JWT安全配置详解.md)

---

> 更新日期：2026-05-06