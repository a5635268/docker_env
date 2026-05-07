# 常见问题FAQ

## 启动问题

### Q: npm install 失败？

确保使用 Node.js 20.19.0+ 或 22.12.0+。

```bash
node -v  # 检查版本
```

### Q: dev:h5 启动后无法访问？

检查防火墙是否允许对应端口访问。

## API对接问题

### Q: 如何切换数据源？

使用不同启动命令：

```bash
npm run dev:mock    # Mock
npm run dev:api     # API
npm run dev:local   # Local
```

### Q: API请求401怎么办？

检查token是否过期，重新登录获取。

### Q: Mock数据和API不一致？

确保 `src/api/sources/mock.js` 和 `src/api/sources/api.js` 返回数据结构一致。

## 构建问题

### Q: 小程序包体积过大？

- 使用分包，将非核心页面放入subPackages
- 检查引入的图片资源大小
- 移除未使用的依赖

### Q: H5构建后样式丢失？

检查 TailwindCSS 的 content 配置是否包含所有文件路径。

## 平台差异

### Q: 小程序样式和H5不一致？

使用条件编译 `#ifdef MP-WEIXIN` 分别处理。

### Q: 部分API在小程序中无法使用？

小程序环境限制较多，使用 uni-app 提供的API替代。
