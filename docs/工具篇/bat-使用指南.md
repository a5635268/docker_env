# BAT - 语法高亮的 cat 替代品使用指南

## 工具简介

**bat** 是一个带有语法高亮和 Git 集成的 `cat` 克隆版，用 Rust 编写。它支持多种编程语言的语法高亮、自动分页、Git 状态显示等功能。

- **GitHub**: https://github.com/sharkdp/bat
- **特点**: 语法高亮、Git 集成、自动分页、显示不可见字符、支持主题定制

---

## 安装方式

### macOS (Homebrew)

```bash
brew install bat
```

### Linux

```bash
# Debian/Ubuntu
sudo apt install bat
# 注意：安装后命令为 batcat，可以创建别名：
# alias bat=batcat

# Arch Linux
sudo pacman -S bat

# Fedora
sudo dnf install bat
```

### Cargo 安装

```bash
cargo install --locked bat
```

---

## 快速对比：bat vs cat

| 场景 | cat | bat |
|------|-----|-----|
| 显示文件 | `cat file.txt` | `bat file.txt` |
| 语法高亮 | 不支持 | 支持（自动识别语言） |
| 显示行号 | 不支持 | 支持 |
| Git 状态 | 不支持 | 显示修改标记 |
| 分页显示 | 不支持 | 自动分页（大文件） |
| 显示不可见字符 | 不支持 | 支持 |

---

## 基本用法

### 最简单的使用

```bash
# 查看文件（带语法高亮和行号）
bat README.md

# 查看多个文件（会显示文件名分隔）
bat file1.js file2.py

# 从标准输入读取
echo "Hello World" | bat

# 直接输出（类似 cat，用于管道）
bat --plain file.txt | grep "pattern"
```

### 常用选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `-n, --number` | 显示行号 | `bat -n file.py` |
| `-P, --plain` | 纯文本输出（无装饰）| `bat -P file.txt` |
| `-l, --language` | 指定语言 | `bat -l json file.txt` |
| `-r, --line-range` | 只显示指定行 | `bat -r 10:20 file.txt` |
| `-H, --highlight-line` | 高亮指定行 | `bat -H 5 file.txt` |
| `-A, --show-all` | 显示所有不可见字符 | `bat -A file.txt` |
| `-p, --paging` | 控制分页 | `bat -p never file.txt` |
| `--list-languages` | 列出支持的语言 | `bat --list-languages` |
| `--list-themes` | 列出可用主题 | `bat --list-themes` |
| `--theme` | 指定主题 | `bat --theme=GitHub file.md` |

---

## 使用场景

### 场景 1：查看代码文件

```bash
# Python 文件（自动语法高亮）
bat app.py

# JavaScript 文件
bat script.js

# JSON 文件
bat package.json

# YAML 文件
bat docker-compose.yml
```

### 场景 2：查看部分代码

```bash
# 只显示前 20 行
bat -r :20 README.md

# 显示第 10 到 30 行
bat -r 10:30 app.py

# 高亮显示第 15 行
bat -H 15 -r 10:20 app.py

# 显示特定函数（配合 grep）
bat app.py | grep -A 10 "def main"
```

### 场景 3：作为 cat 替代品

```bash
# 管道中使用（--plain 去除装饰）
bat config.yml | grep "database" | bat -l yaml

# 追加到文件
bat header.txt >> combined.txt

# 创建文件
bat > new-file.md << 'EOF'
# 标题
这是内容
EOF
```

### 场景 4：Git 集成

```bash
# 在 Git 仓库中查看文件
# 会显示修改标记：
# - 已修改的行显示为黄色
# - 新增的行显示为绿色
# - 删除的行显示为红色
bat src/main.py

# 查看特定分支的文件
bat branch:file.txt
```

### 场景 5：配合 fzf 预览

```bash
# 使用 bat 作为 fzf 的预览器
fd --type f | fzf --preview 'bat --color=always --line-range :50 {}'

# 在 yazi 中使用
# 已在 yazi/fzf 配置中内置
```

---

## 高级用法

### 1. 自定义主题

```bash
# 查看所有可用主题
bat --list-themes

# 使用特定主题
bat --theme=Dracula file.py
bat --theme=GitHub README.md

# 设置默认主题
export BAT_THEME="Dracula"
```

### 2. 配置 pager

```bash
# 禁用分页
bat --paging=never file.txt

# 始终使用分页
bat --paging=always file.txt

# 自动分页（默认，文件超过一屏时启用）
bat --paging=auto file.txt

# 指定 pager
export BAT_PAGER="less -RF"
```

### 3. 显示特殊字符

```bash
# 显示所有不可见字符
bat -A file.txt

# 显示 Tab 为 →
bat --tabs=4 file.txt

# 显示行尾换行符
bat --show-ends file.txt
```

### 4. 作为 man 的 pager

```bash
# 设置 man 使用 bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# 现在 man 命令会有语法高亮
man grep
```

---

## 配置文件

创建 `~/.config/bat/config`：

```bash
# 设置默认主题
--theme="Dracula"

# 设置 Tab 宽度
--tabs=4

# 禁用分页
--paging=never

# 设置样式（行号、网格、标题等）
--style="numbers,grid"
```

---

## 与 Yazi/FZF 集成

### 作为 fzf 的预览器

```bash
# 基本预览
fd --type f | fzf --preview 'bat --color=always {}'

# 限制预览行数（提高性能）
fd --type f | fzf --preview 'bat --color=always --line-range :50 {}'

# 高亮当前行
fd --type f | fzf --preview 'bat --color=always --highlight-line {2} {}'
```

### 在 Yazi 中使用

```toml
# ~/.config/yazi/keymap.toml
[[manager.prepend_keymap]]
on = ["F"]
run = '''
    shell '(
        file=$(fd --type f . . | fzf \
            --preview "bat --color=always --line-range :50 {}");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
```

---

## 常用别名

在 `~/.zshrc` 中添加：

```bash
# 替代 cat
alias cat='bat'

# 常用选项
alias c='bat'
alias cp='bat --plain'    # 类似原 cat，用于管道
alias cn='bat --number'   # 强制显示行号
alias ch='bat --header'   # 显示文件名

# 特定语言
alias cjson='bat -l json'
alias cyaml='bat -l yaml'
alias cpy='bat -l python'
```

**注意**：如果完全替代 cat，可能影响依赖 cat 行为的脚本，建议使用别名只在交互式 shell 中生效：

```bash
# 只在交互式 shell 中启用
if [ -n "$PS1" ]; then
    alias cat='bat --plain'
fi
```

---

## 与 cat 的兼容性

```bash
# bat 的 --plain 模式几乎完全兼容 cat
bat --plain file.txt

# 可以安全地用于脚本
bat --plain file.txt | grep "pattern"

# 不会破坏二进制文件检测
bat binary-file  # 自动检测并禁用高亮
```

---

## 注意事项

1. **分页器依赖**：需要安装 `less` 才能使用分页功能
2. **终端支持**：语法高亮需要支持真彩色的终端
3. **性能**：大文件（>10MB）建议使用 `--line-range` 限制输出
4. **二进制文件**：自动检测并禁用高亮，避免乱码

---

## 相关资源

- **GitHub**: https://github.com/sharkdp/bat
- **主题预览**: https://github.com/sharkdp/bat#highlighting-themes
- **与 fd 配合使用**: https://github.com/sharkdp/fd
