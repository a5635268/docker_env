# Yazi - 极速终端文件管理器使用指南

## 工具简介

**Yazi** 是一个用 Rust 编写的极速终端文件管理器，提供异步 I/O、强大的插件系统和丰富的功能，是 ranger、lf 等工具的现代替代品。

- **GitHub**: https://github.com/sxyazi/yazi
- **特点**: 异步渲染、内置图像预览、多标签页、批量重命名、集成搜索

---

## 安装方式

### macOS (Homebrew)

```bash
brew install yazi
```

### Linux

```bash
# Arch Linux
sudo pacman -S yazi

# Debian/Ubuntu（需手动安装）
# 从 releases 下载 .deb 包安装
curl -LO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
```

### Cargo 安装

```bash
cargo install --locked yazi-fm yazi-cli
```

### 预览依赖（可选但推荐）

yazi 支持多种文件类型的预览，但需要安装对应的工具：

| 预览类型 | 依赖工具 | 安装命令 |
|---------|---------|---------|
| **视频** (mp4/mov/avi) | `ffmpegthumbnailer` | `brew install ffmpegthumbnailer` |
| **PDF** | `pdftoppm` (poppler) | `brew install poppler` |
| **图片** | yazi 内置支持 | 无需额外安装 |
| **JSON** | `jq` | `brew install jq` |
| **文本高亮** | `bat` | `brew install bat` |
| **压缩包** | `7z` | `brew install sevenzip` |

**一键安装所有预览依赖**：

```bash
brew install ffmpegthumbnailer poppler jq bat sevenzip fd ripgrep fzf zoxide file
```

> **注意**：如果不安装 `ffmpegthumbnailer`，视频文件将无法显示缩略图预览；如果不安装 `poppler`，PDF 文件无法预览。

---

## 快速启动

```bash
# 启动 yazi
yazi

# 在指定目录启动
yazi ~/Documents

# 启动后记录退出目录（配合别名使用）
yazi --cwd-file /tmp/yazi-cwd
```

---

## 核心快捷键

### 导航

| 按键 | 功能 |
|------|------|
| `↑` / `k` | 向上移动 |
| `↓` / `j` | 向下移动 |
| `←` / `h` | 返回上级目录 |
| `→` / `l` | 进入目录/打开文件 |
| `g` + `g` | 跳转到顶部 |
| `G` | 跳转到底部 |
| `~` | 跳转到 Home 目录 |
| `/` | 搜索 |
| `f` | 模糊查找（需 fzf） |

### 文件操作

| 按键 | 功能 |
|------|------|
| `Space` | 选择/取消选择 |
| `v` | 切换选择模式 |
| `y` | 复制 |
| `x` | 剪切 |
| `p` | 粘贴 |
| `P` | 粘贴（强制覆盖）|
| `d` | 删除（到回收站）|
| `D` | 永久删除 |
| `a` | 重命名 |
| `A` | 批量重命名 |
| `o` | **以默认软件打开文件** |
| `Enter` | 打开文件 |
| `r` | 刷新 |
| `.` | 显示/隐藏隐藏文件 |

### 标签页

| 按键 | 功能 |
|------|------|
| `t` | 新建标签页 |
| `1-9` | 切换到第 N 个标签页 |
| `[]` | 上一个/下一个标签页 |
| `{ }` | 移动当前标签页 |
| `w` | 关闭当前标签页 |
| `W` | 关闭所有其他标签页 |
| `q` | 退出 |
| `Q` | 强制退出 |

### 临时命令输入

| 按键 | 功能 |
|------|------|
| `:` | 进入**命令模式**，输入 yazi 内部命令 |
| `;` | 进入**shell 模式**，执行命令并等待返回 |
| `!` | 进入**shell 模式**，后台执行命令（不等待） |

#### 使用示例

```bash
# 按 : 进入命令模式，输入 yazi 内部命令
cd /usr/local       # 跳转到指定目录
select file.txt     # 选中指定文件
rename old.txt      # 重命名文件

# 按 ; 进入 shell 模式，执行命令后返回 yazi
ls -la              # 查看当前目录
mkdir new_folder    # 创建目录
vim file.txt        # 用 vim 编辑（退出后返回 yazi）

# 按 ! 执行后台命令（不阻塞 yazi）
code .              # 用 VS Code 打开当前目录
open file.pdf       # 用系统默认程序打开文件
nohup server &      # 启动后台服务
```

