# Ghostty 终端使用指南

Ghostty 是一款硬核高效的终端工具，核心理念是**"极简外表，极致性能"**。与传统终端（如 iTerm2）不同，它倾向于配置文件驱动而非复杂 GUI 菜单。

## 基础操作

| 快捷键 | 功能 |
|--------|------|
| `Cmd + T` | 新建标签页 |
| `Cmd + W` | 关闭当前窗口/标签 |
| `Cmd + D` | 垂直分屏 |
| `Cmd + Shift + D` | 水平分屏 |
| `Cmd + Option + 方向键` | 分屏间切换焦点 |

## 配置文件

所有自定义通过 `~/.config/ghostty/config` 完成：

```bash
mkdir -p ~/.config/ghostty && touch ~/.config/ghostty/config
```

### 常用配置项

```ini
# 字体设置
font-family = "Maple Mono NF CN"
font-size = 14
font-thicken = true
adjust-cell-height = 2

# 主题
theme = Catppuccin Mocha

# 外观
background-opacity = 0.85
background-blur-radius = 30
macos-titlebar-style = transparent
window-padding-x = 10
window-padding-y = 8

# 光标
cursor-style = bar
cursor-style-blink = true

# 快捷终端（Quake 风格）
quick-terminal-position = top
quick-terminal-autohide = true
keybind = global:ctrl+grave_accent=toggle_quick_terminal

# 性能
scrollback-limit = 25000000
```

### CLI 辅助工具

```bash
ghostty +list-themes   # 查看所有内置主题
ghostty +list-fonts    # 查看系统支持的字体
```

## 核心使用场景

### 1. 高频日志滚动

Docker 日志、Webpack 编译、后端服务监控等大规模输出场景。

**优势**：GPU 加速渲染，快速滚动不掉帧，CPU 占用远低于自带终端。

### 2. 多任务分屏协作

左侧写代码（Vim/Claude Code），右侧运行测试，下方观察服务器状态。

**优势**：原生分屏性能优于 Zsh 套 Tmux。

### 3. TUI 应用

`htop`、`k9s`、`Vim/Neovim` 等终端用户界面应用。

**优势**：True Color 支持和精准字符渲染，视觉体验接近现代 GUI。

### 4. 远程开发与 SSH

频繁连接远程服务器进行运维。

**优势**：标准转义序列支持，远程连接不易乱码或渲染错位。

### 5. 桌面美学

配合 Raycast、Yabai 等窗口管理工具，打造无边框、半透明纯净工作环境。

**优势**：macOS 上最轻量现代化的终端之一。

## 与 Starship 的协同

Ghostty 和 Starship 运行在不同层级，是**合作关系**：

| 工具 | 层级 | 职责 |
|------|------|------|
| Ghostty | 终端模拟器 | 窗口外观、字体渲染 |
| Starship | Shell 提示符 | 提示符内容、Git 图标 |

### 完美联动

1. **Nerd Font 符号闭环**：Starship 的特殊符号（``、``、``）需要 Nerd Font 支持，Ghostty 配置指定 `Maple Mono NF CN` 后可完美渲染。

2. **主题配色统一**：Starship 使用 `palette = 'catppuccin_mocha'`，Ghostty 同样配置 `theme = Catppuccin Mocha`，视觉设计语言一致。

3. **行间距修复**：`adjust-cell-height = 2` 可解决 Starship 彩虹状态栏色块拼接不齐的问题。

## 前置准备

确保已安装 Nerd Font 字体（如 `Maple Mono NF CN`），否则 Starship 图标会显示为乱码框。

```bash
# Homebrew 安装
brew install font-maple-mono-nf-cn
```

## 总结

如果你日常大部分工作在命令行完成，Ghostty 是**"装上就不用管，但用起来极爽"**的工具。配置好主题和字体后，剩下的交给它极致的性能。	