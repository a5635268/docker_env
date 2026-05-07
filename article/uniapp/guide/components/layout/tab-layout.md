# tab-layout Tab切换布局

## 组件介绍

Tab切换布局组件,提供标签页切换功能,适用于多标签内容展示、分类信息查看、多功能页签等场景。

**功能特点:**
- 多Tab标签切换
- 自定义Tab配置
- 每个Tab独立内容区域
- 支持默认激活Tab
- Tab激活状态样式

**适用场景:**
- 商品详情页(规格/参数/评论)
- 用户中心(信息/订单/设置)
- 多功能页面(首页/分类/收藏)
- 分类内容展示

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| tabs | Array | `[{key: 'tab1', label: 'Tab 1'}, {key: 'tab2', label: 'Tab 2'}]` | 否 | Tab配置数组 |
| defaultTab | String | '' | 否 | 默认激活的Tab key(默认激活第一个) |

**tabs 数组结构:**

| 字段 | 类型 | 说明 |
|------|------|------|
| key | String | Tab键名,用于slot命名 |
| label | String | Tab标签文本 |

## Slots 插槽

| 插槽名 | 参数 | 说明 |
|--------|------|------|
| tab-{key} | activeTab(String) | 指定Tab的内容区域,key为tabs中的key值 |
| default | - | 默认内容区域(当没有tab-{key} slot时使用) |

## 使用示例

### 基础用法

```vue
<template>
  <tab-layout :tabs="tabs" default-tab="info">
    <!-- 商品信息Tab -->
    <template #tab-info>
      <view class="bg-white rounded-lg p-4">
        <text class="font-bold">商品名称</text>
        <text class="text-gray-600">详细描述信息...</text>
      </view>
    </template>

    <!-- 商品参数Tab -->
    <template #tab-spec>
      <view class="bg-white rounded-lg p-4">
        <text class="font-bold">规格参数</text>
        <text class="text-gray-600">尺寸: 10x20cm</text>
        <text class="text-gray-600">重量: 500g</text>
      </view>
    </template>
  </tab-layout>
</template>

<script setup>
import { ref } from 'vue'

const tabs = ref([
  { key: 'info', label: '商品信息' },
  { key: 'spec', label: '规格参数' }
])
</script>
```

### 多Tab内容切换

```vue
<template>
  <tab-layout :tabs="userTabs" default-tab="profile">
    <!-- 个人信息Tab -->
    <template #tab-profile>
      <view class="bg-white rounded-lg p-4 mb-4">
        <text class="font-bold mb-2 block">基本信息</text>
        <text class="text-gray-600">姓名: 张三</text>
        <text class="text-gray-600">邮箱: zhangsan@example.com</text>
      </view>
    </template>

    <!-- 我的订单Tab -->
    <template #tab-orders>
      <view
        v-for="order in orders"
        :key="order.id"
        class="bg-white rounded-lg p-4 mb-4"
      >
        <text class="font-bold">{{ order.orderNo }}</text>
        <text class="text-gray-600">{{ order.status }}</text>
      </view>
    </template>

    <!-- 设置Tab -->
    <template #tab-settings>
      <view class="bg-white rounded-lg p-4">
        <text class="font-bold mb-2 block">账户设置</text>
        <button class="text-blue-500 mb-2">修改密码</button>
        <button class="text-red-500">退出登录</button>
      </view>
    </template>
  </tab-layout>
</template>

<script setup>
import { ref } from 'vue'

const userTabs = ref([
  { key: 'profile', label: '个人信息' },
  { key: 'orders', label: '我的订单' },
  { key: 'settings', label: '设置' }
])

const orders = ref([
  { id: 1, orderNo: 'ORD-001', status: '已完成' },
  { id: 2, orderNo: 'ORD-002', status: '待支付' }
])
</script>
```

### 使用默认slot

```vue
<template>
  <tab-layout :tabs="categoryTabs">
    <!-- 默认内容区域(适用于简单场景) -->
    <view class="bg-white rounded-lg p-4">
      <text class="font-bold">当前分类内容</text>
      <text class="text-gray-600">根据activeTab动态显示不同内容</text>
    </view>
  </tab-layout>
</template>

<script setup>
import { ref } from 'vue'

const categoryTabs = ref([
  { key: 'all', label: '全部' },
  { key: 'electronics', label: '电子产品' },
  { key: 'clothing', label: '服装' }
])
</script>
```

### 完整示例(商品详情页)

