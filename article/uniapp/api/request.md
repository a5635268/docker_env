# 请求封装

## 概述

`src/utils/request.js` 封装了 uni.request 的基础调用。

## 使用方式

```js
import request from '@/utils/request'

// GET请求
request({ url: '/user/list', method: 'get', params: { page: 1 } })

// POST请求
request({ url: '/login', method: 'post', data: { username, password } })
```

## 配置项

| 配置 | 类型 | 说明 |
|------|------|------|
| url | string | 请求地址 |
| method | string | 请求方法，默认get |
| params | object | GET请求参数 |
| data | object | POST请求参数 |
| timeout | number | 超时时间，默认10000ms |
| headers | object | 请求头配置 |

## 响应处理

- 200: 正常返回 `res.data`
- 401: 提示登录过期，跳转登录页
- 500: 提示错误信息
- 其他: 提示错误码对应信息

## 错误处理

网络异常自动提示"接口连接异常"，超时提示"请求超时"。
