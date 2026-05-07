# uni-app 核心工具

> uni-app 跨端框架核心、小程序开发工具、TailwindCSS适配

---

本文档涵盖uni-app跨端开发的核心工具，是多端应用的基础设施。

**包含包数量**：7个

---

## 📊 uni-app 体系架构

在开始具体包分析前，先理解uni-app核心工具的协同关系：

```
uni-app 跨端开发架构：

@dcloudio/vite-plugin-uni (Vite核心插件)
  ├── @dcloudio/uni-cli-shared (CLI共享工具)
  ├── @dcloudio/types (TypeScript类型)
  └── @dcloudio/uni-stacktracey (错误追踪)

小程序开发工具：
  ├── weapp-ide-cli (微信开发者工具CLI)
  └── weapp-tailwindcss (TailwindCSS小程序适配)

自动化测试：
  └── @dcloudio/uni-automator (小程序自动化测试)
```

**跨端支持平台**：

| 平台 | 依赖包 | 说明 |
|------|--------|------|
| 微信小程序 | @dcloudio/uni-mp-weixin | 主包默认 |
| H5 | @dcloudio/uni-h5 | Web应用 |
| 支付宝小程序 | @dcloudio/uni-mp-alipay | 支付宝平台 |
| 百度小程序 | @dcloudio/uni-mp-baidu | 百度平台 |
| QQ小程序 | @dcloudio/uni-mp-qq | QQ平台 |

---

## @dcloudio/vite-plugin-uni@3.0.0-4080720251210001

> uni-app Vite核心插件，跨端构建基础设施

### 📦 基础信息

- **当前版本**：3.0.0-4080720251210001
- **安装命令**：
  ```bash
  pnpm add -D @dcloudio/vite-plugin-uni
  ```
- **官方文档**：https://uniapp.dcloud.net.cn/
- **GitHub**：https://github.com/dcloudio/uni-app

### 🎯 选择理由

**为什么选择 @dcloudio/vite-plugin-uni？**

uni-app Vite插件带来的革命性改变：

1. **Vite原生支持**：uni-app与Vite完美集成，享受极速开发体验
2. **多端构建**：一套代码构建微信小程序、H5、支付宝小程序等
3. **条件编译**：平台特定代码自动处理
4. **页面分包**：自动优化小程序分包加载
5. **TypeScript支持**：完整的类型定义

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **uni-app Vite** | 多端支持、Vite快速、现代化 | uni-app框架约束 | 多端应用开发 |
| **uni-app Webpack** | 稳定、成熟 | 构建慢、HMR慢 | 传统项目 |
| **原生开发** | 完全可控 | 多端重复开发 | 单平台项目 |

**项目决策**：选择 uni-app Vite 因为：
- Vite 极速开发体验
- 多端发布需求（微信小程序、H5）
- 条件编译处理平台差异

### 💡 实际案例

**在本项目中的使用**：

[vite.config.ts](../../vite.config.ts) 核心配置：

```typescript
import uni from "@dcloudio/vite-plugin-uni";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    uni(),  // uni-app核心插件，必须第一个加载
    // 其他插件...
  ],
});
```

**关键功能说明**：

1. **页面路由处理**：解析 pages.json，生成页面路由
2. **条件编译**：处理 `#ifdef MP-WEIXIN` 等条件编译指令
3. **分包优化**：自动处理 subPackages 分包配置
4. **样式适配**：小程序样式单位转换（rpx）
5. **API适配**：uni API 跨端兼容处理

**pages.json 配置示例**：

[src/pages.json](../../src/pages.json)（需读取确认）：

```json
{
  "pages": [
    {
      "path": "pages/index",
      "style": { "navigationBarTitleText": "首页" }
    },
    {
      "path": "pages/example/list",
      "style": { "navigationBarTitleText": "示例列表" }
    }
  ],
  "subPackages": [
    {
      "root": "pages/sub-example/",
      "pages": [
        { "path": "detail", "style": { "navigationBarTitleText": "分包示例" } }
      ]
    }
  ]
}
```

**条件编译示例**：

