# Web Screenshot 高质量截图指南

本指南总结了使用 Playwright 进行高质量全屏截图的实战方案，特别针对现代 Web 页面（如 Vue/React 框架、懒加载、嵌套滚动容器等）的复杂场景。

## 1. 核心挑战与策略

| 挑战场景 | 现象 | 解决方案 |
| :--- | :--- | :--- |
| **懒加载** | 截图下方内容缺失或显示加载中 | 模拟步进式滚动（Step Scroll），触发所有资源加载。 |
| **嵌套滚动容器** | 截图只显示首屏，滚动条无效 | 识别 `overflow: auto` 容器，强制解除溢出隐藏限制。 |
| **PC 端布局变形** | 全屏截图导致宽度缩放或侧边栏重叠 | 固定视口宽度（如 1920px），动态拉伸高度而非依赖内置参数。 |
| **移动端 UI 干扰** | 底部导航栏在长图中多次出现或遮挡 | 截图前通过 CSS 隐藏固定定位（Fixed）的 UI 元素。 |

## 2. PC 端截图流程 (推荐方案)

针对管理后台、电商首页等桌面端页面，建议使用“视口拉伸法”。

### 核心逻辑：
1. 设置标准宽度：`await page.setViewportSize({ width: 1920, height: 1080 });`
2. 触发懒加载：循环滚动页面。
3. 计算内容总高度。
4. **拉伸视口**：将 Viewport 高度设为内容总高度。
5. 截图并保存。

## 3. 移动端截图流程 (推荐方案)

针对手机 H5 页面，建议使用“容器解锁法”。

### 核心逻辑：
1. 模拟设备：设置 375px 或 390px 宽度，模拟 Mobile User-Agent。
2. **解锁滚动条**：
   ```javascript
   // 寻找真正的滚动容器并使其溢出可见
   const container = findScrollableElement(); 
   container.style.overflow = 'visible';
   container.style.height = 'auto';
   ```
3. 隐藏干扰：如 `.van-tabbar`（Vant 组件库）、`.fixed-bottom`。
4. 执行全屏截图：`await page.screenshot({ fullPage: true });`

## 4. 故障排除 (Troubleshooting)

- **图片依然模糊/不全**：增加滚动后的等待时间 `page.waitForTimeout(2000)`。
- **布局完全乱掉**：避免使用通配符 `*` 强制修改 `height: auto`，应只针对特定的滚动容器及其父级进行修改。
- **空白区域过大**：检查是否有元素设置了 `min-height: 100vh` 且在内容展开后未重置。

---
*注：该逻辑已封装在 `web-screenshot` 技能中，AI 助手在处理类似任务时会自动优先采用上述策略。*
