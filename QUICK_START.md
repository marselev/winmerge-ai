# WinMerge AI 自动合并功能 - 快速开始

## 功能简介

为 WinMerge 添加 AI 自动合并开关，用户可选择是否使用 AI 智能合并，并配置不同的合并策略。

## 文件清单

### 源代码文件 (4个)
| 文件 | 大小 | 说明 |
|------|------|------|
| `AIAutoMerge.h` | 2.8 KB | AI 自动合并管理器头文件 |
| `AIAutoMerge.cpp` | 9.8 KB | AI 自动合并核心实现 |
| `PropAIAutoMerge.h` | 1.3 KB | 设置对话框头文件 |
| `PropAIAutoMerge.cpp` | 3.5 KB | 设置对话框实现 |

### 补丁文件 (12个)
| 文件 | 说明 |
|------|------|
| `OptionsDef.h.patch` | 添加选项常量 |
| `OptionsInit.cpp.patch` | 初始化选项 |
| `MergeDoc.h.patch` | 添加 AI 合并方法 |
| `MergeDoc.cpp.patch` | 实现 AI 合并方法 |
| `MergeEditView.h.patch` | 添加菜单处理 |
| `MergeEditView.cpp.patch` | 实现菜单处理 |
| `resource.h.patch` | 添加资源 ID |
| `resource.h.menu.patch` | 添加菜单 ID |
| `Merge.rc.patch` | 添加对话框 |
| `Merge.rc.menu.patch` | 添加菜单项 |
| `Merge2.rc.patch` | 添加字符串 |
| `Merge.vcxproj.patch` | 添加文件到项目 |

### 文档文件 (5个)
| 文件 | 说明 |
|------|------|
| `README.md` | 详细使用说明 |
| `IMPLEMENTATION_SUMMARY.md` | 实现总结 |
| `QUICK_START.md` | 本文件 |
| `architecture.png` | 架构图 |
| `strategy_comparison.png` | 策略对比图 |
| `workflow.png` | 工作流程图 |

### 脚本文件 (1个)
| 文件 | 说明 |
|------|------|
| `apply_patch.sh` | 一键安装脚本 |

## 快速安装

### 前提条件
- WinMerge 源代码
- Visual Studio 2017/2019/2022
- Git (用于应用补丁)

### 安装步骤

1. **下载补丁包**
   ```bash
   # 假设补丁包在 /path/to/winmerge_ai_merge/
   cd /path/to/winmerge/source
   ```

2. **运行安装脚本**
   ```bash
   bash /path/to/winmerge_ai_merge/apply_patch.sh
   ```

3. **编译 WinMerge**
   ```bash
   # 使用 Visual Studio
   WinMerge.sln
   # 或命令行
   msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64
   ```

4. **测试**
   - 运行编译后的 WinMerge
   - 打开 Edit -> Options -> AI Auto Merge
   - 启用 AI 自动合并并选择策略

## 使用指南

### 启用 AI 自动合并

```
Edit → Options → AI Auto Merge
  ☑ Enable AI Auto Merge
  Merge Strategy: [Balanced ▼]
  [OK]
```

### 执行 AI 自动合并

```
文件比较窗口:
Merge → AI Auto Merge
```

### 合并策略选择

| 策略 | 置信度阈值 | 合并率 | 适用场景 |
|------|-----------|--------|----------|
| Conservative | 0.9 | ~30% | 安全优先 |
| Balanced | 0.7 | ~60% | 大多数场景 |
| Aggressive | 0.3 | ~85% | 快速合并 |
| Smart | 0.85 | ~70% | 代码合并 |

## 配置选项

### 注册表/配置文件

```ini
[Settings]
AiAutoMergeEnabled=1          ; 0=禁用, 1=启用
AiAutoMergeStrategy=1         ; 0=Conservative, 1=Balanced, 2=Aggressive, 3=Smart
```

### 代码中使用

```cpp
// 检查 AI 自动合并是否启用
AIAutoMergeManager* mgr = GetAIAutoMergeManager();
if (mgr && mgr->IsEnabled()) {
    // 执行 AI 自动合并
    AIAutoMergeResult result = mgr->PerformAutoMerge(pDoc, dstPane);
}
```

## 故障排除

### 问题: 补丁应用失败

**解决方案:**
```bash
# 手动复制文件
cp AIAutoMerge.h AIAutoMerge.cpp PropAIAutoMerge.h PropAIAutoMerge.cpp Src/

# 手动修改文件 (参考补丁内容)
```

### 问题: 编译错误

**检查:**
1. 所有文件是否已复制到正确位置
2. 项目文件是否已更新 (Merge.vcxproj)
3. 资源文件是否已更新 (Merge.rc)

### 问题: AI 合并选项不显示

**检查:**
1. 资源 ID 是否正确添加
2. 菜单资源是否正确更新
3. 字符串资源是否正确添加

## 扩展开发

### 添加新的合并策略

1. 在 `AIAutoMerge.h` 中添加新策略到枚举
2. 在 `AIAutoMerge.cpp` 中实现分析函数
3. 更新 `GetStrategyName()` 和 `GetAllStrategyNames()`

### 集成机器学习

```cpp
// 在 AnalyzeSmart() 中添加 ML 模型调用
bool AIAutoMergeManager::AnalyzeSmart(const DIFFRANGE& diff, int srcPane, int dstPane) {
    // 调用 ML 模型进行预测
    double mlConfidence = MLModel::Predict(diff, srcPane, dstPane);
    return mlConfidence >= 0.9;
}
```

## 贡献指南

欢迎提交改进:
1. Fork WinMerge 仓库
2. 应用本补丁
3. 进行改进
4. 提交 Pull Request

## 许可证

GPL-2.0-or-later (与 WinMerge 相同)

## 联系方式

如有问题，请通过以下方式联系:
- WinMerge GitHub Issues
- WinMerge 论坛

---

**感谢使用 WinMerge AI 自动合并功能!**
