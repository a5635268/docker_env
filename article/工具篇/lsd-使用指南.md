# LSD - 现代化的 ls 替代工具使用指南

## 工具简介

**lsd** (LSDeluxe) 是一个现代化的 `ls` 命令替代品，由 Rust 编写，提供了丰富的颜色、图标和格式化选项，让目录列表更加美观和实用。

- **GitHub**: https://github.comlsd-rs/lsd
- **特点**: 图标支持、Git 集成、树形视图、丰富的颜色主题

---

## 安装方式

### macOS (Homebrew)

```bash
brew install lsd
```

### Linux

```bash
# Debian/Ubuntu
curl -LO https://github.com/lsd-rs/lsd/releases/download/0.23.1/lsd_0.23.1_amd64.deb
sudo dpkg -i lsd_0.23.1_amd64.deb

# Arch Linux
sudo pacman -S lsd

# Fedora
sudo dnf install lsd

# 通过 Cargo 安装
cargo install lsd
```

### Windows

```bash
# Scoop
scoop install lsd

# Chocolatey
choco install lsd
```

---

## 基本用法

### 替代 ls 命令

```bash
# 基本列表（显示图标和颜色）
lsd

# 详细列表
lsd -l

# 显示隐藏文件
lsd -a

# 显示所有文件（不包括 . 和 ..）
lsd -A

# 递归显示
lsd -R
```

---

## 核心特性

### 1. 文件图标

lsd 自动为不同类型的文件显示对应的图标（需要 Nerd Font 字体支持）

```bash
# 默认显示图标
lsd

# 禁用图标
lsd --icon never

# 使用 Unicode 图标（不需要 Nerd Font）
lsd --icon-theme unicode
```

### 2. 树形视图

```bash
# 显示目录树
lsd --tree

# 限制深度
lsd --tree --depth 2

# 只显示目录
lsd --tree --directory-only

# 递归显示并限制深度
lsd --tree --depth 3 docs/
```

输出示例：
```
.
├── CLAUDE.md
├── docs
│   ├── ai编程
│   └── 工具篇
├── examples
│   ├── go
│   ├── java
│   ├── php
│   └── python
└── README.md
```

### 3. Git 状态集成

```bash
# 显示 Git 状态（需要在 Git 仓库内）
lsd -l --git
```

Git 状态标记：
- `N` - 新文件 (New)
- `M` - 修改 (Modified)
- `D` - 删除 (Deleted)
- `R` - 重命名 (Renamed)
- `I` - 忽略 (Ignored)
- `-` - 未跟踪/无变化

### 4. 自定义显示块

```bash
# 自定义显示列
lsd -l --blocks permission,user,size,date,name

# 可用块：permission, user, group, size, date, name, inode, links, git
lsd -l --blocks permission,size,date,name
```

---

## 常用选项

| 选项 | 说明 |
|------|------|
| `-a, --all` | 显示隐藏文件（包括 . 和 ..） |
| `-A, --almost-all` | 显示隐藏文件（不包括 . 和 ..） |
| `-l, --long` | 详细列表格式 |
| `-h, --human-readable` | 人类可读的文件大小 |
| `-F, --classify` | 在文件名后添加类型指示符（*/=>@\|） |
| `-1, --oneline` | 每行显示一个条目 |
| `-R, --recursive` | 递归显示子目录 |
| `-r, --reverse` | 反向排序 |
| `-t, --timesort` | 按修改时间排序 |
| `-S, --sizesort` | 按文件大小排序 |
| `-X, --extensionsort` | 按扩展名排序 |
| `-G, --gitsort` | 按 Git 状态排序 |
| `-d, --directory-only` | 只显示目录本身 |

---

## 使用场景

### 场景 1：日常文件浏览

```bash
# 基本使用（带图标和颜色）
lsd

# 查看详细信息
lsd -l

# 查看隐藏文件
lsd -la
```

### 场景 2：项目结构查看

```bash
# 查看项目目录结构
lsd --tree --depth 2

# 只查看源代码目录
lsd --tree src/

# 查看当前目录树，限制深度
lsd --tree --depth 3
```

