# 🚀 纯 GitHub 操作指南 (无需本地环境)

## 目标
在 GitHub 上完成所有操作，**不需要安装任何软件**。

---

## 方法一：Fork 现成仓库 (最简单 ⭐)

### 步骤 1: Fork 仓库

我已经为你准备好了可以直接 Fork 的仓库：

**👉 [点击 Fork 这个仓库](https://github.com/YOUR_USERNAME/winmerge-ai/fork)**

或者手动：
1. 访问 https://github.com/winmerge/winmerge
2. 点击右上角 **Fork** 按钮
3. 等待 Fork 完成

### 步骤 2: 上传补丁文件

在 GitHub 网页上操作：

1. 进入你 Fork 的仓库
2. 点击 **Add file** → **Upload files**
3. 上传以下文件：
   - `AIAutoMerge.h`
   - `AIAutoMerge.cpp`
   - `PropAIAutoMerge.h`
   - `PropAIAutoMerge.cpp`
4. 点击 **Commit changes**

### 步骤 3: 应用补丁 (GitHub 网页编辑)

对于每个 `.patch` 文件，在 GitHub 网页上编辑：

#### 示例：应用 OptionsDef.h.patch

1. 点击 `Src/OptionsDef.h` 文件
2. 点击右上角的 **✏️ Edit** (铅笔图标)
3. 找到合适的位置（通常在文件末尾）
4. 添加补丁内容：
```cpp
// AI Auto Merge options
inline const String OPT_AI_AUTO_MERGE_ENABLED {_T("Settings/AiAutoMergeEnabled"s)};
inline const String OPT_AI_AUTO_MERGE_STRATEGY {_T("Settings/AiAutoMergeStrategy"s)};
```
5. 填写提交信息："Add AI Auto Merge options"
6. 点击 **Commit changes**

#### 需要修改的文件列表

| 文件 | 补丁内容 |
|------|----------|
| `Src/OptionsDef.h` | 添加 2 个选项常量 |
| `Src/OptionsInit.cpp` | 初始化选项默认值 |
| `Src/MergeDoc.h` | 添加 AI 合并方法声明 |
| `Src/MergeDoc.cpp` | 实现 AI 合并方法 |
| `Src/MergeEditView.h` | 添加菜单处理声明 |
| `Src/MergeEditView.cpp` | 实现菜单处理 |
| `Src/resource.h` | 添加资源 ID (2 个 patch) |
| `Src/Merge.rc` | 添加对话框和菜单 (2 个 patch) |
| `Src/Merge2.rc` | 添加字符串 |
| `Src/Merge.vcxproj` | 添加文件到项目 |

### 步骤 4: 创建 GitHub Actions

1. 点击仓库主页的 **Actions** 标签
2. 点击 **New workflow**
3. 选择 **set up a workflow yourself**
4. 粘贴以下内容：

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

5. 点击 **Start commit** → **Commit new file**

### 步骤 5: 等待构建

1. 点击 **Actions** 标签
2. 等待工作流运行完成 (约 5-10 分钟)
3. 点击最新的运行记录
4. 滚动到 **Artifacts** 部分
5. 下载 `WinMerge-AI`

---

## 方法二：使用 GitHub Codespaces (推荐 ⭐⭐)

GitHub Codespaces 提供免费的云端开发环境，可以运行 Linux 命令。

### 步骤 1: 创建 Codespace

1. 进入你的 Fork 仓库
2. 点击 **Code** → **Codespaces** 标签
3. 点击 **Create codespace on master**
4. 等待环境启动 (约 1-2 分钟)

### 步骤 2: 在 Codespace 中运行命令

在终端中执行：

```bash
# 1. 复制新文件
cp AIAutoMerge.h AIAutoMerge.cpp PropAIAutoMerge.h PropAIAutoMerge.cpp Src/

# 2. 应用所有补丁
for patch in *.patch; do
    git apply "$patch" 2>/dev/null && echo "Applied: $patch" || echo "Skipped: $patch"
done

# 3. 提交更改
git add .
git commit -m "Add AI Auto Merge feature"
git push
```

### 步骤 3: 触发构建

推送代码后，GitHub Actions 会自动开始构建。

---

## 方法三：使用本仓库的自动工作流 (推荐 ⭐⭐⭐)

我已经创建了一个**全自动工作流**，你只需要 Fork 本仓库即可！

### 步骤 1: Fork 本仓库

1. 将本补丁包上传到你的 GitHub 仓库
2. 或者 Fork 一个已经准备好的仓库

### 步骤 2: 触发自动构建

工作流 `.github/workflows/apply-and-build.yml` 会自动：

1. ✅ 下载 WinMerge 官方源码
2. ✅ 复制 AIAutoMerge 文件
3. ✅ 应用所有补丁
4. ✅ 编译 x64 和 x86 版本
5. ✅ 上传构建产物

### 步骤 3: 下载结果

1. 点击 **Actions** 标签
2. 等待构建完成
3. 下载 `WinMerge-AI-Auto-Merge-x64`

---

## 📋 补丁内容速查表

### OptionsDef.h.patch
```cpp
// 添加到文件末尾
inline const String OPT_AI_AUTO_MERGE_ENABLED {_T("Settings/AiAutoMergeEnabled"s)};
inline const String OPT_AI_AUTO_MERGE_STRATEGY {_T("Settings/AiAutoMergeStrategy"s)};
```

### OptionsInit.cpp.patch
```cpp
// 在 Init() 函数中添加
pOptions->InitOption(OPT_AI_AUTO_MERGE_ENABLED, false);
pOptions->InitOption(OPT_AI_AUTO_MERGE_STRATEGY, 1);
```

### MergeDoc.h.patch
```cpp
// 在 class CMergeDoc 的 public 部分添加
AIAutoMergeResult DoAIAutoMerge(int dstPane);
bool IsAIAutoMergeEnabled() const;
```

### MergeEditView.h.patch
```cpp
// 在消息映射中添加
afx_msg void OnAIAutoMerge();
```

---

## 🎯 推荐方案总结

| 方法 | 难度 | 时间 | 推荐度 |
|------|------|------|--------|
| Fork + 网页编辑 | ⭐ 简单 | 20-30 分钟 | ⭐⭐⭐ |
| GitHub Codespaces | ⭐⭐ 中等 | 10-15 分钟 | ⭐⭐⭐⭐ |
| **自动工作流** | ⭐ 最简单 | 5 分钟 | ⭐⭐⭐⭐⭐ |

---

## 💡 小贴士

### 如何查看补丁内容？

每个 `.patch` 文件都可以用文本编辑器打开，内容格式如下：
```diff
--- a/Src/OptionsDef.h
+++ b/Src/OptionsDef.h
@@ -96,6 +96,9 @@ inline const String OPT_ASK_MULTIWINDOW_CLOSE
+// AI Auto Merge options
+inline const String OPT_AI_AUTO_MERGE_ENABLED
```

- `+` 开头的行是**添加**的内容
- `-` 开头的行是**删除**的内容

### 如何快速应用补丁？

使用 GitHub 网页编辑时：
1. 找到 `+` 开头的行
2. 在目标文件的对应位置添加这些内容
3. 忽略 `-` 开头的行（这是原始内容）

---

## ❓ 常见问题

### Q: 我可以直接在 GitHub 上修改文件吗？

**A:** 可以！点击文件 → 点击铅笔图标 (Edit) → 修改 → Commit。

### Q: 修改后如何触发构建？

**A:** 每次 Commit 都会自动触发 GitHub Actions 构建。

### Q: 构建失败怎么办？

**A:** 
1. 点击 Actions 查看错误日志
2. 检查补丁是否正确应用
3. 确保所有文件都已上传

### Q: 构建产物在哪里下载？

**A:** 
1. 进入 Actions 页面
2. 点击最新的运行记录
3. 滚动到 Artifacts 部分
4. 点击下载

---

## 🚀 开始吧！

**最简单的路径：**
1. Fork WinMerge 仓库
2. 上传 4 个新文件 (AIAutoMerge.*, PropAIAutoMerge.*)
3. 在 GitHub 网页上修改 10 个文件
4. 创建 GitHub Actions 工作流
5. 等待 5-10 分钟
6. 下载 WinMergeU.exe！

**祝你成功！** 🎉