```vue
<template>
  <!-- 仅微信小程序显示 -->
  <!-- #ifdef MP-WEIXIN -->
  <button open-type="share">微信分享</button>
  <!-- #endif -->

  <!-- 仅H5显示 -->
  <!-- #ifdef H5 -->
  <a href="/home">H5链接</a>
  <!-- #endif -->

  <!-- 多平台条件 -->
  <!-- #ifdef MP-WEIXIN || H5 -->
  <view>微信小程序或H5</view>
  <!-- #endif -->
</template>

<script>
// 条件编译导入
// #ifdef MP-WEIXIN
import wechatShare from '@/utils/wechat'
// #endif

// 条件编译代码
// #ifdef H5
console.log('H5平台')
// #endif
</script>
```

**常见使用场景**：

1. **多端构建**：`pnpm dev:mp-weixin`（小程序）、`pnpm dev:h5`（H5）
2. **平台差异**：条件编译处理平台特定功能
3. **分包加载**：优化小程序包体积和加载速度
4. **API适配**：uni API 跨端兼容（如 uni.navigateTo）

### ⚠️ 最佳实践

**常见问题及解决**：

1. **插件加载顺序错误**
   - **问题**：uni() 未在 plugins 第一位，构建失败
   - **解决**：确保 uni() 插件最先加载

   ```typescript
   plugins: [
     uni(),  // 必须第一个
     // 其他插件
   ]
   ```

2. **条件编译未生效**
   - **问题**：条件编译指令未正确处理
   - **解决**：检查指令语法，确保 `#ifdef` 和 `#endif` 匹配

   ```vue
   <!-- #ifdef MP-WEIXIN -->
   微信小程序代码
   <!-- #endif -->  <!-- 必须闭合 -->
   ```

3. **分包路径错误**
   - **问题**：subPackages 配置路径不正确
   - **解决**：确保分包路径与实际文件路径一致

**性能优化建议**：

- **合理分包**：将非首屏页面放入分包，减小主包体积
- **条件编译**：平台特定代码仅在该平台编译
- **图片优化**：小程序图片使用CDN或本地压缩

**注意事项**：

- uni() 插件必须第一个加载
- 条件编译指令必须闭合（`#ifdef` → `#endif`）
- pages.json 配置需符合uni-app规范
- 分包路径需正确配置

---

## @dcloudio/types@^3.4.8

> uni-app TypeScript 类型定义

### 📦 基础信息

- **当前版本**：^3.4.8
- **安装命令**：
  ```bash
  pnpm add -D @dcloudio/types
  ```
- **官方文档**：https://uniapp.dcloud.net.cn/
- **GitHub**：https://github.com/dcloudio/uni-app

### 🎯 选择理由

**为什么需要 @dcloudio/types？**

uni-app TypeScript 类型支持：

1. **完整类型定义**：uni API、页面参数、组件类型
2. **智能提示**：IDE自动提示uni API参数和返回值
3. **类型安全**：编译时检查uni API调用错误
4. **跨端兼容**：类型定义覆盖所有平台API

### 💡 实际案例

**在本项目中的使用**：

类型定义已集成到 TypeScript 项目中，无需额外配置。

**uni API类型示例**：

```typescript
// uni.navigateTo 类型定义
uni.navigateTo({
  url: '/pages/example/detail?id=123',
  success: (res) => {
    console.log(res.errMsg)  // 类型提示: errMsg: string
  },
  fail: (err) => {
    console.log(err.errMsg)  // 类型提示: errMsg: string
  }
})

// uni.request 类型定义
uni.request({
  url: 'https://api.example.com/data',
  method: 'GET',
  success: (res) => {
    console.log(res.statusCode)  // 类型提示: statusCode: number
    console.log(res.data)  // 类型提示: data: any
  }
})

// uni.showToast 类型定义
uni.showToast({
  title: '成功',
  icon: 'success',  // 类型提示: 'success' | 'loading' | 'none'
  duration: 2000
})
```

**页面参数类型定义**：

```typescript
// 页面接收参数类型
interface PageParams {
  id: string
  name?: string
}

// 页面onLoad接收参数
onLoad((params: PageParams) => {
  console.log(params.id)  // 类型安全
})
```

**常见使用场景**：

1. **API调用**：uni.navigateTo、uni.request等
2. **页面参数**：onLoad接收参数类型定义
3. **组件Props**：uni-app组件类型定义
4. **平台差异**：条件编译中的平台特定API

