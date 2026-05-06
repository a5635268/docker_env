# Compound Engineering Tools 使用总览

> AI 编程助手高效工具集，专为 Claude Code、Cursor 等 Agent 优化的 CLI 工具和技能

---

## 概述

Compound Engineering 插件提供了一套专为 AI 编程助手设计的 CLI 工具和技能。这些工具经过优化，具有以下特点：

- ✅ **Token 高效** - 命令行输出紧凑，不浪费上下文
- ✅ **无需 Schema** - 直接命令交互，不加载大型工具定义
- ✅ **跨平台兼容** - 支持 macOS/Linux/Windows
- ✅ **AI 优先设计** - 输出格式适合 AI 解析和决策

---

## 工具清单

### CLI 工具

| 工具 | 用途 | 安装命令 |
|------|------|----------|
| agent-browser | 浏览器自动化测试 | `npm i -g agent-browser && agent-browser install` |
| gh | GitHub CLI | `brew install gh` |
| jq | JSON 处理器 | `brew install jq` |
| vhs | CLI GIF 制作 | `brew install vhs` |
| silicon | 代码截图生成 | `brew install silicon` |
| ffmpeg | 视频处理 | `brew install ffmpeg` |
| ast-grep | AST 结构搜索 | `brew install ast-grep` |

### Agent 技能

| 技能 | 用途 | 安装命令 |
|------|------|----------|
| agent-browser | 浏览器自动化工作流指导 | `npx skills add vercel-labs/agent-browser -g -y` |
| ast-grep | AST 搜索规则编写指导 | `npx skills add ast-grep/agent-skill -g -y` |

---

## 使用场景矩阵

| 场景 | 推荐工具 | 说明 |
|------|----------|------|
| Web 应用测试 | agent-browser | 自动化 UI 测试、表单填写、截图 |
| GitHub 操作 | gh | 创建 PR、管理 Issues、查看仓库 |
| API 数据处理 | jq | JSON 解析、过滤、转换 |
| 演示文档制作 | vhs | 终端操作录制为 GIF |
| 代码展示 | silicon | 生成美观的代码截图 |
| 视频编辑 | ffmpeg | 格式转换、剪辑、压缩 |
| 代码重构 | ast-grep | 结构化搜索和替换 |

---

## 快速入门

### 环境检查

```bash
# 运行 Compound Engineering 健康检查
/ce-setup
```

### 工具验证

```bash
# 检查所有工具是否已安装
command -v agent-browser gh jq vhs silicon ffmpeg ast-grep
```

### 技能验证

```bash
# 检查技能是否已安装
ls ~/.claude/skills/
```

---

## 详细文档

### Skills 完整指南
- [Compound Engineering Skills 完整指南](./Compound-Engineering-Skills-完整指南.md) - 30+ Skills 详细参考

### CLI 工具指南
- [Agent-Browser 自动化测试指南](./Agent-Browser-自动化测试指南.md)
- [gh GitHub CLI 使用指南](./gh-GitHub-CLI-使用指南.md)
- [jq JSON 处理器使用指南](./jq-JSON处理器-使用指南.md)
- [vhs GIF 制作指南](./vhs-GIF制作指南.md)
- [silicon 代码截图指南](./silicon-代码截图指南.md)
- [ffmpeg 视频处理指南](./ffmpeg-视频处理指南.md)
- [ast-grep 结构搜索指南](./ast-grep-结构搜索指南.md)

### 概念与原理
- [Compound Engineering 复利式工程](./Compound-Engineering-复利式工程.md) - CE 原理详解

---

## 安装顺序建议

1. **基础工具优先**：jq、gh - 数据处理和 GitHub 操作
2. **浏览器自动化**：agent-browser - Web 测试必备
3. **内容创作工具**：vhs、silicon、ffmpeg - 文档和演示
4. **代码分析工具**：ast-grep - 重构和搜索

---

## 配置文件

Compound Engineering 使用 `.compound-engineering/` 目录存储配置：

```
<repo-root>/.compound-engineering/
├── config.local.yaml      # 本地配置（不入库）
├── config.local.example.yaml  # 配置示例（入库）
```

配置已在 `.gitignore` 中排除：
```gitignore
.compound-engineering/*.local.yaml
```

---

## 更新与维护

```bash
# 重新检查环境
/ce-setup

# 更新 Compound Engineering 插件
/ce-update

# 更新单个工具
brew upgrade <tool>
npm update -g <package>
```

---

## 常见问题

### Q: 工具安装后找不到命令？

检查 PATH 路径是否包含安装目录：
- Homebrew: `/usr/local/bin` 或 `/opt/homebrew/bin`
- npm 全局: `npm bin -g`

### Q: 技能不生效？

确认技能文件存在于 `~/.claude/skills/` 目录，且为有效链接。

### Q: agent-browser Chrome 下载失败？

Chrome 下载约 180MB，确保网络稳定。可手动指定 Chrome 路径。

---

## 参考链接

- [Compound Engineering GitHub](https://github.com/compound-engineering)
- [agent-browser](https://github.com/vercel-labs/agent-browser)
- [gh CLI](https://cli.github.com/)
- [jq](https://jqlang.github.io/jq/)
- [vhs](https://github.com/charmbracelet/vhs)
- [silicon](https://github.com/Aloxaf/silicon)
- [ast-grep](https://ast-grep.github.io/)