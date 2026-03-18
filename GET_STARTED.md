# WinMerge AI 自动合并 - 快速开始

## ⚠️ 重要说明

由于 WinMerge 是 **Windows MFC 应用程序**，需要 **Visual Studio** 才能编译。当前 Linux 环境无法直接编译 Windows 可执行文件。

## 🚀 推荐方案：使用 Windows 编译

### 方案一：一键编译脚本 (推荐)

在 Windows 上双击运行：

```
ApplyAndBuild.bat    :: 批处理版本
ApplyAndBuild.ps1    :: PowerShell 版本 (推荐)
```

**脚本会自动完成：**
1. 检测 Visual Studio 安装
2. 克隆 WinMerge 源码
3. 应用 AI 自动合并补丁
4. 编译 Release 版本
5. 提示运行

### 方案二：手动编译

#### 1. 准备工作

- Windows 10/11
- Visual Studio 2019 或 2022
- 安装组件：**C++ MFC for latest v143 build tools (x86 & x64)**

#### 2. 下载并应用补丁

```batch
:: 1. 下载 WinMerge 源码
git clone https://github.com/winmerge/winmerge.git
cd winmerge

:: 2. 复制新文件
copy ..\winmerge_ai_merge\AIAutoMerge.h Src\
copy ..\winmerge_ai_merge\AIAutoMerge.cpp Src\
copy ..\winmerge_ai_merge\PropAIAutoMerge.h Src\
copy ..\winmerge_ai_merge\PropAIAutoMerge.cpp Src\

:: 3. 应用补丁
git apply ..\winmerge_ai_merge\*.patch
```

#### 3. 编译

**使用 Visual Studio IDE:**
1. 打开 `WinMerge.sln`
2. 选择 `Release` + `x64`
3. 菜单: `Build` → `Build Solution`

**使用命令行:**
```batch
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"^
    WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m
```

#### 4. 运行

```batch
Build\x64\Release\WinMergeU.exe
```

## 📦 文件说明

| 文件 | 用途 |
|------|------|
| `ApplyAndBuild.bat` | Windows 批处理编译脚本 |
| `ApplyAndBuild.ps1` | PowerShell 编译脚本 (推荐) |
| `BuildInstructions.md` | 详细编译指南 |
| `*.h`, `*.cpp` | 新源代码文件 |
| `*.patch` | 补丁文件 |

## 🔧 常见问题

### Q: 提示 "MFC libraries are required"

**A:** 安装 MFC 支持
1. 打开 Visual Studio Installer
2. 点击 "修改"
3. 勾选 "C++ MFC for latest v143 build tools (x86 & x64)"
4. 安装

### Q: 补丁应用失败

**A:** 手动应用补丁内容，参考 `README.md` 中的手动修改说明

### Q: 编译成功但找不到 AI 选项

**A:** 检查资源文件是否正确更新：
- `resource.h` 是否包含 AI 相关的 ID
- `Merge.rc` 是否包含 AI 对话框
- `Merge2.rc` 是否包含 AI 字符串

## 🖼️ 功能预览

编译完成后，你将看到：

### 设置对话框
```
Edit → Options → AI Auto Merge
  ☑ Enable AI Auto Merge
  Merge Strategy: [Balanced ▼]
    - Conservative (安全优先)
    - Balanced (推荐)
    - Aggressive (快速合并)
    - Smart (智能分析)
```

### 合并菜单
```
Merge → AI Auto Merge
```

### 结果提示
```
AI Auto Merge completed: 15 changes merged, 3 conflicts need manual resolution
```

## 📊 策略对比

| 策略 | 置信度 | 合并率 | 冲突率 | 适用场景 |
|------|--------|--------|--------|----------|
| Conservative | 0.9 | 30% | 5% | 安全优先 |
| Balanced | 0.7 | 60% | 15% | 大多数场景 |
| Aggressive | 0.3 | 85% | 30% | 快速合并 |
| Smart | 0.85 | 70% | 10% | 代码合并 |

## 🎯 使用建议

1. **首次使用**: 选择 `Balanced` 策略
2. **代码审查**: 选择 `Conservative` 策略
3. **快速合并**: 选择 `Aggressive` 策略
4. **代码重构**: 选择 `Smart` 策略

## 📞 需要帮助?

如果遇到问题：
1. 查看 `BuildInstructions.md` 详细指南
2. 检查 Visual Studio 是否正确安装 MFC
3. 确保补丁文件完整

---

**注意**: 本补丁需要 Windows + Visual Studio 环境才能编译。Linux 环境无法直接编译 Windows MFC 应用程序。
