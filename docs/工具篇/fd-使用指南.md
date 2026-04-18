# FD - 友好的 find 替代品使用指南

## 工具简介

**fd** 是一个简单、快速、用户友好的 `find` 命令替代品，用 Rust 编写。它提供直观的语法、更快的搜索速度和彩色输出，是查找文件的理想工具。

- **GitHub**: https://github.com/sharkdp/fd
- **特点**: 语法简单、极速搜索、智能过滤、彩色输出、支持并行执行

---

## 安装方式

### macOS (Homebrew)

```bash
brew install fd
```

### Linux

```bash
# Debian/Ubuntu
sudo apt install fd-find
# 注意：安装后命令为 fdfind，可以创建别名：
# alias fd=fdfind

# Arch Linux
sudo pacman -S fd

# Fedora
sudo dnf install fd-find
```

### Cargo 安装

```bash
cargo install fd-find
```

---

## 快速对比：fd vs find

| 场景 | find | fd |
|------|------|-----|
| 查找文件 | `find . -name "*.txt"` | `fd .txt` |
| 查找目录 | `find . -type d -name "test"` | `fd -t d test` |
| 执行命令 | `find . -exec ls {} \;` | `fd -x ls` |
| 搜索速度 | 较慢 | 更快（Rust + 并行）|
| 语法复杂度 | 复杂 | 简洁直观 |
| 隐藏文件 | 默认包含 | 默认忽略 |

---

## 基本用法

### 最简单的搜索

```bash
# 查找包含 "readme" 的文件（不区分大小写）
fd readme

# 在当前目录及子目录查找所有 .md 文件
fd .md

# 查找以 "config" 开头的文件
fd "^config"
```

### 按类型搜索

```bash
# 只查找文件（默认）
fd -t f .txt

# 只查找目录
fd -t d node_modules

# 查找可执行文件
fd -t x

# 查找空文件或目录
fd -t e
```

### 常用选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `-t, --type` | 按类型搜索 | `fd -t f .js` |
| `-d, --max-depth` | 限制搜索深度 | `fd -d 2 .md` |
| `-H, --hidden` | 包含隐藏文件 | `fd -H .config` |
| `-I, --no-ignore` | 不忽略 .gitignore | `fd -I target` |
| `-L, --follow` | 跟随符号链接 | `fd -L .env` |
| `-E, --exclude` | 排除模式 | `fd -E node_modules .js` |
| `-x, --exec` | 执行命令 | `fd -t f -x rm` |
| `-X, --exec-batch` | 批量执行命令 | `fd -t f -X ls -l` |
| `-c, --case-sensitive` | 区分大小写 | `fd -c README` |
| `-g, --glob` | 使用 glob 模式 | `fd -g "*.min.js"` |

---

## 使用场景

### 场景 1：快速查找文件

```bash
# 查找所有 JavaScript 文件
fd .js

# 查找特定名称
fd config.yml

# 限制深度（只查当前目录和一级子目录）
fd -d 2 .md

# 使用正则表达式
fd "^test.*\.py$"
```

### 场景 2：查找并操作文件

```bash
# 查找并删除所有 .tmp 文件
fd .tmp -t f -x rm

# 批量重命名（将 .txt 改为 .bak）
fd .txt -t f -x mv {} {.}.bak

# 查找所有图片并复制到备份目录
fd -t f -e jpg -e png -e gif -x cp {} ~/backup/

# 批量压缩日志文件
fd .log -t f -X gzip
```

### 场景 3：结合其他工具

```bash
# 与 fzf 结合（推荐）
fd --type f | fzf --preview 'bat {}'

# 与 yazi 结合
fd --type f | fzf --preview 'bat {}' | xargs yazi --select

# 与 bat 结合查看文件
fd .md | xargs bat

# 与 ripgrep 结合搜索内容
fd .py -x rg 'TODO' {}
```

### 场景 4：排除特定目录

```bash
# 排除 node_modules 和 .git
fd .js -E node_modules -E .git

# 使用 .fdignore 文件（类似 .gitignore）
# 创建 ~/.fdignore
echo "node_modules" >> ~/.fdignore
echo "*.log" >> ~/.fdignore
```

### 场景 5：查找并批量处理

```bash
# 查找所有空目录并删除
fd -t d -t e -x rmdir

# 查找所有大于 1MB 的文件（配合其他命令）
fd -t f -x ls -lh | awk '$5 ~ /M|G/'

# 批量修改权限
fd .sh -t f -x chmod +x
```

---

## 高级用法

### 1. 使用正则表达式

```bash
# 查找以数字开头的文件
fd "^[0-9]+"

# 查找包含 "test" 或 "spec" 的文件
fd "(test|spec)"

# 查找特定命名格式的文件
fd "^[A-Z][a-z]+\.[a-z]+$"
```

### 2. 批量执行命令

```bash
# -x 对每个文件执行一次命令
fd .log -x gzip        # gzip 每个 .log 文件

# -X 批量执行（性能更好）
fd .log -X gzip        # 一次处理所有 .log 文件

# 使用占位符
fd .txt -x mv {} /backup/{/.}.bak
# {}    - 完整路径
# {/}   - 文件名
# {//}  - 父目录
# {/.}  - 无扩展名的文件名
# {.}   - 无扩展名的完整路径
```

### 3. 智能搜索

```bash
# 默认忽略 .gitignore 中指定的文件
fd .js
# 自动跳过 node_modules, target 等目录

# 显示被忽略的文件
fd .js -I

# 包含隐藏文件
fd .config -H
```

---

## 与 Yazi/FZF 集成

### Yazi 配置中使用

```toml
# ~/.config/yazi/keymap.toml
[[manager.prepend_keymap]]
on = ["F"]
run = '''
    shell '(
        file=$(fd --type f --hidden --follow --exclude .git . . | fzf \
            --preview "bat --color=always {}");
        if [ -n "$file" ]; then
            ya select "$file";
        fi
    )' --confirm
'''
```

### FZF 函数中使用

```bash
# 在 ~/.zshrc 中添加

# 搜索文件并打开
fvi() {
    local file
    file=$(fd --type f | fzf --preview 'bat --color=always {}') && vim "$file"
}

# 搜索目录并进入
cd() {
    if [ $# -eq 0 ]; then
        builtin cd
    else
        local dir
        dir=$(fd --type d | fzf --query "$1" --select-1) && builtin cd "$dir"
    fi
}
```

---

## 常用别名

在 `~/.zshrc` 中添加：

```bash
# 基础别名
alias ff='fd --type f'
alias fd='fd --type d'
alias fh='fd --hidden'

# 常用搜索
alias fjs='fd .js'
alias fpy='fd .py'
alias fmd='fd .md'

# 排除目录的搜索
alias fdn='fd -E node_modules -E .git -E target'
```

---

## 注意事项

1. **默认忽略隐藏文件**：需要使用 `-H` 选项
2. **遵循 .gitignore**：默认会忽略 git 忽略的文件，使用 `-I` 取消
3. **大小写不敏感**：默认不区分大小写，使用 `-c` 启用区分
4. **性能**：在大型项目中比 find 快 5-10 倍

---

## 相关资源

- **GitHub**: https://github.com/sharkdp/fd
- **文档**: https://github.com/sharkdp/fd#usage
- **与 bat 配合使用**: https://github.com/sharkdp/bat
