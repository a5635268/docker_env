# page-layout 标准页面布局

## 组件介绍

标准页面布局组件,提供完整的页面结构框架,包含头部导航、内容区域和底部操作区域,适用于详情页、编辑页、设置页等标准页面场景。

**功能特点:**
- 固定头部导航栏
- 可定制头部左右操作区域
- 内容区域自动填充
- 固定底部操作区域
- 返回按钮、标题、右侧操作的标准布局

**适用场景:**
- 详情页面
- 编辑页面
- 设置页面
- 表单页面
- 需要固定底部按钮的页面

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| title | String | '页面' | 否 | 页面标题文本 |

## Slots 插槽

| 插槽名 | 参数 | 说明 |
|--------|------|------|
| left | - | 头部左侧区域(常用于返回按钮) |
| right | - | 头部右侧区域(常用于操作按钮) |
| content | - | 页面主内容区域 |
| footer | - | 底部固定区域(常用于提交按钮) |

## 使用示例

### 基础用法

```vue
<template>
  <page-layout title="用户详情">
    <!-- 内容区域 -->
    <template #content>
      <view class="flex flex-col gap-4">
        <view class="bg-white rounded-lg p-4">
          <text class="font-bold">基本信息</text>
          <text class="text-gray-600">姓名: 张三</text>
          <text class="text-gray-600">邮箱: zhangsan@example.com</text>
        </view>

        <view class="bg-white rounded-lg p-4">
          <text class="font-bold">账户信息</text>
          <text class="text-gray-600">注册时间: 2024-01-01</text>
        </view>
      </view>
    </template>
  </page-layout>
</template>
```

### 带返回按钮和操作按钮

```vue
<template>
  <page-layout title="商品详情">
    <!-- 左侧返回按钮 -->
    <template #left>
      <text class="text-gray-600" @click="goBack">← 返回</text>
    </template>

    <!-- 右侧操作按钮 -->
    <template #right>
      <text class="text-blue-500" @click="shareProduct">分享</text>
    </template>

    <!-- 内容区域 -->
    <template #content>
      <view class="bg-white rounded-lg p-4">
        <image :src="product.image" class="w-full h-48 rounded mb-2" />
        <text class="font-bold text-lg">{{ product.name }}</text>
        <text class="text-red-500 font-bold">¥{{ product.price }}</text>
      </view>
    </template>
  </page-layout>
</template>

<script setup>
import { ref } from 'vue'

const product = ref({
  image: 'https://example.com/product.jpg',
  name: '商品名称',
  price: 99.99
})

const goBack = () => {
  uni.navigateBack()
}

const shareProduct = () => {
  uni.share({
    title: product.value.name,
    path: '/pages/product/detail'
  })
}
</script>
```

### 带底部提交按钮

```vue
<template>
  <page-layout title="编辑信息">
    <!-- 左侧返回按钮 -->
    <template #left>
      <text class="text-gray-600" @click="goBack">取消</text>
    </template>

    <!-- 内容区域 -->
    <template #content>
      <view class="bg-white rounded-lg p-4">
        <view class="mb-3">
          <text class="text-gray-600 mb-1 block">姓名</text>
          <input v-model="formData.name" class="border rounded p-2 w-full" />
        </view>
        <view class="mb-3">
          <text class="text-gray-600 mb-1 block">邮箱</text>
          <input v-model="formData.email" type="email" class="border rounded p-2 w-full" />
        </view>
      </view>
    </template>

    <!-- 底部提交按钮 -->
    <template #footer>
      <button
        class="bg-blue-500 text-white py-2 rounded"
        @click="handleSubmit"
      >
        保存
      </button>
    </template>
  </page-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'

const formData = reactive({
  name: '',
  email: ''
})

const goBack = () => {
  uni.navigateBack()
}

const handleSubmit = async () => {
  try {
    await updateUserInfo(formData)
    uni.showToast({ title: '保存成功', icon: 'success' })
    uni.navigateBack()
  } catch (err) {
    uni.showToast({ title: '保存失败', icon: 'error' })
  }
}
</script>
```

### 完整示例(详情页)

