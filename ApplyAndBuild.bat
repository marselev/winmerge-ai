@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: WinMerge AI Auto Merge - Apply Patch and Build Script
:: Run this script in Windows with Visual Studio installed

title WinMerge AI Auto Merge Builder

echo ============================================
echo WinMerge AI Auto Merge - Builder
echo ============================================
echo.

:: Configuration
set "WINMERGE_REPO=https://github.com/winmerge/winmerge.git"
set "PATCH_DIR=%~dp0"
set "BUILD_DIR=%USERPROFILE%\winmerge-ai-build"

:: Find Visual Studio
set "VS_PATH="
set "MSBUILD_PATH="

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    set "VS_VERSION=2022 Community"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    set "VS_VERSION=2022 Professional"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    set "VS_VERSION=2022 Enterprise"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "MSBUILD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    set "VS_VERSION=2019 Community"
) else (
    echo [ERROR] Visual Studio not found!
    echo Please install Visual Studio 2019 or 2022 with C++ MFC support.
    pause
    exit /b 1
)

echo [INFO] Found Visual Studio %VS_VERSION%
echo [INFO] MSBuild: %MSBUILD_PATH%
echo.

:: Check for Git
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not found! Please install Git for Windows.
    pause
    exit /b 1
)

echo [INFO] Git found
echo.

:: Create build directory
if not exist "%BUILD_DIR%" (
    echo [INFO] Creating build directory: %BUILD_DIR%
    mkdir "%BUILD_DIR%"
)

cd /d "%BUILD_DIR%"

:: Clone WinMerge if not exists
if not exist "winmerge\.git" (
    echo [INFO] Cloning WinMerge repository...
    git clone %WINMERGE_REPO% winmerge
    if errorlevel 1 (
        echo [ERROR] Failed to clone repository
        pause
        exit /b 1
    )
) else (
    echo [INFO] WinMerge repository already exists, updating...
    cd winmerge
    git pull
    cd ..
)

cd winmerge

echo.
echo ============================================
echo Applying AI Auto Merge Patch
echo ============================================
echo.

:: Copy new source files
echo [INFO] Copying new source files...

copy /Y "%PATCH_DIR%AIAutoMerge.h" "Src\" >nul
copy /Y "%PATCH_DIR%AIAutoMerge.cpp" "Src\" >nul
copy /Y "%PATCH_DIR%PropAIAutoMerge.h" "Src\" >nul
copy /Y "%PATCH_DIR%PropAIAutoMerge.cpp" "Src\" >nul

if errorlevel 1 (
    echo [ERROR] Failed to copy source files
    pause
    exit /b 1
)

echo [OK] Source files copied
echo.

:: Apply patches
echo [INFO] Applying patches...

git apply "%PATCH_DIR%OptionsDef.h.patch" 2>nul
if errorlevel 1 echo [WARNING] OptionsDef.h.patch may already be applied

git apply "%PATCH_DIR%OptionsInit.cpp.patch" 2>nul
if errorlevel 1 echo [WARNING] OptionsInit.cpp.patch may already be applied

git apply "%PATCH_DIR%MergeDoc.h.patch" 2>nul
if errorlevel 1 echo [WARNING] MergeDoc.h.patch may already be applied

git apply "%PATCH_DIR%MergeDoc.cpp.patch" 2>nul
if errorlevel 1 echo [WARNING] MergeDoc.cpp.patch may already be applied

git apply "%PATCH_DIR%MergeEditView.h.patch" 2>nul
if errorlevel 1 echo [WARNING] MergeEditView.h.patch may already be applied

git apply "%PATCH_DIR%MergeEditView.cpp.patch" 2>nul
if errorlevel 1 echo [WARNING] MergeEditView.cpp.patch may already be applied

git apply "%PATCH_DIR%resource.h.patch" 2>nul
if errorlevel 1 echo [WARNING] resource.h.patch may already be applied

git apply "%PATCH_DIR%resource.h.menu.patch" 2>nul
if errorlevel 1 echo [WARNING] resource.h.menu.patch may already be applied

git apply "%PATCH_DIR%Merge.rc.patch" 2>nul
if errorlevel 1 echo [WARNING] Merge.rc.patch may already be applied

git apply "%PATCH_DIR%Merge.rc.menu.patch" 2>nul
if errorlevel 1 echo [WARNING] Merge.rc.menu.patch may already be applied

git apply "%PATCH_DIR%Merge2.rc.patch" 2>nul
if errorlevel 1 echo [WARNING] Merge2.rc.patch may already be applied

git apply "%PATCH_DIR%Merge.vcxproj.patch" 2>nul
if errorlevel 1 echo [WARNING] Merge.vcxproj.patch may already be applied

echo [OK] Patches applied
echo.

:: Build
echo ============================================
echo Building WinMerge
echo ============================================
echo.

:: Restore NuGet packages
echo [INFO] Restoring NuGet packages...
"%MSBUILD_PATH%" WinMerge.sln /t:Restore /p:Configuration=Release /p:Platform=x64 /m

:: Build the solution
echo [INFO] Building Release x64...
"%MSBUILD_PATH%" WinMerge.sln /p:Configuration=Release /p:Platform=x64 /m /v:minimal

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    echo.
    echo Common issues:
    echo 1. MFC libraries not installed
    echo    - Open Visual Studio Installer
    echo    - Modify installation
    echo    - Add "C++ MFC for latest build tools"
    echo.
    echo 2. Windows SDK not installed
    echo    - Install Windows 10/11 SDK
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo Build Successful!
echo ============================================
echo.

set "OUTPUT_EXE=%BUILD_DIR%\winmerge\Build\x64\Release\WinMergeU.exe"

if exist "%OUTPUT_EXE%" (
    echo [OK] Output: %OUTPUT_EXE%
    echo.
    echo To test:
    echo 1. Run: "%OUTPUT_EXE%"
    echo 2. Open Edit -^> Options -^> AI Auto Merge
    echo 3. Enable AI Auto Merge and select strategy
    echo 4. Open file comparison and try Merge -^> AI Auto Merge
    echo.
    
    choice /C YN /M "Run WinMerge now"
    if errorlevel 1 if not errorlevel 2 (
        start "" "%OUTPUT_EXE%"
    )
) else (
    echo [WARNING] Could not find output executable
    echo Build directory: %BUILD_DIR%\winmerge\Build\x64\Release\
)

echo.
pause
