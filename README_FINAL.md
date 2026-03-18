# WinMerge AI 自动合并功能

为 WinMerge 添加 AI 自动合并开关，用户可选择 AI 智能合并。

---

## 🎯 功能亮点

- ✅ **4 种合并策略**: Conservative, Balanced, Aggressive, Smart
- ✅ **设置对话框**: Edit → Options → AI Auto Merge
- ✅ **菜单集成**: Merge → AI Auto Merge
- ✅ **结果报告**: 显示合并成功/冲突数量
- ✅ **配置持久化**: 自动保存用户设置

---

## 🚀 快速开始 (推荐 GitHub Actions)

### 方法一：一键设置 (最简单)

**Linux/Mac:**
```bash
chmod +x setup-github-actions.sh
./setup-github-actions.sh
```

**Windows (PowerShell):**
```powershell
.\Setup-GitHubActions.ps1
```

脚本会自动：
1. Fork WinMerge 仓库
2. 应用 AI 自动合并补丁
3. 创建 GitHub Actions 工作流
4. 触发自动构建
5. 生成可下载的 WinMergeU.exe

### 方法二：手动 Fork

1. Fork [WinMerge](https://github.com/winmerge/winmerge)
2. 复制 `AIAutoMerge.*` 和 `PropAIAutoMerge.*` 到 `Src/` 目录
3. 应用所有 `.patch` 文件
4. 推送代码触发 GitHub Actions
5. 下载构建产物

---

## 📖 文档导航

| 文档 | 说明 |
|------|------|
| `INDEX.md` | 📑 完整文件索引 |
| `GET_STARTED.md` | ⚡ 5分钟快速开始 |
| `README_GITHUB_ACTIONS.md` | 🚀 GitHub Actions 指南 |
| `GITHUB_ACTIONS_GUIDE.md` | 📚 GitHub Actions 详细指南 |
| `BuildInstructions.md` | 🖥️ Windows 本地编译指南 |
| `IMPLEMENTATION_SUMMARY.md` | 🔧 技术实现总结 |

---

## 📦 文件说明

### 核心源代码
- `AIAutoMerge.h/cpp` - AI 自动合并核心实现 (4种策略)
- `PropAIAutoMerge.h/cpp` - 设置对话框

### 补丁文件
- `*.patch` (12个) - 修改现有 WinMerge 文件

### 自动化脚本
- `setup-github-actions.sh` / `Setup-GitHubActions.ps1` - 一键设置
- `ApplyAndBuild.bat` / `ApplyAndBuild.ps1` - Windows 编译脚本
- `apply_patch.sh` - Linux/Mac 补丁脚本

### GitHub Actions
- `.github/workflows/build-winmerge-ai.yml` - 完整工作流
- `.github/workflows/build-simple.yml` - 简化工作流

---

## 🖼️ 预览

### 系统架构
![架构图](architecture.png)

### 策略对比
![策略对比](strategy_comparison.png)

### 工作流程
![工作流程](workflow.png)

---

## 🔧 合并策略

| 策略 | 置信度 | 合并率 | 适用场景 |
|------|--------|--------|----------|
| **Conservative** | 0.9 | ~30% | 安全优先，只合并明显变更 |
| **Balanced** | 0.7 | ~60% | 推荐，适合大多数场景 |
| **Aggressive** | 0.3 | ~85% | 快速合并，适合信任源文件 |
| **Smart** | 0.85 | ~70% | 智能分析，适合代码合并 |

---

## ⚙️ 配置选项

```ini
[Settings]
AiAutoMergeEnabled=1          # 0=禁用, 1=启用
AiAutoMergeStrategy=1         # 0=Conservative, 1=Balanced, 2=Aggressive, 3=Smart
```

---

## 📥 下载编译版本

1. 访问你的 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择最新的工作流运行
4. 下载 `WinMerge-AI-x64` 产物

---

## ❓ 常见问题

**Q: 可以直接运行吗?**  
A: 不能。需要编译。使用 GitHub Actions 自动编译最简单。

**Q: 需要付费吗?**  
A: 不需要。GitHub Actions 对公开仓库免费。

**Q: 编译需要多长时间?**  
A: GitHub Actions 约 5-10 分钟。

**Q: 支持哪些 Windows 版本?**  
A: Windows 7/8/10/11 (x64 和 x86)

---

## 📄 许可证

GPL-2.0-or-later (与 WinMerge 相同)

---

## 🌟 开始使用

```bash
# 最简单的开始方式
./setup-github-actions.sh  # Linux/Mac
# 或
.\Setup-GitHubActions.ps1  # Windows
```

然后访问你的 GitHub 仓库，等待构建完成，下载 WinMerge！
