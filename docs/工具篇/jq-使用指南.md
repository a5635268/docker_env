# jq 使用指南

> jq 是一个轻量级的 JSON 处理命令行工具，专为 shell 脚本和命令行操作设计。

---

## 一、安装指南

### macOS

**使用 Homebrew（推荐）：**

```bash
brew install jq
```

**手动安装：**

```bash
curl -L -o /usr/local/bin/jq https://github.com/jqlang/jq/releases/latest/download/jq-macos-amd64
chmod +x /usr/local/bin/jq
```

### Linux

**Debian/Ubuntu：**

```bash
sudo apt-get update
sudo apt-get install jq
```

**CentOS/RHEL：**

```bash
sudo yum install epel-release
sudo yum install jq
```

### Windows

**使用 Chocolatey：**

```bash
choco install jq
```

**手动安装：**

1. 访问 [jq GitHub Releases](https://github.com/jqlang/jq/releases)
2. 下载 `jq-win64.exe`
3. 重命名为 `jq.exe`，放入 `C:\Windows\System32` 或配置环境变量

### 验证安装

```bash
jq --version
```

输出类似 `jq-1.6` 或更高版本表示安装成功。

---

## 二、核心用法

### 1. 基础字段提取

用点号访问 JSON 属性：

```bash
echo '{"name": "John", "age": 30}' | jq '.name'
# 输出："John"

echo '{"name": "John", "age": 30}' | jq '.age'
# 输出：30
```

### 2. 嵌套字段提取

用连续的点号访问嵌套属性：

```bash
echo '{"owner": {"login": "johndoe", "email": "john@example.com"}}' | jq '.owner.login'
# 输出："johndoe"

echo '{"user": {"profile": {"name": "John"}}}' | jq '.user.profile.name'
# 输出："John"
```

### 3. 数组元素提取

用方括号访问数组元素：

```bash
# 提取数组中每个元素的指定字段
echo '[{"login": "johndoe"}, {"login": "janesmith"}]' | jq '.[] | .login'
# 输出：
# "johndoe"
# "janesmith"

# 提取第一个元素
echo '[{"login": "johndoe"}, {"login": "janesmith"}]' | jq '.[0]'
# 输出：{"login": "johndoe"}

# 提取最后一个元素
echo '[{"login": "johndoe"}, {"login": "janesmith"}]' | jq '.[-1]'
# 输出：{"login": "janesmith"}

# 提取数组切片
echo '[1, 2, 3, 4, 5]' | jq '.[1:3]'
# 输出：[2, 3]
```

### 4. 过滤和条件

```bash
# 条件过滤：提取 age > 25 的用户
echo '[{"name": "John", "age": 30}, {"name": "Jane", "age": 20}]' | jq '.[] | select(.age > 25)'
# 输出：{"name": "John", "age": 30}

# 字符串匹配
echo '[{"name": "John"}, {"name": "Jane"}]' | jq '.[] | select(.name | contains("Jo"))'
# 输出：{"name": "John"}
```

### 5. 重组数据

用花括号选择需要的字段：

```bash
# 只保留指定字段
echo '[{"login": "johndoe", "url": "https://example.com", "id": 123}]' | jq '.[] | {login, url}'
# 输出：{"login": "johndoe", "url": "https://example.com"}

# 重命名字段
echo '[{"login": "johndoe"}]' | jq '.[] | {username: .login}'
# 输出：{"username": "johndoe"}

# 创建新结构
echo '[{"name": "John", "age": 30}]' | jq '.[] | {fullName: .name, isAdult: (.age > 18)}'
# 输出：{"fullName": "John", "isAdult": true}
```

### 6. 常用操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `.` | 当前对象 | `.name` |
| `.[]` | 遍历数组 | `.[] \| .id` |
| `.[]?` | 遍历数组（忽略错误） | `.[]? \| .id` |
| `select()` | 条件过滤 | `select(.age > 18)` |
| `map()` | 数组变换 | `map(.name)` |
| `keys` | 获取所有键 | `keys` |
| `length` | 获取长度 | `length` |
| `has()` | 检查键是否存在 | `has("name")` |
| `//` | 默认值 | `.name // "Unknown"` |
| `|` | 管道操作 | `.users \| .[]` |

---

## 三、使用场景

### 场景 1：解析 API 响应

```bash
# GitHub API 获取用户信息
curl -s https://api.github.com/users/octocat | jq '.login, .name, .public_repos'

# 获取仓库列表中的仓库名
curl -s https://api.github.com/users/octocat/repos | jq '.[] | .name'
```

### 场景 2：Docker 容器信息提取

```bash
# 获取所有运行中容器名
docker ps --format '{{.Names}}' | jq -R -s 'split("\n") | map(select(length > 0))'

# 获取容器 IP 地址
docker inspect <container_id> | jq '.[0].NetworkSettings.IPAddress'

# 获取容器端口映射
docker inspect <container_id> | jq '.[0].NetworkSettings.Ports'
```

### 场景 3：Kubernetes 资源查询

```bash
# 获取所有 Pod 名称
kubectl get pods -o json | jq '.items[].metadata.name'

# 获取处于 Running 状态的 Pod
kubectl get pods -o json | jq '.items[] | select(.status.phase == "Running") | .metadata.name'
```

### 场景 4：日志分析

```bash
# 从 JSON 日志中提取错误
cat app.log | jq 'select(.level == "ERROR") | .message'

# 统计各类型日志数量
cat app.log | jq -s 'group_by(.type) | map({type: .[0].type, count: length})'
```

### 场景 5：配置文件处理

```bash
# 从 package.json 提取依赖
cat package.json | jq '.dependencies'

# 从 docker-compose.yml 转换后的 JSON 提取服务
cat docker-compose.yml | yq -o json | jq '.services | keys'
```

### 场景 6：CI/CD 流水线

```bash
# 提取构建版本号
cat build-info.json | jq '.version'

# 检查测试是否通过
cat test-results.json | jq 'if .passed then "✅ Tests passed" else "❌ Tests failed" end'
```

---

## 四、实用技巧

### 1. 格式化输出

```bash
# 美化 JSON 格式
echo '{"name":"John","age":30}' | jq '.'

# 紧凑输出（单行）
echo '{"name":"John","age":30}' | jq -c '.'
```

### 2. 直接读取文件

```bash
# 从文件读取 JSON
jq '.name' data.json

# 多文件处理
jq -s '.[] | .name' file1.json file2.json
```

### 3. 变量引用

```bash
# 使用变量保存中间结果
jq '(.name | ascii_downcase) as $lower | {original: .name, lower: $lower}'
```

### 4. 函数定义

```bash
# 定义复用函数
jq 'def square: . * .; 5 | square'
# 输出：25
```

### 5. 错误处理

```bash
# 字段不存在时返回 null 而不是错误
echo '{}' | jq '.name'
# 输出：null

# 使用可选操作符
echo '{}' | jq '.name?'
# 输出：null
```

### 6. 与 shell 变量交互

```bash
# shell 变量传入 jq
NAME="John"
echo '{"users": ["John", "Jane"]}' | jq --arg name "$NAME" '.users | map(select(. == $name))'

# 输出 jq 结果到 shell 变量
RESULT=$(echo '{"count": 5}' | jq '.count')
echo "Count: $RESULT"
```

---

## 五、常见问题

### 命令找不到

检查 PATH 环境变量是否配置正确，或重启终端。

### 权限问题

- Linux/macOS：使用 `sudo` 安装
- Windows：使用管理员权限运行安装命令

### JSON 格式错误

确保输入的 JSON 格式正确，可使用 `jq '.'` 验证：

```bash
echo 'invalid json' | jq '.'  # 会显示错误信息
```

### 特殊字符处理

使用双引号包裹字符串，反斜杠转义：

```bash
echo '{"path": "C:\\Users\\John"}' | jq '.path'
```

---

## 六、学习资源

- [官方文档](https://jqlang.github.io/jq/)
- [jq 官方手册](https://jqlang.github.io/jq/manual/)
- [GitHub 仓库](https://github.com/jqlang/jq)
- [在线练习](https://jqplay.org/)

---

## 七、快速参考卡片

```bash
# 基础
jq '.field'                    # 提取字段
jq '.nested.field'             # 嵌套字段
jq '.[0]'                      # 数组索引
jq '.[]'                       # 遍历数组

# 过滤
jq 'select(.age > 18)'         # 条件过滤
jq 'map(.name)'                # 数组变换

# 重组
jq '{a, b}'                    # 选择字段
jq '{x: .a}'                   # 重命名

# 工具
jq 'keys'                      # 所有键
jq 'length'                    # 长度
jq 'has("key")'                # 检查键存在

# 选项
jq -c                          # 紧凑输出
jq -r                          # 原始字符串（无引号）
jq -s                          # 读取全部输入为数组
jq --arg x val                 # 传入变量
```
