# TLDR - 简洁命令行帮助工具使用指南

## 工具简介

**tldr** (Too Long; Didn't Read) 是一个命令行工具，提供简洁实用的命令示例，替代冗长的 man 页面。它将常用命令的最典型用法以简洁明了的方式展示出来，让你快速找到需要的命令示例。

- **GitHub**: https://github.com/tldr-pages/tldr
- **特点**: 简洁、实用、社区驱动、多平台支持

---

## 安装方式

### macOS (Homebrew)

```bash
brew install tldr
```

### Linux

```bash
# Debian/Ubuntu
sudo apt install tldr

# Fedora
sudo dnf install tldr

# Arch Linux
sudo pacman -S tldr
```

### 其他方式

```bash
# npm 安装
npm install -g tldr

# Python 版本
pip install tldr
```

---

## 基本用法

### 查看命令帮助

```bash
# 基本用法
tldr <command>

# 示例：查看 tar 命令
tldr tar

# 示例：查看 git 命令
tldr git
```

### 常用选项

| 选项 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-v, --version` | 显示版本信息 |
| `-u, --update` | 更新本地数据库 |
| `-c, --clear-cache` | 清除本地缓存 |
| `-l, --list` | 列出数据库中所有条目 |
| `-p, --platform=PLATFORM` | 选择平台 (linux/osx/sunos/windows/common) |
| `-C, --color` | 强制彩色显示 |

---

## 使用示例

### 1. 查看 tar 归档命令

```bash
tldr tar
```

输出示例：
```
Archiving utility.
Often combined with a compression method, such as `gzip` or `bzip2`.

- Create an archive and write it to a file:
    tar cf path/to/target.tar path/to/file1 path/to/file2 ...

- Create a gzipped archive:
    tar czf path/to/target.tar.gz path/to/file1 ...

- Extract a compressed archive:
    tar xvf path/to/source.tar.gz

- List contents of a tar file:
    tar tvf path/to/source.tar
```

### 2. 查看 git 版本控制

```bash
tldr git
```

输出示例：
```
Distributed version control system.

- Create an empty Git repository:
    git init

- Clone a remote repository:
    git clone https://example.com/repo.git

- View status of local repository:
    git status

- Stage all changes:
    git add -A

- Commit changes:
    git commit -m "message"

- Push to remote:
    git push
```

### 3. 查看 Docker 命令

```bash
tldr docker
tldr docker-compose
```

### 4. 指定平台查看

```bash
# 查看 Linux 特定的命令用法
tldr -p linux ip

# 查看 macOS 特定的命令用法
tldr -p osx brew
```

---

## 典型使用场景

### 场景 1：快速回忆命令用法

当你忘记某个命令的具体参数时：

```bash
# 忘记如何压缩文件
tldr tar

# 忘记如何查找文件
tldr find

# 忘记如何查看端口占用
tldr lsof
```

### 场景 2：学习新命令

快速了解一个新命令的常用用法：

```bash
# 学习如何使用 jq 处理 JSON
tldr jq

# 学习如何使用 sed 进行文本替换
tldr sed

# 学习如何使用 awk 处理数据
tldr awk
```

### 场景 3：跨平台开发

在不同操作系统间切换时：

```bash
# 查看 Linux 版本的命令
tldr -p linux ps

# 查看 macOS 版本的命令
tldr -p osx pbcopy
```

### 场景 4：日常开发工作流

```bash
# SSH 相关
tldr ssh
tldr scp
tldr rsync

# 文件操作
tldr ls
tldr cp
tldr mv
tldr rm

# 文本处理
tldr grep
tldr cat
tldr less
tldr head
tldr tail

# 系统监控
tldr top
tldr htop
tldr df
tldr du
```

---

## 数据库管理

### 更新本地数据库

```bash
tldr --update
# 或
tldr -u
```

### 清除缓存

```bash
tldr --clear-cache
# 或
tldr -c
```

### 查看所有可用命令

```bash
tldr --list
# 或
tldr -l | head -20
```

---

## 对比 man 和 --help

| 特性 | man | --help | tldr |
|------|-----|--------|------|
| 详细程度 | 非常详细 | 较详细 | 简洁实用 |
| 学习曲线 | 高 | 中 | 低 |
| 典型示例 | 需要搜索 | 较少 | 丰富 |
| 阅读时间 | 长 | 中 | 短 |
| 适用场景 | 深入学习 | 查看选项 | 快速上手 |

**推荐用法**:
- 快速查找命令示例 → 使用 `tldr`
- 了解所有可用选项 → 使用 `--help`
- 深入学习命令原理 → 使用 `man`

---

## 常用命令速查表

### 文件操作

```bash
tldr tar      # 归档压缩
tldr zip      # ZIP 压缩
tldr unzip    # ZIP 解压
tldr rsync    # 文件同步
tldr find     # 文件查找
tldr locate   # 快速定位文件
```

### 文本处理

```bash
tldr grep     # 文本搜索
tldr sed      # 流编辑器
tldr awk      # 文本处理
tldr cut      # 字段提取
tldr sort     # 排序
tldr uniq     # 去重
tldr wc       # 字数统计
```

### 系统监控

```bash
tldr ps       # 进程查看
tldr top      # 系统监控
tldr htop     # 交互式进程查看
tldr df       # 磁盘空间
tldr du       # 目录大小
tldr free     # 内存使用
tldr netstat  # 网络状态
tldr lsof     # 打开的文件
```

### 网络工具

```bash
tldr curl     # HTTP 请求
tldr wget     # 文件下载
tldr ssh      # 远程登录
tldr scp      # 安全复制
tldr rsync    # 远程同步
tldr ping     # 网络测试
tldr dig      # DNS 查询
```

### 开发工具

```bash
tldr git      # 版本控制
tldr docker   # 容器管理
tldr npm      # Node.js 包管理
tldr pip      # Python 包管理
tldr brew     # macOS 包管理
```

---

## 进阶技巧

### 结合其他命令使用

```bash
# 搜索 tldr 中的命令
tldr -l | grep docker

# 结合 fzf 交互式查找
tldr -l | fzf --preview 'tldr {}'

# 保存常用命令示例
tldr tar > ~/cheatsheets/tar.txt
```

### 自定义别名

```bash
# 在 ~/.zshrc 或 ~/.bashrc 中添加
alias tl='tldr'
alias tlu='tldr --update'
alias tll='tldr --list'

# 快速更新并查看
tlu && tldr $1
```

---

## 注意事项

1. **首次使用需要联网**: 第一次运行时会自动下载命令数据库
2. **定期更新**: 建议定期运行 `tldr -u` 获取最新命令示例
3. **社区驱动**: 内容来自社区贡献，某些冷门命令可能覆盖不全
4. **替代非补充**: tldr 适合快速查询，深入学习仍需参考 man 文档

---

## 相关资源

- **官方仓库**: https://github.com/tldr-pages/tldr
- **在线版本**: https://tldr-pages.github.io/
- **客户端列表**: https://github.com/tldr-pages/tldr/wiki/tldr-pages-clients
