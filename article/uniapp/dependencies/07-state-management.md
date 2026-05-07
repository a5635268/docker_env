# 状态管理工具

> Vue 3 状态管理方案：Pinia 与 Vuex 对比分析

---

本文档详细分析项目中的状态管理方案，包括 Pinia、Vuex 及测试工具的对比和使用。

**包含包数量**：3个

---

## 📊 Pinia vs Vuex 对比总览

在开始具体包分析前，先了解为什么项目同时包含两个状态管理库。

### 对比维度分析

| 维度 | Pinia 2.2.4 | Vuex 4.0.2 | 评分 |
|------|------------|------------|------|
| **架构设计** | 模块化、无需 mutations | 集中式、mutations 同步更新 | Pinia ★★★★ |
| **TypeScript** | 原生支持、类型完整 | 需额外配置、类型较弱 | Pinia ★★★★★ |
| **学习曲线** | 简单直观、Composition API | 概念多（state/mutations/actions/getters） | Pinia ★★★★ |
| **性能** | 更优的响应式更新 | 传统响应式 | Pinia ★★★★ |
| **生态地位** | Vue 3 官方推荐 | Vue 3 不推荐 | Pinia ★★★★★ |
| **迁移成本** | Vue 3 首选 | 已有 Vuex 项目升级 | Vuex ★★ |

### 项目当前状态

**检测结果**：项目主要使用 **Pinia**

证据：
- [src/store/index.js](../../src/store/index.js) 使用 `createPinia()`
- [src/store/modules/user.ts](../../src/store/modules/user.ts) 使用 `defineStore`
- [src/store/modules/config.js](../../src/store/modules/config.js) 使用 Pinia Composition API

**Vuex 状态**：虽然在 `package.json` 中存在，但未检测到实际使用代码。

**建议**：可以移除 Vuex 依赖，减少包体积。

---

## pinia@2.2.4

> Vue 3 官方推荐的状态管理库，简洁、类型安全、模块化

### 📦 基础信息

- **当前版本**：2.2.4（生产依赖）
- **安装命令**：
  ```bash
  pnpm add pinia
  ```
- **官方文档**：https://pinia.vuejs.org/
- **GitHub**：https://github.com/vuejs/pinia

### 🎯 选择理由

**为什么选择 Pinia？**

Pinia 是 Vue 3 的官方状态管理方案，优势明显：

1. **Vue 3 原生支持**：完全基于 Vue 3 Composition API 设计
2. **TypeScript 优先**：完整的类型推断，无需额外配置
3. **简洁直观**：无需 mutations，直接修改 state
4. **模块化设计**：每个 Store 独立，无需嵌套 modules
5. **DevTools 支持**：Vue DevTools 完美集成

**Pinia vs Vuex 详细对比**：

#### 1. 架构设计对比

**Pinia 架构**：
```typescript
// 定义 Store（无需 mutations）
export const useUserStore = defineStore('user', () => {
  const token = ref('')  // state
  const userInfo = ref({})  // state

  // 直接修改（无需 mutations）
  const setToken = (val: string) => {
    token.value = val
  }

  // actions（异步操作）
  const login = async (data: LoginData) => {
    const res = await loginAPI(data)
    setToken(res.token)
  }

  return { token, userInfo, setToken, login }
})
```

**Vuex 架构**：
```javascript
// 定义 Store（需要 mutations）
const store = createStore({
  state: {
    token: '',
    userInfo: {}
  },
  mutations: {
    SET_TOKEN(state, val) {  // 必须通过 mutations 修改
      state.token = val
    }
  },
  actions: {
    async login({ commit }, data) {
      const res = await loginAPI(data)
      commit('SET_TOKEN', res.token)  // 必须 commit mutations
    }
  }
})
```

**对比结论**：Pinia 代码更简洁，无需 mutations 层。

#### 2. TypeScript 支持对比

**Pinia TypeScript**：
```typescript
// Pinia 自动推断类型
export const useUserStore = defineStore('user', () => {
  const userInfo = ref<UserInfo>({ id: '', name: '' })
  const setUserInfo = (val: Partial<UserInfo>) => {
    userInfo.value = { ...userInfo.value, ...val }
  }
  return { userInfo, setUserInfo }
})

// 使用时自动类型提示
const userStore = useUserStore()
userStore.userInfo.id  // string 类型自动推断
userStore.setUserInfo({ name: 'test' })  // 参数类型自动检查
```

