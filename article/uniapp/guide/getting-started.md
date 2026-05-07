# 快速上手

## 环境要求

- Node.js: `^20.19.0 || >=22.12.0`
- 包管理器: npm 或 pnpm

## 安装

```bash
# 安装依赖
npm install

# 或
pnpm install
```

## 项目结构

```
├── src/
│   ├── api/           # API接口层
│   │   ├── sources/   # 数据源适配层
│   │   ├── modules/   # 业务接口层
│   │   └── index.js   # 统一入口
│   ├── components/    # 组件
│   │   └── templates/ # 代码模板
│   ├── pages/         # 页面
│   ├── store/         # 状态管理
│   ├── utils/         # 工具函数
│   └── mock/          # Mock数据
├── docs/              # 文档
├── .env               # 环境配置
└── package.json       # 项目配置
```

## 启动

```bash
# 微信小程序开发（默认API模式）
npm run dev

# Mock模式（无需后端）
npm run dev:mock

# API对接模式
npm run dev:api

# 本地数据模式
npm run dev:local

# H5开发
npm run dev:h5
```

## 开发流程

1. 选择合适的数据源模式（Mock/API/Local）
2. 复制组件模板到页面目录
3. 编写业务逻辑
4. 测试运行
5. 构建发布

## 下一步

- 了解 [API多模式](api-mode.md) 的配置和使用
- 查看 [组件模板详细文档](components/README.md) 快速搭建页面
- 阅读 [最佳实践](best-practices.md) 获取开发建议
