# 代码质量工具

> CSS/样式代码规范检查和自动修复

---

本文档涵盖项目中的代码质量相关依赖包，确保样式代码符合规范。

**包含包数量**：1个

---

## @icebreakers/stylelint-config@^1.2.5

> Stylelint 共享配置，提供 CSS/SCSS 代码规范检查规则

### 📦 基础信息

- **当前版本**：^1.2.5
- **安装命令**：
  ```bash
  pnpm add -D @icebreakers/stylelint-config stylelint
  ```
- **官方文档**：https://github.com/icebreaker/stylelint-config
- **GitHub**：https://github.com/icebreaker/stylelint-config

### 🎯 选择理由

**为什么选择 @icebreakers/stylelint-config？**

共享配置带来的优势：

1. **开箱即用**：预设规则集，无需逐条配置
2. **最佳实践**：社区验证的 CSS 规范
3. **统一标准**：团队协作时统一代码风格
4. **自动修复**：支持 stylelint --fix 自动修复问题

**对比分析**：

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **共享配置** | 快速集成、维护简单、团队统一 | 可能需要局部调整 | 中大型项目、团队协作 |
| **自定义配置** | 针对性强、完全可控 | 配置复杂、维护成本高 | 特殊需求项目 |
| **stylelint-config-standard** | 官方标准、广泛使用 | 可能过于严格 | 通用项目 |

**项目决策**：选择 @icebreakers/stylelint-config 因为：
- TailwindCSS + uni-app 需要特定规则配置
- 共享配置降低维护成本
- 支持自动修复，提高开发效率

### 💡 实际案例

**在本项目中的使用**：

[stylelint.config.mjs](../../stylelint.config.mjs) 极简配置：

```javascript
import { icebreaker } from "@icebreakers/stylelint-config";

export default icebreaker();
```

**配置特点**：

1. **零配置**：直接使用预设，无需额外规则
2. **TailwindCSS兼容**：预设已适配原子化CSS
3. **uni-app适配**：支持小程序样式语法

**集成方式**：

项目中可能通过以下方式使用：

```bash
# 手动检查
pnpm stylelint "src/**/*.{css,scss,vue}"

# 自动修复
pnpm stylelint "src/**/*.{css,scss,vue}" --fix

# Git hooks（需配置 husky）
# 提交前自动检查样式代码
```

**常见使用场景**：

1. **开发阶段**：编辑器集成 Stylelint 插件，实时提示
2. **提交检查**：Git hooks 自动检查样式规范
3. **CI/CD**：构建流程中检查样式代码质量
4. **代码审查**：PR Review 时自动检查

### ⚠️ 最佳实践

**常见问题及解决**：

1. **TailwindCSS 类名过长被警告**
   - **原因**：默认规则对行长度有限制
   - **解决**：在配置中禁用或调整规则

   ```javascript
   export default icebreaker({
     rules: {
       'max-line-length': null  // 禁用行长度检查
     }
   })
   ```

2. **uni-app 条件编译语法报错**
   - **原因**：条件编译注释（`#ifdef`）可能被误判
   - **解决**：配置允许特定注释语法

   ```javascript
   export default icebreaker({
     rules: {
       'comment-whitespace-inside': null
     }
   })
   ```

3. **与 Prettier 规则冲突**
   - **原因**：Stylelint 和 Prettier 某些规则重叠
   - **解决**：使用 stylelint-config-prettier 禁用冲突规则

   ```bash
   pnpm add -D stylelint-config-prettier
   ```

   ```javascript
   export default icebreaker({
     extends: ['@icebreakers/stylelint-config', 'stylelint-config-prettier']
   })
   ```

**性能优化建议**：

- **忽略文件**：通过 `.stylelintignore` 排除无需检查的文件

   ```
   node_modules/
   dist/
   coverage/
   *.min.css
   ```

- **增量检查**：仅在 CI 中检查修改的文件

   ```bash
   # 仅检查最近提交的文件
   pnpm stylelint $(git diff --name-only --diff-filter=d HEAD | grep -E '\.(css|scss|vue)$')
   ```

**注意事项**：

- TailwindCSS 原子类可能导致行过长，建议禁用 `max-line-length`
- uni-app 条件编译可能影响某些规则，需要针对性配置
- 建议配置编辑器插件（VS Code Stylelint）实时提示

---

## Stylelint 集成建议

### 编辑器集成

**VS Code 配置**：

```json
{
  "stylelint.validate": ["css", "scss", "vue"],
  "stylelint.autoFixOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.stylelint": true
  }
}
```

### Git Hooks 集成

**Husky + lint-staged 配置**（package.json）：

```json
{
  "scripts": {
    "lint:style": "stylelint \"src/**/*.{css,scss,vue}\" --fix"
  },
  "lint-staged": {
    "*.{css,scss,vue}": ["stylelint --fix", "git add"]
  }
}
```

### CI/CD 集成

**GitHub Actions 示例**：

```yaml
name: Stylelint Check
on: [push, pull_request]
jobs:
  stylelint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: pnpm install
      - run: pnpm stylelint "src/**/*.{css,scss,vue}"
```

---

## 代码质量体系总结

### 样式代码规范覆盖

| 工具 | 检查范围 | 说明 |
|------|---------|------|
| Stylelint | CSS/SCSS/Vue样式 | 样式语法、命名、格式 |
| TailwindCSS | 厽子类 | 由TailwindCSS自身保证 |
| TypeScript | 类型安全 | 由TS编译器检查 |
| ESLint（可选） | JavaScript/TypeScript | JS/TS代码规范（未在本项目中） |

### 建议的完整质量体系

为构建完整的代码质量保障体系，建议添加：

1. **ESLint**：JavaScript/TypeScript 代码规范
2. **Prettier**：代码格式化统一
3. **Husky**：Git hooks 自动检查
4. **lint-staged**：增量检查优化

---

*文档生成时间：2026-05-07*