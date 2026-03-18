# WinMerge AI Auto Merge - Apply Patch and Build Script
# Run this script in Windows PowerShell with Administrator privileges

param(
    [string]$BuildDir = "$env:USERPROFILE\winmerge-ai-build",
    [switch]$SkipClone,
    [switch]$DebugBuild,
    [switch]$RunAfterBuild
)

$ErrorActionPreference = "Stop"

# Colors
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

function Write-Status($Message, $Color = "White") {
    Write-Host "[INFO] $Message" -ForegroundColor $Color
}

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor $Green
}

function Write-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Warning($Message) {
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

# Header
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "WinMerge AI Auto Merge - Builder" -ForegroundColor $Cyan
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

# Find Visual Studio
$MSBuildPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

$MSBuildPath = $null
foreach ($path in $MSBuildPaths) {
    if (Test-Path $path) {
        $MSBuildPath = $path
        break
    }
}

if (-not $MSBuildPath) {
    Write-Error "Visual Studio not found! Please install Visual Studio 2019 or 2022 with C++ MFC support."
    exit 1
}

Write-Status "Found MSBuild: $MSBuildPath" $Green

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git not found! Please install Git for Windows."
    exit 1
}
Write-Status "Git found" $Green

# Create build directory
if (-not (Test-Path $BuildDir)) {
    Write-Status "Creating build directory: $BuildDir"
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Set-Location $BuildDir

# Clone or update WinMerge
$WinMergeDir = Join-Path $BuildDir "winmerge"

if (-not $SkipClone) {
    if (-not (Test-Path (Join-Path $WinMergeDir ".git"))) {
        Write-Status "Cloning WinMerge repository..."
        git clone https://github.com/winmerge/winmerge.git winmerge
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to clone repository"
            exit 1
        }
    } else {
        Write-Status "Updating WinMerge repository..."
        Set-Location $WinMergeDir
        git pull
        Set-Location $BuildDir
    }
}

Set-Location $WinMergeDir

# Get patch directory
$PatchDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "Applying AI Auto Merge Patch" -ForegroundColor $Cyan
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

# Copy new source files
Write-Status "Copying new source files..."
$SourceFiles = @("AIAutoMerge.h", "AIAutoMerge.cpp", "PropAIAutoMerge.h", "PropAIAutoMerge.cpp")
foreach ($file in $SourceFiles) {
    $source = Join-Path $PatchDir $file
    $dest = Join-Path "Src" $file
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Success "Copied $file"
    } else {
        Write-Error "Source file not found: $source"
        exit 1
    }
}

# Apply patches
Write-Status "Applying patches..."
$Patches = @(
    "OptionsDef.h.patch"
    "OptionsInit.cpp.patch"
    "MergeDoc.h.patch"
    "MergeDoc.cpp.patch"
    "MergeEditView.h.patch"
    "MergeEditView.cpp.patch"
    "resource.h.patch"
    "resource.h.menu.patch"
    "Merge.rc.patch"
    "Merge.rc.menu.patch"
    "Merge2.rc.patch"
    "Merge.vcxproj.patch"
)

foreach ($patch in $Patches) {
    $patchPath = Join-Path $PatchDir $patch
    if (Test-Path $patchPath) {
        git apply $patchPath 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Applied $patch"
        } else {
            Write-Warning "$patch may already be applied"
        }
    } else {
        Write-Warning "Patch not found: $patch"
    }
}

# Build
Write-Host ""
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host "Building WinMerge" -ForegroundColor $Cyan
Write-Host "============================================" -ForegroundColor $Cyan
Write-Host ""

$Configuration = if ($DebugBuild) { "Debug" } else { "Release" }
Write-Status "Building $Configuration x64..."

# Restore NuGet packages
Write-Status "Restoring NuGet packages..."
& $MSBuildPath WinMerge.sln /t:Restore /p:Configuration=$Configuration /p:Platform=x64 /m /v:quiet

# Build
& $MSBuildPath WinMerge.sln /p:Configuration=$Configuration /p:Platform=x64 /m /v:minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Error "Build failed!"
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor $Yellow
    Write-Host "1. MFC libraries not installed" -ForegroundColor $Yellow
    Write-Host "   - Open Visual Studio Installer" -ForegroundColor $Yellow
    Write-Host "   - Modify installation" -ForegroundColor $Yellow
    Write-Host "   - Add 'C++ MFC for latest build tools'" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "2. Windows SDK not installed" -ForegroundColor $Yellow
    Write-Host "   - Install Windows 10/11 SDK" -ForegroundColor $Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor $Green
Write-Host "Build Successful!" -ForegroundColor $Green
Write-Host "============================================" -ForegroundColor $Green
Write-Host ""

$OutputExe = Join-Path $WinMergeDir "Build\x64\$Configuration\WinMergeU.exe"

if (Test-Path $OutputExe) {
    Write-Success "Output: $OutputExe"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor $Cyan
    Write-Host "1. Run WinMerge: $OutputExe"
    Write-Host "2. Open Edit -> Options -> AI Auto Merge"
    Write-Host "3. Enable AI Auto Merge and select strategy"
    Write-Host "4. Open file comparison and try Merge -> AI Auto Merge"
    Write-Host ""
    
    if ($RunAfterBuild) {
        Write-Status "Starting WinMerge..."
        Start-Process $OutputExe
    } else {
        $response = Read-Host "Run WinMerge now? (Y/N)"
        if ($response -eq 'Y' -or $response -eq 'y') {
            Start-Process $OutputExe
        }
    }
} else {
    Write-Warning "Could not find output executable"
    Write-Status "Build directory: $(Join-Path $WinMergeDir "Build\x64\$Configuration")"
}

Write-Host ""
Read-Host "Press Enter to exit"
