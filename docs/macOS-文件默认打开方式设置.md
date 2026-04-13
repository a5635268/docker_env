# macOS 终端修改文件默认打开方式

要在 macOS 终端通过命令行修改**所有** `.md` 文件的默认打开方式，最专业且稳定的工具是 `duti`。macOS 自带的 `open` 命令本身并不提供"修改关联"的功能。

## 安装 duti

使用 Homebrew 安装：

```bash
brew install duti
```

## 设置 Typora 为 .md 的默认程序

```bash
duti -s abnerworks.Typora md all
```

## 命令解析

| 参数 | 说明 |
|------|------|
| `duti` | Designate User Type Index，专门处理 macOS 文件关联的工具 |
| `-s` | 设置 (Set) 命令 |
| `abnerworks.Typora` | Typora 的 Bundle ID（macOS 识别软件的唯一标识） |
| `md` | 目标扩展名 |
| `all` | 设置为查看、编辑等所有角色的默认应用 |

## 验证设置

设置完成后，直接使用 `open` 命令（无需 `-a` 参数）：

```bash
open ~/.claude/plans/iterative-chasing-sunbeam.md
```

如果文件在 Typora 中打开，说明设置已生效。

## 替代方案：Finder 手动操作

如果没有 Homebrew，可通过 Finder 手动设置：

1. 在 Finder 找到任意 `.md` 文件
2. 按 `Command + I` 打开 **显示简介**
3. 在"打开方式"栏选择 **Typora**
4. 点击下方的"全部更改..."按钮

此方式与 `duti` 命令效果相同。

## 常用 Bundle ID 参考

| 应用 | Bundle ID |
|------|-----------|
| Typora | `abnerworks.Typora` |
| VS Code | `com.microsoft.VSCode` |
| Sublime Text | `com.sublimetext.4` |
| MacDown | `com.macdown.macdown` |

## 扩展用法

设置其他文件类型的默认应用：

```bash
# JSON 文件用 VS Code 打开
duti -s com.microsoft.VSCode json all

# Python 文件用 VS Code 打开
duti -s com.microsoft.VSCode py all
```