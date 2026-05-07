# 开发最佳实践

## 代码组织

### 目录结构

- `src/api/` - 所有接口定义，按模块组织
- `src/pages/` - 页面组件，按功能分目录
- `src/components/` - 可复用组件（非模板）
- `src/utils/` - 工具函数
- `src/store/` - 状态管理

### 命名规范

- 页面文件：小写字母+连字符，如 `user-list.vue`
- 组件文件：小驼峰，如 `basicForm.vue`
- API函数：小驼峰，语义化命名

## 状态管理建议

- 简单的页面状态：使用 `ref`/`reactive`
- 跨页面共享数据：使用 Pinia store
- 临时表单数据：页面内 `reactive` 即可

## API调用模式

```js
// 推荐：从统一入口导入
import { getUserInfo, login } from '@/api'

// 不推荐：直接使用数据源
import dataSource from '@/api/sources'
```

所有页面调用统一的 `@/api` 入口，无需关心底层数据源。

## 小程序开发注意事项

- 小程序不支持 DOM 操作，避免 `document`/`window`
- 使用 uni-app 提供的 API 进行页面跳转、存储等
- 注意包体积，合理使用分包
- 图片使用本地或CDN资源

## 多端适配技巧

- 使用条件编译 `#ifdef` / `#ifndef`
- 利用 TailwindCSS 的条件类（wx/mp等）
- 测试各平台差异，特别是样式表现
