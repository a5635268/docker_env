# 测试工具体系

> Vitest 测试框架、Vue 测试工具、覆盖率、DOM 环境

---

本文档涵盖项目的测试工具体系，从单元测试到组件测试的完整方案。

**包含包数量**：7个

---

## 📊 测试体系架构

在开始具体包分析前，先理解测试工具的协同关系：

```
Vitest (测试框架)
  ├── happy-dom (DOM环境)
  ├── @vitest/coverage-v8 (覆盖率报告)
  ├── @vue/test-utils (Vue组件测试)
  ├── @pinia/testing (状态管理测试 - 见07文档)
  ├── @vue/runtime-core (Vue类型支持)
  └── src/test/setup.ts (uni-app Mock)
```

**测试类型覆盖**：

| 测试类型 | 工具 | 说明 |
|---------|------|------|
| 单元测试 | Vitest | 函数、工具类测试 |
| 组件测试 | @vue/test-utils | Vue组件测试 |
| Store测试 | @pinia/testing | Pinia状态管理测试 |
| E2E测试 | @dcloudio/uni-automator | 小程序自动化测试（见02文档） |

---

## vitest@^2.1.9

> Vite 原生测试框架，快速单元测试和组件测试

### 📦 基础信息

- **当前版本**：^2.1.9
- **安装命令**：
  ```bash
  pnpm add -D vitest
  ```
- **官方文档**：https://vitest.dev/
- **GitHub**：https://github.com/vitest-dev/vitest

### 🎯 选择理由

**为什么选择 Vitest？**

Vitest 专为 Vite 项目设计，优势明显：

1. **Vite 集成**：直接使用 Vite 配置，无需额外配置
2. **极速性能**：利用 Vite 的即时编译和缓存
3. **Jest兼容**：API 与 Jest 兼容，迁移成本低
4. **TypeScript原生**：无需额外配置即可测试 TS
5. **智能监听**：仅运行相关测试，极大提升速度

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **Vitest** | Vite原生、速度快、Jest兼容 | 相对年轻（2022年） | Vite项目 |
| **Jest** | 生态成熟、功能全面 | 配置复杂、启动慢 | 传统项目 |
| **Mocha** | 简单、灵活 | 需额外配置断言库 | 定制化项目 |

**项目决策**：选择 Vitest 因为：
- 项目基于 Vite 构建，Vitest 原生集成
- 多数据源模式需要快速测试反馈
- TypeScript 项目无需额外配置

### 💡 实际案例

**在本项目中的使用**：

[vitest.config.ts](../../vitest.config.ts) 配置：

```typescript
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    environment: 'happy-dom',  // DOM环境
    globals: true,  // 全局API（describe、it、expect）
    include: ['src/**/*.{test,spec}.{js,ts}'],  // 测试文件匹配
    coverage: {
      reporter: ['text', 'json', 'html'],  // 覆盖率报告格式
      exclude: ['node_modules/', 'src/auto-imports.d.ts', 'src/**/*.vue']
    },
    setupFiles: ['./src/test/setup.ts']  // uni-app Mock
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

**关键配置说明**：

1. **`environment: 'happy-dom'`**：轻量级DOM环境（比jsdom更快）
2. **`globals: true`**：全局测试API（无需导入 describe、it）
3. **`include`**：测试文件匹配规则（.test.js、.spec.ts）
4. **`setupFiles`**：测试前执行setup.ts，mock uni-app API
5. **`coverage`**：覆盖率配置，排除无关文件

**项目测试示例**：

[src/test/setup.ts](../../src/test/setup.ts) - uni-app Mock：

```typescript
import { vi } from 'vitest'

// Mock uni-app API
vi.stubGlobal('uni', {
  request: vi.fn(),
  getStorageSync: vi.fn((key: string) => {
    const store: Record<string, any> = {}
    return store[key] || ''
  }),
  setStorageSync: vi.fn((key: string, value: any) => {
    console.log(`[mock] setStorageSync: ${key} = ${value}`)
  }),
  showToast: vi.fn(),
  showModal: vi.fn(() => Promise.resolve({ confirm: true })),
  reLaunch: vi.fn(),
  navigateTo: vi.fn(),
  // ... 其他 uni API
})

// Mock process.env
vi.stubGlobal('process.env', {
  DATA_SOURCE_MODE: 'mock',
  NODE_ENV: 'test'
})
```

**测试文件示例**：

```typescript
// src/utils/common.test.ts
import { describe, it, expect } from 'vitest'
import { toast, modal } from '@/utils/common'