**Vuex TypeScript**（需要额外配置）：
```typescript
// Vuex 需要手动声明类型
interface State {
  token: string
  userInfo: UserInfo
}

const store = createStore<State>({
  state: {
    token: '',
    userInfo: { id: '', name: '' }
  },
  mutations: {
    SET_TOKEN(state, val: string) {  // 需要手动类型声明
      state.token = val
    }
  }
})

// 使用时类型较弱
store.state.token  // 需要手动类型断言
```

**对比结论**：Pinia 类型推断更完整，无需额外配置。

#### 3. 学习曲线对比

**Pinia 学习要点**：
- defineStore：定义 Store
- state：使用 ref/reactive
- actions：普通函数
- getters：computed
- **学习时间**：1-2天

**Vuex 学习要点**：
- state：状态数据
- mutations：同步修改
- actions：异步操作
- getters：计算属性
- modules：模块嵌套
- 辅助函数：mapState、mapActions、mapGetters
- **学习时间**：3-5天

**对比结论**：Pinia 更易学习，概念更少。

### 💡 实际案例

**在本项目中的使用**：

[src/store/index.js](../../src/store/index.js) - Pinia 入口：

```javascript
import { createPinia } from "pinia";
import { useUserStore } from "./modules/user";
import { useConfigStore } from "./modules/config";

const pinia = createPinia();

export default pinia;

export { useUserStore, useConfigStore };
```

[src/store/modules/user.ts](../../src/store/modules/user.ts) - User Store：

```typescript
import { defineStore } from 'pinia'
import { ref } from 'vue'
import storage from '@/utils/storage'
import constant from '@/utils/constant'
import { getToken, removeToken } from '@/utils/auth'
import type { UserInfo } from '@/types/user'

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref<string>(getToken())
  const userInfo = ref<UserInfo>(storage.get(constant.userInfo) || { id: '', name: '' })

  // Actions（直接修改 state，无需 mutations）
  const SET_TOKEN = (val: string): void => {
    token.value = val
  }

  const SET_USER_INFO = (val: Partial<UserInfo>): void => {
    userInfo.value = { id: val.id || '', name: val.name || '', ...val }
    storage.set(constant.userInfo, userInfo.value)
  }

  // 异步 Actions
  const login = (_loginData: any): Promise<void> => {
    return new Promise((resolve) => {
      // 实际登录逻辑
      resolve()
    })
  }

  const logout = (): Promise<void> => {
    return new Promise((resolve) => {
      SET_TOKEN('')
      SET_USER_INFO({ id: '', name: '' })
      removeToken()
      storage.clean()
      resolve()
    })
  }

  return {
    token,
    userInfo,
    SET_TOKEN,
    SET_USER_INFO,
    login,
    logout
  }
})
```

[src/store/modules/config.js](../../src/store/modules/config.js) - Config Store：

```javascript
import { defineStore } from "pinia";
import { ref } from "vue";

export const useConfigStore = defineStore("config", () => {
  const config = ref();
  const setConfig = (val) => {
    config.value = val;
  };
  return {
    config,
    setConfig,
  };
});
```

**使用示例**：

```vue
<template>
  <view>{{ userStore.userInfo.name }}</view>
</template>

<script setup lang="ts">
import { useUserStore } from '@/store'

const userStore = useUserStore()

// 直接访问 state
console.log(userStore.token)

// 调用 actions
userStore.SET_TOKEN('new-token')
userStore.logout()
</script>
```

**常见使用场景**：

1. **用户认证**：token 管理、用户信息存储
2. **应用配置**：全局配置、主题设置
3. **购物车**：商品列表、数量管理
4. **缓存数据**：API 数据缓存、本地存储同步

### ⚠️ 最佳实践

**常见问题及解决**：

1. **持久化存储问题**
   - **问题**：小程序环境 state 不持久化，刷新后丢失
   - **解决**：使用 uni.storage 同步 state

   ```typescript
   const userInfo = ref<UserInfo>(
     storage.get(constant.userInfo) || { id: '', name: '' }
   )

   const SET_USER_INFO = (val: Partial<UserInfo>) => {
     userInfo.value = { ...userInfo.value, ...val }
     storage.set(constant.userInfo, userInfo.value)  // 同步存储
   }
   ```

