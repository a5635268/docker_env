# ast-grep 结构搜索指南

> 基于 AST（抽象语法树）的代码结构搜索工具，超越文本匹配的精准搜索

---

## 概述

ast-grep 是结构化代码搜索和重写工具：

- ✅ **AST 精准匹配** - 不受格式、命名影响
- ✅ **多语言支持** - JavaScript、TypeScript、Python、Go、Rust 等
- ✅ **模式重写** - 支持结构化代码替换
- ✅ **规则系统** - 可配置复杂搜索规则
- ✅ **LSP 支持** - 集成到编辑器

---

## 安装

### CLI 安装

```bash
# Homebrew 安装 (macOS)
brew install ast-grep

# 验证安装
ast-grep --version
```

### 技能安装（Agent 指导）

```bash
# 安装 ast-grep 技能
npx skills add ast-grep/agent-skill -g -y
```

---

## 基础用法

### 搜索模式

```bash
# 基本搜索
ast-grep run -p 'console.log($A)' -l js

# 在文件中搜索
ast-grep run -p 'if ($COND) { $$$BODY }' -l js path/to/file.js

# 搜索目录
ast-grep run -p 'function $NAME($ARGS) { $$$BODY }' -l ts src/
```

### 重写模式

```bash
# 替换代码
ast-grep run -p 'console.log($A)' -r 'console.error($A)' -l js

# 复杂替换
ast-grep run -p 'var $VAR = $VAL' -r 'const $VAR = $VAL' -l js
```

---

## 元变量语法

| 元变量 | 说明 | 示例匹配 |
|--------|------|----------|
| `$A` | 单个 AST 节点 | `console.log($A)` 匹配任意参数 |
| `$VAR` | 变量名 | `var $VAR` 匹配任意变量名 |
| `$$$BODY` | 多个节点（代码块） | `{ $$$BODY }` 匹配任意代码块内容 |
| `$FUNC` | 函数名 | `function $FUNC` |
| `$ARGS` | 参数列表 | `$FUNC($ARGS)` |

---

## 常用模式

### JavaScript/TypeScript

```bash
# 查找 console.log
ast-grep run -p 'console.log($A)' -l js

# 查找箭头函数
ast-grep run -p '($ARGS) => $BODY' -l js

# 查找 async 函数
ast-grep run -p 'async function $NAME($ARGS) { $$$BODY }' -l js

# 查找 try-catch
ast-grep run -p 'try { $$$TRY } catch ($ERR) { $$$CATCH }' -l js

# 查找 useEffect
ast-grep run -p 'useEffect($FUNC, $DEPS)' -l tsx
```

### Python

```bash
# 查找 print 语句
ast-grep run -p 'print($A)' -l py

# 查找函数定义
ast-grep run -p 'def $NAME($ARGS): $$$BODY' -l py

# 查找类定义
ast-grep run -p 'class $NAME: $$$BODY' -l py

# 查找 import
ast-grep run -p 'import $MODULE' -l py
```

### Go

```bash
# 查找函数定义
ast-grep run -p 'func $NAME($ARGS) $RET { $$$BODY }' -l go

# 查找错误处理
ast-grep run -p 'if $ERR != nil { $$$BODY }' -l go

# 查找 defer
ast-grep run -p 'defer $CALL' -l go
```

---

## 使用场景

### 1. 代码重构

```bash
# var → const/let
ast-grep run -p 'var $VAR = $VAL' -r 'const $VAR = $VAL' -l js src/

# callback → async/await
ast-grep run -p '$OBJ.method($ARGS, function($ERR, $RES) { $$$BODY })' \
  -r 'const $RES = await $OBJ.method($ARGS); $$$BODY' -l js
```

### 2. 安全检查

```bash
# 查找 eval 使用
ast-grep run -p 'eval($A)' -l js

# 查找 innerHTML
ast-grep run -p '$EL.innerHTML = $A' -l js

# 查找 SQL 查询
ast-grep run -p 'execute($QUERY)' -l py --json
```

### 3. API 迁移

```bash
# React 类组件 → 函数组件
ast-grep run -p 'class $NAME extends React.Component { $$$BODY }' -l jsx

# 查找 componentWillMount
ast-grep run -p 'componentWillMount() { $$$BODY }' -l jsx
```

### 4. 代码审查

```bash
# 查找未处理的 Promise
ast-grep run -p '$PROMISE.then($FUNC)' -l js --json

# 查找空的 catch 块
ast-grep run -p 'try { $$$TRY } catch ($ERR) { }' -l js
```

---

## 规则配置

### 创建规则文件

```yaml
# sgconfig.yml
rules:
  - id: no-console-log
    language: js
    pattern: console.log($A)
    message: "Avoid console.log in production code"
    severity: warning
    fix: console.error($A)

  - id: use-const
    language: js
    pattern: var $VAR = $VAL
    message: "Use const instead of var"
    severity: error
    fix: const $VAR = $VAL
```

### 使用规则扫描

```bash
# 扫描项目
ast-grep scan

# 指定配置文件
ast-grep scan -c sgconfig.yml

# 输出 JSON
ast-grep scan --json
```

---

## AI Agent 工作流

### 加载技能指导

```bash
# 查看技能帮助
cat ~/.claude/skills/ast-grep/skill.md

# 技能内容指导如何编写 AST 规则
```

### 结构化搜索流程

```bash
# 1. 确定目标代码模式
# 2. 构造 AST 模式（使用元变量）
# 3. 搜索验证
ast-grep run -p 'pattern' -l lang path/

# 4. 确认匹配后重写
ast-grep run -p 'old_pattern' -r 'new_pattern' -l lang path/
```

---

## 输出格式

### JSON 输出

```bash
# JSON 格式结果
ast-grep run -p 'console.log($A)' -l js --json

# 输出结构
{
  "text": "console.log('hello')",
  "range": { "start": {...}, "end": {...} },
  "file": "example.js",
  "language": "JavaScript"
}
```

---

## 常见问题

### Q: 模式匹配不到？

确保语言正确，检查模式语法：
```bash
ast-grep run -p 'pattern' -l js --debug
```

### Q: 替换不生效？

使用 `-r` 参数并确保替换模式有效：
```bash
ast-grep run -p 'old' -r 'new' -l js --update-all
```

### Q: 如何处理多语言？

使用 `--lang` 指定或让 ast-grep 自动检测：
```bash
ast-grep run -p 'pattern'  # 自动检测
ast-grep run -p 'pattern' -l ts  # 指定 TypeScript
```

---

## 参考链接

- [ast-grep 官网](https://ast-grep.github.io/)
- [GitHub 仓库](https://github.com/ast-grep/ast-grep)
- [规则编写指南](https://ast-grep.github.io/guide/rule/introduction.html)
- [技能详情](https://skills.sh/ast-grep/agent-skill)