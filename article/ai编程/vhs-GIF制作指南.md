# vhs GIF 制作指南

> Charmbracelet 出品的终端录制工具，将 CLI 操作转换为 GIF 动图

---

## 概述

vhs 是专为终端录制设计的 GIF 生成工具：

- ✅ **脚本驱动** - 使用 Tape 文件定义录制脚本
- ✅ **美观输出** - 自动美化终端样式
- ✅ **多格式支持** - GIF、WebM、MP4
- ✅ **主题丰富** - 内置多种终端主题
- ✅ **在线分享** - 支持发布到 vhs.charm.sh

---

## 安装

```bash
# Homebrew 安装 (macOS)
brew install vhs

# 验证安装
vhs --version
```

---

## 核心命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `vhs <file>` | 执行 Tape 文件生成 GIF | `vhs demo.tape` |
| `vhs new` | 创建示例 Tape 文件 | `vhs new demo.tape` |
| `vhs record` | 录制终端操作生成 Tape | `vhs record demo.tape` |
| `vhs validate` | 验证 Tape 文件语法 | `vhs validate *.tape` |
| `vhs publish` | 发布到 vhs.charm.sh | `vhs publish demo.tape` |
| `vhs themes` | 列出可用主题 | `vhs themes` |

---

## Tape 文件语法

### 基本结构

```tape
# demo.tape

Require echo
Require cat

Set Shell "bash"
Set FontSize 14
Set Width 800
Set Height 400

Type "echo 'Hello, vhs!'" Enter
Sleep 500ms

Type "cat README.md" Enter
Sleep 1s

Screenshot demo.png
```

### 设置命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `Set Shell` | 设置 Shell 类型 | `Set Shell "bash"` |
| `Set FontSize` | 设置字体大小 | `Set FontSize 16` |
| `Set Width` | 设置宽度 | `Set Width 800` |
| `Set Height` | 设置高度 | `Set Height 400` |
| `Set Theme` | 设置主题 | `Set Theme "Dracula"` |
| `Set Padding` | 设置边距 | `Set Padding 20` |

### 操作命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `Type` | 输入文本 | `Type "ls -la"` |
| `Enter` | 按回车 | `Type "ls" Enter` |
| `Backspace` | 按退格 | `Backspace 5` |
| `Sleep` | 等待时间 | `Sleep 500ms` |
| `Wait` | 等待输出 | `Wait+500ms` |
| `Ctrl+C` | 发送 Ctrl+C | `Ctrl+C` |
| `Screenshot` | 截图 | `Screenshot frame.png` |
| `Hide` | 隐藏光标 | `Hide` |
| `Show` | 显示光标 | `Show` |

---

## 使用场景

### 1. CLI 工具演示

```tape
# cli-demo.tape

Require mycli

Set Shell "bash"
Set FontSize 14
Set Width 800
Set Height 500
Set Theme "Catppuccin Mocha"

Type "mycli --help" Enter
Sleep 1s

Type "mycli init myproject" Enter
Sleep 2s

Type "cd myproject" Enter
Sleep 500ms

Type "mycli run" Enter
Sleep 3s
```

执行生成 GIF：
```bash
vhs cli-demo.tape -o cli-demo.gif
```

### 2. 命令行教程

```tape
# tutorial.tape

Set Shell "bash"
Set Theme "Gotham"

Type "# Git 基础教程" Enter
Sleep 500ms

Type "git status" Enter
Sleep 1s

Type "git add ." Enter
Sleep 500ms

Type "git commit -m 'Initial commit'" Enter
Sleep 1s
```

### 3. API 调用展示

```tape
# api-demo.tape

Require curl
Require jq

Set Theme "Dracula"

Type "curl -s https://api.github.com/users/octocat | jq '.name'" Enter
Wait+2s

Screenshot api-result.png
```

---

## 输出格式

### 多格式输出

```bash
# 输出 GIF 和 WebM
vhs demo.tape -o demo.gif -o demo.webm

# 输出 MP4
vhs demo.tape -o demo.mp4
```

### 发布分享

```bash
# 发布到 vhs.charm.sh
vhs publish demo.tape

# 返回分享链接
# https://vhs.charm.sh/xxx/demo.gif
```

---

## 内置主题

查看所有主题：
```bash
vhs themes
```

常用主题：
- `Dracula` - 深色主题
- `Catppuccin Mocha` - 柔和深色
- `Gotham` - 深蓝主题
- `Monokai` - 经典编辑器主题
- `PowerShell` - PowerShell 风格
- `Tokyo Night` - 夜色主题

---

## AI Agent 工作流

### 快速录制

```bash
# 创建 Tape 文件模板
vhs new demo.tape

# 交互录制（手动操作生成脚本）
vhs record demo.tape

# 生成 GIF
vhs demo.tape
```

### 脚本生成

AI Agent 可以直接生成 Tape 脚本内容：

```tape
# 由 AI Agent 生成的演示脚本

Require your-cli

Set Shell "bash"
Set FontSize 12
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"

Type "your-cli version" Enter
Sleep 1s

Type "your-cli config init" Enter
Sleep 2s

Type "your-cli run --verbose" Enter
Sleep 3s
```

---

## 常见问题

### Q: GIF 体积过大？

减小尺寸和时长：
```tape
Set Width 600
Set Height 300
# 减少不必要的 Sleep
```

### Q: 终端输出不完整？

增加等待时间：
```tape
Wait+2s  # 等待输出完成
Sleep 500ms
```

### Q: 命令找不到？

添加 Require 声明：
```tape
Require jq
Require curl
```

---

## 参考链接

- [vhs GitHub](https://github.com/charmbracelet/vhs)
- [vhs 官网](https://vhs.charm.sh/)
- [Tape 文件语法](https://github.com/charmbracelet/vhs#tape-file)