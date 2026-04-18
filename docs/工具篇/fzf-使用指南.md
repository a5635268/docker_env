# FZF - 命令行模糊查找器使用指南

## 工具简介

**fzf** 是一个通用的交互式模糊查找器，可以与任何列表一起使用。它实现了模糊匹配算法，让你快速通过输入部分字符就能找到想要的结果。

- **GitHub**: https://github.com/junegunn/fzf
- **特点**: 模糊匹配、实时预览、多选支持、高度可定制

---

## 安装方式

### macOS (Homebrew)

```bash
brew install fzf

# 安装 shell 集成（可选但推荐）
/usr/local/opt/fzf/install
```

### Linux

```bash
# Git 安装
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Debian/Ubuntu
sudo apt install fzf

# Arch Linux
sudo pacman -S fzf

# Fedora
sudo dnf install fzf
```

### 验证安装

```bash
fzf --version
```

---

## 基本用法

### 最简单的使用

```bash
# 从标准输入读取列表，输出选中的行
cat file.txt | fzf

# 或者
ls | fzf

# 选择后输出到文件
ls | fzf > selected.txt
```

### 快捷键

| 按键 | 功能 |
|------|------|
| `Ctrl + j/k` 或 `↓/↑` | 上下移动 |
| `Ctrl + n/p` | 下/上一个匹配项 |
| `Enter` | 确认选择 |
| `Esc` / `Ctrl + g` | 取消 |
| `Ctrl + c` / `Ctrl + q` | 退出 |
| `Tab` | 多选（标记当前项）|
| `Shift + Tab` | 取消选择 |
| `Ctrl + a` | 全选 |
| `Ctrl + d` | 删除当前行 |
| `Ctrl + u` | 向上翻半页 |
| `Ctrl + d` | 向下翻半页 |
| `Ctrl + /` | 切换布局 |

---

## 搜索模式

### 模糊匹配（默认）

```bash
# 输入 "abc" 匹配包含 a、b、c 的任意顺序的项
# "abc" 可以匹配 "abc", "acb", "cba", "xaxbxcx" 等
ls | fzf
```

### 精确匹配

```bash
# 使用 ' 前缀表示精确匹配（顺序敏感）
ls | fzf --exact

# 或者在搜索框输入时：
# 'abc  - 精确匹配包含 abc 的项（顺序敏感）
# ^abc  - 匹配以 abc 开头的项
# abc$  - 匹配以 abc 结尾的项
# !abc  - 排除包含 abc 的项
```

### 组合搜索

```bash
# 在 fzf 搜索框中：
# "src test"    - 同时包含 src 和 test
# "src | test"  - 包含 src 或 test
# "'src 'test"  - 同时精确包含 src 和 test
# "src !test"   - 包含 src 但不包含 test
```

---

## 常用选项

### 界面选项

```bash
# 指定高度（百分比或固定行数）
ls | fzf --height 40%
ls | fzf --height 20

# 反向布局（搜索框在顶部）
ls | fzf --reverse

# 添加边框
ls | fzf --border

# 带标签的边框
ls | fzf --border-label="选择文件"

# 预览窗口
ls | fzf --preview 'cat {}'
ls | fzf --preview 'bat --color=always {}'
```

### 搜索选项

```bash
# 忽略大小写
ls | fzf -i

# 智能大小写（默认）
ls | fzf --smart-case

# 精确匹配模式
ls | fzf --exact

# 多选模式
ls | fzf --multi
ls | fzf -m

# 预选择第一行
ls | fzf --select-1

# 只有一项时自动退出
ls | fzf --exit-0
```

### 输入/输出选项

```bash
# 读取以 NUL 分隔的输入
find . -print0 | fzf --read0 --print0

# ANSI 颜色支持
ls --color=always | fzf --ansi

# 限制结果数量
ls | fzf --tail 100
```

---

## 使用场景

### 场景 1：快速文件查找

```bash
# 查找当前目录的文件
find . -type f | fzf

# 查找并打开文件
find . -type f | fzf --preview 'cat {}' | xargs -o vim

# 使用 fd 更快查找（需安装 fd）
fd --type f | fzf
```

