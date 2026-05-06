# jq JSON 处理器使用指南

> 强大的命令行 JSON 处理工具，AI Agent 处理结构化数据的必备利器

---

## 概述

jq 是专为 JSON 设计的命令行处理器：

- ✅ **轻量高效** - C 语言实现，性能优秀
- ✅ **丰富语法** - 支持过滤、映射、变换、聚合
- ✅ **流式处理** - 支持大文件流式解析
- ✅ **管道友好** - 与 shell 命令无缝集成
- ✅ **零依赖** - 单二进制文件，无运行时依赖

---

## 安装

```bash
# Homebrew 安装 (macOS)
brew install jq

# 验证安装
jq --version
```

---

## 基础语法

### 最简过滤器

```bash
# 格式化 JSON（默认输出）
echo '{"name":"test","value":123}' | jq .

# 输出：
{
  "name": "test",
  "value": 123
}
```

### 字段访问

```bash
# 获取单个字段
echo '{"name":"test"}' | jq '.name'
# 输出: "test"

# 获取嵌套字段
echo '{"user":{"name":"John"}}' | jq '.user.name'
# 输出: "John"

# 获取数组元素
echo '[1,2,3]' | jq '.[0]'
# 输出: 1

# 获取数组切片
echo '[1,2,3,4,5]' | jq '.[1:3]'
# 输出: [2, 3]
```

---

## 常用过滤器

### 数组操作

| 操作 | 示例 | 说明 |
|------|------|------|
| `.[]` | `jq '.[]'` | 遍历数组所有元素 |
| `.[n]` | `jq '.[2]'` | 获取第 n 个元素 |
| `.[-1]` | `jq '.[-1]'` | 获取最后一个元素 |
| `length` | `jq 'length'` | 数组/对象长度 |
| `sort` | `jq 'sort'` | 排序 |
| `reverse` | `jq 'reverse'` | 反转 |
| `unique` | `jq 'unique'` | 唯一值 |
| `flatten` | `jq 'flatten'` | 展平嵌套数组 |

### 对象操作

| 操作 | 示例 | 说明 |
|------|------|------|
| `keys` | `jq 'keys'` | 获取所有键 |
| `values` | `jq 'values'` | 获取所有值 |
| `has("key")` | `jq 'has("name")'` | 检查键是否存在 |
| `del(.key)` | `jq 'del(.name)'` | 删除字段 |

### 数值操作

| 操作 | 示例 | 说明 |
|------|------|------|
| `add` | `jq 'add'` | 数组求和 |
| `min` / `max` | `jq 'min'` / `jq 'max'` | 最小/最大值 |
| `floor` / `ceil` | `jq 'floor'` | 取整 |

---

## 高级语法

### 管道操作

```bash
# 链式处理
echo '[{"id":1,"val":10},{"id":2,"val":20}]' | jq '.[] | .val'
# 输出: 10, 20

# 多步转换
echo '{"items":[{"price":100},{"price":200}]}' | jq '.items[] | .price | . / 10'
# 输出: 10, 20
```

### map / select

```bash
# map：对每个元素应用表达式
echo '[1,2,3]' | jq 'map(. * 2)'
# 输出: [2, 4, 6]

# select：过滤元素
echo '[1,2,3,4,5]' | jq 'map(select(. > 3))'
# 输出: [4, 5]

# 组合使用
echo '[{"name":"a","age":20},{"name":"b","age":30}]' | \
  jq 'map(select(.age > 25) | .name)'
# 输出: ["b"]
```

### 构造新对象

```bash
# 构造新对象
echo '{"first":"John","last":"Doe"}' | jq '{name: (.first + " " + .last)}'
# 输出: {"name": "John Doe"}

# 数组构造
echo '{"a":1,"b":2}' | jq '[.a, .b]'
# 输出: [1, 2]
```

### 条件表达式

```bash
# if-then-else
echo '5' | jq 'if . > 3 then "big" else "small" end'
# 输出: "big"

# 复合条件
echo '{"score":85}' | jq 'if .score >= 90 then "A" elif .score >= 80 then "B" else "C" end'
# 输出: "B"
```

---

## 使用场景

### 1. API 响应处理

```bash
# 提取 GitHub API 用户名
gh api user | jq '.login'

# 提取仓库列表
gh repo list --json name,url | jq '.[].name'

# 统计 PR 数量
gh pr list --json number | jq 'length'
```

### 2. 日志分析

```bash
# 解析 JSON 日志
cat logs.json | jq 'select(.level == "error") | {time: .timestamp, msg: .message}'

# 统计错误类型
cat logs.json | jq 'select(.level == "error") | .type' | sort | uniq -c
```

### 3. 配置文件处理

```bash
# 修改 JSON 配置
cat config.json | jq '.debug = true' > config.new.json

# 合并配置
jq -s '.[0] * .[1]' base.json override.json > merged.json
```

### 4. 数据转换

```bash
# JSON 转 CSV
echo '[{"name":"a","val":1},{"name":"b","val":2}]' | \
  jq -r '(keys | @csv), (.[] | values | @csv)'
# 输出: "name,val"\n"a,1"\n"b,2"

# JSON 转 TSV
jq -r '.[] | [.name, .val] | @tsv' data.json
```

---

## AI Agent 工作流

### 提取结构化数据

```bash
# 从 API 响应提取特定字段
curl -s https://api.example.com/data | jq '.items[] | {id, name, status}'

# 过滤并格式化
gh pr list --json number,title,author | \
  jq '.[] | select(.author.login == "me") | "PR #\(.number): \(.title)"'
```

### 数据聚合统计

```bash
# 分组统计
echo '[{"type":"A","val":10},{"type":"B","val":20},{"type":"A","val":30}]' | \
  jq 'group_by(.type) | map({type: .[0].type, total: map(.val) | add})'

# 输出: [{"type":"A","total":40},{"type":"B","total":20}]
```

---

## 输出选项

| 选项 | 说明 | 示例 |
|------|------|------|
| `-r` | 去除引号，原始字符串 | `jq -r '.name'` |
| `-c` | 紧凑输出 | `jq -c '.'` |
| `-n` | 使用 null 作为输入 | `jq -n '{a:1}'` |
| `-s` | 将所有输入合并为数组 | `jq -s '.'` |
| `-f` | 从文件读取过滤器 | `jq -f filter.jq` |

---

## 常见问题

### Q: 处理大文件内存不足？

使用流式模式：
```bash
jq -c '.[]' large.json | while read item; do
  # 处理单个元素
done
```

### Q: 如何处理非 JSON 输入？

使用 `-R` 读取原始输入：
```bash
echo "hello" | jq -R .
# 输出: "hello"
```

### Q: 如何调试复杂过滤器？

使用 `debug` 输出中间结果：
```bash
echo '[1,2,3]' | jq 'map(debug | . * 2)'
```

---

## 参考链接

- [jq 官网](https://jqlang.github.io/jq/)
- [jq 手册](https://jqlang.github.io/jq/manual/)
- [jq Cookbook](https://github.com/stedolan/jq/wiki/Cookbook)