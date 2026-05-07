# Utils 工具模块使用指南

Utils 模块提供通用的工具函数，包括分页查询、字符串处理、时间格式化、命名风格转换、Excel 导入导出等功能。

## 1. 核心概念

### 1.1 为什么需要工具模块？

工具模块封装常用的辅助功能：

- **分页工具**：简化数据库查询分页逻辑
- **字符串工具**：空白判断、HTTP 判断、大小写处理
- **时间格式化**：统一时间格式处理
- **命名转换**：驼峰与下划线互转（前后端数据对接）
- **Excel 工具**：数据导入导出

### 1.2 模块组成

| 文件 | 类 | 职责 |
|------|-----|------|
| `page_util.py` | `PageUtil` | 分页查询与切片分页 |
| `string_util.py` | `StringUtil` | 字符串判断与转换 |
| `time_format_util.py` | `TimeFormatUtil` | 时间格式化与解析 |
| `case_util.py` | `CamelCaseUtil`, `SnakeCaseUtil` | 命名风格转换 |
| `excel_util.py` | `ExcelUtil` | Excel 导入导出 |

---

## 2. 分页工具（PageUtil）

### 2.1 ORM 分页查询

```python
from app.utils.page_util import PageUtil
from app.models.user import User

# Tortoise ORM 分页查询
page_result = await PageUtil.paginate(
    queryset=User.all(),
    page=1,
    page_size=20,
)

# 返回结果
{
    "data": [...],      # 当前页数据
    "total": 100,       # 总记录数
    "page": 1,          # 当前页码
    "page_size": 20,    # 每页数量
    "pages": 5          # 总页数
}
```

### 2.2 列表切片分页

```python
# 对已有列表进行切片分页
all_items = [{'id': i} for i in range(100)]

page_result = PageUtil.get_page_obj(
    data_list=all_items,
    page=2,
    page_size=10,
)

# 返回结果
{
    "data": [{'id': 10}, {'id': 11}, ...],
    "total": 100,
    "page": 2,
    "page_size": 10,
    "pages": 10
}
```

### 2.3 转换为分页响应

```python
from app.core.response import PaginatedResponse

# 将字典转换为 PaginatedResponse 模型
response = PageUtil.to_paginated_response(
    page_result,
    msg="获取成功"
)
```

### 2.4 参数说明

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `queryset` | QuerySet | - | Tortoise ORM 查询集 |
| `data_list` | List | - | 数据列表（切片分页） |
| `page` | int | 1 | 当前页码（从 1 开始） |
| `page_size` | int | 10 | 每页数量 |

---

## 3. 字符串工具（StringUtil）

### 3.1 空白判断

```python
from app.utils.string_util import StringUtil

# 判断是否为空字符串或全空格
StringUtil.is_blank("  ")       # True（全空格）
StringUtil.is_blank("")         # True（空字符串）
StringUtil.is_blank(None)       # True
StringUtil.is_blank("abc")      # False

# 判断是否为空字符串（不包括空格）
StringUtil.is_empty("")         # True
StringUtil.is_empty(None)       # True
StringUtil.is_empty("  ")       # False

# 判断是否非空
StringUtil.is_not_empty("abc")  # True
StringUtil.is_not_empty("")     # False
```

### 3.2 HTTP 判断

```python
# 判断是否为 HTTP(S) 链接
StringUtil.is_http("https://example.com")  # True
StringUtil.is_http("http://example.com")   # True
StringUtil.is_http("ftp://example.com")    # False
```

### 3.3 大小写忽略判断

```python
# 包含判断（忽略大小写）
StringUtil.contains_ignore_case("Hello World", "world")  # True
StringUtil.contains_ignore_case("Hello World", "WORLD")  # True

# 列表包含判断
StringUtil.contains_any_ignore_case("Hello", ["world", "HELLO"])  # True

# 相等判断（忽略大小写）
StringUtil.equals_ignore_case("ABC", "abc")  # True

# 列表相等判断
StringUtil.equals_any_ignore_case("abc", ["ABC", "xyz"])  # True
```

### 3.4 前缀判断

```python
# 以指定字符串开头
StringUtil.startswith_case("Hello World", "Hello")  # True

# 以列表中任意一个开头
StringUtil.startswith_any_case("Hello", ["Hi", "Hello"])  # True
```

