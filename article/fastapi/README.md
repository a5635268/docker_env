# fastapi-tp6 文档中心

本目录包含 fastapi-tp6 项目的完整文档，包括技术框架使用指南、公共组件文档、开发分析和环境配置。

## 技术框架文档

| 文档 | 主题 | 说明 |
|------|------|------|
| [httpx_usage.md](httpx_usage.md) | HTTPX | 异步 HTTP 客户端使用指南 |
| [pydantic_usage.md](pydantic_usage.md) | Pydantic | 数据验证与序列化 |
| [tortoise_orm_usage.md](tortoise_orm_usage.md) | Tortoise ORM | 异步 ORM 使用指南 |
| [uv_usage.md](uv_usage.md) | uv | Python 包管理器 |
| [production_deployment.md](production_deployment.md) | 生产部署 | Docker 部署与 Makefile 自动化 |

## 公共组件文档

位于 `components/` 目录，包含项目核心组件的详细使用指南：

### 模块使用指南

| 文档 | 说明 |
|------|------|
| [Core核心模块使用指南.md](components/Core核心模块使用指南.md) | 配置管理、JWT、统一响应、Redis |
| [Annotations注解系统使用指南.md](components/Annotations注解系统使用指南.md) | 缓存、限流、日志装饰器 |
| [Middlewares中间件使用指南.md](components/Middlewares中间件使用指南.md) | CORS、GZIP、上下文清理 |
| [Utils工具模块使用指南.md](components/Utils工具模块使用指南.md) | 分页、字符串、Excel 处理 |

### 最佳实践

| 文档 | 说明 |
|------|------|
| [统一响应最佳实践.md](components/best-practices/统一响应最佳实践.md) | API 响应规范 |
| [缓存策略最佳实践.md](components/best-practices/缓存策略最佳实践.md) | ApiCache 配置 |
| [限流配置最佳实践.md](components/best-practices/限流配置最佳实践.md) | ApiRateLimit 预设 |
| [分页查询最佳实践.md](components/best-practices/分页查询最佳实践.md) | PageUtil 使用 |

### 配置详解

| 文档 | 说明 |
|------|------|
| [Redis配置详解.md](components/config-reference/Redis配置详解.md) | 连接池与键名规范 |
| [CORS配置详解.md](components/config-reference/CORS配置详解.md) | 跨域安全配置 |
| [JWT安全配置详解.md](components/config-reference/JWT安全配置详解.md) | 密钥管理与验证 |

详见 [components/README.md](components/README.md)。

## 开发分析

位于 `开发分析/` 目录：

- 项目架构分析
- 模块依赖关系
- 技术选型说明

## 开发环境配置

位于 `开发环境配置/` 目录：

- 本地开发环境搭建
- Docker 开发环境
- 调试配置说明

## 项目架构

fastapi-tp6 采用 MVC 分层架构：

```
app/
├── core/           # 核心模块（配置、安全、响应）
├── annotations/    # 注解系统（缓存、限流、日志）
├── middlewares/    # 中间件（CORS、GZIP）
├── routers/        # 路由控制器
├── services/       # 业务服务层
├── models/         # 数据模型（Tortoise ORM）
├── schemas/        # 数据契约（Pydantic）
├── utils/          # 工具函数
└── ai/             # AI 模块
```

详见项目根目录 [CLAUDE.md](../CLAUDE.md)。

## 快速开始

### 1. 安装依赖

```bash
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

### 2. 配置环境

```bash
cp .env.example .env
# 编辑 .env 配置数据库、Redis、JWT 等
```

### 3. 启动服务

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. 查看文档

访问 http://localhost:8000/docs 查看 API 文档。

---

> 更新日期：2026-05-06