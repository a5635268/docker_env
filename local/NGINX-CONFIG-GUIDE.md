# Nginx 配置修改指南（配合 local 使用）

## 你的环境结构

- **Nginx 配置目录**: `/Users/mac/Library/FlyEnv/server/vhost/nginx/`
- **项目类型**: 框架项目（index.php 在 public 目录下）
- **Docker 挂载**: `/Users/mac/wwwroot/www.mengdada.club/public` → `/var/www/html`

## 需要修改的 Nginx 配置文件

### 1. www.mengdada.club 配置

**文件路径**: `/Users/mac/Library/FlyEnv/server/vhost/nginx/www.mengdada.club.conf`

**需要修改的关键配置：**

```nginx
server {
    listen 80;
    server_name www.mengdada.club test.mengdada.club;
    
    # ⚠️ 重要：指向 public 目录（因为 index.php 在 public 下）
    root /Users/mac/wwwroot/www.mengdada.club/public;
    
    index index.php index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        # 连接到 PHP 容器的端口（需与你在 local/projects.conf 中配置的端口一致）
        fastcgi_pass 127.0.0.1:9001;
        fastcgi_index index.php;
        
        include fastcgi_params;
        # 关键：SCRIPT_FILENAME 基于 root 目录
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
    }
}
```

### 2. admin.shenglinmall.cn 配置

**文件路径**: `/Users/mac/Library/FlyEnv/server/vhost/nginx/admin.shenglinmall.cn.conf`

```nginx
server {
    listen 80;
    server_name admin.shenglinmall.cn;
    
    # ⚠️ 重要：指向 public 目录
    root /Users/mac/wwwroot/admin.shenglinmall.cn/public;
    
    index index.php index.php index.html index.htm;
    
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9002;  # 项目 2 的端口
        # ... 其他配置同上
    }
}
```

## 快速修改步骤

### 步骤 1：找到配置文件

```bash
# 列出所有 Nginx 配置
ls -la /Users/mac/Library/FlyEnv/server/vhost/nginx/
```

### 步骤 2：备份并修改

```bash
# 备份原配置
cd /Users/mac/Library/FlyEnv/server/vhost/nginx/
cp www.mengdada.club.conf www.mengdada.club.conf.bak
cp admin.shenglinmall.cn.conf admin.shenglinmall.cn.conf.bak

# 编辑配置
vim www.mengdada.club.conf
```

### 步骤 3：修改 root 指令

**找到并修改：**

```nginx
# ❌ 错误的配置（指向项目根目录）
root /Users/mac/wwwroot/www.mengdada.club;

# ✅ 正确的配置（指向 public 目录）
root /Users/mac/wwwroot/www.mengdada.club/public;
```

### 步骤 4：测试并重载

```bash
# 测试 Nginx 配置
nginx -t

# 重载 Nginx
nginx -s reload
```

## 验证配置

### 1. 检查目录结构

```bash
# 确认 public 目录存在
ls -la /Users/mac/wwwroot/www.mengdada.club/public/

# 应该能看到 index.php
```

### 2. 检查容器是否运行

```bash
docker ps | grep mengdada-php
```

### 3. 查看容器日志

```bash
docker logs -f mengdada-php
```

### 4. 测试访问

```bash
# 测试本地访问
curl -I http://www.mengdada.club

# 或测试特定文件
curl http://www.mengdada.club/index.php
```

## 常见问题

### 问题 1: 404 错误

**症状**: 访问 `test.mengdada.club` 返回 404  
**原因**: Nginx 的 `root` 指向了项目根目录，而不是 `public` 目录  
**解决**: 修改 `root` 为 `/Users/mac/wwwroot/www.mengdada.club/public`

### 问题 2: 502 Bad Gateway

**症状**: Nginx 返回 502  
**原因**: PHP 容器未运行或端口不正确  
**解决**:

```bash
# 检查容器状态
docker ps | grep mengdada-php

# 检查端口监听
lsof -i :9001

# 重启容器
docker restart mengdada-php
```

### 问题 3: 文件权限错误

**症状**: 提示 Permission denied  
**解决**:

```bash
# 修改项目目录权限
sudo chown -R $(whoami):staff /Users/mac/wwwroot/www.mengdada.club
```

## Docker 挂载说明

在 `local/manage.sh` 管理的容器中，一般会把你的项目代码路径直接挂载到容器内相同路径，例如：

```bash
-v "/Users/mac/wwwroot/www.mengdada.club/public:/Users/mac/wwwroot/www.mengdada.club/public"
```

只要 Nginx 的 `root` 与容器内 PHP 实际执行路径保持一致（`SCRIPT_FILENAME` 使用 `$document_root$fastcgi_script_name`），即可正常工作。

## 配置对应关系

| 组件 | 配置 | 说明 |
|------|------|------|
| **Docker 挂载** | `/Users/mac/wwwroot/xxx/public` → 容器内同路径 | 在 `local/manage.sh` 启动容器时配置 |
| **Nginx root** | `/Users/mac/wwwroot/xxx/public` | 在你的 Nginx 配置文件中修改 |
| **PHP 容器路径** | `/Users/mac/wwwroot/xxx/public/index.php` | 与挂载路径一致 |
| **FastCGI 端口** | `127.0.0.1:900X` | 在 Nginx 配置中指定，对应 `projects.conf` 中端口 |

## 完整的 Nginx 配置示例

```nginx
server {
    listen 80;
    server_name test.mengdada.club www.mengdada.club;
    
    # 关键：指向 public 目录
    root /Users/mac/wwwroot/www.mengdada.club/public;
    index index.php index.html index.htm;
    
    # 字符集
    charset utf-8;
    
    # 日志
    access_log /Users/mac/Library/FlyEnv/logs/www.mengdada.club-access.log;
    error_log /Users/mac/Library/FlyEnv/logs/www.mengdada.club-error.log;
    
    # 默认位置
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # PHP 处理
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9001;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        
        # 超时设置
        fastcgi_connect_timeout 60s;
        fastcgi_send_timeout 300s;
        fastcgi_read_timeout 300s;
        
        # 缓冲区
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }
    
    # 禁止访问隐藏文件
    location ~ /\. {
        deny all;
    }
    
    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public";
    }
}
```