#### 常用内部命令（: 模式）

| 命令 | 说明 |
|------|------|
| `cd <path>` | 跳转到指定路径 |
| `select <file>` | 选中指定文件 |
| `rename <name>` | 重命名当前文件 |
| `remove` | 删除选中文件 |
| `copy` | 复制选中文件 |
| `paste` | 粘贴到当前目录 |
| `hidden` | 切换隐藏文件显示 |
| `search <pattern>` | 搜索文件 |

### 预览

| 按键 | 功能 |
|------|------|
| `z` | 切换预览 |
| `Z` | 切换所有预览 |
| `Ctrl + ↑/↓` | 预览向上/向下滚动 |

### 搜索与筛选

| 按键 | 功能 |
|------|------|
| `/` | 搜索当前目录 |
| `?` | 搜索内容（需 ripgrep）|
| `Ctrl + s` | 筛选模式 |
| `Esc` | 取消搜索/筛选 |

### 复制路径

| 按键 | 功能 | 复制内容示例 |
|------|------|-------------|
| `y` `p` | 复制绝对路径 | `/Users/mac/project/main.go` |
| `y` `n` | 复制文件名 | `main.go` |
| `y` `d` | 复制所在目录路径 | `/Users/mac/project` |

> **操作方式**：先按 `y`，松开后立即按第二个字母。

#### 自定义快捷键（推荐）

在 `~/.config/yazi/keymap.toml` 中添加更直观的映射（避免使用 `Ctrl+c` 等终端保留键）：

```toml
# ========== 复制路径快捷键 ==========

# c + p - 复制当前文件绝对路径到剪贴板
[[manager.prepend_keymap]]
on = ["c", "p"]
run = '''
    shell 'echo "$1" | pbcopy' --confirm
'''
desc = "Copy absolute path to clipboard"

# c + n - 复制当前文件名到剪贴板
[[manager.prepend_keymap]]
on = ["c", "n"]
run = '''
    shell 'basename "$1" | pbcopy' --confirm
'''
desc = "Copy file name to clipboard"

# c + d - 复制当前文件所在目录路径到剪贴板
[[manager.prepend_keymap]]
on = ["c", "d"]
run = '''
    shell 'dirname "$1" | pbcopy' --confirm
'''
desc = "Copy directory path to clipboard"
```

| 自定义快捷键 | 功能 | 说明 |
|-------------|------|------|
| `c` `p` | 复制绝对路径 | 先按 `c`，再按 `p` |
| `c` `n` | 复制文件名 | 先按 `c`，再按 `n` |
| `c` `d` | 复制目录路径 | 先按 `c`，再按 `d` |

> **注意**：不要使用 `Ctrl+c`，这是终端的中断信号，会导致 yazi 直接退出。

### 全局搜索（需配置）

| 按键 | 功能 |
|------|------|
| `F` | 全局递归搜索文件（跨所有子目录）|
| `g` + `f` | 搜索文件并跳转到其所在目录 |
| `g` + `d` | 全局搜索目录并跳转 |
| `Ctrl` + `f` | 当前目录搜索（不递归）|

---

## 使用场景

### 场景 1：日常文件管理

```bash
# 启动 yazi
yazi

# 基本操作：
# - j/k 上下移动
# - h/l 进出目录
# - Space 选择文件
# - y 复制，d 删除，x剪切
# - p 粘贴
```

### 场景 2：快速跳转目录（目录跟随）

#### 方式一：配合 zoxide 使用

```bash
# 在 ~/.zshrc 中添加：
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# 使用
yy              # 启动 yazi
yy ~/projects   # 在指定目录启动
# 退出 yazi 时自动切换到当前所在目录
```

#### 方式二：命令行全局搜索后跳转

