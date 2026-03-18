# WinMerge AI 自动合并 - Windows 编译指南

## 系统要求

- Windows 10/11
- Visual Studio 2019 或 2022 (包含 C++ MFC 支持)
- Git for Windows

## 编译步骤

### 1. 下载 WinMerge 源码

```bash
git clone https://github.com/winmerge/winmerge.git
cd winmerge
```

### 2. 应用 AI 自动合并补丁

将本补丁包复制到 WinMerge 目录：

```bash
# 假设补丁包在 D:\winmerge_ai_merge\
cd C:\path\to\winmerge

# 复制新文件
xcopy D:\winmerge_ai_merge\AIAutoMerge.h Src\
xcopy D:\winmerge_ai_merge\AIAutoMerge.cpp Src\
xcopy D:\winmerge_ai_merge\PropAIAutoMerge.h Src\
xcopy D:\winmerge_ai_merge\PropAIAutoMerge.cpp Src\

# 应用补丁 (使用 Git Bash)
git apply D:\winmerge_ai_merge\OptionsDef.h.patch
git apply D:\winmerge_ai_merge\OptionsInit.cpp.patch
git apply D:\winmerge_ai_merge\MergeDoc.h.patch
git apply D:\winmerge_ai_merge\MergeDoc.cpp.patch
git apply D:\winmerge_ai_merge\MergeEditView.h.patch
git apply D:\winmerge_ai_merge\MergeEditView.cpp.patch
git apply D:\winmerge_ai_merge\resource.h.patch
git apply D:\winmerge_ai_merge\resource.h.menu.patch
git apply D:\winmerge_ai_merge\Merge.rc.patch
git apply D:\winmerge_ai_merge\Merge.rc.menu.patch
git apply D:\winmerge_ai_merge\Merge2.rc.patch
git apply D:\winmerge_ai_merge\Merge.vcxproj.patch
```

### 3. 使用 Visual Studio 编译

#### 方法一：Visual Studio IDE

1. 打开 `WinMerge.sln`
2. 选择配置：`Release` + `x64`
3. 菜单：`Build` → `Build Solution` (Ctrl+Shift+B)
4. 等待编译完成

#### 方法二：命令行 (Developer Command Prompt)

```bash
# 打开 "Developer Command Prompt for VS 2022"
cd C:\path\to\winmerge

# 还原 NuGet 包 (如果需要)
nuget restore WinMerge.sln

# 编译
msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m

# 或者编译特定项目
msbuild Src\Merge.vcxproj /p:Configuration=Release /p:Platform=x64
```

### 4. 输出文件

编译成功后，可执行文件位于：
```
Build\x64\Release\WinMergeU.exe
```

## 可能遇到的问题

### 问题 1: 缺少 MFC 支持

**错误信息：**
```
error MSB8041: MFC libraries are required for this project.
```

**解决方案：**
1. 打开 Visual Studio Installer
2. 修改安装
3. 勾选 "C++ MFC for latest v143 build tools (x86 & x64)"
4. 安装并重启

### 问题 2: 补丁应用失败

**解决方案：**
手动修改文件，参考补丁内容：

1. **OptionsDef.h** - 在文件末尾添加：
```cpp
inline const String OPT_AI_AUTO_MERGE_ENABLED {_T("Settings/AiAutoMergeEnabled"s)};
inline const String OPT_AI_AUTO_MERGE_STRATEGY {_T("Settings/AiAutoMergeStrategy"s)};
```

2. **OptionsInit.cpp** - 在 Init() 函数中添加：
```cpp
pOptions->InitOption(OPT_AI_AUTO_MERGE_ENABLED, false);
pOptions->InitOption(OPT_AI_AUTO_MERGE_STRATEGY, 1);
```

3. **Merge.vcxproj** - 在 `<ClCompile>` 和 `<ClInclude>` 节中添加新文件

### 问题 3: 资源编译错误

**解决方案：**
确保所有资源 ID 没有冲突，检查 `resource.h` 中的 ID 值。

## 验证安装

编译完成后：

1. 运行 `WinMergeU.exe`
2. 打开 `Edit` → `Options`
3. 检查是否有 "AI Auto Merge" 选项页
4. 打开文件比较窗口
5. 检查 `Merge` 菜单是否有 "AI Auto Merge" 选项

## 调试编译

如果需要调试：

```bash
# 编译 Debug 版本
msbuild WinMerge.sln /p:Configuration=Debug /p:Platform=x64 /m

# 运行调试
Build\x64\Debug\WinMergeU.exe
```

## 创建安装包

```bash
# 编译 Installer 项目
msbuild Installer\WinMergeX64.iss /p:Configuration=Release

# 或使用 Inno Setup 直接编译
iscc Installer\WinMergeX64.iss
```

## 自动化脚本

创建 `build_ai_merge.bat`：

```batch
@echo off
setlocal

set WINMERGE_DIR=C:\path\to\winmerge
set PATCH_DIR=C:\path\to\winmerge_ai_merge
set VS_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

cd /d %WINMERGE_DIR%

echo Applying AI Auto Merge patch...
xcopy /Y %PATCH_DIR%\AIAutoMerge.h Src\
xcopy /Y %PATCH_DIR%\AIAutoMerge.cpp Src\
xcopy /Y %PATCH_DIR%\PropAIAutoMerge.h Src\
xcopy /Y %PATCH_DIR%\PropAIAutoMerge.cpp Src\

git apply %PATCH_DIR%\*.patch

echo Building WinMerge with AI Auto Merge...
%VS_PATH% WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m

echo Build complete!
pause
```

## 联系方式

如有编译问题，请检查：
1. Visual Studio 版本是否兼容
2. MFC 组件是否安装
3. 补丁是否正确应用
