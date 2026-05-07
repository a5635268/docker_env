# zsh + oh-my-zsh + starship 安装配置指南

> 最后更新：2026-04-11
> 适用系统：macOS

## 目录

- [概述](#概述)
- [安装步骤](#安装步骤)
  - [1. 检查系统环境](#1-检查系统环境)
  - [2. 安装 Ghostty 终端（可选，推荐）](#2-安装 ghostty 终端可选推荐)
  - [3. 安装 Nerd Font](#3-安装 nerd-font)
  - [4. 安装 oh-my-zsh](#4-安装 oh-my-zsh)
  - [5. 安装 starship](#5-安装 starship)
  - [6. 安装 zsh 插件](#6-安装 zsh 插件)
- [配置说明](#配置说明)
- [故障排查](#故障排查)

---

## 概述

本指南帮助你配置一个功能完整的 zsh 开发环境，包含：

- **zsh**: 现代化的 shell
- **oh-my-zsh**: zsh 配置管理框架
- **starship**: 跨 shell 的提示符主题
- **zsh-autosuggestions**: 命令自动补全
- **zsh-syntax-highlighting**: 命令语法高亮
- **JetBrains Mono Nerd Font**: 图标字体支持
- **Ghostty**: 现代化高性能终端模拟器（可选，推荐）

---

## 安装步骤

### 1. 检查系统环境

```bash
# 检查 zsh 是否安装
which zsh
zsh --version

# 检查 Homebrew 是否安装
brew --version
```

### 2. 安装 Ghostty 终端（可选，推荐）

[Ghostty](https://ghostty.org/) 是一个快速、功能丰富的现代化终端模拟器，原生支持 macOS。

```bash
# 使用 Homebrew 安装
brew install --cask ghostty
```

**Ghostty 特点：**
- GPU 加速渲染，性能优异
- 原生支持 Nerd Font 图标
- 支持分屏、标签页
- 自动读取 `~/.config/ghostty/config` 配置文件

**配置 Ghostty（可选）：**

创建配置文件 `~/.config/ghostty/config`：

```bash
mkdir -p ~/.config/ghostty
cat > ~/.config/ghostty/config << 'EOF'
# 字体设置
font-family = "JetBrainsMono Nerd Font"
font-size = 14

# 主题（可选）
theme = "Catppuccin Mocha"

# 窗口设置
window-width = 120
window-height = 40
EOF
```

> **提示**：安装完成后，打开 Ghostty App 即可使用，它会自动加载 zsh 配置。

### 4. 安装 Nerd Font（图标支持）

> 如果已使用 Ghostty，它会自动检测系统安装的 Nerd Font，此步骤仍然需要执行。

```bash
# 安装 JetBrains Mono Nerd Font
brew install --cask font-jetbrains-mono-nerd-font
```

> **重要**：安装后需要在终端设置中应用此字体（见 [配置终端字体](#配置终端字体)）

### 5. 安装 oh-my-zsh

```bash
# 官方源安装
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 如果国内访问慢，使用镜像源
sh -c "$(curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### 6. 安装 starship

```bash
# 使用 Homebrew 安装
brew install starship
```

### 7. 安装 zsh 插件

```bash
# 安装 zsh-autosuggestions（命令自动补全）
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 安装 zsh-history-substring-search（历史命令搜索）
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

> 注意：`zsh-syntax-highlighting` 如果已通过 Homebrew 安装，路径为 `/usr/local/share/zsh-syntax-highlighting`

---

## 配置说明

### 1. 配置 Ghostty（如果使用）

Ghostty 会自动检测系统安装的 Nerd Font，通常无需额外配置。

**创建配置文件（可选）：**

```bash
mkdir -p ~/.config/ghostty
cat > ~/.config/ghostty/config << 'EOF'
# 字体设置
font-family = "JetBrainsMono Nerd Font"
font-size = 14

# 主题（可选）
theme = "Catppuccin Mocha"

# 窗口设置
window-width = 120
window-height = 40
EOF
```

### 2. 配置 ~/.zshrc

编辑 `~/.zshrc` 文件：

```bash
vim ~/.zshrc
```

#### 核心配置项

```bash
# ============ Oh My Zsh 基础配置 ============
export ZSH="$HOME/.oh-my-zsh"

# 禁用 oh-my-zsh 内置主题（使用 starship）
ZSH_THEME=""

# 启用插件
plugins=(git zsh-autosuggestions zsh-history-substring-search)

# 加载 oh-my-zsh
source $ZSH/oh-my-zsh.sh

# ============ Starship 主题 ============
eval "$(starship init zsh)"

# ============ zsh-syntax-highlighting（如果通过 brew 安装）============
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============ 其他配置 ============
# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 自定义 PATH
export PATH=/Users/mac/.opencode/bin:$PATH
```

### 3. 配置终端字体

**使用 macOS 自带终端：**

安装完 Nerd Font 后，需要在终端中手动应用：

1. 打开 **终端** App
2. 按 `Cmd + ,` 打开设置
3. 点击 **描述文件** 标签
4. 选择当前使用的描述文件
5. 取消勾选 **使用 Pro 描述文件字体**
6. 点击 **更改...** 按钮
7. 选择 **JetBrainsMono Nerd Font**（字号建议 13-14）
8. 关闭设置窗口

**使用 Ghostty：**

Ghostty 会自动检测并使用系统安装的 Nerd Font，无需手动配置。如需自定义，编辑 `~/.config/ghostty/config`：

```ini
font-family = "JetBrainsMono Nerd Font"
font-size = 14
```

### 4. 应用配置

```bash
# 重新加载配置
source ~/.zshrc

# 或者重启终端
```

### 5. （可选）Starship 自定义配置

如需自定义 starship 外观，创建 `~/.config/starship.toml`：

```bash
mkdir -p ~/.config
vim ~/.config/starship.toml
```

示例配置（纯文本模式，无需 Nerd Font）：

```toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[git_branch]
symbol = "git:"

[git_status]
ahead = "↑"
behind = "↓"
diverged = "↕"
untracked = "?"
```

---

## 故障排查

### 问题 1：图标显示为方框/问号

**原因**：终端未使用 Nerd Font 字体

**解决**：
1. 确认字体已安装：`ls /Library/Fonts/ | grep -i nerd`
2. 在终端设置中应用 JetBrainsMono Nerd Font

### 问题 2：自动补全不工作

**检查插件是否加载**：

```bash
# 查看插件目录
ls ~/.oh-my-zsh/custom/plugins/

# 检查 ~/.zshrc 中 plugins 配置
grep "^plugins=" ~/.zshrc
```

**确保配置正确**：
```bash
plugins=(git zsh-autosuggestions zsh-history-substring-search)
```

### 问题 3：starship 主题未显示

**检查 starship 是否安装**：
```bash
which starship
starship --version
```

**检查 ~/.zshrc 配置**：
```bash
# 确保 ZSH_THEME 为空
grep "ZSH_THEME" ~/.zshrc

# 确保有 starship 初始化
grep "starship init" ~/.zshrc
```

### 问题 4：配置加载报错

**查看具体错误**：
```bash
source ~/.zshrc 2>&1
```

**常见错误**：
- 文件不存在：检查路径是否正确
- 权限问题：`chmod 644 ~/.zshrc`

---

## 功能验证

安装完成后，打开新终端验证以下功能：

| 功能 | 验证方法 |
|------|----------|
| starship 主题 | 提示符显示彩色信息和图标 |
| 自动补全 | 输入 `git` 等命令时显示灰色建议 |
| 语法高亮 | 输入正确命令显示绿色，错误显示红色 |
| 历史搜索 | 按 `↑` 键搜索匹配的历史命令 |
| 图标显示 | git 分支、目录等图标正常显示 |

---

## 备份与恢复

### 备份当前配置

```bash
# 备份.zshrc
cp ~/.zshrc ~/.zshrc.backup

# 备份 oh-my-zsh 自定义配置
cp -r ~/.oh-my-zsh/custom ~/.oh-my-zsh/custom.backup
```

### 恢复配置

```bash
# 从备份恢复
cp ~/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

---

## 参考链接

- [oh-my-zsh 官网](https://ohmyz.sh/)
- [starship 官网](https://starship.rs/)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Ghostty 官网](https://ghostty.org/)
- [Catppuccin 主题](https://github.com/catppuccin/ghostty)