### 场景 2：历史命令搜索

```bash
# 搜索历史命令
history | fzf

# 更好的历史搜索（结合 shell 集成）
# 按 Ctrl + r 触发
```

### 场景 3：进程管理

```bash
# 查找并 kill 进程
ps aux | fzf | awk '{print $2}' | xargs kill -9

# 更简洁的方式
pgrep -a "" | fzf | awk '{print $1}' | xargs kill
```

### 场景 4：Git 操作

```bash
# 选择分支
git branch -a | fzf | xargs git checkout

# 选择 commit
git log --oneline | fzf | awk '{print $1}' | xargs git show

# 选择文件进行 git add
git status -s | fzf -m | awk '{print $2}' | xargs git add
```

### 场景 5：目录跳转

```bash
# 快速跳转到常用目录
# 结合 zoxide（推荐）
zoxide query --list | fzf | cd

# 或配合 autojump
j -l | fzf | awk '{print $2}' | cd
```

### 场景 6：多选批量操作

```bash
# 选择多个文件复制到目录
ls | fzf -m | xargs -I {} cp {} ~/backup/

# 选择多个文件删除（危险，请谨慎）
ls | fzf -m | xargs rm

# 选择多个文件移动
ls | fzf -m | xargs -I {} mv {} ~/target/
```

---

## Shell 集成

### 添加到 ~/.zshrc 或 ~/.bashrc

```bash
# 加载 fzf 的 shell 集成
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# 或
[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ] && source /usr/local/opt/fzf/shell/key-bindings.zsh
[ -f /usr/local/opt/fzf/shell/completion.zsh ] && source /usr/local/opt/fzf/shell/completion.zsh
```

### 快捷键（shell 集成后）

| 按键 | 功能 |
|------|------|
| `Ctrl + r` | 搜索历史命令 |
| `Ctrl + t` | 查找文件并插入 |
| `Alt + c` | 查找目录并切换 |

### 示例

```bash
# Ctrl + r - 搜索历史命令
# 输入关键词，选择后回车执行

# Ctrl + t - 在当前命令行插入文件路径
# vim <Ctrl+t> 选择文件

# Alt + c - 快速切换目录
# 直接跳转到选择的目录
```

---

## 高级用法

### 预览窗口

```bash
# 文件内容预览
ls | fzf --preview 'cat {}'

# 图片预览（需 kitty 或 iTerm2）
ls *.jpg | fzf --preview 'kitty icat {}'

# 目录预览
ls | fzf --preview 'ls -la {}'

# 预览在右侧，占 50% 宽度
ls | fzf --preview 'cat {}' --preview-window=right:50%

# 预览在底部
ls | fzf --preview 'cat {}' --preview-window=down:30%

# 跟随滚动预览
ls | fzf --preview 'cat {}' --preview-window=right:50%:wrap
```

### 自定义提示符

```bash
# 自定义提示符
ls | fzf --prompt="选择> "

# 自定义指针
ls | fzf --pointer="▶"

# 自定义标记
ls | fzf --multi --marker="✓"
```

### 环境变量

```bash
# 默认选项
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# 默认命令（Ctrl + t 使用）
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Ctrl + t 命令
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Alt + c 命令
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
```

---

## 与其他工具集成

### 与 Ripgrep 集成

```bash
# 实时搜索文件内容
rg --line-number --column --color=always "" | \
  fzf --ansi --delimiter=: --nth=3.. \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window=up:60%
```

### 与 Bat 集成

```bash
# 带语法高亮的预览
fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'
```

### 与 LSD 集成

```bash
# 彩色文件列表
lsd -1 --color=always | fzf --ansi --preview 'lsd -la --color=always {}'
```

### 在 Vim 中使用

```vim
" .vimrc 或 init.vim
set rtp+=/usr/local/opt/fzf

" 基本用法
:nmap <C-p> :FZF<CR>
:nmap <C-f> :Rg<CR>
```

### 与 Yazi 集成

