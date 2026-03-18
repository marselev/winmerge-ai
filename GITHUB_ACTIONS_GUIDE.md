# WinMerge AI 自动合并 - GitHub Actions 编译指南

## 🚀 快速开始

使用 GitHub Actions 自动编译 WinMerge + AI 自动合并功能！

## 方法一：Fork WinMerge 仓库 (推荐)

### 步骤 1: Fork WinMerge 仓库

1. 访问 https://github.com/winmerge/winmerge
2. 点击右上角的 **Fork** 按钮
3. 等待 Fork 完成

### 步骤 2: 应用 AI 自动合并补丁

在你的 Fork 仓库中：

```bash
# 克隆你的 Fork
git clone https://github.com/YOUR_USERNAME/winmerge.git
cd winmerge

# 复制 AI 自动合并文件
cp /path/to/ai-merge/AIAutoMerge.h Src/
cp /path/to/ai-merge/AIAutoMerge.cpp Src/
cp /path/to/ai-merge/PropAIAutoMerge.h Src/
cp /path/to/ai-merge/PropAIAutoMerge.cpp Src/

# 应用补丁
git apply /path/to/ai-merge/OptionsDef.h.patch
git apply /path/to/ai-merge/OptionsInit.cpp.patch
git apply /path/to/ai-merge/MergeDoc.h.patch
git apply /path/to/ai-merge/MergeDoc.cpp.patch
git apply /path/to/ai-merge/MergeEditView.h.patch
git apply /path/to/ai-merge/MergeEditView.cpp.patch
git apply /path/to/ai-merge/resource.h.patch
git apply /path/to/ai-merge/resource.h.menu.patch
git apply /path/to/ai-merge/Merge.rc.patch
git apply /path/to/ai-merge/Merge.rc.menu.patch
git apply /path/to/ai-merge/Merge2.rc.patch
git apply /path/to/ai-merge/Merge.vcxproj.patch

# 提交更改
git add .
git commit -m "Add AI Auto Merge feature"
git push origin master
```

### 步骤 3: 添加 GitHub Actions 工作流

在你的 Fork 仓库中创建文件 `.github/workflows/build-ai-merge.yml`：

```yaml
name: Build WinMerge AI

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v4
      - uses: microsoft/setup-msbuild@v2
      - uses: NuGet/setup-nuget@v2
      
      - run: nuget restore WinMerge.sln
      
      - run: msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m
      
      - uses: actions/upload-artifact@v4
        with:
          name: WinMerge-AI-x64
          path: Build/x64/Release/WinMergeU.exe
```

### 步骤 4: 触发构建

1. 推送代码到你的 Fork
2. 进入 GitHub 仓库页面
3. 点击 **Actions** 标签
4. 等待构建完成
5. 下载构建产物

---

## 方法二：使用本补丁包的工作流

### 步骤 1: 创建新仓库

1. 在 GitHub 创建新仓库 (例如 `winmerge-ai`)
2. 不要初始化 README

### 步骤 2: 上传补丁文件

将本补丁包的所有文件上传到新仓库：

```bash
# 在你的补丁包目录中
git init
git add .
git commit -m "Initial AI Auto Merge patch"
git remote add origin https://github.com/YOUR_USERNAME/winmerge-ai.git
git push -u origin main
```

### 步骤 3: GitHub Actions 自动编译

本补丁包已包含完整的工作流文件 `.github/workflows/build-winmerge-ai.yml`

推送后，GitHub Actions 会自动：
1. 检出 WinMerge 官方源码
2. 应用 AI 自动合并补丁
3. 编译 x64 和 x86 版本
4. 上传构建产物

### 步骤 4: 下载编译结果

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择最新的工作流运行
4. 下载 `WinMerge-AI-Merge-x64-Release` 产物

---

## 📋 工作流说明

### 完整工作流功能

本补丁包包含两个工作流：

| 工作流 | 用途 |
|--------|------|
| `build-winmerge-ai.yml` | 完整功能，自动下载 WinMerge 源码并编译 |
| `build-simple.yml` | 简化版，用于已打补丁的 Fork |

### 触发条件

- **Push 到 main/master 分支**: 自动编译
- **Pull Request**: 验证编译
- **手动触发**: 在 Actions 页面点击 "Run workflow"

### 构建配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| Build Type | Release | 可在手动触发时选择 Debug |
| Platform | x64, x86 | 同时编译两个版本 |

---

## 📥 下载编译结果

### 方式 1: GitHub Actions 产物

1. 打开仓库页面
2. 点击 **Actions**
3. 选择最新的运行
4. 滚动到 **Artifacts** 部分
5. 下载 `WinMerge-AI-Merge-x64-Release`

### 方式 2: GitHub Releases (自动)

推送 Tag 时自动创建 Release：

```bash
git tag v2.16.50-ai
git push origin v2.16.50-ai
```

---

## 🔧 自定义编译

### 修改编译配置

编辑 `.github/workflows/build-winmerge-ai.yml`：

```yaml
# 修改编译配置
- name: Build WinMerge
  run: |
    msbuild WinMerge.sln `
      /p:Configuration=Debug `        # 改为 Debug
      /p:Platform=x64 `
      /m
```

### 添加更多平台

```yaml
strategy:
  matrix:
    platform: [x64, Win32, ARM64]
    configuration: [Release, Debug]
```

---

## ❓ 常见问题

### Q: 构建失败，提示找不到 MFC

**A:** GitHub Actions 的 `windows-2022` 镜像已包含 MFC，无需额外安装。

### Q: 如何加快构建速度

**A:** 
- 使用 `/m` 参数启用并行构建
- 使用 `actions/cache` 缓存 NuGet 包
- 只编译需要的项目

### Q: 构建产物在哪里

**A:** 
- 在 Actions 页面的 **Artifacts** 部分下载
- 或使用 GitHub API 下载

### Q: 可以创建安装包吗

**A:** 可以，添加 Inno Setup 步骤：

```yaml
- name: Create Installer
  run: |
    iscc Installer\WinMergeX64.iss
```

---

## 📊 构建状态徽章

在你的 README.md 中添加构建状态徽章：

```markdown
![Build Status](https://github.com/YOUR_USERNAME/winmerge-ai/workflows/Build%20WinMerge%20with%20AI%20Auto%20Merge/badge.svg)
```

---

## 🎯 下一步

1. **Fork WinMerge 仓库**
2. **应用 AI 自动合并补丁**
3. **推送代码触发构建**
4. **下载并使用编译好的 WinMerge**

---

## 📞 需要帮助?

- GitHub Actions 文档: https://docs.github.com/actions
- WinMerge 文档: https://winmerge.org/docs/
