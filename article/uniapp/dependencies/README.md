# 依赖包使用指南

> UniApp Scaffold 项目依赖包的完整使用指南

---

## 文档体系导航

本项目的依赖包文档按功能领域分为以下7个分类文档：

| 分类文档 | 包数量 | 主要内容 |
|---------|-------|---------|
| [01-build-tools.md](01-build-tools.md) | 2个 | Vite 构建工具、自动导入插件 |
| [02-uniapp-core.md](02-uniapp-core.md) | 7个 | uni-app 核心、小程序开发工具、TailwindCSS适配 |
| [03-styling-tools.md](03-styling-tools.md) | 8个 | TailwindCSS、图标系统、PostCSS、Sass |
| [04-testing-tools.md](04-testing-tools.md) | 7个 | Vitest测试框架、Vue测试工具、覆盖率、DOM环境 |
| [05-types-support.md](05-types-support.md) | 2个 | TypeScript、Node类型定义 |
| [06-quality-tools.md](06-quality-tools.md) | 1个 | Stylelint代码质量配置 |
| [07-state-management.md](07-state-management.md) | 3个 | Pinia、Vuex状态管理、测试工具 |

---

## 快速索引表

### 构建工具（Build Tools）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| vite | 5.4.21 | [01-build-tools](01-build-tools.md) | 下一代前端构建工具，快速冷启动、即时热更新 |
| unplugin-auto-import | 20.3.0 | [01-build-tools](01-build-tools.md) | 自动导入API，无需手动import |

### uni-app 核心（UniApp Core）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| @dcloudio/types | ^3.4.8 | [02-uniapp-core](02-uniapp-core.md) | uni-app TypeScript类型定义 |
| @dcloudio/uni-automator | 3.0.0-4080720251210001 | [02-uniapp-core](02-uniapp-core.md) | uni-app自动化测试工具 |
| @dcloudio/uni-cli-shared | 3.0.0-4080720251210001 | [02-uniapp-core](02-uniapp-core.md) | uni-app CLI共享工具库 |
| @dcloudio/uni-stacktracey | 3.0.0-4080720251210001 | [02-uniapp-core](02-uniapp-core.md) | uni-app错误堆栈追踪工具 |
| @dcloudio/vite-plugin-uni | 3.0.0-4080720251210001 | [02-uniapp-core](02-uniapp-core.md) | uni-app Vite插件，核心构建支持 |
| weapp-ide-cli | ^5.0.1 | [02-uniapp-core](02-uniapp-core.md) | 微信开发者工具命令行接口 |
| weapp-tailwindcss | ^4.9.8 | [02-uniapp-core](02-uniapp-core.md) | 小程序 TailwindCSS 适配器 |

### 样式工具（Styling Tools）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| tailwindcss | ^3.4.19 | [03-styling-tools](03-styling-tools.md) | 原子化CSS框架，快速构建UI |
| @egoist/tailwindcss-icons | ^1.9.2 | [03-styling-tools](03-styling-tools.md) | TailwindCSS图标插件，Iconify集成 |
| @iconify-json/mdi | ^1.2.3 | [03-styling-tools](03-styling-tools.md) | Material Design Icons图标集 |
| @iconify-json/svg-spinners | ^1.2.4 | [03-styling-tools](03-styling-tools.md) | SVG加载动画图标集 |
| autoprefixer | ^10.4.24 | [03-styling-tools](03-styling-tools.md) | 自动添加CSS浏览器前缀 |
| postcss | ^8.5.6 | [03-styling-tools](03-styling-tools.md) | CSS转换工具，TailwindCSS依赖 |
| sass | ^1.97.3 | [03-styling-tools](03-styling-tools.md) | CSS预处理器，支持嵌套和变量 |

### 测试工具（Testing Tools）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| vitest | ^2.1.9 | [04-testing-tools](04-testing-tools.md) | Vite原生测试框架，快速单元测试 |
| @vitest/coverage-v8 | ^2.1.9 | [04-testing-tools](04-testing-tools.md) | Vitest覆盖率工具，V8引擎 |
| @vue/test-utils | ^2.4.10 | [04-testing-tools](04-testing-tools.md) | Vue官方测试工具库 |
| @pinia/testing | ^1.0.3 | [07-state-management](07-state-management.md) | Pinia状态管理测试工具 |
| happy-dom | ^20.9.0 | [04-testing-tools](04-testing-tools.md) | 轻量级DOM环境，测试运行器 |
| @vue/runtime-core | ^3.5.27 | [04-testing-tools](04-testing-tools.md) | Vue运行时核心，测试类型支持 |

