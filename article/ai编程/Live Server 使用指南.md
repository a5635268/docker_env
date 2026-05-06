# Live Server 使用指南

快速启动本地 HTTP 服务器预览前端页面，类似 VSCode Live Server 插件。

## 快速开始

### 方式 1：终端命令（推荐）

```bash
# 安装 alias（一次性）
echo 'alias live-server="/Users/mac/.claude/skills/live-server/live-server.sh"' >> ~/.zshrc
source ~/.zshrc

# 使用
live-server              # 当前目录，端口 8000
live-server 3000         # 指定端口
live-server 8000 ./public  # 指定目录和端口
```

### 方式 2：直接运行脚本

```bash
/Users/mac/.claude/skills/live-server/live-server.sh
```

### 方式 3：在 Claude Code 中

让 Claude 帮你启动：
```
帮我启动 live server 预览这个页面
```

## 脚本功能

- **自动检测可用端口**：8000 被占用则尝试 8001、8002...
- **智能选择服务器**：优先使用 Python3（macOS 自带）
- **支持指定目录和端口**
- **按 Ctrl+C 停止服务器**

## 依赖检测

脚本会按以下顺序检测并使用可用的 HTTP 服务器：

1. **Python3**（推荐，macOS 自带）
   ```bash
   python3 -m http.server 8000
   ```

2. **PHP**（如果已安装）
   ```bash
   php -S localhost:8000
   ```

3. **Node.js**（需要安装 http-server）
   ```bash
   npx http-server -p 8000
   ```

## 使用示例

```bash
# 在当前目录启动
cd /path/to/your/project
live-server

# 在指定目录启动
live-server 8000 /Users/mac/wwwroot/my-project/public

# 指定不同端口
live-server 9000
```

## 文件位置

- 技能定义：`~/.claude/skills/live-server/SKILL.md`
- 启动脚本：`~/.claude/skills/live-server/live-server.sh`

## 访问地址

启动后在浏览器访问：
```
http://localhost:8000
```
