# 🚀 使用 GitHub Actions 自动编译

## 最简单的使用方法

### 方法一：一键设置脚本 (推荐)

#### Linux/Mac:
```bash
# 1. 下载并解压补丁包
cd winmerge_ai_merge

# 2. 运行设置脚本
chmod +x setup-github-actions.sh
./setup-github-actions.sh

# 3. 按提示输入 GitHub 用户名和仓库名
# 4. 等待脚本完成
```

#### Windows:
```powershell
# 1. 下载并解压补丁包
cd winmerge_ai_merge

# 2. 运行设置脚本
.\Setup-GitHubActions.ps1

# 3. 按提示输入信息
# 4. 等待脚本完成
```

脚本会自动：
- ✅ 克隆 WinMerge 源码
- ✅ 应用 AI 自动合并补丁
- ✅ 创建 GitHub 仓库
- ✅ 推送代码
- ✅ 触发 GitHub Actions 构建

---

### 方法二：手动 Fork

#### 步骤 1: Fork WinMerge

1. 访问 https://github.com/winmerge/winmerge
2. 点击右上角 **Fork** 按钮
3. 等待 Fork 完成

#### 步骤 2: 下载补丁包

下载 `winmerge_ai_merge.zip` 并解压

#### 步骤 3: 应用补丁

```bash
# 克隆你的 Fork
git clone https://github.com/YOUR_USERNAME/winmerge.git
cd winmerge

# 复制新文件
cp /path/to/patch/AIAutoMerge.h Src/
cp /path/to/patch/AIAutoMerge.cpp Src/
cp /path/to/patch/PropAIAutoMerge.h Src/
cp /path/to/patch/PropAIAutoMerge.cpp Src/

# 应用所有补丁
git apply /path/to/patch/*.patch

# 提交
git add .
git commit -m "Add AI Auto Merge feature"
git push
```

#### 步骤 4: 创建 GitHub Actions

在你的仓库中创建 `.github/workflows/build.yml`：

```yaml
name: Build WinMerge AI
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4
      - uses: microsoft/setup-msbuild@v2
      - run: nuget restore WinMerge.sln
      - run: msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m
      - uses: actions/upload-artifact@v4
        with:
          name: WinMerge-AI
          path: Build/x64/Release/WinMergeU.exe
```

#### 步骤 5: 下载构建结果

1. 进入你的 GitHub 仓库
2. 点击 **Actions** 标签
3. 等待构建完成 (约 5-10 分钟)
4. 下载 `WinMerge-AI` 产物

---

## 📥 下载编译好的版本

### 从 GitHub Actions 下载

1. 打开你的 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择最新的工作流运行
4. 滚动到 **Artifacts** 部分
5. 点击下载 `WinMerge-AI-x64`

### 文件说明

下载的 ZIP 包含：
- `WinMergeU.exe` - 主程序
- `*.dll` - 依赖库
- `README.txt` - 使用说明

---

## 🔧 自定义构建

### 修改构建配置

编辑 `.github/workflows/build.yml`：

```yaml
# 编译 Debug 版本
run: msbuild WinMerge.sln /p:Configuration=Debug /p:Platform=x64 /m

# 编译 x86 版本
run: msbuild WinMerge.sln /p:Configuration=Release /p:Platform=Win32 /m
```

### 添加更多功能

```yaml
# 创建安装包
- name: Create Installer
  run: |
    choco install innosetup
    iscc Installer\WinMergeX64.iss

# 发布到 Releases
- name: Release
  uses: softprops/action-gh-release@v1
  with:
    files: Build/x64/Release/WinMergeU.exe
```

---

## ❓ 常见问题

### Q: 构建失败，提示找不到 MFC

**A:** GitHub Actions 的 `windows-2022` 镜像已包含 MFC，无需额外安装。

### Q: 如何加快构建速度

**A:** 工作流已启用并行构建 (`/m`)，通常 5-10 分钟完成。

### Q: 构建产物在哪里下载

**A:** 
- 在 Actions 页面的 **Artifacts** 部分
- 或使用 GitHub API 下载

### Q: 可以创建安装包吗

**A:** 可以，添加 Inno Setup 步骤到工作流。

---

## 📊 构建状态

在你的 README.md 中添加构建状态徽章：

```markdown
![Build Status](https://github.com/YOUR_USERNAME/winmerge-ai/workflows/Build%20WinMerge%20AI/badge.svg)
```

---

## 🎯 下一步

1. **运行设置脚本** 或 **手动 Fork**
2. **等待 GitHub Actions 构建完成**
3. **下载 WinMergeU.exe**
4. **享受 AI 自动合并功能！**

---

## 📞 需要帮助?

- GitHub Actions 文档: https://docs.github.com/actions
- 查看 `GITHUB_ACTIONS_GUIDE.md` 详细指南