### 类型支持（Types Support）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| typescript | ^5.9.3 | [05-types-support](05-types-support.md) | TypeScript语言支持，类型安全 |
| @types/node | ^24.10.1 | [05-types-support](05-types-support.md) | Node.js类型定义 |

### 代码质量（Code Quality）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| @icebreakers/stylelint-config | ^1.2.5 | [06-quality-tools](06-quality-tools.md) | Stylelint共享配置，CSS规范检查 |

### 状态管理（State Management）

| 包名 | 版本 | 分类文档 | 用途说明 |
|------|------|---------|---------|
| pinia | 2.2.4 | [07-state-management](07-state-management.md) | Vue 3推荐状态管理库（生产依赖） |
| vuex | 4.0.2 | [07-state-management](07-state-management.md) | Vue状态管理库（生产依赖） |
| @pinia/testing | ^1.0.3 | [07-state-management](07-state-management.md) | Pinia测试工具 |

---

## 依赖包统计

**总计**：30个依赖包

**分类统计**：
- 构建工具：2个
- uni-app核心：7个
- 样式工具：8个（包含跨领域包）
- 测试工具：7个（包含跨领域包）
- 类型支持：2个
- 代码质量：1个
- 状态管理：3个

**依赖类型统计**：
- devDependencies：27个
- dependencies：3个（Pinia、Vuex、Vue相关）

---

## 使用建议

### 如何查阅文档

1. **快速定位**：根据包名在快速索引表中查找对应的分类文档
2. **系统学习**：按分类文档顺序阅读，理解同一领域工具的关联性
3. **问题解决**：直接查看"最佳实践"模块，快速找到解决方案

### 文档内容结构

每个依赖包文档包含四个核心模块：

1. **📦 基础信息**：版本、安装命令、官方文档链接
2. **🎯 选择理由**：为什么选择这个包、与其他方案的对比
3. **💡 实际案例**：在本项目中的配置示例和使用场景
4. **⚠️ 最佳实践**：常见问题解决方案、性能优化建议

### 推荐阅读路径

**新手开发者**：
- 先读 [01-build-tools.md](01-build-tools.md) 了解构建系统
- 再读 [02-uniapp-core.md](02-uniapp-core.md) 理解uni-app框架
- 然后按需要查阅其他分类

**中级开发者**（推荐）：
- 根据当前任务直接查阅相关分类文档
- 重点关注"实际案例"和"最佳实践"模块
- 参考快速索引表快速定位

**高级开发者**：
- 使用快速索引表直接定位需要的包
- 重点查阅版本信息和最佳实践
- 参考配置示例快速集成

---

## 跨领域包说明

部分包涉及多个技术领域，文档采用主副分类策略：

| 包名 | 主分类文档 | 副分类文档 | 说明 |
|------|----------|----------|------|
| weapp-tailwindcss | [02-uniapp-core](02-uniapp-core.md) | [03-styling-tools](03-styling-tools.md) | 主分类包含完整文档，副分类仅说明样式集成 |
| @pinia/testing | [07-state-management](07-state-management.md) | [04-testing-tools](04-testing-tools.md) | 主分类包含完整文档，副分类仅说明测试集成 |

---

## 文档维护

### 更新触发条件

当以下情况发生时，需更新本文档体系：

1. `package.json` 依赖版本升级
2. 新增或删除依赖包
3. 项目配置文件变更
4. 发现新的最佳实践

### 维护步骤

1. 更新 `README.md` 的快速索引表（版本号）
2. 更新对应分类文档的包内容
3. 检查配置示例是否与项目文件一致
4. 补充新发现的最佳实践

---

## 相关链接

- [项目主文档](../../CLAUDE.md)
- [package.json](../../package.json)
- [vite.config.ts](../../vite.config.ts)
- [tailwind.config.ts](../../tailwind.config.ts)

---

*文档生成时间：2026-05-07*
*基于 package.json 依赖包分析*