```vue
<template>
  <page-layout :title="pageTitle">
    <!-- 左侧返回 -->
    <template #left>
      <view class="flex items-center">
        <text class="text-gray-600" @click="goBack">←</text>
      </view>
    </template>

    <!-- 右侧操作 -->
    <template #right>
      <view class="flex gap-2">
        <text class="text-blue-500" @click="editOrder">编辑</text>
        <text class="text-red-500" @click="deleteOrder">删除</text>
      </view>
    </template>

    <!-- 内容区域 -->
    <template #content>
      <!-- 订单信息 -->
      <view class="bg-white rounded-lg p-4 mb-4">
        <text class="font-bold mb-2 block">订单信息</text>
        <view class="flex justify-between mb-1">
          <text class="text-gray-600">订单号</text>
          <text>{{ order.orderNo }}</text>
        </view>
        <view class="flex justify-between mb-1">
          <text class="text-gray-600">创建时间</text>
          <text>{{ order.createTime }}</text>
        </view>
        <view class="flex justify-between">
          <text class="text-gray-600">状态</text>
          <text class="text-blue-500">{{ order.statusText }}</text>
        </view>
      </view>

      <!-- 商品列表 -->
      <view class="bg-white rounded-lg p-4 mb-4">
        <text class="font-bold mb-2 block">商品列表</text>
        <view
          v-for="item in order.items"
          :key="item.id"
          class="flex items-center gap-2 mb-2"
        >
          <image :src="item.image" class="w-16 h-16 rounded" />
          <view class="flex-1">
            <text class="font-bold text-sm">{{ item.name }}</text>
            <text class="text-gray-500 text-xs">{{ item.quantity }}件</text>
          </view>
          <text class="text-red-500">¥{{ item.price }}</text>
        </view>
      </view>

      <!-- 总计 -->
      <view class="bg-white rounded-lg p-4">
        <view class="flex justify-between">
          <text class="font-bold">总计</text>
          <text class="text-red-500 font-bold text-lg">¥{{ order.totalAmount }}</text>
        </view>
      </view>
    </template>

    <!-- 底部操作 -->
    <template #footer>
      <view class="flex gap-2">
        <button
          class="flex-1 bg-gray-200 text-gray-700 py-2 rounded"
          @click="cancelOrder"
        >
          取消订单
        </button>
        <button
          class="flex-1 bg-blue-500 text-white py-2 rounded"
          @click="payOrder"
        >
          立即支付
        </button>
      </view>
    </template>
  </page-layout>
</template>

<script setup>
import { ref, computed } from 'vue'

const order = ref({
  orderNo: 'ORD-20240101-001',
  createTime: '2024-01-01 10:30',
  statusText: '待支付',
  totalAmount: 299.99,
  items: [
    { id: 1, name: '商品A', quantity: 2, price: 99.99, image: '' },
    { id: 2, name: '商品B', quantity: 1, price: 100, image: '' }
  ]
})

const pageTitle = computed(() => `订单 ${order.value.orderNo}`)

const goBack = () => uni.navigateBack()

const editOrder = () => {
  uni.navigateTo({ url: '/pages/order/edit' })
}

const deleteOrder = () => {
  uni.showModal({
    title: '确认删除',
    content: '是否删除该订单?',
    success: (res) => {
      if (res.confirm) {
        // 执行删除
      }
    }
  })
}

const cancelOrder = async () => {
  await cancelOrderApi()
  uni.showToast({ title: '订单已取消', icon: 'success' })
}

const payOrder = async () => {
  await payOrderApi()
  uni.showToast({ title: '支付成功', icon: 'success' })
}
</script>
```

## 定制指南

### 常见修改点

1. **头部样式**: 修改 TailwindCSS 类名调整头部样式
2. **返回按钮**: 在 left slot 中自定义返回按钮样式
3. **标题样式**: 修改标题文本样式和位置
4. **底部按钮**: 在 footer slot 中添加提交/操作按钮

### 代码复制路径

```bash
cp src/components/templates/layout/page-layout.vue src/pages/your-page.vue
```

### 高级定制

**隐藏底部区域:**

```vue
<template>
  <!-- 不使用 footer slot 时,底部区域不显示 -->
  <page-layout title="详情">
    <template #content>
      <!-- 内容 -->
    </template>
  </page-layout>
</template>
```

**自定义头部高度:**

```vue
<template>
  <view class="bg-white px-4 py-4 border-b border-gray-200">
    <!-- 修改 py-3 为 py-4 增加高度 -->
  </view>
</template>
```

**动态标题:**

```vue
<script setup>
import { computed } from 'vue'

const pageTitle = computed(() => {
  return editMode ? '编辑信息' : '查看详情'
})
</script>

<template>
  <page-layout :title="pageTitle">
  </page-layout>
</template>
```

## 注意事项

1. **固定头部**: 使用 `sticky top-0 z-10` 保持头部固定在顶部
2. **固定底部**: footer slot 使用 `fixed bottom-0` 固定在底部
3. **内容滚动**: 内容区域高度自动适配,长内容会自动滚动
4. **slot命名**: 必须使用 #content、#left、#right、#footer 等固定 slot 名称

## 相关组件

- [tab-layout](./tab-layout.md) - Tab切换布局
- [basic-form](../form/basic-form.md) - 表单组件(配合使用)

## 返回

[返回组件概览](../README.md)