### ⚠️ 最佳实践

**注意事项**：

- @dcloudio/types 版本需与uni-app版本匹配
- 部分uni API可能缺少类型，需手动补充
- TypeScript项目自动识别类型定义

---

## @dcloudio/uni-automator@3.0.0-4080720251210001

> uni-app 自动化测试工具，小程序E2E测试

### 📦 基础信息

- **当前版本**：3.0.0-4080720251210001
- **安装命令**：
  ```bash
  pnpm add -D @dcloudio/uni-automator
  ```
- **官方文档**：https://uniapp.dcloud.net.cn/tutorial/automator.html
- **GitHub**：https://github.com/dcloudio/uni-app

### 🎯 选择理由

**为什么需要 uni-automator？**

小程序自动化测试挑战：

1. **官方支持**：uni-app官方自动化测试工具
2. **跨端测试**：支持微信、支付宝、百度小程序
3. **开发者工具集成**：与微信开发者工具集成
4. **API模拟**：模拟小程序环境API调用

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **uni-automator** | uni-app官方、跨端支持 | 配置复杂 | uni-app项目 |
| **miniprogram-automator** | 微信官方 | 仅微信小程序 | 微信小程序项目 |
| **手动测试** | 简单 | 效率低、易出错 | 小型项目 |

### 💡 实际案例

**自动化测试配置示例**：

```typescript
// automator.config.js
module.exports = {
  projectPath: './dist/dev/mp-weixin',
  platform: 'mp-weixin'
}

// 测试脚本示例
const automator = require('@dcloudio/uni-automator')

describe('小程序自动化测试', () => {
  let miniProgram

  beforeAll(async () => {
    miniProgram = await automator.launch({
      cliPath: '/Applications/wechatwebdevtools.app/Contents/MacOS/cli',
      projectPath: './dist/dev/mp-weixin'
    })
  })

  it('首页渲染测试', async () => {
    const page = await miniProgram.reLaunch('/pages/index')
    await page.waitFor(1000)

    const element = await page.$('.title')
    const text = await element.text()
    expect(text).toContain('首页')
  })

  afterAll(async () => {
    if (miniProgram) {
      await miniProgram.close()
    }
  })
})
```

**常见使用场景**：

1. **页面渲染测试**：验证页面正确渲染
2. **交互测试**：测试点击、滑动等操作
3. **API调用测试**：测试uni API调用
4. **跨端测试**：多平台自动化测试

### ⚠️ 最佳实践

**注意事项**：

- 需要微信开发者工具CLI支持
- 测试环境需启动小程序开发版
- 跨端测试需配置对应平台CLI

---

## @dcloudio/uni-cli-shared@3.0.0-4080720251210001

> uni-app CLI共享工具库

### 📦 础信息

- **当前版本**：3.0.0-4080720251210001
- **安装命令**：
  ```bash
  pnpm add -D @dcloudio/uni-cli-shared
  ```
- **官方文档**：https://uniapp.dcloud.net.cn/
- **GitHub**：https://github.com/dcloudio/uni-app

### 🎯 选择理由

**为什么需要 uni-cli-shared？**

CLI共享工具作用：

1. **Vite插件依赖**：@dcloudio/vite-plugin-uni 内部依赖
2. **工具函数**：uni-app CLI通用工具函数
3. **配置处理**：pages.json解析、条件编译处理
4. **跨端适配**：平台差异处理工具

### 💡 实际案例

**说明**：此包为uni-app内部依赖，开发者无需直接使用。

**内部功能**（供参考）：

- pages.json 解析工具
- 条件编译预处理
- 平台配置生成
- 分包优化计算

**注意事项**：

- 开发者通常无需直接调用
- uni-app Vite插件自动依赖
- 更新时需与uni-app核心包版本一致

---

## @dcloudio/uni-stacktracey@3.0.0-4080720251210001

> uni-app 错误堆栈追踪工具

### 📦 基础信息

- **当前版本**：3.0.0-4080720251210001
- **安装命令**：
  ```bash
  pnpm add -D @dcloudio/uni-stacktracey
  ```
- **官方文档**：https://uniapp.dcloud.net.cn/
- **GitHub**：https://github.com/dcloudio/uni-app

### 🎯 选择理由

