# FastAPI 生产环境部署指南

在本地开发环境中，我们习惯使用 `uvicorn app.main:app --reload` 以热重载的单核进程运行服务。但进入真正的生产环境后，我们需要面对高并发、HTTPS 握手耗时、应用崩溃拉起、多核 CPU 利用等工程问题。

本指南提供了如何将该项目安全、高效地部署至生产服务器的最佳实践方案。

---

## 一、 生产环境必须完成的代码与配置调整

在将代码打包发往服务器之前，务必要修改或核验 `.env` 文件和以下几处项目核心节点：

### 1. .env 配置项
```ini
# 1. 务必关闭 DEBUG（关闭自动生成表防止不可逆错误、关闭栈追溯到客户端）
DEBUG=False

# 2. 修改复杂安全的 JWT 秘钥
JWT_SECRET="rM3^91bN(Q$r89@pLxT!34k_R-QZ9WjH..."

# 3. 配置生产级数据库连接及凭证参数 (MySQL)
DATABASE_URL="mysql://username:password@10.0.0.10:3306/fastpaidb"
```

### 2. 数据库驱动及迁移调整
- 由于 `Tortoise ORM` 被我们接入，当你使用 Postgres/MySQL 生产数据库时，必须使用更优且非阻塞的异步协议 `asyncpg` 或 `asyncmy`。
- 在 `requirements.txt` 末尾追加：`asyncpg` (如果是 PostgreSQL) 或 `asyncmy` (MySQL)。

>**⚠️ 建表提示**: 当 `DEBUG=False` 时 `Tortoise ORM` 不再执行 `Tortoise.generate_schemas()` 自动建表（这是十分危险的！），您需要搭配 `aerich`（Tortoise的官方迁移工具）在预生产流水线中完成针对新环境的表结构迁移。

---

## 二、 经典裸机部署: Gunicorn + Uvicorn Workers + Nginx

FastAPI 虽然是一个全双工异步框架且 Uvicorn 足够快（基于 uvloop），但 **Uvicorn 依旧只是单进程处理循环**。它仅能使用服务器的单核 CPU。我们将引入 `Gunicorn` 这个 WSGI HTTP Server 来作为主进程调度管理多个 `UvicornWorker` 子工作进程，榨干多核红利。

### 1. 安装配置 Gunicorn
进入服务器项目目录的虚拟环境，执行：
```bash
uv pip install gunicorn
```

在项目根目录下创建一个名为 `gunicorn_conf.py` 的配置文件：
```python
import multiprocessing

# 绑定的内网 IP 和地址（由 Nginx 承接外网）
bind = "127.0.0.1:8000"

# 根据 CPU 核心数自动计算需要启动的 worker 进程数 (2 * 核数) + 1
workers = multiprocessing.cpu_count() * 2 + 1

# 必须指定 worker 类型为 FastAPI 支持的 ASGI 工作模式
worker_class = "uvicorn.workers.UvicornWorker"

# 每个工作进程维持的最大并发数
worker_connections = 1000

# 最大无响应时长 (生产环境如遇长时间数据库查询等，应该调高如 120)
timeout = 120
keepalive = 5

# 日志配置
errorlog = "/var/log/fastapi_error.log"
loglevel = "info"
accesslog = "/var/log/fastapi_access.log"
```

使用它启动应用：
```bash
gunicorn -c gunicorn_conf.py app.main:app
```

### 2. 服务器进程守护 (Systemd)
Gunicorn 应该成为操作系统的后台长期服务，以便服务器重启、崩溃或者被人误关终端时能被拉起。
在 Linux 系统下，编辑 `/etc/systemd/system/fastapi.service`：