describe('common utils', () => {
  it('should call uni.showToast', () => {
    toast('test message')
    expect(uni.showToast).toHaveBeenCalledWith({
      title: 'test message',
      icon: 'none'
    })
  })

  it('should show modal', async () => {
    const result = await modal('确认删除？')
    expect(result).toBe(true)
  })
})
```

**常见使用场景**：

1. **工具函数测试**：request封装、storage操作、common工具
2. **Store测试**：Pinia actions、state修改（配合@pinia/testing）
3. **API测试**：mock数据源、测试响应处理
4. **组件测试**：Vue组件渲染、交互（配合@vue/test-utils）

### ⚠️ 最佳实践

**常见问题及解决**：

1. **uni-app API 未定义**
   - **问题**：测试时报错 "uni is not defined"
   - **解决**：在 setupFiles 中 mock uni API（已配置）

2. **环境变量未生效**
   - **问题**：process.env.DATA_SOURCE_MODE 为 undefined
   - **解决**：在 setup.ts 中 stubGlobal('process.env', ...)

   ```typescript
   vi.stubGlobal('process.env', {
     DATA_SOURCE_MODE: 'mock'
   })
   ```

3. **路径别名失效**
   - **问题**：@/ 导入报错
   - **解决**：在 vitest.config.ts 配置 resolve.alias

   ```typescript
   resolve: {
     alias: {
       '@': path.resolve(__dirname, './src')
     }
   }
   ```

**性能优化建议**：

- **智能监听**：Vitest 默认仅运行相关测试，已启用
- **并行测试**：默认并行执行，无需配置
- **缓存利用**：Vitest 自动缓存编译结果

**注意事项**：

- uni-app API 需要在 setup.ts 中完整 mock
- 测试 Vue 组件需配合 @vue/test-utils
- Pinia Store 测试需初始化 Pinia 实例

---

## @vitest/coverage-v8@^2.1.9

> Vitest 覆盖率工具，基于 V8 引擎的精确覆盖率报告

### 📦 基础信息

- **当前版本**：^2.1.9
- **安装命令**：
  ```bash
  pnpm add -D @vitest/coverage-v8
  ```
- **官方文档**：https://vitest.dev/guide/coverage.html
- **GitHub**：https://github.com/vitest-dev/vitest

### 🎯 选择理由

**为什么选择 coverage-v8？**

覆盖率工具对比：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **coverage-v8** | V8引擎原生、精确、快速 | Node.js 14+ | Vitest项目 |
| **coverage-istanbul** | 兼容性好、成熟 | 较慢、不够精确 | 旧版本Node |

**项目决策**：选择 coverage-v8 因为：
- Node.js 版本支持，性能最优
- Vitest 官方推荐
- V8 原生覆盖率，更精确

### 💡 实际案例

**在本项目中的使用**：

[vitest.config.ts](../../vitest.config.ts) 覆盖率配置：

```typescript
coverage: {
  reporter: ['text', 'json', 'html'],  // 多格式报告
  exclude: [
    'node_modules/',  // 第三方库
    'src/auto-imports.d.ts',  // 自动生成文件
    'src/**/*.vue'  // Vue组件（可选）
  ]
}
```

**生成覆盖率报告**：

```bash
# 运行覆盖率测试
pnpm test:coverage

# 输出格式：
# 1. text：终端输出覆盖率摘要
# 2. json：coverage/coverage-final.json
# 3. html：coverage/index.html（可视化报告）
```

**覆盖率报告解读**：

```
 % Coverage report from v8
------------------------------------
File                | % Stmts | % Branch | % Funcs | % Lines
------------------------------------
All files           |   85.71 |    78.57 |   80.00 |   85.71
 src/utils/common.ts|   92.31 |    85.71 |  100.00 |   92.31
 src/utils/request.ts|   78.57 |    71.43 |   66.67 |   78.57