### 3.5 下划线转驼峰

```python
# 转换为大驼峰（类名风格）
StringUtil.convert_to_camel_case("user_name")  # "UserName"
StringUtil.convert_to_camel_case("created_at")  # "CreatedAt"
StringUtil.convert_to_camel_case("user")        # "User"
```

### 3.6 字典值查找（忽略大小写）

```python
mapping = {"Name": "Alice", "AGE": 25}
StringUtil.get_mapping_value_by_key_ignore_case(mapping, "name")  # "Alice"
StringUtil.get_mapping_value_by_key_ignore_case(mapping, "age")   # "25"
StringUtil.get_mapping_value_by_key_ignore_case(mapping, "id")    # ""（不存在）
```

---

## 4. 时间格式化工具（TimeFormatUtil）

### 4.1 基础用法

```python
from app.utils.time_format_util import TimeFormatUtil

# 格式化时间字符串
TimeFormatUtil.format_time("2026-05-06T10:30:00", "%Y-%m-%d %H:%M:%S")
# 返回："2026-05-06 10:30:00"

TimeFormatUtil.format_time("2026-05-06T10:30:00", "%Y年%m月%d日")
# 返回："2026年05月06日"
```

### 4.2 解析日期

```python
# 从时间字符串提取日期对象
date_obj = TimeFormatUtil.parse_date("2026-05-06T10:30:00")
# 返回：datetime.date(2026, 5, 6)
```

### 4.3 批量格式化

```python
# 字典时间字段格式化
time_dict = {
    "created_at": "2026-05-06T10:30:00",
    "updated_at": "2026-05-06T12:00:00"
}
formatted = TimeFormatUtil.format_time_dict(time_dict, "%Y-%m-%d")
# 返回：{"created_at": "2026-05-06", "updated_at": "2026-05-06"}

# 列表时间格式化
time_list = ["2026-05-06T10:30:00", "2026-05-06T12:00:00"]
formatted = TimeFormatUtil.format_time_list(time_list, "%Y-%m-%d")
# 返回：["2026-05-06", "2026-05-06"]
```

### 4.4 dateutil 可选依赖

工具自动检测 `python-dateutil`：

```python
# 已安装 dateutil：使用强大的解析能力
# 未安装 dateutil：使用 datetime.fromisoformat 降级
```

安装 dateutil 可获得更好的时间解析能力：

```bash
pip install python-dateutil
```

---

## 5. 命名风格转换（CaseUtil）

### 5.1 下划线转小驼峰

```python
from app.utils.case_util import CamelCaseUtil

# 单个字段转换
CamelCaseUtil.snake_to_camel("user_name")   # "userName"
CamelCaseUtil.snake_to_camel("created_at")  # "createdAt"
CamelCaseUtil.snake_to_camel("id")          # "id"
```

### 5.2 批量转换字典

```python
data = {
    "user_name": "Alice",
    "created_at": "2026-05-06",
    "is_active": True
}
camel_data = CamelCaseUtil.transform_result(data)
# 返回：
# {
#     "userName": "Alice",
#     "createdAt": "2026-05-06",
#     "isActive": True
# }
```

### 5.3 嵌套结构转换

```python
data = {
    "user_name": "Alice",
    "profile": {
        "created_at": "2026-05-06",
        "tags": [{"tag_name": "admin"}, {"tag_name": "user"}]
    }
}
result = CamelCaseUtil.transform_result(data)
# 返回：
# {
#     "userName": "Alice",
#     "profile": {
#         "createdAt": "2026-05-06",
#         "tags": [{"tagName": "admin"}, {"tagName": "user"}]
#     }
# }
```

### 5.4 小驼峰转下划线

```python
from app.utils.case_util import SnakeCaseUtil

# 单个字段转换
SnakeCaseUtil.camel_to_snake("userName")    # "user_name"
SnakeCaseUtil.camel_to_snake("createdAt")   # "created_at"
SnakeCaseUtil.camel_to_snake("isActive")    # "is_active"

# 批量转换字典
data = {"userName": "Alice", "createdAt": "2026-05-06"}
snake_data = SnakeCaseUtil.transform_result(data)
# 返回：{"user_name": "Alice", "created_at": "2026-05-06"}
```

---

## 6. Excel 工具（ExcelUtil）

