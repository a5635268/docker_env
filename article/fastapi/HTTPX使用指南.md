# HTTPX 使用指南 (FastAPI 环境)

`httpx` 是一个为 Python 3 提供全功能 HTTP 客户端的现代库。它不仅涵盖了 `requests` 库提供的所有功能，还原生支持标准的 `async`/`await` 异步调用，因而成为开发高性能的 FastAPI 应用时的最佳搭档（特别是在微服务通信或者调用外部 API 接口的场景中）。

## 1. 同步与异步模式的区别

### 为什么在 FastAPI 中推荐 `AsyncClient`？
FastAPI 基于 `Starlette` 的ASGI框架实现高并发。如果在异步路由（`async def`）中使用传统的 `requests` 或者 `httpx.Client` 这种同步阻塞式的 HTTP 库抓取网页，就会阻塞整个事件循环，导致其他所有请求都被挂起。

而在异步路由下使用 **`httpx.AsyncClient`** 处理请求，当系统等待外部响应时，会将执行权交还给事件循环，处理其余的客户端请求，极大地提升了系统的并发承载力。

---

## 2. 基础请求写法

在使用 `httpx.AsyncClient` 时，始终推荐通过上下文管理器（`async with`）来控制，这样可以确保用完后底层连接自动关闭和清理。

### 2.1 发起 GET 请求
可以通过 `params` 传递 URL 查询参数：

```python
import httpx

async def fetch_user_data(user_id: int):
    url = "https://api.example.com/users"
    params_dict = {"id": user_id, "active": "true"}
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url, params=params_dict)
        # 获取 JSON 响应
        return response.json()
```

### 2.2 发起 POST 请求
通过 `json` 传递字典时，HTTPX 会自动添加 `Content-Type: application/json` 头；通过 `data` 参数通常用来提交表单 `application/x-www-form-urlencoded`。

```python
import httpx

async def create_user(payload: dict):
    url = "https://api.example.com/users/create"
    custom_headers = {"Authorization": "Bearer YOUR_TOKEN"}
    
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=custom_headers)
        
        # 检查是否请求成功，否则抛出 httpx.HTTPStatusError 异常
        response.raise_for_status() 
        return response.json()
```

---

## 3. 高级用法

### 3.1 超时控制 (`timeout`)
默认情况下，HTTPX 将超时时间设置为 **5 秒**。在请求第三方（如微信解析、LLM等可能卡住的任务），你可以全局设置或者覆盖请求的超时：

```python
import httpx

# 对整个客户端设置较长超时（比如 30 秒）
async with httpx.AsyncClient(timeout=30.0) as client:
    response = await client.get("https://slow.api.example.com/data")
```

### 3.2 代理配置 (`proxy`) 和 证书验证 (`verify`)

> **🚨 重要版本迁移提醒 (v0.28.0 及以上版本)** 
> 在 `httpx 0.28.0` 更新中，初始化代理相关的 API 发生了不向后兼容的重大变动：
> - **旧版本 (v0.28.0之前)**: 使用 `proxies={"http://": "http://127.0.0.1:xxx"}` 传递字典。
> - **新版本 (v0.28.0起)**: 移除了 `proxies` 并统一为 `proxy`（类型为字符串或特定的 Proxy 模型）。因此请务必只用 `proxy="..."` 传参！

```python
import httpx

async def fetch_with_proxy(url: str):
    # httpx >= 0.28.0 正确的写法
    proxy_url = "http://127.0.0.1:7890" 
    
    # verify=False 可以忽略 SSL 证书验证
    async with httpx.AsyncClient(proxy=proxy_url, verify=False) as client:
        response = await client.get(url)
        return response.text
```

### 3.3 HTTP 版本控制 (HTTP/2 支持)
如果你需要更高的连接复用效率，只要安装了 `httpx[http2]` 扩展环境，就可以支持 HTTP/2 通信：

```python
async with httpx.AsyncClient(http2=True) as client:
    response = await client.get("https://http2.golang.org/")
```

---

## 4. 常见的异常处理机制

外部网络不稳定时常发生报错，合理的捕获并给出用户清晰反馈非常重要：

```python
import httpx
from fastapi import HTTPException

async def robust_fetch(url: str):
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url)
            # 对响应码（4xx, 5xx）进行抛错保护
            response.raise_for_status()
            
    # 连接失败、超时或目标不可达
    except httpx.RequestError as exc:
        raise HTTPException(
            status_code=503, 
            detail=f"网络请求失败 {exc.request.url!r}: {exc}"
        )
    # HTTP状态码不正常 (例如404, 500)
    except httpx.HTTPStatusError as exc:
        raise HTTPException(
            status_code=exc.response.status_code, 
            detail=f"远端服务器返回错误响应: {exc.response.status_code}"
        )
```

## 5. 最佳实践：FastAPI 中的全局客户端共享

如果在请求频繁的高并发场景（如调用大模型 API）下，在每个路由里依然去重新创建 `AsyncClient()`（执行 `async with httpx.AsyncClient() as client`） 意味着频繁建立并销毁底层连接池结构，这其实比较损耗性能。

在 FastAPI 企业级应用中，最佳实践是利用“**生命周期 (Lifespan)**”管理，将客户端共享并在应用启动时建立、在关闭时回收。

### 在主进程中维护全局连接池（示例）

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
import httpx

class HttpClient:
    client: httpx.AsyncClient = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时初始化唯一的全局 AsyncClient（自带连接复用池）
    HttpClient.client = httpx.AsyncClient(timeout=15.0)
    yield
    # 关闭时清理
    await HttpClient.client.aclose()

# 挂载生命周期
app = FastAPI(lifespan=lifespan)

@app.get("/search")
async def do_search(q: str):
    # 直接使用全局长活的 client 进行通信
    resp = await HttpClient.client.get(f"https://api.github.com/search/users", params={"q": q})
    return resp.json()
```
这样可以最大化利用 TCP 和 SSL 握手的复用，并降低内存开销。