------------------------------------
```

**覆盖率阈值配置**（可选）：

```typescript
coverage: {
  thresholds: {
    lines: 80,
    functions: 80,
    branches: 80,
    statements: 80
  }
}
```

**常见使用场景**：

1. **CI/CD集成**：GitHub Actions 自动检查覆盖率
2. **代码审查**：PR Review 要求覆盖率达标
3. **质量监控**：定期生成覆盖率报告，监控趋势

### ⚠️ 最佳实践

**常见问题及解决**：

1. **覆盖率数据不准确**
   - **问题**：某些文件覆盖率显示 0%
   - **解决**：确保测试文件正确导入被测代码

2. **Vue组件覆盖率低**
   - **问题**：Vue组件未测试，覆盖率低
   - **解决**：exclude Vue组件或编写组件测试

**性能优化建议**：

- **排除无关文件**：exclude node_modules、自动生成文件
- **设置阈值**：避免过度追求100%覆盖率

**注意事项**：

- coverage-v8 需 Node.js 14+
- 覆盖率报告在 coverage/ 目录
- html 报告可在浏览器打开查看详情

---

## @vue/test-utils@^2.4.10

> Vue.js 官方测试工具库，组件测试标准方案

### 📦 基础信息

- **当前版本**：^2.4.10
- **安装命令**：
  ```bash
  pnpm add -D @vue/test-utils
  ```
- **官方文档**：https://test-utils.vuejs.org/
- **GitHub**：https://github.com/vuejs/test-utils

### 🎯 选择理由

**为什么选择 @vue/test-utils？**

Vue 官方测试工具优势：

1. **官方维护**：Vue 核心团队开发，与 Vue 3 完全兼容
2. **组件挂载**：mount/shallowMount 简化组件测试
3. **交互模拟**：trigger、setValue 模拟用户操作
4. **Pinia集成**：配合 @pinia/testing 测试状态管理

### 💡 实际案例

**Vue组件测试示例**：

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import UserCard from '@/components/UserCard.vue'

describe('UserCard Component', () => {
  it('should render user info', () => {
    const wrapper = mount(UserCard, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              user: { userInfo: { name: 'Test User', id: '123' } }
            }
          })
        ]
      }
    })

    expect(wrapper.text()).toContain('Test User')
    expect(wrapper.find('.user-name').text()).toBe('Test User')
  })

  it('should call logout on button click', async () => {
    const wrapper = mount(UserCard, {
      global: {
        plugins: [createTestingPinia()]
      }
    })

    const logoutBtn = wrapper.find('.logout-btn')
    await logoutBtn.trigger('click')

    const userStore = useUserStore()
    expect(userStore.logout).toHaveBeenCalled()
  })
})
```

**关键API**：

| API | 用途 | 示例 |
|------|------|------|
| mount | 挂载组件 | mount(Component, { props: {...} }) |
| shallowMount | 浅挂载（不渲染子组件） | shallowMount(Component) |
| wrapper.find | 查找DOM元素 | wrapper.find('.class') |
| wrapper.trigger | 触发事件 | wrapper.trigger('click') |
| wrapper.text | 获取文本内容 | wrapper.text() |
| wrapper.html | 获取HTML内容 | wrapper.html() |

**常见使用场景**：

1. **组件渲染测试**：验证组件正确渲染数据
2. **交互测试**：测试点击、输入等用户操作
3. **Props测试**：测试组件接收props后的行为
4. **事件测试**：测试组件emit事件

### ⚠️ 最佳实践

**常见问题及解决**：

1. **组件挂载失败**
   - **问题**：mount 报错 "Cannot read property of undefined"
   - **解决**：确保组件依赖（Pinia、插件）正确注入

   ```typescript
   mount(Component, {
     global: {
       plugins: [createTestingPinia()]
     }
   })
   ```

2. **异步更新未等待**
   - **问题**：trigger('click') 后立即断言，DOM未更新
   - **解决**：使用 await 或 flushPromises

   ```typescript
   await wrapper.trigger('click')
   await flushPromises()  // 等待Promise完成
   ```

**注意事项**：

- shallowMount 不渲染子组件，适合测试组件逻辑
- mount 渲染完整组件树，适合测试组件集成
- 需配合 happy-dom 或 jsdom 提供 DOM 环境

---

## happy-dom@^20.9.0

> 轻量级DOM环境，比jsdom快10倍

### 📦 基础信息

- **当前版本**：^20.9.0
- **安装命令**：
  ```bash
  pnpm add -D happy-dom
  ```
- **官方文档**：https://github.com/capricorn86/happy-dom
- **GitHub**：https://github.com/capricorn86/happy-dom

### 🎯 选择理由

**为什么选择 happy-dom？**

DOM环境对比：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **happy-dom** | 极快（10倍速度）、轻量 | 功能相对简单 | Vitest单元测试 |
| **jsdom** | 功能完整、成熟 | 较慢（约100ms启动） | Jest、完整DOM模拟 |

