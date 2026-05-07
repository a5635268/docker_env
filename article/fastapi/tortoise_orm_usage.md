# FastAPI + Tortoise ORM 使用指南

本文档包含在当前项目中 Tortoise ORM 的核心使用指南，基于现有的模型 (`app/models/user.py`) 和服务处 (`app/services/user.py`) 为例进行说明。由于我们从 SQLAlchemy 迁移到了 Tortoise ORM，所有的数据库操作均转变为原生的 `async/await` 形式，并且不再需要通过依赖注入传递数据库的会话（Session）。

## 1. 核心模型定义

所有的实体模型位于 `app/models/` 目录中。新模型必须继承自 `tortoise.models.Model`。包含完整的约束、索引和字段类型定义。

```python
from tortoise import fields, models

class User(models.Model):
    """用户模型"""
    id = fields.IntField(pk=True)
    username = fields.CharField(max_length=50, unique=True, index=True)
    email = fields.CharField(max_length=100, unique=True, index=True)
    hashed_password = fields.CharField(max_length=255)
    is_active = fields.BooleanField(default=True)
    created_at = fields.DatetimeField(auto_now_add=True)

    class Meta:
        table = "users" # 自定义物理表名

    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}')>"
```

**注意事项**：每当增加一个新的模型类，**都必须**在 `app/core/config.py` 的 `Settings.TORTOISE_ORM` 的 `models` 配置中注册该模块的路径（例如：`"app.models.user"`）。

## 2. 数据库连接与 DDL 生成 (自动建表)

我们在 `app/main.py` 的应用启动阶段，配置了 `register_tortoise`：

```python
register_tortoise(
    app,
    config=settings.TORTOISE_ORM,
    generate_schemas=settings.DEBUG, # 在 DEBUG 模式下自动创建表
    add_exception_handlers=True,
)
```
当你新增模型或字段时，如果配置中 `DEBUG=True`，重启服务 `uvicorn app.main:app` 会自动检查并**生成缺失的表结构**（注意：它不会做增量修改已有列属性，针对已有列变更或表结构同步在生产环境中需引入 `aerich` 框架进行数据迁移管理）。

## 3. 基本的 CRUD 操作 (增删改查)

Tortoise ORM 的 API 设计深受 Django ORM 启发，操作都非常直接且由于底层是异步的，均需提供 `await` 调用。建议将这些操作封装在 `app/services/` 层，作为主要的读写点。

### 3.1 创建 (Create)

创建新记录通常推荐使用类方法 `create()`：

```python
from app.models.user import User

# 方法一：直接使用 create()
user = await User.create(
    username="test_user",
    email="test@example.com",
    hashed_password="xxx..."
)

# 方法二：先实例化对象，再执行 save() (用于需要再处理一些相关逻辑的情况)
user = User(username="test_user", email="test@example.com", hashed_password="xxx...")
await user.save()
```

### 3.2 查询 (Read)

所有的查询都采用链式调用，通过 `QuerySet` 对象完成。

**单条查询：**

```python
# 根据条件获取，如果找不到会抛出 tortoise.exceptions.DoesNotExist，多条则抛出 MultipleObjectsReturned
user = await User.get(id=1) 
user = await User.get(username="test_user")

# 【在服务侧最常用的方法】：查询不存在时返回 None，而非抛出异常 (等同于 SQLAlchemy 的 session.get())
user = await User.get_or_none(username="test_user")
user = await User.get_or_none(id=1)
```

**多条列表查询过滤器：**

```python
# 获取全表的所有用户
users = await User.all()

# 获取部分记录 (WHERE 条件匹配，多个参数自动由 AND 连接)
active_users = await User.filter(is_active=True, username="test_user")

# 使用特定的魔术查询方法 (类似 Django ORM 的双下划线操作)
users = await User.filter(username__contains="test")  # 对应 LIKE '%test%'
users = await User.filter(username__icontains="test") # 对应 ILIKE '%test%' （忽略大小写）
users = await User.filter(id__in=[1, 2, 3])           # 对应 IN (1, 2, 3)
users = await User.filter(created_at__gt=time_obj)    # 对应 > 大于
users = await User.filter(created_at__lte=time_obj)   # 对应 <= 小于等于

# 排序、切片和分页 (对应 ORDER BY / LIMIT / OFFSET )
users = await User.all().order_by("-created_at").limit(10).offset(20) # 倒序排列，取10条，切片游标跳过前20条
```

### 3.3 更新 (Update)

**单条对象状态更新 (实例化更新)：**

