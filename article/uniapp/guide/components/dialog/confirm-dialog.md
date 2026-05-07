# confirm-dialog 确认对话框

## 组件介绍

确认对话框组件,用于简单的确认提示场景,支持确认和取消操作,适用于删除确认、提交确认、退出确认等场景。

**功能特点:**
- 简化的确认/取消对话框
- 自定义按钮文本
- 遮罩层关闭控制
- 简洁的对话框样式

**适用场景:**
- 删除操作确认
- 提交操作确认
- 退出/取消确认
- 重要操作提示

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| visible | Boolean | false | 否 | 是否显示对话框 |
| title | String | '提示' | 否 | 对话框标题 |
| content | String | '' | 否 | 对话框内容文本 |
| confirmText | String | '确定' | 否 | 确认按钮文本 |
| cancelText | String | '取消' | 否 | 取消按钮文本 |
| showCancel | Boolean | true | 否 | 是否显示取消按钮 |
| maskClosable | Boolean | false | 否 | 点击遮罩是否关闭 |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| confirm | - | 点击确认按钮时触发 |
| cancel | - | 点击取消按钮时触发 |
| close | - | 点击遮罩关闭时触发(需 maskClosable=true) |

## 使用示例

### 基础用法

```vue
<template>
  <view>
    <button @click="showConfirm">删除</button>

    <confirm-dialog
      :visible="visible"
      title="确认删除"
      content="删除后数据将无法恢复,是否继续?"
      @confirm="handleConfirm"
      @cancel="handleCancel"
    />
  </view>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)

const showConfirm = () => {
  visible.value = true
}

const handleConfirm = async () => {
  try {
    await deleteData()
    uni.showToast({ title: '删除成功', icon: 'success' })
    visible.value = false
  } catch (err) {
    uni.showToast({ title: '删除失败', icon: 'error' })
  }
}

const handleCancel = () => {
  visible.value = false
}
</script>
```

### 自定义按钮文本

```vue
<template>
  <confirm-dialog
    :visible="visible"
    title="提交确认"
    content="数据已填写完成,是否提交?"
    confirm-text="立即提交"
    cancel-text="继续编辑"
    @confirm="handleSubmit"
    @cancel="handleCancel"
  />
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)

const handleSubmit = async () => {
  await submitForm()
  visible.value = false
}

const handleCancel = () => {
  visible.value = false
}
</script>
```

### 仅确认按钮(无取消)

```vue
<template>
  <view>
    <button @click="showAlert">查看提示</button>

    <confirm-dialog
      :visible="visible"
      title="系统提示"
      content="新版本已发布,请前往更新"
      :show-cancel="false"
      confirm-text="知道了"
      @confirm="visible = false"
    />
  </view>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)

const showAlert = () => {
  visible.value = true
}
</script>
```

### 完整示例(删除确认)

```vue
<template>
  <view class="min-h-screen">
    <!-- 数据列表 -->
    <view v-for="item in dataList" :key="item.id" class="flex items-center gap-2 mb-2">
      <text class="flex-1">{{ item.name }}</text>
      <button class="text-red-500" @click="confirmDelete(item)">删除</button>
    </view>

    <!-- 确认对话框 -->
    <confirm-dialog
      :visible="visible"
      title="删除确认"
      :content="deleteContent"
      confirm-text="确认删除"
      cancel-text="取消"
      @confirm="handleDelete"
      @cancel="handleCancel"
    />
  </view>
</template>

<script setup>
import { ref } from 'vue'

const dataList = ref([
  { id: 1, name: '项目A' },
  { id: 2, name: '项目B' },
  { id: 3, name: '项目C' }
])

const visible = ref(false)
const deleteTarget = ref(null)

const deleteContent = ref('')

const confirmDelete = (item) => {
  deleteTarget.value = item
  deleteContent.value = `确定要删除"${item.name}"吗?删除后无法恢复。`
  visible.value = true
}

const handleDelete = async () => {
  try {
    await deleteItem(deleteTarget.value.id)

    // 从列表中移除
    dataList.value = dataList.value.filter(item => item.id !== deleteTarget.value.id)

    uni.showToast({ title: '删除成功', icon: 'success' })
    visible.value = false
    deleteTarget.value = null
  } catch (err) {
    uni.showToast({ title: '删除失败', icon: 'error' })
  }
}

const handleCancel = () => {
  visible.value = false
  deleteTarget.value = null
}
</script>
```

## 定制指南

### 常见修改点

1. **按钮文本**: 修改 `confirmText` 和 `cancelText` 自定义按钮文本
2. **隐藏取消**: 设置 `showCancel: false` 只显示确认按钮
3. **遮罩关闭**: 设置 `maskClosable: true` 允许点击遮罩关闭
4. **内容文本**: 修改 `content` prop 设置提示文本

### 代码复制路径

```bash
cp src/components/templates/dialog/confirm-dialog.vue src/pages/your-page.vue
```

### 高级定制

**添加加载状态:**

```vue
<script setup>
import { ref } from 'vue'

const visible = ref(false)
const loading = ref(false)

const handleConfirm = async () => {
  loading.value = true
  try {
    await performAction()
    visible.value = false
  } finally {
    loading.value = false
  }
}
</script>
```

**动态内容:**

```vue
<script setup>
import { ref, computed } from 'vue'

const visible = ref(false)
const actionType = ref('') // delete/publish/submit

const dialogContent = computed(() => {
  const contents = {
    delete: '删除后数据将无法恢复,是否继续?',
    publish: '发布后数据将公开可见,是否继续?',
    submit: '数据已填写完成,是否提交?'
  }
  return contents[actionType.value] || ''
})

const showDialog = (type) => {
  actionType.value = type
  visible.value = true
}
</script>
```

## 注意事项

1. **简化设计**: confirm-dialog 是简化版对话框,不适合复杂内容
2. **遮罩关闭**: 默认 maskClosable=false,防止误操作关闭
3. **按钮样式**: 确认按钮为蓝色,取消按钮为灰色
4. **内容长度**: content 文本过长会自动换行

## 相关组件

- [basic-dialog](./basic-dialog.md) - 基础弹窗(支持复杂内容)

## 返回

[返回组件概览](../README.md)