```bash
# 在 ~/.zshrc 中添加：

# 全局搜索文件并打开 yazi 定位
function yyf() {
    local file
    local search_dir="${1:-.}"
    file=$(fd --type f --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}' \
            --height 80% --reverse --border --prompt "🔍 File> " \
            --header "ESC: Cancel | Enter: Open in yazi")
    if [ -n "$file" ]; then
        local dir=$(dirname "$file")
        local base=$(basename "$file")
        echo "Opening: $dir/$base"
        cd "$dir" && yazi --select "$base"
    fi
}

# 全局搜索目录并打开 yazi
function yyd() {
    local dir
    local search_dir="${1:-.}"
    dir=$(fd --type d --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'lsd --tree --depth 2 {}' \
            --height 80% --reverse --border --prompt "📁 Dir> " \
            --header "Enter: Open in yazi")
    if [ -n "$dir" ]; then
        echo "Opening: $dir"
        cd "$dir" && yazi
    fi
}

# 使用方式
# ┌────────────────────────────────────────────────────────────────┐
# │ 重要：参数是「搜索目录范围」，不是搜索关键词！                    │
# │ 关键词需要在 fzf 交互界面中输入                                  │
# └────────────────────────────────────────────────────────────────┘

yyf              # 当前目录搜索 → 启动后输入关键词
yyf ~/docs       # 指定目录范围 → 启动后输入关键词
yyf /Users/mac   # 指定目录范围 → 启动后输入关键词

yyd              # 当前目录搜索子目录 → 启动后输入关键词
yyd ~/Projects   # 指定目录范围 → 启动后输入关键词
```

#### 参数说明

| 命令 | 参数作用 | 搜索关键词输入位置 |
|------|---------|------------------|
| `yyf` | 无参数时默认当前目录 `.` | fzf 交互界面 |
| `yyf ~/docs` | 指定搜索范围为 `~/docs` | fzf 交互界面 |
| `yyf zcf` | ❌ 错误用法（把 `zcf` 当成目录） | - |

> **正确用法**：先启动 `yyf`，然后在弹出的 fzf 界面中输入关键词进行模糊搜索。

### 场景 3：批量操作

```bash
# 1. 启动 yazi
yazi

# 2. 使用 Space 或 v 选择多个文件

# 3. 批量重命名：按 A
#    - 支持正则替换
#    - 支持序号重命名
#    - 实时预览效果

# 4. 批量复制/移动：按 y/x 然后 p
```

### 场景 4：文件搜索

```bash
# 在 yazi 中：
# /          - 快速搜索当前目录
# Ctrl + s   - 筛选显示
# f          - fzf 模糊查找（需安装 fzf）

# 配合 ripgrep：
# ?          - 全文搜索文件内容
```

### 场景 5：预览文件

```bash
# 在 yazi 中：
# - 右侧面板自动预览文件内容
# - z 切换预览开关
# - Ctrl + ↑/↓ 滚动预览
# - 支持图片、视频、PDF、代码高亮、JSON 等
```

#### 预览功能对照表

| 文件类型 | 预览效果 | 依赖要求 |
|---------|---------|---------|
| 图片 (png/jpg/gif) | 显示缩略图 | 无需依赖 |
| 视频 (mp4/mov/avi) | 显示视频帧缩略图 | 需要 `ffmpegthumbnailer` |
| PDF | 显示首页渲染图 | 需要 `poppler` |
| JSON | 语法高亮格式化 | 需要 `jq` |
| 代码文件 | 语法高亮显示 | 需要 `bat` |
| 压缩包 | 显示内容列表 | 需要 `sevenzip` |

> 如果某些文件无法预览，请检查对应依赖是否已安装。

### 场景 6：全局文件搜索（跨目录）

yazi 默认按 `f` 只在当前目录搜索，要实现跨目录递归搜索，需要配置 keymap.toml。

#### 在 yazi 中配置全局搜索

创建 `~/.config/yazi/keymap.toml`：

```toml
# F - 全局递归搜索文件
[[manager.prepend_keymap]]
on = ["F"]
run = '''
    shell '(
        file=$(fd --type f --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 80% --reverse --border --prompt "🔍 Global File> ");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Global recursive file search"

# g + f - 搜索文件并跳转到其目录
[[manager.prepend_keymap]]
on = ["g", "f"]
run = '''
    shell '(
        file=$(fd --type f --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 80% --reverse --border --prompt "🔍 Jump to Dir> ");
        if [ -n "$file" ]; then
            ya cd "$(dirname "$file")";
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Jump to directory containing file"

# g + d - 全局搜索目录
[[manager.prepend_keymap]]
on = ["g", "d"]
run = '''
    shell '(
        dir=$(fd --type d --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "lsd --tree --depth 2 {}" \
            --height 80% --reverse --border --prompt "📁 Global Dir> ");
        if [ -n "$dir" ]; then
            ya cd "$dir";
        fi
    )' --confirm
'''
desc = "Global directory search and cd"

# Ctrl + f - 当前目录搜索
[[manager.prepend_keymap]]
on = ["C-f"]
run = '''
    shell '(
        file=$(fd --type f --max-depth 1 . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 60% --reverse --border --prompt "📄 Current Dir> ");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Current directory file search"
```

