# FastAPI + Pydantic 数据校验与契约使用指南

本文档全面梳理了本项目中关于 **Pydantic** 的核心规范和应用场景。在 FastAPI 的体系中，Pydantic 主要扮演了以下几个角色，它等价于 ThinkPHP 中的 `Validate` 验证器、Java 开发中的 `DTO`(数据传输对象) 和 `VO`(视图对象)。

项目中的所有 Schema 统一放置在 `app/schemas/` 目录下。

## 1. 基础模型定义 (BaseModel)

所有的请求参数和响应数据结构，都必须继承自 `pydantic.BaseModel`。本项目遵循 Pydantic V2 规范。

### 1.1 基本类型推导
Pydantic 利用 Python 类型提示（Type Hints）机制进行强制类型转换和校验。

```python
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    # 必填字段 (无默认值)
    username: str 
    # 可选字段 (推荐明确标记 Optional 并提供默认值)
    email: Optional[str] = None 
    # 解析日期处理: Pydantic 会自动把字符串(ISO8601等)解析为 datetime 对象
    created_at: datetime 
```

### 1.2 使用 Field 进行高级约束
当需要在基础类型之上进行特定的范围、长度或正则校验时，需引入 `Field` 对象。

```python
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    # ... 代表必填，限制最小与最大长度，并添加文档描述（会自动注入到 Swagger API 文档）
    username: str = Field(..., min_length=3, max_length=50, description="用户名")
    
    # 结合正则表达式进行邮箱或手机号强验证
    email: str = Field(..., pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$', description="用户邮箱")
    
    # 整形数字的范围限定
    age: int = Field(default=18, ge=0, le=120, description="年龄必须在0-120之间")
```

常用的 Field 参数：
- `default`: 默认值，不指定或指定 `...` 时意味着必填
- `min_length` / `max_length`: 字符串长度限制
- `ge` (>=) / `gt` (>) / `le` (<=) / `lt` (<) : 数值大小限制
- `pattern`: 字符串正则限制 (在 Pydantic V1 叫 regex，V2 变更为 pattern)
- `description` / `example`: 用于供 API 文档展示的额外元数据

## 2. ORM 模型转换 (从 Tortoise 到 Pydantic)

当我们从数据库拉取了 Tortoise ORM 返回的模型实例，可以通过特定的 Pydantic 配置直接将其序列化为 JSON 返回给客户端。

在 **响应 Schema (Response Schema)** 中，必须开启 `from_attributes = True`，这相当于 Pydantic V1 中的 `orm_mode = True`。

```python
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class UserResponse(BaseModel):
    id: int
    username: str
    is_active: bool
    created_at: datetime

    # 【关键配置】：允许 Pydantic 去读取对象属性 (例如 obj.username)，而不仅是字典校验
    class Config:
        from_attributes = True
```

**控制器层面使用示范：**

在 FastAPI 路由中，直接将其声明在 `response_model` 中，FastAPI 会自动隐式地将你通过 Tortoise 查询出来的对象转化为该 Pydantic 字典：

```python
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    # 此处返回的是 Tortoise 对象
    user = await User.get_or_none(id=user_id)
    return user # FastAPI 会依据 response_model 自动剔除并提取关联字段
```

## 3. 面向对象的设计：模型继承组合

为了保持 DRY (Don't Repeat Yourself) 原则并且简化代码逻辑，极度推荐使用继承来划分业务场景（输入和输出应该做隔离拆分）：

```python
# 1. 抽取基础共性
class UserBase(BaseModel):
    username: str = Field(..., description="用户名")
    email: str = Field(..., description="邮箱")

# 2. 专门用于“创建”的 DTO：增加密码字段（必填）
class UserCreate(UserBase):
    password: str = Field(..., min_length=6, description="密码")

# 3. 专门用于“局部更新”的 DTO：所有字段改为可选 (Optional)
class UserUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=3, max_length=50)
    email: Optional[str] = None
    password: Optional[str] = Field(None, min_length=6)

# 4. 专门用于渲染输出结果的 VO：增加系统管理的只读字段以及主键，并开启 ORM 序列化支持
class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    # 绝不能在此处返回 password 哈希字段

    class Config:
        from_attributes = True
```

## 4. 与 Service 等逻辑层结合：清洗模型输入数据

从 Controller 层拿到校验完通过的 Pydantic 模型（如 `UserUpdate`）后，在传递给数据库操作 (Tortoise ORM) 前的典型处理步骤：

**使用 `model_dump()` 获取字典：**

```python
async def update_user(user_id: int, user_in: UserUpdate):
    user = await User.get_or_none(id=user_id)
    
    # model_dump() 用于将请求强类型类转变为标准的 python 字典
    # 【非常重点】：exclude_unset=True 参数指示丢弃掉用户未提交请求的字段（防止将其重置为 None）
    update_data = user_in.model_dump(exclude_unset=True)
    
    if not update_data:
        return user # 若没有任何需要更新的内容
    
    # 在这里可以做密码加密等预处理，加工完字典后直接丢入 ORM
    if "password" in update_data:
        update_data["hashed_password"] = p_hash(update_data.pop("password"))

    # 将清洗后的字典推入 ORM 对象更新机制
    await user.update_from_dict(update_data)
    await user.save()
```

*(附：在 Pydantic V1 中此方法叫做 `dict()`，在当前使用的 V2 版规范中已经变更为 `model_dump()`。同理，以前将 JSON 转码的方法 `parse_raw` 现在变为了 `model_validate_json`。)*

## 5. API 文档示例提供

对于复杂结构体，为了前端能够对照 Swagger 文档直接测试，建议使用 `json_schema_extra` 注入参考数据体：

```python
class ResponseModel(BaseModel):
    code: int
    message: str
    data: Optional[dict] = None

    class Config:
        json_schema_extra = {
            "example": {
                "code": 200,
                "message": "success",
                "data": {"token": "eyJhb..."}
            }
        }
```
结合这一特性，能够极大地提升接口联调时期文档的可读性。