### 场景 3：Git 仓库管理

```bash
# 查看文件 Git 状态
lsd -l --git

# 按 Git 状态排序
lsd -l --git --sort git

# 查看未跟踪文件
lsd -la --git | grep "N"
```

### 场景 4：大文件查找

```bash
# 按大小排序
lsd -lS

# 按大小排序，反向显示（最大的在最后）
lsd -lS -r

# 显示目录总大小
lsd -l --total-size
```

### 场景 5：文件筛选

```bash
# 忽略某些文件
lsd -I "*.log" -I "node_modules"

# 忽略多个模式
lsd -I "*.tmp" -I ".git"
```

---

## 高级配置

### 创建配置文件

创建 `~/.config/lsd/config.yaml`：

```yaml
# 经典模式（类似传统 ls）
classic: false

# 图标设置
icons:
  when: auto
  theme: fancy
  separator: " "

# 颜色设置
colors:
  when: auto
  theme: default

# 显示块
blocks:
  - permission
  - user
  - size
  - date
  - name

# 日期格式
date: date

# 目录排序
group-dirs: first

# 权限显示格式
permission: rwx
```

### 设置别名（推荐）

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# 替代 ls
alias ls='lsd'

# 常用别名
alias l='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias lta='lsd --tree -a'
alias lg='lsd -l --git'
```

### 图标显示问题排查

如果图标显示为方块或问号：

```bash
# 1. 安装 Nerd Font
# 推荐：FiraCode Nerd Font, JetBrainsMono Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font

# 2. 在终端中设置字体为 Nerd Font
# iTerm2: Preferences → Profiles → Text → Font
# VS Code: settings.json 中设置 "terminal.integrated.fontFamily": "FiraCode Nerd Font"

# 3. 使用 Unicode 图标（无需 Nerd Font）
lsd --icon-theme unicode
```

---

## 对比 ls 和 lsd

| 功能 | ls | lsd |
|------|-----|-----|
| 颜色 | 有限 | 丰富的文件类型颜色 |
| 图标 | 不支持 | 支持文件类型图标 |
| 树形视图 | 不支持 | 内置支持 |
| Git 集成 | 不支持 | 显示文件 Git 状态 |
| 文件大小 | -lh | 默认人类可读 |
| 配置 | 环境变量 | YAML 配置文件 |

---

## 常用命令速查表

### 基础命令

```bash
lsd              # 彩色带图标列表
lsd -l           # 详细列表
lsd -la          # 显示隐藏文件
lsd -lh          # 人类可读大小
lsd -ltr         # 按时间排序（反向）
```

### 树形视图

```bash
lsd --tree                    # 完整树形
lsd --tree --depth 2          # 限制深度
lsd --tree --directory-only   # 仅目录
lsd --tree docs/              # 指定目录
```

### Git 相关

```bash
lsd -l --git          # 显示 Git 状态
lsd -lG               # 按 Git 状态排序
lsd -la --git         # 显示所有文件 Git 状态
```

### 排序

```bash
lsd -lS               # 按大小排序
lsd -lt               # 按时间排序
lsd -lX               # 按扩展名排序
lsd -lv               # 版本号排序
lsd -l --sort size    # 显式指定排序
```

---

## 与其他工具结合

### 配合 fzf 使用

```bash
# 交互式选择文件
lsd -1 | fzf

# 预览文件内容
lsd -1 | fzf --preview 'cat {}'
```

### 配合 bat 使用

```bash
# 查看文件列表后阅读文件
lsd -l && bat README.md
```

---

## 注意事项

1. **字体要求**: 完整图标支持需要 Nerd Font
2. **性能**: 在包含大量文件的目录中，首次渲染可能稍慢
3. **兼容性**: 大部分 ls 脚本可直接使用，但某些特定选项可能不兼容
4. **SSH 环境**: 远程服务器无图标支持时，使用 `--icon never`

---

## 相关资源

- **GitHub**: https://github.com/lsd-rs/lsd
- **Nerd Fonts**: https://www.nerdfonts.com/
- **配置示例**: https://github.com/lsd-rs/lsd#configuration