```vue
<template>
  <view class="min-h-screen">
    <!-- 商品图片和基本信息 -->
    <view class="bg-white mb-4">
      <image :src="product.image" class="w-full h-48" mode="aspectFill" />
      <view class="p-4">
        <text class="font-bold text-lg">{{ product.name }}</text>
        <text class="text-red-500 font-bold text-xl">¥{{ product.price }}</text>
      </view>
    </view>

    <!-- Tab切换详情 -->
    <tab-layout :tabs="detailTabs" default-tab="detail">
      <!-- 商品详情Tab -->
      <template #tab-detail>
        <view class="bg-white rounded-lg p-4">
          <text class="font-bold mb-2 block">商品详情</text>
          <rich-text :nodes="product.detailHtml"></rich-text>
        </view>
      </template>

      <!-- 规格参数Tab -->
      <template #tab-spec>
        <view class="bg-white rounded-lg p-4">
          <text class="font-bold mb-2 block">规格参数</text>
          <view
            v-for="spec in product.specs"
            :key="spec.label"
            class="flex justify-between mb-1"
          >
            <text class="text-gray-600">{{ spec.label }}</text>
            <text>{{ spec.value }}</text>
          </view>
        </view>
      </template>

      <!-- 用户评论Tab -->
      <template #tab-comments>
        <view class="flex flex-col gap-4">
          <view
            v-for="comment in comments"
            :key="comment.id"
            class="bg-white rounded-lg p-4"
          >
            <view class="flex items-center gap-2 mb-2">
              <image :src="comment.avatar" class="w-8 h-8 rounded-full" />
              <text class="font-bold">{{ comment.userName }}</text>
              <text class="text-gray-400 text-xs">{{ comment.date }}</text>
            </view>
            <text class="text-gray-700">{{ comment.content }}</text>
          </view>
        </view>
      </template>
    </tab-layout>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const product = ref({
  name: '智能手机',
  price: 2999,
  image: 'https://example.com/product.jpg',
  detailHtml: '<p>详细描述...</p>',
  specs: [
    { label: '屏幕', value: '6.5英寸' },
    { label: '内存', value: '8GB' },
    { label: '存储', value: '128GB' }
  ]
})

const detailTabs = ref([
  { key: 'detail', label: '商品详情' },
  { key: 'spec', label: '规格参数' },
  { key: 'comments', label: '用户评论' }
])

const comments = ref([
  {
    id: 1,
    userName: '用户A',
    avatar: '',
    date: '2024-01-01',
    content: '产品质量很好,值得购买'
  },
  {
    id: 2,
    userName: '用户B',
    avatar: '',
    date: '2024-01-02',
    content: '性价比高,推荐'
  }
])
</script>
```

## 定制指南

### 常见修改点

1. **Tab配置**: 修改 `tabs` 数组添加/删除Tab
2. **默认Tab**: 设置 `defaultTab` 指定默认激活的Tab
3. **Tab样式**: 修改 TailwindCSS 类名调整Tab样式
4. **Tab内容**: 使用 `tab-{key}` slot 定义每个Tab的内容

### 代码复制路径

```bash
cp src/components/templates/layout/tab-layout.vue src/pages/your-page.vue
```

### 高级定制

**自定义Tab样式:**

```vue
<template>
  <!-- 修改激活状态的样式 -->
  <view
    :class="activeTab === tab.key ? 'bg-blue-500 text-white' : 'text-gray-600'"
  >
  </view>
</template>
```

**动态Tab配置:**

```vue
<script setup>
import { ref, onMounted } from 'vue'

const tabs = ref([])

onMounted(async () => {
  // 从API加载Tab配置
  const categories = await getCategories()
  tabs.value = categories.map(cat => ({
    key: cat.id,
    label: cat.name
  }))
})
</script>
```

**Tab切换事件:**

```vue
<script setup>
import { ref, watch } from 'vue'

const activeTab = ref('')

// 监听Tab切换
watch(activeTab, (newTab) => {
  console.log('切换到:', newTab)
  // 可以在这里加载对应的Tab数据
})
</script>
```

## 注意事项

1. **slot命名**: Tab内容slot必须使用 `tab-{key}` 格式命名
2. **默认Tab**: 如不设置 defaultTab,默认激活第一个Tab
3. **Tab切换**: 点击Tab头部自动切换,无需手动处理
4. **内容管理**: 每个Tab内容独立管理,切换时不会丢失状态

## 相关组件

- [page-layout](./page-layout.md) - 标准页面布局
- [infinite-list](../list/infinite-list.md) - 无限滚动列表(配合Tab使用)

## 返回

[返回组件概览](../README.md)