# infinite-list 无限滚动列表

## 组件介绍

无限滚动列表组件,支持下拉刷新和自动加载更多,适用于商品流、内容列表等需要无限滚动的场景。

**功能特点:**
- 下拉刷新机制
- 滚动到底部自动加载
- 加载状态智能管理
- 空数据和加载完成提示
- 自定义列表项渲染

**适用场景:**
- 商品/内容流列表
- 新闻资讯列表
- 社交动态流
- 需要无限滚动的移动端列表

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
  <infinite-list
    title="商品推荐"
    :load-data="loadProducts"
    @item-click="onItemClick"
  />
</template>

<script setup>
const loadProducts = async ({ page }) => {
  const result = await getRecommendProducts({ page, pageSize: 10 })
  return {
    list: result.data // 返回 {list: [...]}
  }
}

const onItemClick = (item) => {
  uni.navigateTo({ url: `/pages/product/detail?id=${item.id}` })
}
</script>
```

### 自定义列表项

```vue
<template>
  <infinite-list
    title="新闻资讯"
    :load-data="loadNews"
    @item-click="onNewsClick"
  >
    <template #default="{ item }">
      <view class="flex gap-2">
        <image :src="item.cover" class="w-20 h-20 rounded" mode="aspectFill" />
        <view class="flex-1">
          <text class="font-bold text-sm">{{ item.title }}</text>
          <text class="text-gray-500 text-xs mt-1">{{ item.summary }}</text>
          <text class="text-gray-400 text-xs mt-1">{{ item.date }}</text>
        </view>
      </view>
    </template>
  </infinite-list>
</template>

<script setup>
const loadNews = async ({ page }) => {
  const result = await getNews({ page })
  return {
    list: result.data.map(news => ({
      id: news.id,
      title: news.title,
      summary: news.summary,
      cover: news.cover_image,
      date: news.publish_date
    }))
  }
}

const onNewsClick = (item) => {
  uni.navigateTo({ url: `/pages/news/detail?id=${item.id}` })
}
</script>
```

### 完整示例(带下拉刷新)

```vue
<template>
  <view class="min-h-screen">
    <infinite-list
      title="社交动态"
      :load-data="loadFeeds"
      @item-click="onFeedClick"
    >
      <!-- 头部操作 -->
      <template #header-action>
        <button class="text-blue-500 text-sm" @click="publishFeed">
          发布
        </button>
      </template>

      <!-- 自定义列表项 -->
      <template #default="{ item }">
        <view class="flex flex-col gap-2">
          <view class="flex items-center gap-2">
            <image :src="item.avatar" class="w-10 h-10 rounded-full" />
            <view>
              <text class="font-bold">{{ item.userName }}</text>
              <text class="text-gray-400 text-xs">{{ item.time }}</text>
            </view>
          </view>
          <text class="text-gray-700">{{ item.content }}</text>
          <view v-if="item.images" class="flex gap-1">
            <image
              v-for="(img, i) in item.images"
              :key="i"
              :src="img"
              class="w-1/3 h-20 rounded"
              mode="aspectFill"
            />
          </view>
          <view class="flex justify-between text-gray-500 text-sm">
            <text>点赞 {{ item.likes }}</text>
            <text>评论 {{ item.comments }}</text>
          </view>
        </view>
      </template>
    </infinite-list>
  </view>
</template>

<script setup>
const loadFeeds = async ({ page }) => {
  const result = await getFeeds({ page })
  return {
    list: result.data.map(feed => ({
      id: feed.id,
      userName: feed.user_name,
      avatar: feed.avatar_url,
      content: feed.content,
      images: feed.images,
      time: feed.publish_time,
      likes: feed.like_count,
      comments: feed.comment_count
    }))
  }
}

const onFeedClick = (item) => {
  uni.navigateTo({ url: `/pages/feed/detail?id=${item.id}` })
}

const publishFeed = () => {
  uni.navigateTo({ url: '/pages/feed/publish' })
}
</script>
```

## 定制指南

### 常见修改点

1. **列表项渲染**: 使用 default slot 自定义渲染逻辑
2. **下拉刷新**: scroll-view 的 `refresher-enabled` 支持下拉刷新
3. **自动加载**: scroll-view 的 `@scrolltolower` 监听滚动到底部
4. **滚动高度**: 调整 `h-screen pb-16` 类名设置滚动区域高度

### 代码复制路径

```bash
cp src/components/templates/list/infinite-list.vue src/pages/your-page.vue
```

### 高级定制

**设置滚动高度:**

```vue
<template>
  <scroll-view
    scroll-y
    class="h-screen pb-16"  <!-- 修改为合适的高度 -->
    @scrolltolower="loadMore"
  >
  </scroll-view>
</template>
```

**性能优化:**

```vue
<script setup>
// 添加虚拟滚动或分页优化
const list = ref([])
const maxItems = 100 // 限制最大条数

const loadList = async (reset = false) => {
  const result = await props.loadData({ page: page.value })

  if (list.value.length >= maxItems) {
    // 删除旧数据,保留最新数据
    list.value = list.value.slice(-50)
  }

  list.value = [...list.value, ...result.list]
}
</script>
```

## 注意事项

1. **滚动高度**: scroll-view 必须设置固定高度才能触发 scrolltolower
2. **下拉刷新**: 使用 `refresher-enabled` 和 `@refresherrefresh` 实现
3. **防抖机制**: loading 状态会阻止重复加载
4. **性能考虑**: 长列表建议限制最大条数或使用虚拟滚动

## 相关组件

- [basic-list](./basic-list.md) - 基础分页列表
- [card-list](./card-list.md) - 卡片网格列表
- [search-form](../form/search-form.md) - 搜索表单

## 返回

[返回组件概览](../README.md)