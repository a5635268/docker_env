# 业务接口模块

## 统一入口

所有接口从 `@/api` 导入：

```js
import { getUserInfo, login, getExampleList } from '@/api'
```

## 用户模块

| 函数 | 参数 | 返回 | 说明 |
|------|------|------|------|
| getUserInfo | - | Promise\<User\> | 获取用户信息 |
| login | { username, password } | Promise\<LoginResult\> | 用户登录 |
| logout | - | Promise\<void\> | 退出登录 |

## 示例模块

| 函数 | 参数 | 返回 | 说明 |
|------|------|------|------|
| getExampleList | { page, size } | Promise\<ExampleList\> | 获取示例列表 |
| getExampleDetail | id | Promise\<Example\> | 获取示例详情 |
| createExample | data | Promise\<Example\> | 创建示例 |
| updateExample | id, data | Promise\<Example\> | 更新示例 |
| deleteExample | id | Promise\<void\> | 删除示例 |

## 添加新模块

1. 在 `src/api/sources/` 中各数据源添加对应方法
2. 在 `src/api/modules/` 创建模块文件，调用dataSource
3. 在 `src/api/modules/index.js` 中导出