2. **响应式更新问题**
   - **问题**：直接修改对象属性可能不触发更新
   - **解决**：整体替换对象或使用 reactive

   ```typescript
   // ❌ 错误
   userInfo.value.name = 'test'

   // ✅ 正确
   userInfo.value = { ...userInfo.value, name: 'test' }
   ```

3. **跨页面状态共享**
   - **问题**：小程序页面间状态共享时机
   - **解决**：在 App.vue onLaunch 时初始化 Store

   ```vue
   <script>
   import { useUserStore } from '@/store'

   export default {
     onLaunch() {
       const userStore = useUserStore()
       // 初始化用户信息
     }
   }
   </script>
   ```

**性能优化建议**：

- **按需拆分 Store**：不同功能模块独立 Store
- **避免过度使用 computed**：仅在需要派生数据时使用
- **懒加载 Store**：在需要时才调用 useStore()

**注意事项**：

- Pinia 需在 main.ts 中注册：`app.use(pinia)`
- 小程序环境建议使用 uni.storage 持久化关键数据
- Composition API 风格需要在 setup 函数中调用 useStore()

---

## vuex@4.0.2

> Vue 状态管理库，集中式存储管理

### 📦 基础信息

- **当前版本**：4.0.2（生产依赖）
- **安装命令**：
  ```bash
  pnpm add vuex
  ```
- **官方文档**：https://vuex.vuejs.org/
- **GitHub**：https://github.com/vuejs/vuex

### 🎯 选择理由

**为什么项目中存在 Vuex？**

可能的原因：

1. **历史遗留**：从 Vue 2 项目迁移过来
2. **兼容性考虑**：某些第三方库依赖 Vuex
3. **备用方案**：团队部分成员熟悉 Vuex

**Vuex 在 Vue 3 中的地位**：

- Vue 3 **官方不再推荐** Vuex
- Vuex 4 是 Vue 2 到 Vue 3 的过渡版本
- **Pinia 是 Vue 3 的官方推荐**

### 💡 实际案例

**项目检测结果**：

未在项目中检测到 Vuex 实际使用代码。

**建议操作**：

1. **移除 Vuex 依赖**：
   ```bash
   pnpm remove vuex
   ```

2. **如有 Vuex 代码，迁移到 Pinia**：

   **Vuex 代码**：
   ```javascript
   const store = createStore({
     state: { count: 0 },
     mutations: {
       INCREMENT(state) { state.count++ }
     },
     actions: {
       increment({ commit }) { commit('INCREMENT') }
     }
   })
   ```

   **Pinia 迁移后**：
   ```typescript
   export const useCounterStore = defineStore('counter', () => {
     const count = ref(0)
     const increment = () => { count.value++ }
     return { count, increment }
   })
   ```

### ⚠️ 最佳实践

**Vuex 迁移建议**：

1. **逐步迁移**：一个 module 一个 module 地迁移到 Pinia
2. **保留 mutations 命名**：迁移时可保留原 mutations 名称作为 actions
3. **类型增强**：迁移时添加 TypeScript 类型定义

**Vuex vs Pinia 迁移对比**：

| Vuex 术语 | Pinia 对应 | 说明 |
|----------|-----------|------|
| state | ref/reactive | 状态定义 |
| mutations | 直接修改/actions | Pinia 无 mutations概念 |
| actions | actions | 异步操作 |
| getters | computed | 派生数据 |
| modules | defineStore | 每个 Store 独立 |

---

## @pinia/testing@^1.0.3

> Pinia Store 测试工具，简化状态管理测试

### 📦 基础信息

- **当前版本**：^1.0.3
- **安装命令**：
  ```bash
  pnpm add -D @pinia/testing
  ```
- **官方文档**：https://pinia.vuejs.org/cookbook/testing.html
- **GitHub**：https://github.com/vuejs/pinia

### 🎯 选择理由

**为什么需要 @pinia/testing？**

测试 Pinia Store 的挑战：

1. **Pinia 初始化**：测试环境需要创建 Pinia 实例
2. **Store 状态模拟**：需要预设初始状态
3. **Actions 测试**：需要 Mock 异步操作
4. **组件集成测试**：需要测试组件与 Store 的交互

