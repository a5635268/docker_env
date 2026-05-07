# search-form 搜索表单

## 组件介绍

搜索表单组件,支持关键词搜索和多条件筛选,适用于商品搜索、内容检索、数据过滤等场景。

**功能特点:**
- 关键词搜索输入框
- 多条件筛选器支持
- 灵活的筛选项配置
- 搜索事件统一触发

**适用场景:**
- 商品搜索页面
- 内容检索页面
- 数据列表筛选
- 后台数据查询

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| placeholder | String | '请输入搜索关键词' | 否 | 搜索输入框提示文本 |
| filters | Array | `[]` | 否 | 筛选项配置数组 |

**filters 数组结构:**

| 字段 | 类型 | 说明 |
|------|------|------|
| key | String | 筛选项键名 |
| label | String | 筛选项标签文本 |
| options | Array | 筛选选项数组,每项包含 `{label, value}` |
| defaultLabel | String | 默认显示文本(可选,默认'全部') |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| search | `{keyword, ...filters}` | 搜索时触发,包含关键词和所有筛选项值 |

## 使用示例

### 基础用法

```vue
<template>
  <search-form
    placeholder="搜索商品名称"
    @search="onSearch"
  />
</template>

<script setup>
const onSearch = (searchData) => {
  console.log('搜索数据:', searchData)
  // searchData: { keyword: '用户输入的关键词' }
}
</script>
```

### 带筛选条件

```vue
<template>
  <search-form
    placeholder="搜索商品"
    :filters="productFilters"
    @search="onSearch"
  />
</template>

<script setup>
import { ref } from 'vue'

const productFilters = ref([
  {
    key: 'category',
    label: '分类',
    defaultLabel: '全分类',
    options: [
      { label: '电子产品', value: 'electronics' },
      { label: '服装', value: 'clothing' },
      { label: '食品', value: 'food' }
    ]
  },
  {
    key: 'priceRange',
    label: '价格',
    defaultLabel: '不限',
    options: [
      { label: '0-100', value: '0-100' },
      { label: '100-500', value: '100-500' },
      { label: '500+', value: '500+' }
    ]
  }
])

const onSearch = (searchData) => {
  console.log('搜索条件:', searchData)
  // searchData: { keyword: '手机', category: '电子产品', priceRange: '100-500' }
}
</script>
```

### 完整示例

```vue
<template>
  <view class="min-h-screen">
    <!-- 搜索表单 -->
    <search-form
      placeholder="搜索商品名称/品牌"
      :filters="filters"
      @search="handleSearch"
    />

    <!-- 搜索结果列表 -->
    <view class="p-4">
      <view v-for="item in searchResults" :key="item.id" class="mb-2">
        <text>{{ item.name }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const filters = ref([
  {
    key: 'category',
    label: '分类',
    options: [
      { label: '全部', value: '' },
      { label: '电子产品', value: 'electronics' },
      { label: '服装', value: 'clothing' }
    ]
  },
  {
    key: 'brand',
    label: '品牌',
    options: [
      { label: '全部', value: '' },
      { label: 'Apple', value: 'apple' },
      { label: '华为', value: 'huawei' }
    ]
  }
])

const searchResults = ref([])

const handleSearch = async (searchData) => {
  try {
    // 调用搜索API
    const result = await searchProducts(searchData)
    searchResults.value = result.list
  } catch (err) {
    uni.showToast({ title: '搜索失败', icon: 'error' })
  }
}
</script>
```

## 定制指南

### 常见修改点

1. **筛选配置**: 修改 `filters` 数组添加/删除筛选项
2. **样式调整**: 修改 TailwindCSS 类名调整样式
3. **搜索触发**: 支持按钮点击和键盘确认触发
4. **筛选交互**: 使用 picker 组件实现筛选选择

### 代码复制路径

```bash
cp src/components/templates/form/search-form.vue src/pages/your-page.vue
```

### 高级定制

**添加搜索防抖:**

```vue
<script setup>
import { ref } from 'vue'

const searchKeyword = ref('')
let searchTimer = null

const handleSearch = (searchData) => {
  // 清除之前的定时器
  if (searchTimer) clearTimeout(searchTimer)

  // 设置新的防抖定时器(500ms)
  searchTimer = setTimeout(() => {
    performSearch(searchData)
  }, 500)
}

const performSearch = async (searchData) => {
  const result = await searchProducts(searchData)
  // 处理搜索结果
}
</script>
```

**动态筛选项:**

```vue
<script setup>
import { ref, onMounted } from 'vue'

const filters = ref([])

onMounted(async () => {
  // 从API加载筛选项
  const categories = await getCategories()
  const brands = await getBrands()

  filters.value = [
    { key: 'category', label: '分类', options: categories },
    { key: 'brand', label: '品牌', options: brands }
  ]
})
</script>
```

## 注意事项

1. **筛选默认值**: 未选择时显示 `defaultLabel`,默认为'全部'
2. **搜索触发**: 点击搜索按钮或键盘确认都会触发 search 事件
3. **筛选数据**: 筛选项变化后需手动触发搜索才能更新结果
4. **数据格式**: search 事件返回的对象包含 keyword 和所有筛选项的 label 值

## 相关组件

- [basic-form](./basic-form.md) - 基础表单
- [basic-list](../list/basic-list.md) - 基础列表(配合搜索结果展示)

## 返回

[返回组件概览](../README.md)