**项目决策**：选择 happy-dom 因为：
- Vitest 推荐使用
- 性能极佳，启动时间 <10ms
- 满足 Vue 组件测试需求

### 💡 实际案例

**在本项目中的使用**：

[vitest.config.ts](../../vitest.config.ts) 配置：

```typescript
test: {
  environment: 'happy-dom',  // DOM环境选择
  // ...
}
```

**happy-dom提供的DOM API**：

```typescript
// 提供的DOM API（无需导入）
document.createElement('div')
document.querySelector('.class')
window.location.href
window.localStorage
// ... 标准DOM API
```

**性能对比**：

| 操作 | jsdom | happy-dom | 提升 |
|------|-------|-----------|------|
| 环境启动 | 100ms | 10ms | **10倍** |
| createElement | 0.5ms | 0.05ms | **10倍** |
| querySelector | 0.8ms | 0.08ms | **10倍** |

### ⚠️ 最佳实践

**常见问题及解决**：

1. **某些DOM API缺失**
   - **问题**：happy-dom不支持某些高级DOM API
   - **解决**：切换到 jsdom 或手动 mock

   ```typescript
   // vitest.config.ts
   environment: 'jsdom'  // 改用 jsdom
   ```

2. **uni-app API冲突**
   - **问题**：happy-dom 的 window 与 uni-app 冲突
   - **解决**：在 setup.ts 中 stubGlobal uni API

**注意事项**：

- happy-dom 功能较jsdom简单，高级DOM特性可能不支持
- uni-app 小程序API 需要手动 mock
- Vue组件测试基础功能完全满足

---

## @vue/runtime-core@^3.5.27

> Vue 3 运行时核心，提供类型定义

### 📦 础信息

- **当前版本**：^3.5.27
- **安装命令**：
  ```bash
  pnpm add -D @vue/runtime-core
  ```
- **官方文档**：https://vuejs.org/
- **GitHub**：https://github.com/vuejs/vue-next

### 🎯 选择理由

**为什么需要 @vue/runtime-core？**

测试环境用途：

1. **类型定义**：提供 Vue 3 内部类型（Ref、ComputedRef等）
2. **测试类型提示**：测试 Vue 组件时的类型支持
3. **版本一致性**：与项目 Vue 版本保持一致

### 💡 实际案例

**在测试中的类型支持**：

```typescript
import { ref, computed, Ref, ComputedRef } from '@vue/runtime-core'

// 测试中类型提示
const count: Ref<number> = ref(0)
const doubled: ComputedRef<number> = computed(() => count.value * 2)

// 测试类型正确性
expect(count.value).toBe(0)
expect(doubled.value).toBe(0)
```

**常见使用场景**：

1. **类型导入**：测试文件导入 Vue 类型
2. **类型断言**：测试 Vue API 返回值类型
3. **类型推导**：IDE 类型提示支持

### ⚠️ 最佳实践

**注意事项**：

- @vue/runtime-core 仅用于开发环境
- 生产环境使用 vue 包（包含runtime-core）
- 测试环境需要独立安装以确保类型定义

---

## 测试工具体系总结

### 测试金字塔

```
        E2E测试
      /          \     @dcloudio/uni-automator
     /            \    小程序自动化测试
    /              \
   /  组件测试      \   @vue/test-utils + @pinia/testing
  /                \  Vue组件、Store测试
 /                  \
/    单元测试         \ vitest + happy-dom
--------------------  工具函数、API测试
```

### 测试覆盖率目标

| 代码类型 | 目标覆盖率 | 说明 |
|---------|-----------|------|
| 工具函数 | 90%+ | 纯函数易测试 |
| API封装 | 80%+ | request、数据源测试 |
| Store | 80%+ | 状态管理测试 |
| Vue组件 | 60%+ | 核心组件测试（可选） |

### 测试最佳实践清单

1. ✅ **配置vitest.config.ts**：环境、覆盖率、别名
2. ✅ **Mock uni-app API**：setup.ts stubGlobal
3. ✅ **Mock process.env**：环境变量注入
4. ✅ **Pinia初始化**：测试前 setActivePinia
5. ✅ **异步操作处理**：await、flushPromises
6. ✅ **覆盖率报告**：定期生成、设置阈值

---

*文档生成时间：2026-05-07*
*测试体系：Vitest + happy-dom + Vue Test Utils*