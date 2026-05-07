# basic-form 基础表单

## 组件介绍

基础表单组件,支持动态字段配置,适用于用户注册、信息编辑、数据提交等场景。

**功能特点:**
- 动态字段配置,无需硬编码表单字段
- 自动初始化表单数据
- 支持提交和取消操作
- 使用 TailwindCSS 样式

**适用场景:**
- 用户注册/登录表单
- 信息编辑表单
- 数据提交表单
- 设置表单

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| title | String | '表单' | 否 | 表单标题 |
| fields | Array | `[{key: 'name', label: '名称', placeholder: '请输入'}]` | 否 | 表单字段配置数组 |
| showCancel | Boolean | true | 否 | 是否显示取消按钮 |

**fields 数组结构:**

| 字段 | 类型 | 说明 |
|------|------|------|
| key | String | 字段键名,用于数据提交 |
| label | String | 字段标签文本 |
| type | String | 输入类型(可选,默认text) |
| placeholder | String | 输入提示文本 |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| submit | formData(Object) | 提交表单时触发,参数为表单数据对象 |
| cancel | - | 点击取消按钮时触发 |

## 使用示例

### 基础用法

```vue
<template>
  <basic-form
    title="用户注册"
    :fields="userFields"
    @submit="onSubmit"
    @cancel="onCancel"
  />
</template>

<script setup>
import { ref } from 'vue'

const userFields = ref([
  { key: 'username', label: '用户名', placeholder: '请输入用户名' },
  { key: 'email', label: '邮箱', type: 'email', placeholder: '请输入邮箱' },
  { key: 'phone', label: '手机号', type: 'number', placeholder: '请输入手机号' }
])

const onSubmit = (formData) => {
  console.log('提交数据:', formData)
  // formData: { username: '...', email: '...', phone: '...' }
}

const onCancel = () => {
  console.log('取消提交')
}
</script>
```

### 完整示例

```vue
<template>
  <view class="min-h-screen">
    <basic-form
      title="商品信息"
      :fields="productFields"
      :show-cancel="true"
      @submit="handleSubmit"
      @cancel="handleCancel"
    />
  </view>
</template>

<script setup>
import { ref } from 'vue'

const productFields = ref([
  { key: 'name', label: '商品名称', placeholder: '请输入商品名称' },
  { key: 'price', label: '价格', type: 'number', placeholder: '请输入价格' },
  { key: 'stock', label: '库存', type: 'number', placeholder: '请输入库存数量' },
  { key: 'description', label: '描述', placeholder: '请输入商品描述' }
])

const handleSubmit = async (formData) => {
  try {
    // 调用API提交数据
    const result = await createProduct(formData)
    uni.showToast({ title: '提交成功', icon: 'success' })
  } catch (err) {
    uni.showToast({ title: '提交失败', icon: 'error' })
  }
}

const handleCancel = () => {
  uni.navigateBack()
}
</script>
```

## 定制指南

### 常见修改点

1. **字段配置**: 修改 `fields` 数组添加/删除字段
2. **样式调整**: 修改 TailwindCSS 类名调整表单样式
3. **字段类型**: 支持更多输入类型(text/number/email/password等)
4. **验证逻辑**: 在 submit 事件中添加表单验证

### 代码复制路径

```bash
cp src/components/templates/form/basic-form.vue src/pages/your-page.vue
```

### 高级定制

**添加字段验证:**

```vue
<script setup>
const handleSubmit = (formData) => {
  // 添加验证逻辑
  if (!formData.username) {
    uni.showToast({ title: '请输入用户名', icon: 'error' })
    return
  }

  if (!formData.email.includes('@')) {
    uni.showToast({ title: '邮箱格式错误', icon: 'error' })
    return
  }

  // 验证通过后提交
  submitForm(formData)
}
</script>
```

**自定义样式:**

修改模板中的 TailwindCSS 类名:
- `bg-gray-50` → 背景色
- `bg-white` → 表单卡片背景
- `border-gray-300` → 边框颜色
- `bg-blue-500` → 提交按钮颜色

## 注意事项

1. **字段初始化**: 组件会自动初始化所有字段为空字符串
2. **数据绑定**: 使用 `v-model` 双向绑定,数据实时同步
3. **必填字段**: 如需必填验证,请在 submit 事件中自行处理
4. **复杂表单**: 对于复杂表单场景,建议复制模板代码并直接修改

## 相关组件

- [search-form](./search-form.md) - 搜索表单
- [basic-dialog](../dialog/basic-dialog.md) - 弹窗容器

## 返回

[返回组件概览](../README.md)