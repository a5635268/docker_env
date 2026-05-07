# basic-dialog 基础弹窗

## 组件介绍

基础弹窗组件,支持多个位置展示(居中/底部/顶部),适用于复杂内容展示、表单编辑、详情查看等场景。

**功能特点:**
- 多位置弹窗(居中/底部/顶部)
- 自定义内容区域
- 遮罩层关闭控制
- 显示/隐藏关闭按钮
- 自定义底部操作按钮

**适用场景:**
- 表单编辑弹窗
- 详情信息展示
- 复杂内容弹窗
- 底部弹出菜单
- 顶部通知提示

## Props 参数

| 参数名 | 类型 | 默认值 | 必填 | 说明 |
|--------|------|--------|------|------|
| visible | Boolean | false | 否 | 是否显示弹窗 |
| title | String | '提示' | 否 | 弹窗标题 |
| showClose | Boolean | true | 否 | 是否显示关闭按钮 |
| showFooter | Boolean | true | 否 | 是否显示底部操作按钮 |
| showCancel | Boolean | true | 否 | 是否显示取消按钮 |
| position | String | 'center' | 否 | 弹窗位置: center/bottom/top |
| maskClosable | Boolean | true | 否 | 点击遮罩是否关闭 |

## Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| close | - | 关闭弹窗时触发 |
| confirm | - | 点击确定按钮时触发 |
| cancel | - | 点击取消按钮时触发 |

## Slots 插槽

| 插槽名 | 参数 | 说明 |
|--------|------|------|
| default | - | 弹窗内容区域 |

## 使用示例

### 基础用法(居中弹窗)

```vue
<template>
  <view>
    <button @click="showDialog">打开弹窗</button>

    <basic-dialog
      :visible="visible"
      title="用户信息"
      @close="handleClose"
      @confirm="handleConfirm"
    >
      <!-- 自定义弹窗内容 -->
      <view class="flex flex-col gap-2">
        <text>姓名: 张三</text>
        <text>邮箱: zhangsan@example.com</text>
        <text>注册时间: 2024-01-01</text>
      </view>
    </basic-dialog>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)

const showDialog = () => {
  visible.value = true
}

const handleClose = () => {
  visible.value = false
}

const handleConfirm = () => {
  console.log('确定操作')
  visible.value = false
}
</script>
```

### 底部弹出菜单

```vue
<template>
  <view>
    <button @click="showMenu">打开菜单</button>

    <basic-dialog
      :visible="visible"
      title="操作菜单"
      position="bottom"
      :show-footer="false"
      :show-close="false"
      @close="visible = false"
    >
      <view class="flex flex-col">
        <button class="text-left p-3 border-b border-gray-100" @click="handleEdit">
          编辑
        </button>
        <button class="text-left p-3 border-b border-gray-100" @click="handleDelete">
          删除
        </button>
        <button class="text-left p-3 text-gray-500" @click="visible = false">
          取消
        </button>
      </view>
    </basic-dialog>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const visible = ref(false)

const showMenu = () => visible.value = true

const handleEdit = () => {
  console.log('编辑操作')
  visible.value = false
}

const handleDelete = () => {
  console.log('删除操作')
  visible.value = false
}
</script>
```

### 表单编辑弹窗

```vue
<template>
  <view>
    <button @click="openEdit">编辑用户</button>

    <basic-dialog
      :visible="visible"
      title="编辑用户信息"
      @close="handleClose"
      @confirm="handleSubmit"
      @cancel="handleClose"
    >
      <!-- 表单内容 -->
      <view class="flex flex-col gap-3">
        <view>
          <text class="text-gray-600 mb-1 block">姓名</text>
          <input v-model="formData.name" class="border rounded p-2 w-full" />
        </view>
        <view>
          <text class="text-gray-600 mb-1 block">邮箱</text>
          <input v-model="formData.email" type="email" class="border rounded p-2 w-full" />
        </view>
      </view>
    </basic-dialog>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'

const visible = ref(false)
const formData = reactive({
  name: '',
  email: ''
})

const openEdit = () => {
  // 初始化表单数据
  formData.name = '张三'
  formData.email = 'zhangsan@example.com'
  visible.value = true
}

const handleClose = () => {
  visible.value = false
}

const handleSubmit = async () => {
  try {
    await updateUser(formData)
    uni.showToast({ title: '更新成功', icon: 'success' })
    visible.value = false
  } catch (err) {
    uni.showToast({ title: '更新失败', icon: 'error' })
  }
}
</script>
```

### 顶部通知弹窗

```vue
<template>
  <view>
    <basic-dialog
      :visible="visible"
      title="系统通知"
      position="top"
      :show-footer="false"
      :mask-closable="true"
      @close="visible = false"
    >
      <view class="flex items-center gap-2">
        <text class="text-blue-500">📢</text>
        <text>新版本已发布,请更新应用</text>
      </view>
    </basic-dialog>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const visible = ref(false)

onMounted(() => {
  // 页面加载时显示通知
  setTimeout(() => {
    visible.value = true
  }, 1000)
})
</script>
```

## 定制指南

### 常见修改点

1. **弹窗位置**: 修改 `position` prop 选择合适位置
2. **关闭按钮**: `showClose` 控制是否显示右上角关闭按钮
3. **底部按钮**: `showFooter` 控制是否显示底部操作按钮
4. **遮罩关闭**: `maskClosable` 控制点击遮罩是否关闭

### 代码复制路径

```bash
cp src/components/templates/dialog/basic-dialog.vue src/pages/your-page.vue
```

### 高级定制

**自定义底部按钮:**

```vue
<template>
  <basic-dialog :visible="visible" :show-footer="false">
    <view class="flex flex-col gap-2">
      <!-- 内容区域 -->
    </view>

    <!-- 自定义底部 -->
    <view class="p-4 border-t border-gray-200 flex gap-2">
      <button class="flex-1 bg-gray-200 py-2 rounded">保存草稿</button>
      <button class="flex-1 bg-blue-500 text-white py-2 rounded">发布</button>
    </view>
  </basic-dialog>
</template>
```

**动态控制遮罩:**

```vue
<script setup>
import { ref } from 'vue'

const visible = ref(false)
const maskClosable = ref(false) // 禁止点击遮罩关闭

// 只能通过按钮关闭
const handleClose = () => {
  visible.value = false
}
</script>
```

## 注意事项

1. **位置样式**: position 支持 center/bottom/top 三种位置
2. **遮罩层级**: 使用 `z-50` 确保弹窗在最上层
3. **事件处理**: 点击遮罩关闭会触发 close 事件,不会触发 cancel
4. **内容滚动**: 长内容建议在 slot 中使用 scroll-view

## 相关组件

- [confirm-dialog](./confirm-dialog.md) - 简化的确认对话框
- [basic-form](../form/basic-form.md) - 表单组件(配合弹窗使用)

## 返回

[返回组件概览](../README.md)