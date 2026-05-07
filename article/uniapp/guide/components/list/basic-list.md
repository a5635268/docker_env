# basic-list 基础列表

## 组件介绍

基础列表组件,支持手动分页加载,适用于后台管理列表、数据查询结果等传统分页场景。

**功能特点:**
- 分页加载机制
- 加载状态展示
- 空数据提示
- 自定义列表项渲染
- 点击加载更多按钮

**适用场景:**
- 后台管理系统列表
- 数据查询结果展示
- 订单/用户管理等传统列表
- 不需要无限滚动的列表

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| title | String | '列表' | 否 | 列表标题 |
| loadData | Function | - | 是 | 数据加载函数 |

**loadData 函数签名:**

```javascript
loadData({ page }) => { list: Array }
```

**返回数据结构:**

| 字段 | 类型 | 说明 |
|------|------|------|
| list | Array | 列表数据数组,每项需包含 `{id, title, description}` |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| item-click | item(Object) | 点击列表项时触发 |

## Slots 插槽

| 插槽名 | 参数 | 说明 |
|--------|------|------|
| default | item(Object) | 自定义列表项渲染 |
| header-action | - | 头部右侧操作区域 |

## 使用示例

### 基础用法

```vue
<template>
  <basic-list
    title="用户列表"
    :load-data="loadUsers"
    @item-click="onItemClick"
  />
</template>

<script setup>
const loadUsers = async ({ page }) => {
  // 调用API获取用户列表
  const result = await getUserList({ page, pageSize: 10 })
  return {
    list: result.data.list // 返回 {list: [...]}
  }
}

const onItemClick = (item) => {
  console.log('点击用户:', item)
  uni.navigateTo({ url: `/pages/user/detail?id=${item.id}` })
}
</script>
```

### 自定义列表项渲染

```vue
<template>
  <basic-list
    title="订单列表"
    :load-data="loadOrders"
    @item-click="onOrderClick"
  >
    <!-- 自定义列表项 -->
    <template #default="{ item }">
      <view class="flex justify-between items-center">
        <view>
          <text class="font-bold">订单号: {{ item.orderNo }}</text>
          <text class="text-gray-500 text-sm">¥{{ item.amount }}</text>
        </view>
        <text class="text-blue-500">{{ item.status }}</text>
      </view>
    </template>
  </basic-list>
</template>

<script setup>
const loadOrders = async ({ page }) => {
  const result = await getOrders({ page })
  return {
    list: result.data.map(order => ({
      id: order.id,
      orderNo: order.order_no,
      amount: order.amount,
      status: order.status_text
    }))
  }
}

const onOrderClick = (item) => {
  uni.navigateTo({ url: `/pages/order/detail?id=${item.id}` })
}
</script>
```

### 完整示例(带头部操作)

```vue
<template>
  <view class="min-h-screen">
    <basic-list
      title="商品列表"
      :load-data="loadProducts"
      @item-click="onProductClick"
    >
      <!-- 头部右侧操作 -->
      <template #header-action>
        <button class="text-blue-500 text-sm" @click="showFilters">
          筛选
        </button>
      </template>

      <!-- 自定义列表项 -->
      <template #default="{ item }">
        <view class="flex items-center gap-2">
          <image :src="item.image" class="w-16 h-16 rounded" />
          <view class="flex-1">
            <text class="font-bold">{{ item.name }}</text>
            <text class="text-gray-500 text-sm">库存: {{ item.stock }}</text>
          </view>
          <text class="text-red-500 font-bold">¥{{ item.price }}</text>
        </view>
      </template>
    </basic-list>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const filters = ref({})

const loadProducts = async ({ page }) => {
  const result = await getProducts({
    page,
    pageSize: 10,
    ...filters.value
  })

  return {
    list: result.data.map(p => ({
      id: p.id,
      name: p.name,
      price: p.price,
      stock: p.stock,
      image: p.image_url
    }))
  }
}

const onProductClick = (item) => {
  uni.navigateTo({ url: `/pages/product/detail?id=${item.id}` })
}

const showFilters = () => {
  // 显示筛选对话框
}
</script>
```

## 定制指南

### 常见修改点

1. **列表项渲染**: 使用 default slot 自定义列表项样式
2. **分页逻辑**: loadData 函数支持 page 参数,默认每页10条
3. **头部操作**: 使用 header-action slot 添加筛选/排序按钮
4. **加载判断**: hasMore 根据 newList.length >= 10 判断

### 代码复制路径

```bash
cp src/components/templates/list/basic-list.vue src/pages/your-page.vue
```

### 高级定制

**添加搜索功能:**

```vue
<template>
  <view>
    <search-form @search="handleSearch" />
    <basic-list :load-data="loadData" ref="listRef" />
  </view>
</template>

<script setup>
import { ref } from 'vue'

const listRef = ref(null)
const searchParams = ref({})

const handleSearch = (params) => {
  searchParams.value = params
  // 手动触发列表刷新
  listRef.value?.loadList(true)
}

const loadData = async ({ page }) => {
  return await getProducts({ page, ...searchParams.value })
}
</script>
```

**自定义加载判断:**

修改源代码中的 hasMore 判断逻辑:

```vue
<script setup>
// 修改判断条件为根据API返回的total字段
const loadList = async (reset = false) => {
  const result = await props.loadData({ page: page.value })

  // 使用API返回的total字段判断
  hasMore.value = list.value.length < result.total
}
</script>
```

## 注意事项

1. **数据格式**: loadData 必须返回 `{list: Array}` 格式
2. **分页判断**: 默认每页10条,可根据 newList.length >= 10 判断是否有更多
3. **加载状态**: loading 状态会自动管理,防止重复加载
4. **点击加载**: 不支持无限滚动,需点击"加载更多"按钮

## 相关组件

- [infinite-list](./infinite-list.md) - 无限滚动列表
- [card-list](./card-list.md) - 卡片网格列表
- [search-form](../form/search-form.md) - 搜索表单(配合使用)

## 返回

[返回组件概览](../README.md)