[根目录](../../CLAUDE.md) > [examples](..) > **java**

# examples/java 模块文档

## 模块职责

Java (Eclipse Temurin JDK 17) 示例项目，演示如何在 Docker 容器中运行 Java 应用并连接到 middleware 提供的 MySQL 和 Redis 服务。

## 入口与启动

### 启动项目

```bash
cd examples/java
docker-compose up -d
```

### 停止项目

```bash
cd examples/java
docker-compose down
```

### 进入容器

```bash
docker exec -it java-app bash
```

## 对外接口

### 容器配置

- **容器名**: `java-app`
- **镜像**: `eclipse-temurin:17.0.10_7-jdk`
- **工作目录**: `/app`
- **启动命令**: `tail -f /dev/null`（保持容器运行，需手动启动应用）

### 依赖服务

- **MySQL 8**: 容器内连接地址 `mysql8:3306`
- **Redis**: 容器内连接地址 `redis:6379`

> 注意：本示例容器通过 `shared-network` 连接到 middleware 服务。

## 关键依赖与配置

### 依赖服务

本示例依赖 middleware 提供的服务，启动前需确保：

1. `shared-network` 网络已创建
2. middleware 的 MySQL 8 和 Redis 服务已启动

### 配置文件

```
examples/java/
└── docker-compose.yml    # 容器编排配置
```

### 源代码

源代码应放置在 `src/` 目录下，将自动挂载到容器的 `/app`。

#### Spring Boot 配置示例

```properties
# src/application.properties
spring.datasource.url=jdbc:mysql://mysql8:3306/default?useSSL=false&serverTimezone=Asia/Shanghai
spring.datasource.username=devuser
spring.datasource.password=devpassword

spring.redis.host=redis
spring.redis.port=6379
spring.redis.password=devredis123
```

#### Maven 项目示例

```bash
# 进入容器后编译运行
docker exec -it java-app bash
cd /app
mvn clean package
java -jar target/your-app.jar
```

## 数据模型

本示例项目暂无业务数据模型，仅作为连接演示。

## 测试与质量

当前为空示例项目，无测试文件。建议添加：

- JUnit 单元测试
- Maven/Gradle 构建配置
- 集成测试

## 常见问题 (FAQ)

### 1. 如何构建并运行 JAR 文件？

```bash
# 在 src 目录下构建项目
mvn clean package

# 复制 JAR 到容器
docker cp target/your-app.jar java-app:/app/

# 在容器内运行
docker exec -it java-app java -jar /app/your-app.jar
```

### 2. 如何添加 Gradle 支持？

修改 `docker-compose.yml`：

```yaml
volumes:
  - ./src:/app
  - ~/.gradle:/root/.gradle  # 缓存依赖
```

### 3. 如何连接到宿主机服务？

使用 `host.docker.internal`：

```properties
spring.datasource.url=jdbc:mysql://host.docker.internal:3308/default
```

## 相关文件清单

- `docker-compose.yml` - 容器编排配置

## 变更记录 (Changelog)

### 2026-05-07
- 初始化模块文档