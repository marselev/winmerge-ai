# WinMerge AI 自动合并功能实现总结

## 概述

本项目为 WinMerge 添加了 AI 自动合并开关功能，用户可以选择是否使用 AI 智能合并，并配置不同的合并策略。

## 核心功能

### 1. AI 自动合并管理器 (AIAutoMerge)

**文件**: `AIAutoMerge.h`, `AIAutoMerge.cpp`

主要类:
- `AIAutoMergeManager` - 管理 AI 自动合并的核心类

功能:
- 启用/禁用 AI 自动合并
- 选择合并策略 (Conservative, Balanced, Aggressive, Smart)
- 执行自动合并操作
- 分析差异并决定是否合并

### 2. 合并策略

| 策略 | 描述 | 适用场景 |
|------|------|----------|
| Conservative | 只合并简单的添加/删除，变更行数 ≤3 | 安全优先 |
| Balanced | 使用上下文分析，置信度 ≥0.7 | 大多数场景 |
| Aggressive | 合并大部分变更，只跳过明显冲突 | 快速合并 |
| Smart | 使用代码模式匹配，置信度 ≥0.85 | 代码合并 |

### 3. 设置对话框 (PropAIAutoMerge)

**文件**: `PropAIAutoMerge.h`, `PropAIAutoMerge.cpp`

- 在 WinMerge 设置中添加 "AI Auto Merge" 选项页
- 启用/禁用 AI 自动合并开关
- 选择合并策略下拉框
- 实时更新配置

### 4. 菜单集成

- 在 Merge 菜单添加 "AI Auto Merge" 选项
- 快捷键支持
- 工具栏按钮（可扩展）

## 代码修改详情

### 新增文件 (4个)

1. **AIAutoMerge.h** (2.8 KB)
   - AIAutoMergeStrategy 枚举
   - AIAutoMergeResult 结构体
   - AIAutoMergeManager 类声明

2. **AIAutoMerge.cpp** (9.8 KB)
   - 四种合并策略的实现
   - 置信度计算算法
   - 全局管理器实例

3. **PropAIAutoMerge.h** (1.3 KB)
   - 属性页类声明

4. **PropAIAutoMerge.cpp** (3.5 KB)
   - 对话框初始化
   - 选项读写
   - 控件状态更新

### 修改文件 (10个补丁)

1. **OptionsDef.h.patch**
   - 添加 `OPT_AI_AUTO_MERGE_ENABLED`
   - 添加 `OPT_AI_AUTO_MERGE_STRATEGY`

2. **OptionsInit.cpp.patch**
   - 初始化 AI 自动合并选项
   - 默认禁用，策略为 Balanced

3. **MergeDoc.h.patch**
   - 添加 `DoAIAutoMerge()` 方法
   - 添加 `IsAIAutoMergeEnabled()` 方法

4. **MergeDoc.cpp.patch**
   - 实现 AI 自动合并方法
   - 初始化和清理 AI 管理器

5. **MergeEditView.h.patch**
   - 添加 `OnAIAutoMerge()` 消息处理

6. **MergeEditView.cpp.patch**
   - 实现 AI 合并菜单处理
   - 显示合并结果对话框

7. **resource.h.patch**
   - 添加对话框资源 ID
   - 添加控件 ID

8. **resource.h.menu.patch**
   - 添加菜单命令 ID

9. **Merge.rc.patch**
   - 添加 AI Auto Merge 对话框
   - 对话框布局定义

10. **Merge.rc.menu.patch**
    - 在 Merge 菜单添加 AI 合并项

11. **Merge2.rc.patch**
    - 添加字符串资源

12. **Merge.vcxproj.patch**
    - 添加新文件到项目

## 技术亮点

### 1. 智能合并算法

```cpp
// 置信度计算考虑多个因素:
// - 变更大小相似度
// - 变更行数
// - 简单添加/删除检测

double CalculateChangeConfidence(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    double confidence = 0.5;
    
    // 大小相似度加分
    if (srcLines == dstLines) confidence += 0.2;
    
    // 小变更加分
    if (totalLines <= 5) confidence += 0.2;
    
    return clamp(confidence, 0.0, 1.0);
}
```

### 2. 策略模式实现

```cpp
bool ShouldMergeDiff(const DIFFRANGE& diff, int srcPane, int dstPane)
{
    switch (m_strategy) {
    case AIAutoMergeStrategy::CONSERVATIVE:
        return AnalyzeConservative(diff, srcPane, dstPane);
    case AIAutoMergeStrategy::BALANCED:
        return AnalyzeBalanced(diff, srcPane, dstPane);
    // ...
    }
}
```

### 3. 配置持久化

- 使用 WinMerge 现有的选项管理系统
- 配置保存在注册表/配置文件中
- 启动时自动加载

## 使用方法

### 1. 启用 AI 自动合并

```
Edit -> Options -> AI Auto Merge
☑ Enable AI Auto Merge
Merge Strategy: [Balanced ▼]
[OK]
```

### 2. 执行 AI 自动合并

```
文件比较窗口:
Merge -> AI Auto Merge

或

右键菜单 -> AI Auto Merge
```

### 3. 查看结果

```
AI Auto Merge completed: 15 changes merged, 3 conflicts need manual resolution

Some differences require manual resolution.
[OK]
```

## 安装步骤

### 快速安装 (推荐)

```bash
cd /path/to/winmerge/source
bash /path/to/winmerge_ai_merge/apply_patch.sh
```

### 手动安装

1. 复制新文件到 `Src/` 目录
2. 应用所有补丁文件
3. 用 Visual Studio 重新编译

## 扩展建议

### 1. 机器学习集成
- 训练模型识别安全的合并模式
- 基于用户历史行为学习

### 2. 更多策略
- 基于文件类型的策略
- 自定义规则引擎

### 3. UI 增强
- 合并预览功能
- 可视化冲突解决

### 4. 批处理支持
- 文件夹比较的 AI 合并
- 命令行支持

## 兼容性

- WinMerge 2.16.x 及以上版本
- Visual Studio 2017/2019/2022
- Windows 7/8/10/11

## 许可证

GPL-2.0-or-later (与 WinMerge 相同)

## 作者

AI 助手为 WinMerge 社区贡献
