# card-list 卡片网格列表

## 组件介绍

卡片网格列表组件,支持多列卡片布局,适用于商品展示、图片库、产品目录等需要卡片网格展示的场景。

**功能特点:**
- 多列网格布局
- 支持卡片图片
- 自定义卡片底部
- 卡片点击交互
- 灵活的列数配置

**适用场景:**
- 商品展示页面
- 图片/视频库
- 产品目录展示
- 卡片式内容列表

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| title | String | '卡片列表' | 否 | 列表标题 |
| columns | Number | 2 | 否 | 卡片列数(默认2列) |
| loadData | Function | - | 是 | 数据加载函数 |

**loadData 函数签名:**

```javascript
loadData({ page }) => { list: Array }
```

**返回数据结构:**

| 字段 | 类型 | 说明 |
|------|------|------|
| list | Array | 卡片数据数组,每项需包含 `{id, title, description, image, footer}` |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| item-click | item(Object) | 点击卡片时触发 |

## Slots 插槽

| 插槽名 | 参数 | 说明 |
|--------|------|------|
| card-footer | item(Object) | 自定义卡片底部内容 |

## 使用示例

### 基础用法(2列)

```vue
<template>
  <card-list
    title="商品展示"
    :load-data="loadProducts"
    @item-click="onProductClick"
  />
</template>

<script setup>
const loadProducts = async ({ page }) => {
  const result = await getProducts({ page })
  return {
    list: result.data.map(p => ({
      id: p.id,
      title: p.name,
      description: `¥${p.price}`,
      image: p.image_url
    }))
  }
}

const onProductClick = (item) => {
  uni.navigateTo({ url: `/pages/product/detail?id=${item.id}` })
}
</script>
```

### 3列卡片布局

```vue
<template>
  <card-list
    title="图片库"
    :columns="3"
    :load-data="loadImages"
    @item-click="onImageClick"
  >
    <!-- 自定义卡片底部 -->
    <template #card-footer="{ item }">
      <view class="flex justify-between text-xs">
        <text class="text-gray-500">{{ item.views }}次浏览</text>
        <text class="text-blue-500">下载</text>
      </view>
    </template>
  </card-list>
</template>

<script setup>
const loadImages = async ({ page }) => {
  const result = await getImages({ page })
  return {
    list: result.data.map(img => ({
      id: img.id,
      title: img.title,
      description: img.category,
      image: img.url,
      footer: true, // 显示底部
      views: img.view_count
    }))
  }
}

const onImageClick = (item) => {
  // 打开图片详情或预览
  uni.previewImage({
    urls: [item.image]
  })
}
</script>
```

### 完整示例(商品展示)

```vue
<template>
  <view class="min-h-screen">
    <card-list
      title="热销商品"
      :columns="2"
      :load-data="loadProducts"
      @item-click="onProductClick"
    >
      <!-- 自定义卡片底部 -->
      <template #card-footer="{ item }">
        <view class="flex flex-col gap-1">
          <view class="flex justify-between items-center">
            <text class="text-red-500 font-bold">¥{{ item.price }}</text>
            <text class="text-gray-400 text-xs">库存{{ item.stock }}</text>
          </view>
          <button class="text-blue-500 text-xs">立即购买</button>
        </view>
      </template>
    </card-list>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const loadProducts = async ({ page }) => {
  const result = await getHotProducts({ page })

  return {
    list: result.data.map(product => ({
      id: product.id,
      title: product.name,
      description: product.brand,
      image: product.cover_image,
      footer: true, // 显示底部信息
      price: product.price,
      stock: product.stock_count
    }))
  }
}

const onProductClick = (item) => {
  uni.navigateTo({
    url: `/pages/product/detail?id=${item.id}`
  })
}
</script>
```

### 4列图片网格

```vue
<template>
  <card-list
    title="相册"
    :columns="4"
    :load-data="loadPhotos"
    @item-click="onPhotoClick"
  />
</template>

<script setup>
const loadPhotos = async ({ page }) => {
  const result = await getPhotos({ page })
  return {
    list: result.data.map(photo => ({
      id: photo.id,
      title: '', // 图片可不显示标题
      image: photo.url
    }))
  }
}

const onPhotoClick = (item) => {
  uni.previewImage({
    urls: allPhotos.value,
    current: item.image
  })
}
</script>
```

## 定制指南

### 常见修改点

1. **列数调整**: 修改 `columns` prop 调整卡片列数(推荐2-4列)
2. **卡片样式**: 修改 TailwindCSS 类名调整卡片大小、间距
3. **图片显示**: 支持图片卡片,使用 `item.image` 字段
4. **卡片底部**: 使用 `card-footer` slot 添加价格、按钮等信息

### 代码复制路径

```bash
cp src/components/templates/list/card-list.vue src/pages/your-page.vue
```

### 高级定制

**调整卡片间距:**

```vue
<template>
  <!-- 修改 gap-2 为其他间距 -->
  <view class="flex flex-wrap px-2 gap-4">
  </view>
</template>
```

**设置卡片最小高度:**

```vue
<template>
  <view class="bg-white rounded-lg p-3 min-h-32">
    <!-- 添加 min-h-32 类名 -->
  </view>
</template>
```

**自适应列数(根据屏幕宽度):**

```vue
<script setup>
import { computed } from 'vue'

// 根据屏幕宽度动态计算列数
const screenWidth = uni.getSystemInfoSync().screenWidth

const columns = computed(() => {
  if (screenWidth < 375) return 2 // 小屏手机
  if (screenWidth < 768) return 3 // 大屏手机
  return 4 // 平板
})

// 计算卡片宽度
const cardWidth = computed(() => {
  const gap = 0.5 // rem
  return `calc(${100 / columns.value}% - ${gap}rem)`
})
</script>
```

## 注意事项

1. **列数限制**: 建议2-4列,过多列数会导致卡片过小
2. **图片加载**: 图片使用 `mode="aspectFill"` 自动裁剪适配
3. **卡片宽度**: 根据列数自动计算,公式: `calc(50% - 0.5rem)`
4. **数据格式**: item 必须包含 `id` 字段,`image` 和 `footer` 可选

## 相关组件

- [basic-list](./basic-list.md) - 基础分页列表
- [infinite-list](./infinite-list.md) - 无限滚动列表

## 返回

[返回组件概览](../README.md)