### 6.1 数据导出

```python
from app.utils.excel_util import ExcelUtil

# 基础导出
data = [
    {'id': 1, 'name': 'Alice', 'age': 25},
    {'id': 2, 'name': 'Bob', 'age': 30}
]
columns = {'id': 'ID', 'name': '姓名', 'age': '年龄'}

response = ExcelUtil.export_excel(data, columns, 'users.xlsx', '用户列表')
# 返回 StreamingResponse，直接用于路由返回
```

### 6.2 数据导入

```python
# 导入 Excel 数据
with open('import.xlsx', 'rb') as f:
    data = ExcelUtil.import_excel(
        f.read(),
        columns={'姓名': 'name', '年龄': 'age'},  # Excel 列名 → 字段名
        skip_header=True,
    )
# 返回：[{'name': 'Alice', 'age': 25}, {'name': 'Bob', 'age': 30}]
```

### 6.3 Pydantic 验证导入

```python
from pydantic import BaseModel

class UserSchema(BaseModel):
    name: str
    age: int

# 导入时自动验证
data = ExcelUtil.import_excel(
    file_content,
    columns={'姓名': 'name', '年龄': 'age'},
    model=UserSchema,  # Pydantic 模型验证
    skip_header=True,
)
# 无效数据会抛出 ValidationError
```

### 6.4 生成模板

```python
columns = {'name': '姓名', 'age': '年龄'}
example_data = [{'name': '示例', 'age': 25}]

response = ExcelUtil.get_excel_template(
    columns,
    'user_template.xlsx',
    example_data=example_data
)
# 返回带示例数据的模板文件
```

### 6.5 默认样式

导出的 Excel 自动应用样式：
- 表头：字体加粗、黄色背景、居中、边框
- 数据行：自动换行、边框

---

## 7. 配置说明

### 7.1 依赖

| 依赖包 | 用途 | 是否必需 |
|--------|------|----------|
| `tortoise-orm` | 分页查询 | 必需 |
| `openpyxl` | Excel 处理 | 必需 |
| `python-dateutil` | 时间解析 | 可选 |

---

## 8. 最佳实践

### 8.1 分页查询

- 使用 `PageUtil.paginate` 进行数据库分页
- 使用 `PageUtil.get_page_obj` 进行内存列表分页
- 使用 `PageUtil.to_paginated_response` 转换为响应模型

### 8.2 命名转换

- 前端返回数据使用 `CamelCaseUtil.transform_result`
- 前端接收数据使用 `SnakeCaseUtil.transform_result`
- 支持嵌套结构自动转换

### 8.3 Excel 导出

- 大数据量建议分批导出或使用后台任务
- 使用 Pydantic 验证导入数据
- 提供模板文件便于用户填写

### 8.4 时间格式化

- 统一使用 `TimeFormatUtil` 处理时间格式
- 安装 `dateutil` 获得更强大的解析能力

---

## 9. 常见问题 (FAQ)

**Q: PageUtil.paginate 与 ResponseBuilder.paginated 有什么区别？**

- `PageUtil.paginate` 返回字典，适合内部使用
- `ResponseBuilder.paginated` 返回 Pydantic 模型，适合 API 响应
- 可用 `PageUtil.to_paginated_response()` 转换

**Q: 命名转换工具如何处理嵌套结构？**

支持递归转换，字典和列表中的嵌套结构都会自动处理。

**Q: Excel 导出如何处理大数据量？**

大数据量建议使用后台任务：

```python
from fastapi import BackgroundTasks

@router.get("/export")
async def export_large_data(background_tasks: BackgroundTasks):
    background_tasks.add_task(generate_large_excel)
    return {"message": "导出任务已提交"}
```

**Q: 为什么 time_format_util 需要 dateutil？**

dateutil 提供更强大的时间解析能力，支持多种格式。未安装时使用 `datetime.fromisoformat` 降级。

---

## 10. 相关依赖

| 依赖包 | 版本要求 | 用途 |
|--------|----------|------|
| `tortoise-orm` | - | 分页查询 |
| `openpyxl` | - | Excel 处理 |
| `python-dateutil` | - | 时间解析（可选） |

---

## 变更记录

| 日期 | 变更内容 |
|------|----------|
| 2026-05-06 | 创建文档 |