# Obsidian 实践步骤指南

> 基于《换了N个笔记工具，最终我还是选择了 Obsidian》整理

## 一、下载安装 Obsidian

### 1. 下载 Obsidian
- 官网：https://obsidian.md/
- 支持平台：Windows / macOS / Linux / iOS / Android

### 2. 安装 Git 命令行工具
- 官网：https://git-scm.com/
- 用于后续 GitHub 同步

### 3. 安装 GitHub Desktop 客户端
- 官网：https://github.com/apps/desktop
- 傻瓜式操作，对新手友好

---

## 二、配置 GitHub 云同步

### 1. 注册并登录 GitHub
- 如遇网络问题，可安装 Watt ToolKit 工具解决

### 2. 创建私有仓库
- 访问 https://github.com/new
- 仓库名：如 `shrimp_vault`
- **Visibility 选择 Private**（私有仓库，笔记不公开）

### 3. 克隆仓库到本地
- 打开 GitHub Desktop → File → Clone Repository
- 登录 GitHub 账号
- 选择仓库和本地路径 → Clone

### 4. 创建 .gitignore 文件
在仓库根目录创建 `.gitignore`，排除以下文件：
```
.obsidian/workspace.json
.obsidian/workspace-mobile.json
```
> 这些文件记录工作区状态，频繁修改易产生冲突

### 5. 首次提交
- GitHub Desktop 选中文件
- 填写描述 → Commit → Publish

---

## 三、配置 Obsidian

### 1. 打开本地仓库
- Obsidian → 打开本地仓库
- 选择克隆下来的文件夹

### 2. 创建笔记
- 每个笔记都是一个 Markdown 文件
- `.obsidian` 文件夹存放配置

### 3. 安装 Git 插件（自动同步）
**步骤：**
1. 设置 → 第三方插件 → 关闭安全模式
2. 浏览社区插件 → 搜索 `git`
3. 安装并启用

**配置选项：**
- `auto commit and sync after stopping file edits`: 开启
- 分钟数改为 `1`（停止编辑1分钟后自动同步）
- `Pull on start`: 开启（启动时自动拉取远端更新）

---

## 四、图片与附件管理

### 问题
默认图片存储方式：
- 图片放在笔记同目录，文件夹变乱
- 使用 Wiki 链接格式，非标准 Markdown（GitHub/VS Code 无法显示）

### 解决方案：Custom Attach Location 插件

**安装：**
1. 设置 → 第三方插件 → 浏览
2. 搜索 `Custom attach location` → 安装启用

**配置：**
1. Markdown URL 格式：
```
assets/${fileName}/${fileName}
```
2. 附件重命名模式：选择 `全部`
3. 勾选"是否重命名附件文件"

**Obsidian 系统设置：**
1. 文件与链接 → 取消"使用 Wiki 链接"
2. 内部链接类型 → 选择"基于当前笔记的相对路径"

**效果：**
- 自动创建 `assets/笔记名/` 子文件夹存放图片
- 使用标准 Markdown 格式（GitHub/VS Code 正常显示）
- 笔记重命名时，附件文件夹同步更新

**调整图片大小：**
在链接方括号中输入数字：
```markdown
![](assets/笔记名/image.png){100}
```

---

## 五、Obsidian + AI（Gemini CLI）

### 1. 安装 Node.js
- 官网：https://nodejs.org/zh-cn

### 2. 安装 Gemini CLI
```bash
npm install -g @google/gemini-cli
```

### 3. 启动并授权
在 Obsidian 笔记目录打开终端：
```bash
gemini
```
选择 `Login with Google`（需海外上网环境）

### 4. AI 使用案例

**案例一：选题生成**
```
自媒体存档这个文件夹里面存的是我所有视频的脚本，
请根据我的选题特色与观众喜好，调用网络搜索工具来搜索热点，
用你丰富的知识，探寻我没有做过的选题，帮我再写10个选题。
你输出一个《选题.md》文件放到当前项目的根目录下面，
每个选题都应该有对应的简介与大纲。
```

**案例二：批量创建文件夹**
```
你把这10个选题建出子文件夹，所有的子文件夹都放到根目录/未来选题这个里面。
每个子文件夹里面都有一份选题大纲文件。
做完以上工作，就把根目录的《选题.md》这个删除掉。
```

**案例三：模仿文风写脚本**
```
我最近看到一篇文章《忘了 n8n 吧，我用国产模型跑通了 Claude Skill》，这个文章很不错。
你搜索下文章的内容，然后根据我的行文风格写一个视频脚本，
需要详细一些，脚本放到根目录即可。
行文风格可以参考我2024年与2025年的往期内容。
```

### 5. 版本控制保护
- Git 记录每次修改
- 不满意可右键 `Discard changes` 还原
- 放心让 AI 修改，不用担心文件丢失

---

## 六、手机端配置与同步

### 1. 传输笔记到手机
- 数据线连接手机与电脑
- 选择传输文件模式
- 复制 Obsidian 笔记文件夹到手机 `Documents` 目录

### 2. 打开 Obsidian 手机版
- 选择 `Open Folder as vault`
- 选择复制进来的文件夹
- 选择 `Trust author`

### 3. 配置手机 Git 插件
**设置步骤：**
1. 左上角 → 设置 → Git 设置
2. 填写 GitHub 用户名（英文）
3. 填写 GitHub 注册邮箱
4. 填写 Personal Access Token

**获取 Token：**
1. GitHub 网页端 → Settings → Developer Settings
2. Personal access tokens (classic) → Generate new token (classic)
3. 名称自定义，过期时间选"永不过期"
4. 勾选 `repository` 权限
5. 复制生成的 Token

### 4. 注意事项
- 手机与电脑不要同时编辑同一文件（易产生冲突）
- 冲突需手动解决

---

## 七、导出功能

### 1. 安装 Pandoc
- GitHub：https://github.com/jgm/pandoc/releases
- 下载对应系统安装包
- 解压可执行程序到本地目录

### 2. 安装 Enhancing Export 插件
1. 设置 → 第三方插件 → 浏览
2. 搜索 `Enhancing Export` → 安装启用
3. 选项中填写 Pandoc 可执行文件路径

### 3. 导出笔记
- 右键笔记 → 导出
- 支持 Word、HTML、PDF 等格式

---

## 八、双向链接与知识图谱

### 1. 创建双向链接
在笔记中输入两对方括号：
```markdown
[[另一篇笔记标题]]
```
可搜索并链接到其他笔记

### 2. 打开链接
- `Ctrl + 点击`：在新 Tab 打开

### 3. 查看关系图谱
- 左侧点击"查看关系图谱"
- 笔记以节点展示，链接以连线表示
- 帮助发现笔记间隐藏关联

---

## 核心优势总结

| 优势 | 说明 |
|------|------|
| 数据安全 | 本地 Markdown 文件，即使软件停运也能用其他编辑器打开 |
| 界面流畅 | 无卡顿，丝滑稳定 |
| AI 绝配 | 与 Claude Code、Gemini CLI 等 AI 工具完美配合 |
| 云同步免费 | GitHub 完全免费，比云笔记/网盘更稳定 |
| 标准格式 | 纯 Markdown，无锁定风险 |

---

## 推荐工作流

```
1. 本地写笔记 → Git 插件自动同步到 GitHub
2. AI 工具处理笔记 → Git 版本控制保护
3. 手机端随时查看/编辑 → GitHub 同步
4. 需导出时 → Enhancing Export + Pandoc
```