**为什么需要 uni-stacktracey？**

错误调试重要性：

1. **错误追踪**：小程序错误堆栈解析和展示
2. **源码映射**：编译后代码映射到源码位置
3. **调试优化**：提升开发调试效率
4. **跨端适配**：适配小程序错误格式

### 💡 实际案例

**说明**：此包为uni-app内部依赖，自动集成到构建流程。

**功能示例**（供参考）：

```
小程序错误输出：
Error: Cannot read property 'id' of undefined
  at onClick (pages/example/list.vue:42)
  at handleClick (pages/example/list.vue:38)

堆栈追踪优化：
- 显示源码位置（而非编译后位置）
- 错误定位精确到Vue组件行号
```

**注意事项**：

- 开发者通常无需直接调用
- uni-app构建时自动集成
- 错误堆栈在开发控制台显示

---

## weapp-ide-cli@^5.0.1

> 微信开发者工具命令行接口

### 📦 基础信息

- **当前版本**：^5.0.1
- **安装命令**：
  ```bash
  pnpm add -D weapp-ide-cli
  ```
- **官方文档**：https://developers.weixin.qq.com/miniprogram/dev/devtools/cli.html
- **GitHub**：https://github.com/wechat-miniprogram/weapp-ide-cli

### 🎯 选择理由

**为什么需要 weapp-ide-cli？**

命令行工具优势：

1. **自动化构建**：CI/CD集成微信小程序上传
2. **开发者工具控制**：通过命令行启动、打开项目
3. **版本上传**：自动化上传小程序代码
4. **二维码生成**：生成预览二维码

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **weapp-ide-cli** | 自动化、CI/CD集成 | 需安装开发者工具 | 自动化流程 |
| **手动操作** | 简单、直观 | 效率低、易出错 | 个人开发 |

**项目决策**：选择 weapp-ide-cli 因为：
- 自动化构建流程
- CI/CD集成小程序上传
- 开发效率提升

### 💡 实际案例

**在本项目中的使用**：

[package.json](../../package.json) 脚本命令：

```json
{
  "scripts": {
    "open:dev": "weapp open -p dist/dev/mp-weixin",
    "open:build": "weapp open -p dist/build/mp-weixin",
    "weapp:login": "weapp login",
    "upload:dev": "weapp upload -p dist/dev/mp-weixin -v 1.0.0 -d \"dev version\"",
    "upload:build": "weapp upload -p dist/build/mp-weixin -v 1.0.0 -d \"release version\""
  }
}
```

**常用命令**：

```bash
# 打开开发版本
pnpm open:dev
# 等同于：weapp open -p dist/dev/mp-weixin

# 打开生产版本
pnpm open:build

# 微信登录
pnpm weapp:login

# 上传开发版本
pnpm upload:dev

# 上传生产版本
pnpm upload:build
```

**命令说明**：

| 命令 | 功能 | 参数说明 |
|------|------|---------|
| weapp open | 打开项目 | -p 项目路径 |
| weapp login | 微信登录 | 无参数 |
| weapp upload | 上传代码 | -p 路径 -v 版本 -d 描述 |
| weapp preview | 生成二维码 | -p 项目路径 |

**CI/CD集成示例**：

```yaml
# GitHub Actions 自动上传
name: Upload Mini Program
on:
  push:
    branches: [main]

jobs:
  upload:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - run: pnpm install
      - run: pnpm build:mp-weixin
      - run: pnpm weapp:login
      - run: pnpm upload:build
```

**常见使用场景**：

1. **开发调试**：打开开发版本进行调试
2. **版本上传**：上传小程序到微信后台
3. **CI/CD**：自动化构建和上传流程
4. **二维码预览**：生成预览二维码分享

### ⚠️ 最佳实践

**常见问题及解决**：

1. **开发者工具未安装**
   - **问题**：命令报错 "cli not found"
   - **解决**：安装微信开发者工具，确保CLI路径正确

2. **登录失败**
   - **问题**：weapp login 报错
   - **解决**：手动在开发者工具中登录，或使用扫码登录

3. **上传权限不足**
   - **问题**：upload 报错 "no permission"
   - **解决**：确保已登录且具备小程序上传权限

**注意事项**：

