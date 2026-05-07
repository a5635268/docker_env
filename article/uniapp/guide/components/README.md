# 组件模板使用说明

## 设计理念

本项目的组件是**代码模板**而非封装好的组件库。

这意味着:
- 没有npm安装,没有组件注册
- 直接复制模板代码到你的页面
- 自由修改,无需考虑组件接口兼容

## 使用方式

```bash
# 1. 复制模板
cp src/components/templates/{category}/{component}.vue src/pages/{your-page}.vue

# 2. 修改模板代码,适配业务需求

# 3. 在pages.json中注册页面
```

## 模板分类

### 表单类

| 组件 | 说明 | 详细文档 |
|------|------|----------|
| basic-form | 基础表单,支持动态字段配置 | [查看详情](./form/basic-form.md) |
| search-form | 搜索表单,支持关键词和筛选 | [查看详情](./form/search-form.md) |

### 列表类

| 组件 | 说明 | 详细文档 |
|------|------|----------|
| basic-list | 基础列表,分页加载 | [查看详情](./list/basic-list.md) |
| infinite-list | 无限滚动,下拉刷新 | [查看详情](./list/infinite-list.md) |
| card-list | 卡片网格,多列展示 | [查看详情](./list/card-list.md) |

### 弹窗类

| 组件 | 说明 | 详细文档 |
|------|------|----------|
| basic-dialog | 基础弹窗,多位置支持 | [查看详情](./dialog/basic-dialog.md) |
| confirm-dialog | 确认对话框 | [查看详情](./dialog/confirm-dialog.md) |

### 布局类

| 组件 | 说明 | 详细文档 |
|------|------|----------|
| page-layout | 标准页面布局 | [查看详情](./layout/page-layout.md) |
| tab-layout | Tab切换布局 | [查看详情](./layout/tab-layout.md) |

## 快速选择指南

### 按场景选择

**表单场景:**
- 用户注册/编辑 → [basic-form](./form/basic-form.md)
- 搜索页面 → [search-form](./form/search-form.md)

**列表场景:**
- 后台管理列表 → [basic-list](./list/basic-list.md) (传统分页)
- 商品/内容流 → [infinite-list](./list/infinite-list.md) (无限滚动)
- 商品展示/图库 → [card-list](./list/card-list.md) (卡片网格)

**弹窗场景:**
- 复杂内容展示 → [basic-dialog](./dialog/basic-dialog.md)
- 确认操作提示 → [confirm-dialog](./dialog/confirm-dialog.md)

**布局场景:**
- 标准详情页 → [page-layout](./layout/page-layout.md)
- 多标签内容 → [tab-layout](./layout/tab-layout.md)

## 定制指南

所有模板使用 TailwindCSS,无需额外CSS文件。

模板中的注释标注了"可定制"区域,这些是常见的修改点:

- 表单字段配置
- 列表项渲染
- 弹窗内容
- 按钮和交互

## 保持轻量

不引入额外依赖,模板代码可以直接在页面中修改。

## 下一步

- 选择合适的组件模板
- 查看详细文档了解参数和用法
- 复制模板到项目并定制