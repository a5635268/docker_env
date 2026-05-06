# silicon 代码截图指南

> 将代码片段转换为美观的图片，适合文档、演示和分享

---

## 概述

silicon 是基于 syntect 的代码截图生成器：

- ✅ **语法高亮** - 支持 150+ 编程语言
- ✅ **多种主题** - 内置丰富配色方案
- ✅ **自定义样式** - 字体、背景、阴影可配置
- ✅ **批量处理** - 支持文件夹批量生成
- ✅ **剪贴板支持** - 直接复制到剪贴板

---

## 安装

```bash
# Homebrew 安装 (macOS)
brew install silicon

# 验证安装
silicon --version
```

---

## 基础用法

### 从文件生成

```bash
# 基本截图
silicon code.py -o screenshot.png

# 指定语言和主题
silicon code.js -l JavaScript --theme Dracula -o screenshot.png
```

### 从 stdin 生成

```bash
# 从标准输入读取
echo 'console.log("Hello");' | silicon -l js -o screenshot.png

# 从剪贴板读取
silicon --from-clipboard -o screenshot.png
```

### 输出到剪贴板

```bash
# 直接复制到剪贴板
silicon code.py --to-clipboard
```

---

## 样式选项

### 主题

```bash
# 列出所有主题
silicon --list-themes

# 常用主题
silicon code.py --theme "Dracula" -o output.png
silicon code.py --theme "OneHalfDark" -o output.png
silicon code.py --theme "Solarized Dark" -o output.png
silicon code.py --theme "GitHub Dark" -o output.png
```

### 字体

```bash
# 列出可用字体
silicon --list-fonts

# 指定字体
silicon code.py --font "Hack" -o output.png

# 多字体（支持 fallback）
silicon code.py --font "Hack; SimSun=31" -o output.png
```

### 背景与边距

```bash
# 自定义背景色
silicon code.py --background "#1e1e1e" -o output.png

# 背景图片
silicon code.py --background-image bg.png -o output.png

# 边距设置
silicon code.py --pad-horiz 80 --pad-vert 100 -o output.png
```

### 行号与窗口

```bash
# 隐藏行号
silicon code.py --no-line-number -o output.png

# 隐藏窗口控件
silicon code.py --no-window-controls -o output.png

# 圆角禁用
silicon code.py --no-round-corner -o output.png

# 窗口标题
silicon code.py --window-title "main.py" -o output.png
```

---

## 使用场景

### 1. 技术文档插图

```bash
# 为文档生成代码截图
silicon src/main.rs --theme "Dracula" \
       --font "Fira Code" \
       --line-offset 1 \
       -o docs/images/main-code.png
```

### 2. 社交媒体分享

```bash
# 生成简洁的代码片段
echo 'const hello = () => console.log("Hello World");' | \
  silicon -l js \
          --theme "OneHalfDark" \
          --background "#282c34" \
          --no-line-number \
          --to-clipboard
```

### 3. 高亮特定行

```bash
# 高亮 1-3 行
silicon code.py --highlight-lines "1-3" -o output.png

# 高亮多个区域
silicon code.py --highlight-lines "1-3;7-9" -o output.png
```

### 4. 批量处理

```bash
# 批量生成目录下所有代码文件截图
for file in src/*.py; do
  silicon "$file" --theme "Dracula" -o "images/${file%.py}.png"
done
```

---

## AI Agent 工作流

### 快速代码展示

```bash
# 展示当前代码片段
cat interesting_code.py | silicon -l python \
    --theme "Dracula" \
    --font "Fira Code" \
    --background "#282c34" \
    --pad-horiz 40 \
    --pad-vert 60 \
    -o code-snippet.png
```

### 配合文档生成

```bash
# 为 README 生成主文件截图
silicon src/index.ts \
    --theme "GitHub Dark" \
    --window-title "index.ts" \
    --line-offset 1 \
    -o docs/assets/index.png
```

---

## 常用组合示例

```bash
# 完整定制化截图
silicon example.rs \
    --language Rust \
    --theme "Dracula" \
    --font "JetBrains Mono" \
    --background "#1a1b26" \
    --pad-horiz 50 \
    --pad-vert 80 \
    --shadow-blur-radius 20 \
    --shadow-color "#000000" \
    --highlight-lines "5-8" \
    --window-title "example.rs" \
    -o assets/example.png
```

---

## 常见问题

### Q: 中文显示乱码？

使用支持中文的字体：
```bash
silicon code.py --font "Hack; SimSun=31" -o output.png
```

### Q: 语言识别错误？

手动指定语言：
```bash
silicon file --language Python -o output.png
silicon file -l py -o output.png
```

### Q: 输出尺寸过大？

减小字体和边距：
```bash
silicon code.py --font-size 14 --pad-horiz 20 --pad-vert 30 -o output.png
```

---

## 参考链接

- [silicon GitHub](https://github.com/Aloxaf/silicon)
- [syntect 语法库](https://github.com/trishume/syntect)