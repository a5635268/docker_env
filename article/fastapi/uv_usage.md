# uv 工具使用指南

`uv` 是一个由 Rust 编写的极速 Python 包和项目管理工具（由 Astral 公司开发，和 Ruff 属于同一个开发团队）。它旨在作为一个速度更快的 `pip`、`pip-tools`、`virtualenv` 甚至完整替代 Poetry/Pipenv 的下一代构建工具。

---

## 🚀 1. 安装 uv

根据您的操作系统，执行以下命令安装 `uv`：

**macOS/Linux**:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# 或者通过 Homebrew (macOS)
brew install uv
```

**Windows**:
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

---

## 📦 2. 虚拟环境管理 (替代 virtualenv)

`uv` 创建隔离的虚拟环境比内置的 `venv` 速度可提升高达百倍。

```bash
# 在当前目录下创建 .venv 虚拟环境
uv venv

# 创建指定 Python 版本的虚拟环境（它会自动去下载该版本的 Python）
uv venv --python 3.10
uv venv --python 3.12.1

# 激活环境 (macOS/Linux)
source .venv/bin/activate
# 激活环境 (Windows)
.venv\\Scripts\\activate
```

---

## ⚡ 3. 依赖安装与卸载 (替代 pip)

`uv` 完全兼容 `pip` 的绝大多数命令，通过简单加入前缀，即可享受极速构建、全局缓存和并行下载。

```bash
# 全局或者在刚才的虚拟环境中，极速安装 requirements.txt 里的所有依赖
uv pip install -r requirements.txt

# 安装指定的单个包（如 fastapi）
uv pip install fastapi

# 安装并指定扩展库（如 uvicorn[standard]）
uv pip install "uvicorn[standard]"

# 卸载包
uv pip uninstall sqlalchemy
```

> **最佳实践体验**：如果您使用 `uv pip` 安装依赖包时未激活任何虚拟环境，它不仅会保护您系统的全局 Python 防止受到污染，而且如果目录下存在 `.venv`，它会自动感知并装入 `.venv` 内部！

---

## 🛠️ 4. 依赖解析与锁定 (替代 pip-tools)

生产级别的项目往往需要锁定具体的依赖层级与子依赖（类似于 `npm` 或 `poetry` 构建的 lock 文件）。

```bash
# 从 requirements.in (或 pyproject.toml) 生成跨平台锁定的要求文件 requirements.txt
uv pip compile pyproject.toml -o requirements.txt

# 将环境精准同步到依赖文件中定义的状态 (清理掉不需要的包)
uv pip sync requirements.txt
```

---

## 🗂️ 5. 原生项目管理 (类似于 Poetry)

目前 `uv` 已经进一步演进，原生支持了高阶的项目级别管理功能。

```bash
# 初始化一个新的 Python 项目 (会直接创建包含 pyproject.toml 的骨架)
uv init my_project
cd my_project

# 添加一个新包（uv 自动帮您把依赖写入 pyproject.toml 中并安装到由它托管的环境中）
uv add requests

# 移除一个包
uv remove requests

# 运行一个指定的 Python 脚本（如果它未安装依赖或需要临时运行），uv run 甚至会自动获取当前所需环境
uv run app/main.py

# 结合 uvicorn 运行项目，省去了手动敲 source 命令激活的麻烦
uv run uvicorn app.main:app --reload
```

---

## 🧹 6. 清理全局缓存

如果需要强制重新下载包，或者释放磁盘空间：

```bash
uv cache clean
```

> **总结**：在当前基于 `FastAPI + Tortoise` 架构的开发中，我们墙裂推荐使用 `uv`，因为它可以大幅缩短切换分支时的依赖补全或重装时间，而且在保证极速的情况下完美代替了传统繁琐的 `pip` 体验。
