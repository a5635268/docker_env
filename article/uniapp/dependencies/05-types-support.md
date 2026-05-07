# 类型支持工具

> TypeScript 类型系统和 Node.js 类型定义

---

本文档涵盖项目中的类型支持相关依赖包，确保代码类型安全和开发体验。

**包含包数量**：2个

---

## TypeScript@^5.9.3

> JavaScript 的超集，提供静态类型检查和现代语言特性

### 📦 基础信息

- **当前版本**：^5.9.3
- **安装命令**：
  ```bash
  pnpm add -D typescript
  ```
- **官方文档**：https://www.typescriptlang.org/
- **GitHub**：https://github.com/microsoft/TypeScript

### 🎯 选择理由

**为什么选择 TypeScript？**

TypeScript 为 uni-app 跨端开发带来以下优势：

1. **类型安全**：编译时捕获错误，减少运行时bug
2. **IDE支持**：智能提示、代码补全、重构支持
3. **团队协作**：类型定义即文档，降低沟通成本
4. **跨端兼容**：uni-app 生态系统良好支持 TypeScript

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **TypeScript** | 类型安全、IDE智能提示、大型项目友好 | 学习曲线、编译开销 | 中大型项目、团队协作 |
| **JavaScript** | 简单、无编译步骤 | 无类型检查、容易出错 | 小型项目、原型开发 |
| **JSDoc** | 无编译、文档化 | 类型检查弱、维护成本高 | 临时类型提示 |

**项目决策**：选择 TypeScript 因为：
- uni-app 跨端开发需要严格的类型检查
- 多数据源模式（mock/api/local）需要明确的类型定义
- 团队协作需要清晰的接口契约

### 💡 实际案例

**在本项目中的使用**：

项目在 [tsconfig.json](../../tsconfig.json) 中配置 TypeScript：

```json
{
  "compilerOptions": {
    "target": "esnext",
    "lib": ["esnext", "dom"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    },
    "allowJs": true,
    "esModuleInterop": true
  }
}
```

**关键配置说明**：

1. **`"target": "esnext"`**：编译到最新 ES 标准，由 Vite 处理向下兼容
2. **`"module": "esnext"`**：使用 ES 模块，配合 Vite bundler 模式
3. **`"strict": true`**：启用严格类型检查
4. **`"paths": { "@/*": ["src/*"] }`**：路径别名，匹配 Vite 配置

**项目中的类型定义示例**：

```typescript
// src/types/user.ts
export interface UserInfo {
  id: string
  name: string
  avatar?: string
  token?: string
}

// src/store/modules/user.ts
import type { UserInfo } from '@/types/user'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref<UserInfo>(storage.get(constant.userInfo) || { id: '', name: '' })
  // ...
})
```

**常见使用场景**：

1. **接口类型定义**：API 响应数据、组件 props
2. **Store 类型声明**：Pinia state、actions 类型
3. **工具函数类型**：request 封装、storage 操作
4. **条件编译类型**：uni-app 平台特定 API

### ⚠️ 最佳实践

**常见问题及解决**：

1. **uni-app API 类型缺失**
   - **原因**：部分 uni-app API 缺少类型定义
   - **解决**：安装 `@dcloudio/types`，或在项目中补充类型声明

   ```typescript
   // src/types/uni-app.d.ts
   declare namespace UniNamespace {
     interface NavigateToOptions {
       url: string
       success?: (res: any) => void
       fail?: (err: any) => void
     }
   }
   ```

2. **路径别名类型提示失效**
   - **原因**：`tsconfig.json` 的 `paths` 配置与实际路径不一致
   - **解决**：确保 `baseUrl` 和 `paths` 配置正确，重启 IDE

3. **条件编译类型错误**
   - **原因**：条件编译导致类型推断混乱
   - **解决**：使用类型断言或分离平台特定代码

**性能优化建议**：

- **项目引用**：大型项目使用 TypeScript 项目引用（Project References）提高编译速度
- **增量编译**：开发模式启用增量编译（`incremental: true`）
- **跳过检查**：生产构建时使用 `skipLibCheck: true` 加快构建

**注意事项**：

- uni-app 某些 API 需要 `@dcloudio/types@3.4.8+` 才有完整类型支持
- Pinia Composition API 需要显式声明类型，否则推断可能不准确
- 避免过度使用 `any` 类型，使用 `unknown` 或具体类型

---

