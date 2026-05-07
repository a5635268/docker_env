# Obsidian 多仓库插件/主题/片段共享方案

Obsidian 每个仓库（Vault）的配置默认独立存放在各自 `.obsidian` 目录。要实现"一处安装、多库共用"，有以下三种方案：

---

## 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| 复制插件目录 | 简单直接，无需命令行 | 一次性操作，不同步更新 | 临时迁移、少量仓库 |
| 符号链接全局共享 | 全局共享，自动同步，节省空间 | 需命令行/管理员权限 | 本地多仓库、长期使用（推荐） |
| Settings Sync 插件 | 跨设备同步、云端备份 | 依赖网络、免费版有限制 | 多设备同步 |

---

## 方案一：临时迁移（复制插件目录）

适合偶尔迁移少量插件，不自动同步。

### 操作步骤

1. **关闭 Obsidian**
2. **显示隐藏文件夹**
   - Windows：文件资源管理器 → 查看 → 勾选"隐藏的项目"
   - macOS：Finder → 按 `Cmd+Shift+.` 显示隐藏文件
3. **从源仓库复制**
   ```
   源仓库/.obsidian/plugins/ → 目标仓库/.obsidian/plugins/
   源仓库/.obsidian/community-plugins.json → 目标仓库/.obsidian/
   ```
4. **重启 Obsidian**，进入"设置 → 第三方插件"，启用所需插件

⚠️ 缺点：后续插件更新/配置修改不会自动同步到其他仓库。

---

## 方案二：符号链接全局共享（推荐）

把所有仓库的 `.obsidian/plugins`、`.obsidian/themes`、`.obsidian/snippets` 指向**同一个全局配置目录**，实现：

**装一次插件、换一次主题、改一次 CSS，所有仓库全部同步生效**

### 原理说明

- **插件本体共用**：所有仓库共享同一套插件程序文件
- **插件配置独立**：各仓库的插件设置（如 `data.json`）仍独立存放，互不干扰
- **仓库独立配置**：布局、笔记设置、核心配置仍各自独立，只共享插件/主题/片段

### 第一步：创建全局配置目录

找一个固定不移动的位置：

| 系统 | 推荐路径 |
|------|----------|
| Windows | `D:\Obsidian\GlobalObsidianConfig` |
| macOS | `~/Obsidian/GlobalObsidianConfig` |

目录结构：
```
GlobalObsidianConfig/
├── plugins    # 共用第三方插件
├── themes     # 共用所有主题
└── snippets   # 共用 CSS 片段
```

### 第二步：迁移主仓库配置

> 选择一个插件/主题最全的仓库作为主仓库

1. **关闭所有 Obsidian 窗口**
2. 打开主仓库，显示隐藏文件 `.obsidian`
3. **剪切**以下文件夹到 `GlobalObsidianConfig`：
   - `.obsidian/plugins`
   - `.obsidian/themes`
   - `.obsidian/snippets`

### 第三步：为每个仓库创建符号链接

#### Windows 版（CMD 管理员身份）

假设：
- 全局目录：`D:\Obsidian\GlobalObsidianConfig`
- 目标仓库：`D:\Obsidian\我的笔记库`

```cmd
:: 备份原有目录（防止丢配置）
ren "D:\Obsidian\我的笔记库\.obsidian\plugins" plugins_bak
ren "D:\Obsidian\我的笔记库\.obsidian\themes" themes_bak
ren "D:\Obsidian\我的笔记库\.obsidian\snippets" snippets_bak

:: 创建 junction 链接（目录映射）
mklink /J "D:\Obsidian\我的笔记库\.obsidian\plugins" "D:\Obsidian\GlobalObsidianConfig\plugins"
mklink /J "D:\Obsidian\我的笔记库\.obsidian\themes" "D:\Obsidian\GlobalObsidianConfig\themes"
mklink /J "D:\Obsidian\我的笔记库\.obsidian\snippets" "D:\Obsidian\GlobalObsidianConfig\snippets"
```

#### macOS 版（终端执行）

```bash
# 进入仓库 .obsidian 目录
cd ~/Obsidian/我的笔记库/.obsidian

# 备份旧目录
mv plugins plugins_bak
mv themes themes_bak
mv snippets snippets_bak

# 建立软链接
ln -s ~/Obsidian/GlobalObsidianConfig/plugins plugins
ln -s ~/Obsidian/GlobalObsidianConfig/themes themes
ln -s ~/Obsidian/GlobalObsidianConfig/snippets snippets
```

### 第四步：生效验证

1. 打开 Obsidian，切换任意仓库
2. 进入"设置 → 第三方插件"，查看所有插件已加载
3. 以后只在**任意一个仓库**安装/更新插件、装主题、改 CSS，**全部仓库自动同步**

---

## 方案三：Settings Sync 插件（跨设备）

适合多设备或不想折腾软链接的用户。

### 操作步骤

1. 在主仓库安装 **Settings Sync** 插件
2. 配置：绑定 GitHub/Gitee 私有仓库，设置同步范围（勾选 `plugins/`、`community-plugins.json`）
3. 其他仓库：安装同插件，登录同一账号，触发同步即可拉取所有插件与配置

⚠️ 注意：免费版依赖网络；敏感配置建议私有仓库加密。

---

## 关键注意事项（避坑）

| 问题 | 解决方案 |
|------|----------|
| 插件配置冲突 | 共享的是插件程序，各仓库的配置文件独立存放，互不干扰 |
| 操作前 Obsidian 运行中 | 必须关闭 Obsidian，避免文件锁定导致链接失败 |
| 符号链接失效 | 检查目标路径是否正确，确保全局目录未移动 |
| 新建仓库 | 只需执行第三步创建三个符号链接，立刻继承所有配置 |
| 主题/片段缺失 | 确保 `themes` 和 `snippets` 目录也已同步 |

---

## 自动化脚本（本项目提供）

当前项目提供自动化脚本，一键完成配置同步：

```bash
# 1. 初始化全局目录（首次使用）
~/.claude/skills/obsidian-plugin-sync/scripts/setup-global.sh

# 2. 从主仓库迁移配置
~/.claude/skills/obsidian-plugin-sync/scripts/migrate-config.sh --source ~/Obsidian/主仓库

# 3. 为目标仓库同步配置
cd ~/Obsidian/目标仓库
~/.claude/skills/obsidian-plugin-sync/scripts/sync-vault.sh

# 4. 检查同步状态
~/.claude/skills/obsidian-plugin-sync/scripts/check-status.sh
```

---

## 总结

- **本地多仓库**：优先使用**符号链接方案**，一劳永逸
- **偶尔迁移**：直接**复制插件目录**
- **多设备同步**：使用 **Settings Sync 插件**

> 需要根据你的操作系统和仓库路径生成具体命令？请提供：系统类型（Windows/macOS）+ 任意一个仓库的完整路径。