### 💡 实际案例

**测试配置示例**：

[vitest.config.ts](../../vitest.config.ts) 已配置测试环境：

```typescript
export default defineConfig({
  test: {
    environment: 'happy-dom',
    setupFiles: ['./src/test/setup.ts']
  }
})
```

**Pinia Store 测试示例**：

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from '@/store/modules/user'

describe('User Store', () => {
  beforeEach(() => {
    // 每个测试前创建新的 Pinia 实例
    setActivePinia(createPinia())
  })

  it('should set token', () => {
    const store = useUserStore()
    store.SET_TOKEN('test-token')
    expect(store.token).toBe('test-token')
  })

  it('should login successfully', async () => {
    const store = useUserStore()
    await store.login({ username: 'test', password: '123456' })
    expect(store.token).toBeDefined()
  })
})
```

**使用 @pinia/testing 简化测试**：

```typescript
import { createTestingPinia } from '@pinia/testing'

describe('Component with Store', () => {
  it('should render user info', () => {
    const wrapper = mount(UserComponent, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              user: { userInfo: { name: 'Test User' } }
            }
          })
        ]
      }
    })

    expect(wrapper.text()).toContain('Test User')
  })
})
```

**常见使用场景**：

1. **Store 单元测试**：测试 actions、state 修改
2. **组件集成测试**：测试组件与 Store 交互
3. **Mock Store**：预设初始状态测试组件行为
4. **异步 Actions 测试**：测试 API 调用和状态更新

### ⚠️ 最佳实践

**常见问题及解决**：

1. **Store 未初始化**
   - **问题**：测试时报错 "Pinia is not installed"
   - **解决**：在 beforeEach 中调用 `setActivePinia(createPinia())`

2. **状态污染**
   - **问题**：多个测试共享同一 Store 实例
   - **解决**：每个测试创建新的 Pinia 实例

   ```typescript
   beforeEach(() => {
     setActivePinia(createPinia())  // 每次新实例
   })
   ```

3. **异步 Actions 测试**
   - **问题**：异步操作未完成就断言
   - **解决**：使用 await 或 vi.useFakeTimers()

**性能优化建议**：

- **使用 stubActions**：禁用真实 actions，加快测试速度

   ```typescript
   createTestingPinia({
     stubActions: false  // 仅测试 actions 调用，不执行
   })
   ```

**注意事项**：

- 测试环境需手动初始化 Pinia
- @pinia/testing 仅用于测试环境，不要在生产代码中使用
- 使用 happy-dom 或 jsdom 提供 DOM 环境

---

## 状态管理体系总结

### 项目状态管理架构

```
App.vue (应用入口)
  └── Pinia (createPinia)
      ├── useUserStore (用户状态)
      │   ├── token (登录凭证)
      │   ├── userInfo (用户信息)
      │   └── login/logout (认证操作)
      └── useConfigStore (配置状态)
          ├── config (应用配置)
          └── setConfig (配置修改)
```

### 跨平台存储策略

| 存储方式 | 适用场景 | 持久化 | 跨平台 |
|---------|---------|--------|--------|
| Pinia state | 临时状态、页面间共享 | ❌ | ✅ |
| uni.storage | 持久化数据、token | ✅ | ✅ |
| localStorage | H5 专用持久化 | ✅ | ❌ 仅H5 |

**推荐方案**：Pinia + uni.storage 组合
- Pinia：管理临时状态和页面间共享
- uni.storage：持久化关键数据（token、用户信息）

### 迁移建议

**从 Vuex 迁移到 Pinia 步骤**：

1. **移除 Vuex**：
   ```bash
   pnpm remove vuex
   ```

2. **创建 Pinia Store**：
   - 一个 Vuex module → 一个 Pinia defineStore
   - mutations → 直接修改 state 或 actions
   - actions → actions（无需 commit）
   - getters → computed

3. **更新组件代码**：
   - `mapState` → `useStore().state`
   - `mapActions` → `useStore().action()`
   - `mapGetters` → `useStore().getter`

4. **更新测试代码**：
   - 使用 @pinia/testing 替代 Vuex 测试工具

---

*文档生成时间：2026-05-07*
*项目主要使用 Pinia，建议移除 Vuex 依赖*