通常在 `Service` 层面我们会先查找提取对象，然后再对需要的字段进行更新并保存。非常方便结合 Pydantic 字典：

```python
user = await User.get_or_none(id=1)
if user:
    # 方式一：逐个赋值并利用 update_fields 指定需要保存到 DB 的字段以优化性能
    user.is_active = False
    await user.save(update_fields=['is_active']) 

    # 方式二：【最佳实践】使用字典批量对字段进行赋值 
    # (尤其结合 Pydantic 的 user_in.model_dump(exclude_unset=True) 使用)
    update_data = {"is_active": False, "email": "new@example.com"}
    await user.update_from_dict(update_data)
    await user.save() 
```

**批量更新 (类似于一条 UPDATE WHERE 命令，不加载到内存中)：**

```python
# 将全表中 is_active 为 False 的全改为 True，直接返回受影响的行数 (int)
modified_count = await User.filter(is_active=False).update(is_active=True)
```

### 3.4 删除 (Delete)

**单对象实例删除：**

```python
user = await User.get_or_none(id=1)
if user:
    await user.delete()
```

**批量范围删除：**

```python
deleted_count = await User.filter(is_active=False).delete()
```

## 4. 关联关系操作 (Relations)

如果在不同模型间涉及外键和连表逻辑（例如 User 和他创建的一组 Article 实例）：

```python
from tortoise import fields, models

class Article(models.Model):
    id = fields.IntField(pk=True)
    title = fields.CharField(max_length=200)
    # 建立外键关联：通过 related_name 指定对主表 User 的反向查询属性
    user = fields.ForeignKeyField('models.User', related_name='articles')
```

**使用 `prefetch_related` 从后端预加载关联对象 (缓解典型的 N+1 查询问题)：**

```python
# 获取特定数据的同时加载作者 (避免后续直接读取 article.user.username 时造成的再次触发懒查询和异常)
article = await Article.get(id=1).prefetch_related("user")
print(article.user.username)

# 获取主表用户的同时顺带来加载他所有的级联映射项目
user = await User.get(id=1).prefetch_related("articles")
for art in user.articles: # 无需另起数据库请求即可读取列表
    print(art.title)
```

## 5. 高阶：事务处理与原生 SQL

**原子级的事务处理限制：**

Tortoise ORM 提供了非常方便的装饰器以及异步上下文处理器。

```python
from tortoise.transactions import atomic, in_transaction

# 方式一：使用基于函数的装饰器 (@atomic)
@atomic()
async def transfer_money(from_user_id: int, to_user_id: int, amount: float):
    # 下面这段代码自动处于独立的原子数据库操作事务块中
    # 执行正常将统一 commit()，发生抛出异常时会直接触发 rollback() 回滚全局
    ...

# 方式二：使用原生的异步上下文管理器 (代码块内细粒度或局部掌控更灵活)
async def manual_transaction():
    async with in_transaction() as connection:
        user = await User.create(...)
        article = await Article.create(user=user, ...)
```

**原生直接执行 Raw SQL 语句：**

如果你遭遇了非常特殊场景中难以复刻的对象逻辑操作或有特殊的聚合诉求，需要直接传递执行 SQL：

```python
from tortoise import Tortoise

# 获取配置文件中 'default' 连接配置对象的底层连接引擎实例
conn = Tortoise.get_connection("default")

# 直接执行操作并以 Dict 输出返回结果
val = await conn.execute_query_dict("SELECT id, username FROM users WHERE is_active = ?", [True])
# 输出例：[{'id': 1, 'username': 'test_user'}, ...]
```

## 6. 在本服务层的架构思想

1. **去 Session 隐性依赖**：项目的各个 Router (控制器层) 和 Services 内部目前彻底摒除了 `db: AsyncSession` 的注入。整个 ORM 使用独立的全局生命周期池管理，业务中只需要通过类模型即可 `User.get`，大大消减了我们签名的复杂长依赖问题。
2. **结合 Pydantic (`schema`) 隔离**：在数据入库中，接收校验来自 Pydantic 表单的请求，剔除未传的可选参 `p_dict = user_input.model_dump(exclude_unset=True)` 之后，安全稳定地通过 `user.update_from_dict(p_dict)` 完成到 Tortoise 的衔接转换是当前主要实践。

更多高级查询比如跨表过滤、复杂的 `Q` 和 `F` 对象运算、分组聚合操作(`Count`, `Sum`) 请查阅 [Tortoise ORM 官方详细开发手册](https://tortoise.github.io/)。