## @types/node@^24.10.1

> Node.js API 的 TypeScript 类型定义

### 📦 基础信息

- **当前版本**：^24.10.1
- **安装命令**：
  ```bash
  pnpm add -D @types/node
  ```
- **官方文档**：https://github.com/DefinitelyTyped/DefinitelyTyped
- **GitHub**：https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/node

### 🎯 选择理由

**为什么需要 @types/node？**

项目使用 Node.js API 的场景：

1. **Vite 配置**：`vite.config.ts` 使用 Node.js path、process 等 API
2. **构建脚本**：自定义构建逻辑可能涉及文件系统操作
3. **环境变量**：`process.env` 类型提示
4. **开发工具**：CLI 工具、自动化脚本

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **@types/node** | 官方维护、完整覆盖、定期更新 | 需要额外安装 | Node.js环境开发 |
| **自行定义** | 针对性强 | 维护成本高、覆盖不全 | 极少数特定场景 |

**项目决策**：选择 @types/node 因为：
- Vite 配置文件使用 Node.js API（path、process）
- 提供完整的环境变量类型提示
- 简化构建脚本开发

### 💡 实际案例

**在本项目中的使用**：

[vite.config.ts](../../vite.config.ts) 使用 Node.js API：

```typescript
import path from 'path'  // Node.js path 模块
import { defineConfig, loadEnv } from 'vite'

export default defineConfig(async ({ mode }) => {
  // Node.js process.cwd()
  const env = loadEnv(mode, process.cwd(), '')

  return {
    // Node.js path.resolve
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src')
      }
    },
    // Node.js process.env 类型提示
    define: {
      'process.env.DATA_SOURCE_MODE': JSON.stringify(env.DATA_SOURCE_MODE || 'api')
    }
  }
})
```

[vitest.config.ts](../../vitest.config.ts) 使用 path 模块：

```typescript
import path from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

**常见使用场景**：

1. **路径处理**：`path.resolve`、`path.join` 构建配置
2. **环境变量**：`process.env` 类型提示
3. **文件操作**：`fs.readFileSync`、`fs.writeFileSync`（构建脚本）
4. **进程信息**：`process.cwd()`、`process.platform`

### ⚠️ 最佳实践

**常见问题及解决**：

1. **Node.js API 在浏览器环境报错**
   - **原因**：Node.js API（如 `fs`）不能在浏览器端使用
   - **解决**：仅在构建配置和开发工具中使用，确保这些代码不会打包到生产环境

2. **`__dirname` 未定义**
   - **原因**：ES 模块模式下 `__dirname` 不可用
   - **解决**：使用 `import.meta.url` 或配置 TypeScript

   ```typescript
   // 方案1：使用 import.meta.url
   import { fileURLToPath } from 'url'
   const __dirname = fileURLToPath(new URL('.', import.meta.url))

   // 方案2：配置 tsconfig.json
   {
     "compilerOptions": {
       "module": "commonjs"  // 或使用 bundler 模式
     }
   }
   ```

3. **类型版本与 Node.js 版本不匹配**
   - **原因**：`@types/node` 版本过高或过低
   - **解决**：根据项目 Node.js 版本选择合适的 `@types/node` 版本

**性能优化建议**：

- 仅导入需要的 API，避免全量导入 `import * as Node from 'node'`
- 使用 Node.js 最新 LTS 版本，`@types/node` 对应版本

**注意事项**：

- uni-app 小程序环境不支持 Node.js API
- 确保构建配置中的 Node.js 代码不会进入客户端包
- Vite 会自动处理 Node.js API 的 polyfill 问题

---

## 类型支持体系总结

### 类型定义覆盖范围

| 类型来源 | 覆盖内容 | 说明 |
|---------|---------|------|
| TypeScript | 基础类型、ES API | 核心类型系统 |
| @types/node | Node.js API | 构建配置、开发工具 |
| @dcloudio/types | uni-app API | 跨端开发（见02文档） |
| 项目自定义 | 业务类型 | `/src/types/*.ts` |

### 类型安全策略

1. **严格模式**：`tsconfig.json` 启用 `strict: true`
2. **渐进迁移**：使用 `allowJs: true` 支持 JavaScript 文件
3. **类型补充**：为缺失类型定义的 API 补充声明
4. **定期更新**：跟随 TypeScript 和 @types/node 版本升级

---

*文档生成时间：2026-05-07*