```ini
[Unit]
Description=Gunicorn process serving FastAPI
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/fastapi-tp6
Environment="PATH=/var/www/fastapi-tp6/venv/bin"
# 指向你的运行服务启动命令
ExecStart=/var/www/fastapi-tp6/venv/bin/gunicorn -c gunicorn_conf.py app.main:app

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

激活后台系统服务：
```bash
sudo systemctl enable fastapi
sudo systemctl start fastapi
```

### 3. 配置 Nginx 反向代理与 SSL
让 Nginx 面向用户外网监听 `443/80`，把高耗时的请求及响应通过缓冲转发给 `127.0.0.1:8000` 端口的 Gunicorn 服务器，避免直接暴露 Gunicorn。同时提供静态资源（如果前端分离有静态页的话）的高效投递和安全证书加密层。

配置 `nginx` 文件（例如 `/etc/nginx/sites-available/fastapi`）：
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    # HTTP 强制重定向至 HTTPS（安全要求）
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    # 配置 HTTPS 证书路径
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;  # 反向指向 Gunicorn 的监听网络栈
        
        # 将原始请求的 Header 毫无损失的传递给 FastAPI 网关
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 三、 云原生时代推荐方案：Docker 容器化部署

利用 Docker 抛弃烦琐的系统环境部署及 Python 版本不一致的“水土不服”，能够实现平滑的水平弹性扩容（如果后续想使用 Kubernetes）。

### 1. 编写生产级 Dockerfile
在项目根目录新建名为 `Dockerfile` 的文件：

```dockerfile
# 选用轻量且稳定的 Python 基础环境版本
FROM python:3.10-slim-buster

# 保持 Python 输出日志免受缓冲及时可见
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 安装必要的系统级依赖（比如 PostgreSQL 和 常见构建包库），视情况可选
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 先复制依赖文件并利用 Docker 缓存层进行极速下载
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# 最后再将应用代码整体拷贝（避免代码发生细微变动就使得依赖需要重新下载）
COPY . .

# 暴露容器发往宿主机的映射端口
EXPOSE 8000

# Entrypoint 采用 Gunicorn 控制 Uvicorn 进行驱动启动
CMD ["gunicorn", "app.main:app", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
```

### 2. 利用 Docker 构建和启动服务

执行镜像构建（打上特定 tag）：
```bash
docker build -t my-enterprise-fastapi:1.0 .
```

随后作为守护进程直接挂在宿主服务器系统上（通过环境变量文件 `.env-prod` 将安全配置隐秘注入到容器内）：
```bash
docker run -d --name fastapi-app \
  -p 8000:8000 \
  --env-file .env-prod \
  --restart always \
  my-enterprise-fastapi:1.0
```

随后外层仍然可以通过挂载 Nginx 并把 Proxy Pass 指向到这台主机的 `8000` 端口上来承接外网客户端的流量接入。

### 3. 基于 Makefile 的一键自动化部署 (极速推荐)

我们在项目中内置了非常成熟且优雅的 `Makefile` 本地部署脚本（类似于上面 Docker 容器化部署机制的封装自动化）。它底层的执行链路为：**`rsync 增量排除同步本机代码` + `SSH 远程触发 docker-compose up -d --build 新镜像拉起`**。

你无需手动敲击繁琐的 Docker 参数命令，极大提升在开发后期的部署体验。

**前置操作：**
1. 请先在本地终端配置好对你的服务器免密登录：
   ```bash
   ssh-keygen -t rsa -b 4096  # （如已有可跳过）
   ssh-copy-id root@你的服务器IP
   ```
2. 打开项目根目录的 `.env` 文件，将最底部的 `DEPLOY_*` 配置段精准填入：
   ```ini
   DEPLOY_USER=root
   DEPLOY_HOST=你的服务器公网IP
   DEPLOY_PATH=/www/wwwroot/fastapi-tp6-docker
   DEPLOY_CONTAINER=fastapi-tp6-app
   ```

**仅需一条指令即可完成全链路构建拉起部署：**
```bash
make deploy
```

> **附属辅助指令**：
> `make restart`：纯粹重启线上的容器（不发送和应用代码变更）。
> `make logs`：进入命令行实时日志追踪模式，随时查看线上生产中是否报错（按 `Ctrl+C` 退出打印）。