#### 使用方式

```bash
# 在 yazi 界面内：
F           # 全局递归搜索文件（所有子目录）
g + f       # 搜索文件并跳转到其所在目录
g + d       # 搜索目录并跳转
Ctrl + f    # 仅在当前目录搜索
```

---

## 配置文件

### 创建配置目录

```bash
mkdir -p ~/.config/yazi
```

### 基本配置 (yazi.toml)

```toml
[manager]
# 显示隐藏文件
show_hidden = false
# 排序方式: alphabetical, natural, size, modified
sort_by = "natural"
# 排序方向: asc, desc
sort_dir = "asc"
# 显示文件大小
show_size = true

[preview]
# 预览最大文件大小 (MB)
max_size = 10485760
# 图片预览质量
image_quality = 75
# 是否显示图片预览
tab_size = 2

[opener]
# 自定义打开方式
edit = [
	{ run = 'nvim "$@"', block = true, for = "unix" },
	{ run = 'code "%"', orphan = true, for = "windows" },
]

[open]
# 默认打开规则
rules = [
	{ mime = "text/*", use = "edit" },
	{ mime = "image/*", use = "open" },
	{ mime = "video/*", use = "open" },
]
```

### 按键绑定 (keymap.toml)

```toml
[[manager.prepend_keymap]]
# 自定义快捷键
on = [ "g", "r" ]
run = 'cd ~/Projects'
desc = "Go to Projects"

[[manager.prepend_keymap]]
on = [ "g", "d" ]
run = 'cd ~/Downloads'
desc = "Go to Downloads"
```

### 主题配置 (theme.toml)

```toml
[manager]
# 文件列表配色
hovered = { bg = "#3b4252", bold = true }
selected = { bg = "#4c566a" }

# 文件类型颜色
[filetype]
rules = [
	{ mime = "image/*", fg = "#88c0d0" },
	{ mime = "video/*", fg = "#bf616a" },
	{ mime = "audio/*", fg = "#b48ead" },
	{ mime = "application/zip", fg = "#ebcb8b" },
	{ name = "*/", fg = "#81a1c1", bold = true },
]
```

---

## 集成其他工具

### 与 fzf 集成

yazi 结合 fzf 可以实现强大的全局文件搜索功能。

#### 安装依赖

```bash
brew install fzf fd bat
```

#### 配置 keymap.toml

```bash
mkdir -p ~/.config/yazi
cat > ~/.config/yazi/keymap.toml << 'EOF'
# F - 全局递归搜索文件（跨所有子目录）
[[manager.prepend_keymap]]
on = ["F"]
run = '''
    shell '(
        file=$(fd --type f --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 80% --reverse --border --prompt "🔍 Global File> ");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Global recursive file search"

# g + f - 搜索文件并跳转到其所在目录
[[manager.prepend_keymap]]
on = ["g", "f"]
run = '''
    shell '(
        file=$(fd --type f --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 80% --reverse --border --prompt "🔍 Jump to Dir> ");
        if [ -n "$file" ]; then
            ya cd "$(dirname "$file")";
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Jump to directory containing file"

# g + d - 全局搜索目录并跳转
[[manager.prepend_keymap]]
on = ["g", "d"]
run = '''
    shell '(
        dir=$(fd --type d --hidden --follow --exclude .git . . 2>/dev/null | fzf \
            --preview "lsd --tree --depth 2 {}" \
            --height 80% --reverse --border --prompt "📁 Global Dir> ");
        if [ -n "$dir" ]; then
            ya cd "$dir";
        fi
    )' --confirm
'''
desc = "Global directory search and cd"

# Ctrl + f - 当前目录搜索（不递归）
[[manager.prepend_keymap]]
on = ["C-f"]
run = '''
    shell '(
        file=$(fd --type f --max-depth 1 . . 2>/dev/null | fzf \
            --preview "bat --color=always --line-range :50 {} 2>/dev/null || cat {}" \
            --height 60% --reverse --border --prompt "📄 Current Dir> ");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
desc = "Current directory file search"
EOF
```

#### 使用方法

```bash
# 在 yazi 界面内：
F           # 全局递归搜索文件（所有子目录）
g + f       # 搜索文件并跳转到其所在目录
g + d       # 搜索目录并跳转
Ctrl + f    # 仅在当前目录搜索
```