- 需要安装微信开发者工具
- macOS CLI路径：`/Applications/wechatwebdevtools.app/Contents/MacOS/cli`
- Windows CLI路径：`微信开发者工具安装目录/cli.bat`
- 上传前需先登录（weapp login）

---

## weapp-tailwindcss@^4.9.8

> 小程序 TailwindCSS 适配器（主分类文档）

### 📦 基础信息

- **当前版本**：^4.9.8
- **安装命令**：
  ```bash
  pnpm add -D weapp-tailwindcss
  ```
- **官方文档**：https://tw.icebreaker.top/
- **GitHub**：https://github.com/sonofmagic/weapp-tailwindcss

### 🎯 选择理由

**为什么选择 weapp-tailwindcss？**

小程序 TailwindCSS 适配挑战：

1. **rem转rpx**：小程序单位自动转换（rem → rpx）
2. **条件编译**：小程序特定样式（如 `wx:text-xl`）
3. **禁用preflight**：小程序禁用重置CSS
4. **SVG适配**：小程序SVG内联支持
5. **性能优化**：按需生成小程序样式

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **weapp-tailwindcss** | 小程序适配、条件编译 | 需额外配置 | uni-app小程序 |
| **原生TailwindCSS** | 标准实现 | 小程序不兼容 | Web项目 |

**项目决策**：选择 weapp-tailwindcss 因为：
- uni-app 小程序 TailwindCSS 完美适配
- rem → rpx 自动转换
- 条件编译支持（微信、H5等）

### 💡 实际案例

**在本项目中的使用**：

[vite.config.ts](../../vite.config.ts) Vite集成：

```typescript
import { UnifiedViteWeappTailwindcssPlugin } from "weapp-tailwindcss/vite";

export default defineConfig({
  plugins: [
    uni(),
    UnifiedViteWeappTailwindcssPlugin({
      rem2rpx: true,  // rem → rpx 自动转换
      disabled: WeappTailwindcssDisabled,  // H5禁用（仅小程序生效）
    }),
  ],
});
```

[tailwind.config.ts](../../tailwind.config.ts) 条件编译配置：

```typescript
import cssMacro from "weapp-tailwindcss/css-macro";

export default {
  plugins: [
    cssMacro({
      variantsMap: {
        wx: "MP-WEIXIN",  // wx:text-xl 仅微信小程序
        "-wx": {
          value: "MP-WEIXIN",
          negative: true,
        },
      },
    }),
  ],
  corePlugins: {
    preflight: !isMp,  // 小程序禁用preflight
    container: !isMp,  // 小程序禁用container
  },
};
```

[postcss.config.ts](../../postcss.config.ts) PostCSS集成：

```typescript
import cssMacro from "weapp-tailwindcss/css-macro/postcss";

const plugins = [tailwindcss(), autoprefixer(), cssMacro];
```

**实际使用示例**：

```vue
<template>
  <!-- rem自动转rpx（小程序） -->
  <view class="text-xl p-4">
    text-xl: 小程序为 32rpx，H5为 1.25rem
    p-4: 小程序为 32rpx，H5为 1rem
  </view>

  <!-- 条件编译（仅微信小程序） -->
  <view class="wx:text-xl text-base">
    微信小程序: text-xl (32rpx)
    其他平台: text-base (16rpx 或 28.67rpx)
  </view>

  <!-- 负向条件编译（非微信小程序） -->
  <view class="-wx:text-lg wx:text-sm">
    微信小程序: text-sm
    其他平台: text-lg
  </view>
</template>
```

**rem → rpx 转换规则**：

| TailwindCSS类 | rem值 | 小程序rpx | H5值 |
|---------------|-------|----------|------|
| text-xs | 0.75rem | 24rpx | 0.75rem |
| text-sm | 0.875rem | 28rpx | 0.875rem |
| text-base | 1rem | 32rpx | 1rem |
| text-lg | 1.125rem | 36rpx | 1.125rem |
| text-xl | 1.25rem | 40rpx | 1.25rem |
| text-2xl | 1.5rem | 48rpx | 1.5rem |

**常见使用场景**：

1. **尺寸适配**：rem自动转rpx，跨端一致
2. **条件编译**：平台特定样式（wx:text-xl）
3. **图标适配**：小程序SVG内联支持
4. **禁用preflight**：小程序禁用重置CSS

