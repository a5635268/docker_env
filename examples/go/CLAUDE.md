[根目录](../../CLAUDE.md) > [examples](..) > **go**

# examples/go 模块文档

## 模块职责

Golang 1.21 示例项目，演示如何在 Docker 容器中运行 Go 应用并连接到 middleware 提供的 Redis 服务。

## 入口与启动

### 启动项目

```bash
cd examples/go
docker-compose up -d
```

### 停止项目

```bash
cd examples/go
docker-compose down
```

### 进入容器

```bash
docker exec -it go-app bash
```

## 对外接口

### 容器配置

- **容器名**: `go-app`
- **镜像**: `golang:1.21.7`
- **工作目录**: `/app`
- **启动命令**: `tail -f /dev/null`（保持容器运行，需手动启动应用）

### 依赖服务

- **Redis**: 容器内连接地址 `redis:6379`

> 注意：本示例容器通过 `shared-network` 连接到 middleware 服务。

## 关键依赖与配置

### 依赖服务

本示例依赖 middleware 提供的服务，启动前需确保：

1. `shared-network` 网络已创建
2. middleware 的 Redis 服务已启动

### 配置文件

```
examples/go/
└── docker-compose.yml    # 容器编排配置
```

### 源代码

源代码应放置在 `src/` 目录下，将自动挂载到容器的 `/app`。

#### Redis 连接示例

```go
// src/main.go
package main

import (
    "context"
    "fmt"
    "github.com/go-redis/redis/v8"
)

func main() {
    ctx := context.Background()

    rdb := redis.NewClient(&redis.Options{
        Addr:     "redis:6379",
        Password: "devredis123",
        DB:       0,
    })

    err := rdb.Set(ctx, "key", "value", 0).Err()
    if err != nil {
        panic(err)
    }

    val, err := rdb.Get(ctx, "key").Result()
    if err != nil {
        panic(err)
    }
    fmt.Println("key:", val)
}
```

#### Gin Web 框架示例

```go
// src/main.go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/go-redis/redis/v8"
)

var rdb *redis.Client

func main() {
    rdb = redis.NewClient(&redis.Options{
        Addr:     "redis:6379",
        Password: "devredis123",
        DB:       0,
    })

    r := gin.Default()
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": "pong",
        })
    })
    r.Run(":8080")
}
```

### 依赖管理

建议在 `src/` 目录下初始化 Go 模块：

```bash
docker exec -it go-app bash
cd /app
go mod init example.com/myapp
go get github.com/go-redis/redis/v8
```

## 数据模型

本示例项目暂无业务数据模型，仅作为连接演示。

## 测试与质量

当前为空示例项目，无测试文件。建议添加：

- Go 单元测试
- go vet 静态分析
- golangci-lint 代码检查

## 常见问题 (FAQ)

### 1. 如何编译并运行 Go 程序？

```bash
# 进入容器
docker exec -it go-app bash

# 编译
cd /app
go build -o main main.go

# 运行
./main
```

### 2. 如何安装 Go 依赖？

```bash
docker exec -it go-app go get github.com/go-redis/redis/v8
```

### 3. 如何连接到宿主机服务？

使用 `host.docker.internal`：

```go
rdb := redis.NewClient(&redis.Options{
    Addr: "host.docker.internal:6379",
    Password: "devredis123",
})
```

### 4. 如何使用 Go Modules？

```bash
docker exec -it go-app bash
cd /app
go mod init example.com/myapp
go mod tidy
```

### 5. 如何热重载代码？

推荐使用 Air 或 Fresh：

```bash
# 安装 Air
go install github.com/cosmtrek/air@latest

# 运行
air
```

## 相关文件清单

- `docker-compose.yml` - 容器编排配置

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档