#### 命令行配合

```bash
# 在 ~/.zshrc 中添加：

# 命令行全局搜索文件并打开 yazi
function yyf() {
    local file=$(fd --type f . "${1:-.}" 2>/dev/null | fzf --preview 'bat --color=always {}')
    [ -n "$file" ] && cd "$(dirname "$file")" && yazi --select "$(basename "$file")"
}

# 命令行全局搜索目录并打开 yazi
function yyd() {
    local dir=$(fd --type d . "${1:-.}" 2>/dev/null | fzf --preview 'lsd --tree --depth 2 {}')
    [ -n "$dir" ] && cd "$dir" && yazi
}

# 使用方式（参数是搜索范围，关键词在界面输入）
yyf              # 当前目录搜索 → 启动后输入关键词
yyf ~/Projects   # 指定目录范围 → 启动后输入关键词
yyd ~/Documents  # 指定目录范围 → 启动后输入关键词
```

### 与 zoxide 集成

```bash
# 在 yazi 中使用 z 快速跳转
# 需先安装配置 zoxide
brew install zoxide
```

### 与编辑器集成

```bash
# 在 yazi.toml 中配置：
[opener]
edit = [
	{ run = 'nvim "$@"', block = true },  # 使用 neovim
]
```

---

## 常用别名推荐

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

### 基础别名

```bash
alias y='yazi'
alias yp='yazi ~/Projects'
alias yd='yazi ~/Downloads'
alias yc='yazi ~/.config'
```

### 智能退出函数

```bash
# 启动 yazi 并自动切换到退出时的目录
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

### 全局搜索函数（配合 fzf）

```bash
# 全局搜索文件并打开 yazi 定位
function yyf() {
    local file
    local search_dir="${1:-.}"
    file=$(fd --type f --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}' \
            --height 80% --reverse --border --prompt "🔍 File> " \
            --header "ESC: Cancel | Enter: Open in yazi")
    if [ -n "$file" ]; then
        local dir=$(dirname "$file")
        local base=$(basename "$file")
        echo "Opening: $dir/$base"
        cd "$dir" && yazi --select "$base"
    fi
}

# 全局搜索目录并打开 yazi
function yyd() {
    local dir
    local search_dir="${1:-.}"
    dir=$(fd --type d --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'lsd --tree --depth 2 {}' \
            --height 80% --reverse --border --prompt "📁 Dir> " \
            --header "Enter: Open in yazi")
    if [ -n "$dir" ]; then
        echo "Opening: $dir"
        cd "$dir" && yazi
    fi
}
```

### 使用示例

```bash
yy              # 启动 yazi，退出后自动切换目录
yy ~/Projects   # 在指定目录启动

# yyf/yyd 参数是搜索范围，关键词在 fzf 界面输入
yyf             # 当前目录范围 → 在界面输入关键词
yyf ~/Projects  # 指定目录范围 → 在界面输入关键词

yyd             # 当前目录范围 → 在界面输入关键词
yyd ~/Documents # 指定目录范围 → 在界面输入关键词
```

> **注意**：`yyf zcf` 是错误用法，会把 `zcf` 当成目录名而非关键词。正确做法是 `yyf` 启动后在界面中输入 `zcf`。

---

## 对比传统工具

| 特性 | ranger | lf | yazi |
|------|--------|-----|------|
| 语言 | Python | Go | Rust |
| 速度 | 较慢 | 快 | 极速（异步）|
| 图像预览 | 依赖外部 | 不支持 | 内置支持 |
| 批量重命名 | 支持 | 不支持 | 内置支持 |
| 多标签页 | 支持 | 不支持 | 支持 |
| 插件系统 | 支持 | 有限 | 支持 |

---

## 注意事项

1. **终端要求**: 需要支持 Unicode 和真彩色的终端（推荐 iTerm2、WezTerm、Ghostty）
2. **图像预览**: 需要终端支持图像协议（iTerm2 原生支持、kitty 支持）
3. **性能**: 在大目录（数万个文件）中仍能流畅运行
4. **学习曲线**: 快捷键与 vim 类似，vim 用户上手快

---

## 相关资源

- **GitHub**: https://github.com/sxyazi/yazi
- **官方文档**: https://yazi-rs.github.io/
- **插件仓库**: https://github.com/yazi-rs/plugins
- **示例配置**: https://github.com/yazi-rs/yazi/tree/main/yazi-config/preset