### ⚠️ 最佳实践

**常见问题及解决**：

1. **H5样式重复转换**
   - **问题**：H5环境rem也被转rpx
   - **解决**：配置 disabled: WeappTailwindcssDisabled（H5禁用）

   ```typescript
   UnifiedViteWeappTailwindcssPlugin({
     disabled: WeappTailwindcssDisabled,  // H5禁用
   })
   ```

2. **条件编译不生效**
   - **问题**：wx:text-xl 在所有平台都生效
   - **解决**：确保 cssMacro 正确配置和加载

3. **小程序样式冲突**
   - **问题**：TailwindCSS与小程序原生样式冲突
   - **解决**：禁用 preflight，避免重置小程序样式

**性能优化建议**：

- **按需生成**：TailwindCSS JIT模式，仅生成使用的类
- **H5禁用**：H5环境禁用weapp-tailwindcss，避免冗余转换
- **条件编译**：合理使用条件编译，避免重复样式

**注意事项**：

- weapp-tailwindcss 仅在小程序环境生效
- H5环境需禁用（配置 disabled）
- rem → rpx 转换规则：1rem = 32rpx（小程序基准）
- 条件编译类名需正确配置 variantsMap

---

## uni-app 核心体系总结

### 跨端开发架构

```
开发阶段：
1. 编写Vue组件（条件编译处理平台差异）
2. Vite + @dcloudio/vite-plugin-uni 编译
3. TailwindCSS原子类 + weapp-tailwindcss适配

构建阶段：
1. uni()插件处理条件编译
2. 平台特定代码编译（小程序/H5）
3. 分包优化和代码压缩
4. 输出到 dist/dev 或 dist/build

调试阶段：
1. 微信开发者工具打开项目（weapp-ide-cli）
2. uni-stacktracey 错误追踪
3. 实时调试和热更新

发布阶段：
1. 构建生产版本（pnpm build:mp-weixin）
2. 上传小程序（weapp upload）
3. 微信后台审核和发布
```

### 跨端支持对比

| 功能 | 微信小程序 | H5 | 支付宝小程序 | 说明 |
|------|-----------|----|-----------|------|
| TailwindCSS | ✅（weapp适配） | ✅（标准） | ✅（weapp适配） | 跨端一致 |
| 条件编译 | ✅（MP-WEIXIN） | ✅（H5） | ✅（MP-ALIPAY） | 平台特定 |
| uni API | ✅ | ✅ | ✅ | 跨端兼容 |
| 分包加载 | ✅ | ❌ | ✅ | 小程序特有 |
| 自动化测试 | ✅ | ✅ | ✅ | uni-automator |

### uni-app 开发最佳实践

1. ✅ **优先uni API**：使用 uni.navigateTo 等，确保跨端兼容
2. ✅ **条件编译**：平台特定代码使用 `#ifdef` 条件编译
3. ✅ **TailwindCSS原子类**：快速构建UI，weapp-tailwindcss适配小程序
4. ✅ **合理分包**：优化小程序包体积，减小主包
5. ✅ **自动化流程**：CI/CD集成weapp-ide-cli自动上传
6. ✅ **TypeScript类型**：使用 @dcloudio/types 确保类型安全

---

## 文档体系完成总结

**全部7个分类文档已完成**：

1. ✅ [01-build-tools.md](01-build-tools.md) - Vite构建工具（2个包）
2. ✅ [02-uniapp-core.md](02-uniapp-core.md) - uni-app核心（7个包）
3. ✅ [03-styling-tools.md](03-styling-tools.md) - TailwindCSS样式工具（8个包）
4. ✅ [04-testing-tools.md](04-testing-tools.md) - Vitest测试工具（7个包）
5. ✅ [05-types-support.md](05-types-support.md) - TypeScript类型支持（2个包）
6. ✅ [06-quality-tools.md](06-quality-tools.md) - Stylelint代码质量（1个包）
7. ✅ [07-state-management.md](07-state-management.md) - Pinia状态管理（3个包）

**已覆盖依赖包数量**：30个（全覆盖）

---

*文档生成时间：2026-05-07*
*uni-app核心：Vite插件 + 小程序工具 + TailwindCSS适配*