在 yazi 中配置全局搜索快捷键，实现跨目录递归搜索。

#### 安装依赖

```bash
brew install fzf fd bat
```

> **依赖说明**:
> - `fzf` - 模糊查找界面
> - `fd` (推荐) - 比 find 更快更智能的文件搜索
> - `bat` (推荐) - 提供带语法高亮的文件预览

#### 1. 创建 yazi 配置文件

```bash
mkdir -p ~/.config/yazi
cat > ~/.config/yazi/keymap.toml << 'EOF'
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
EOF
```

#### 2. 在 yazi 中使用

| 快捷键 | 功能 |
|--------|------|
| `F` | 全局递归搜索文件 |
| `g` + `f` | 搜索文件并跳转到其目录 |
| `g` + `d` | 全局搜索目录并跳转 |

#### 3. 命令行函数（配合 yazi）

在 `~/.zshrc` 中添加：

```bash
# 全局搜索文件并打开 yazi 定位
function yyf() {
    local file
    local search_dir="${1:-.}"
    file=$(fd --type f --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'bat --color=always --line-range :50 {} 2>/dev/null || cat {}' \
            --height 80% --reverse --border --prompt "🔍 File> ")
    if [ -n "$file" ]; then
        cd "$(dirname "$file")" && yazi --select "$(basename "$file")"
    fi
}

# 全局搜索目录并打开 yazi
function yyd() {
    local dir
    local search_dir="${1:-.}"
    dir=$(fd --type d --hidden --follow --exclude .git . "$search_dir" 2>/dev/null | \
        fzf --preview 'lsd --tree --depth 2 {}' \
            --height 80% --reverse --border --prompt "📁 Dir> ")
    if [ -n "$dir" ]; then
        cd "$dir" && yazi
    fi
}
```


---

## 别名推荐

在 `~/.zshrc` 中添加：

### 基础别名

```bash
alias f='fzf'
alias fp='fzf --preview "bat --color=always --line-range :50 {}"'
alias fm='fzf -m'

# 文件查找
alias ff='fd --type f | fzf'
alias fd='fd --type d | fzf'

# 进程查找
alias fkill='ps aux | fzf | awk "{print \$2}" | xargs kill -9'

# Git 相关
alias fbr='git branch -a | fzf | xargs git checkout'
alias fco='git log --oneline | fzf | awk "{print \$1}" | xargs git checkout'
```

### 与 Yazi 配合的函数

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
        cd "$(dirname "$file")" && yazi --select "$(basename "$file")"
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
        cd "$dir" && yazi
    fi
}

# 智能 yazi 启动（退出时自动切换目录）
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

### 使用示例

```bash
# 命令行启动
yy              # 启动 yazi，退出后自动切换目录
yyf             # 递归搜索文件后打开 yazi
yyf ~/Projects  # 指定目录搜索
yyd             # 递归搜索目录
yyd ~/Documents # 指定目录搜索

# 在 yazi 内使用（需配置 keymap.toml）
# F           - 全局递归搜索文件
# g + f       - 搜索文件并跳转到其目录
# g + d       - 搜索目录并跳转
# Ctrl + f    - 当前目录搜索
```

### 其他实用函数

```bash
# 使用 fzf 的 cd
fcd() {
    local dir
    dir=$(fd --type d | fzf --preview 'lsd --tree --depth 2 {}') && cd "$dir"
}

# 使用 fzf 的 vim
fvim() {
    local file
    file=$(fzf --preview 'bat --color=always {}') && vim "$file"
}
```

---

## 注意事项

1. **性能**: 对大量数据（10万+行）可能需要限制输入或使用 `--tail`
2. **UTF-8**: 确保终端支持 UTF-8 以获得最佳显示效果
3. **快捷键冲突**: 部分终端可能与 `Alt + c` 有冲突
4. **预览命令**: 确保预览命令存在，否则会显示错误

---

## 相关资源

- **GitHub**: https://github.com/junegunn/fzf
- **Wiki**: https://github.com/junegunn/fzf/wiki
- **示例**: https://github.com/junegunn/fzf/wiki/Examples
