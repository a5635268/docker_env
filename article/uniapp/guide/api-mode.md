# API多模式使用说明

## 三种模式

本项目支持三种数据源模式，通过环境配置切换：

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| mock | 使用Mock数据 | 前端独立开发、演示 |
| api | 请求真实后端 | 正式开发、生产 |
| local | 读取本地JSON | 原型设计、静态数据展示 |

## 切换模式

通过不同的启动命令切换：

```bash
npm run dev:mock    # Mock模式
npm run dev:api     # API模式（默认）
npm run dev:local   # 本地模式（ldata）
```

## 环境配置

环境变量文件位于项目根目录：

- `.env` - 默认配置（生产环境）
- `.env.mock` - Mock模式配置
- `.env.api` - API模式配置
- `.env.local` - 本地模式配置

> 注意：`.env.local` 和 `.env.*.local` 已被添加到 `.gitignore`，不会提交。

## Mock数据编写

Mock数据存放在 `src/mock/` 目录，按模块组织：

```js
// src/mock/user.js
export default {
  userInfo: { id: '1', name: 'Mock User' },
  loginResult: { token: 'mock-token' }
}
```

数据源层（`src/api/sources/mock.js`）会导入这些数据并返回。

## API对接流程

1. 在 `src/api/sources/api.js` 中定义接口
2. 使用 `request` 模块请求后端
3. 页面通过 `import { xxx } from '@/api'` 调用

接口定义与Mock保持一致，切换模式时代码无需修改。

## 本地数据使用

本地数据存放在 `src/static/json/` 目录，格式为JSON：

```json
// src/static/json/user.json
{
  "id": "1",
  "name": "本地用户"
}
```

## 模式切换时机建议

- **项目初期**：使用Mock模式，快速搭建前端
- **后端就绪后**：切换到API模式，对接真实接口
- **展示/原型**：使用Local模式，无需后端依赖
