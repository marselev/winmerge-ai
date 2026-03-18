# WinMerge AI Auto Merge - GitHub Actions Setup (PowerShell)
# Run this script to create a GitHub repository with AI Auto Merge

param(
    [string]$RepoName = "winmerge-ai",
    [switch]$Private,
    [string]$BuildDir = "$env:TEMP\winmerge-ai-setup"
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Status($Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Success($Message) { Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Error($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Warning($Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }

# Header
Write-Host "============================================" -ForegroundColor Green
Write-Host "WinMerge AI Auto Merge - GitHub Actions Setup" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Status "Checking prerequisites..."

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed. Please install Git for Windows."
    exit 1
}

$GitHubCLI = Get-Command gh -ErrorAction SilentlyContinue
if (-not $GitHubCLI) {
    Write-Warning "GitHub CLI (gh) is not installed."
    Write-Status "Download from: https://cli.github.com/"
    Write-Status "After installation, run: gh auth login"
    Write-Host ""
}

# Get GitHub username
Write-Status "GitHub Configuration"
Write-Host ""

$GitHubUser = & git config user.name 2>$null
if (-not $GitHubUser) {
    $GitHubUser = Read-Host "Enter your GitHub username"
}

if (-not $GitHubUser) {
    Write-Error "GitHub username is required"
    exit 1
}

Write-Status "Using GitHub user: $GitHubUser"

# Confirm repository name
$RepoName = Read-Host "Enter repository name [$RepoName]"
if (-not $RepoName) { $RepoName = "winmerge-ai" }

# Confirm visibility
$Visibility = if ($Private) { "private" } else { "public" }
$PrivateAnswer = Read-Host "Make repository private? [y/N]"
if ($PrivateAnswer -eq 'y' -or $PrivateAnswer -eq 'Y') {
    $Visibility = "private"
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Create build directory
Write-Host ""
Write-Status "Setting up build directory..."

if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir
}
New-Item -ItemType Directory -Path $BuildDir | Out-Null

Set-Location $BuildDir

# Clone WinMerge
Write-Host ""
Write-Status "Cloning WinMerge repository..."
git clone --depth 1 https://github.com/winmerge/winmerge.git $RepoName
Set-Location $RepoName

# Remove original git and reinitialize
Write-Status "Setting up new repository..."
Remove-Item -Recurse -Force .git -ErrorAction SilentlyContinue
git init
git config user.email "ai-merge@example.com"
git config user.name "AI Merge Setup"

# Copy AI Auto Merge files
Write-Host ""
Write-Status "Applying AI Auto Merge Patch"
Write-Host ""

Write-Status "Copying new source files..."
Copy-Item "$ScriptDir\AIAutoMerge.h" "Src\" -Force
Copy-Item "$ScriptDir\AIAutoMerge.cpp" "Src\" -Force
Copy-Item "$ScriptDir\PropAIAutoMerge.h" "Src\" -Force
Copy-Item "$ScriptDir\PropAIAutoMerge.cpp" "Src\" -Force
Write-Success "Source files copied"

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
    $patchPath = "$ScriptDir\$patch"
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

# Setup GitHub Actions
Write-Host ""
Write-Status "Setting up GitHub Actions"
Write-Host ""

New-Item -ItemType Directory -Path ".github\workflows" -Force | Out-Null

@'
name: Build WinMerge AI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build-x64:
    name: Build x64 Release
    runs-on: windows-2022
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup MSBuild
        uses: microsoft/setup-msbuild@v2

      - name: Setup NuGet
        uses: NuGet/setup-nuget@v2

      - name: Restore NuGet Packages
        run: nuget restore WinMerge.sln

      - name: Build WinMerge x64
        run: |
          msbuild WinMerge.sln `
            /p:Configuration=Release `
            /p:Platform=x64 `
            /m `
            /v:minimal

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: WinMerge-AI-x64
          path: |
            Build/x64/Release/WinMergeU.exe
            Build/x64/Release/*.dll
          retention-days: 30

  build-x86:
    name: Build x86 Release
    runs-on: windows-2022
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup MSBuild
        uses: microsoft/setup-msbuild@v2

      - name: Setup NuGet
        uses: NuGet/setup-nuget@v2

      - name: Restore NuGet Packages
        run: nuget restore WinMerge.sln

      - name: Build WinMerge x86
        run: |
          msbuild WinMerge.sln `
            /p:Configuration=Release `
            /p:Platform=Win32 `
            /m `
            /v:minimal

      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: WinMerge-AI-x86
          path: |
            Build/Win32/Release/WinMergeU.exe
            Build/Win32/Release/*.dll
          retention-days: 30
'@ | Set-Content ".github\workflows\build.yml" -Encoding UTF8

Write-Success "Created GitHub Actions workflow"

# Create README
$ReadmeContent = @"
# WinMerge with AI Auto Merge

This repository contains WinMerge with AI Auto Merge feature.

## Features

- **AI Auto Merge**: Intelligent automatic merge with 4 strategies
  - Conservative: Safe, only obvious changes
  - Balanced: Recommended for most scenarios
  - Aggressive: Fast, merge most changes
  - Smart: Pattern matching for code

## Download

Download the latest build from [GitHub Actions](../../actions).

## Usage

1. Download WinMergeU.exe from Actions artifacts
2. Run WinMergeU.exe
3. Go to Edit → Options → AI Auto Merge
4. Enable AI Auto Merge and select strategy
5. Open file comparison and use Merge → AI Auto Merge

## Build Status

![Build Status](../../actions/workflows/build.yml/badge.svg)

## Building Locally

### Prerequisites
- Visual Studio 2019 or 2022
- C++ MFC support

### Build
\`\`\`powershell
# Clone repository
git clone https://github.com/$GitHubUser/$RepoName.git
cd $RepoName

# Restore packages
nuget restore WinMerge.sln

# Build
msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64
\`\`\`

## License

GPL-2.0-or-later (same as WinMerge)
"@

$ReadmeContent | Set-Content "README.md" -Encoding UTF8
Write-Success "Created README.md"

# Commit
Write-Host ""
Write-Status "Committing changes..."
git add .
git commit -m "Add AI Auto Merge feature

- Add AIAutoMergeManager with 4 merge strategies
- Add settings dialog for configuration  
- Add menu integration
- Add GitHub Actions workflow for automated builds"

# Create GitHub repository
Write-Host ""
Write-Status "Creating GitHub repository..."

if ($GitHubCLI) {
    # Check auth
    $AuthStatus = & gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Please login to GitHub CLI:"
        & gh auth login
    }
    
    # Create repo
    $VisibilityFlag = if ($Visibility -eq "private") { "--private" } else { "--public" }
    & gh repo create $RepoName $VisibilityFlag --source=. --remote=origin --push
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Repository created: https://github.com/$GitHubUser/$RepoName"
    } else {
        Write-Error "Failed to create repository"
        exit 1
    }
} else {
    Write-Host ""
    Write-Warning "GitHub CLI not available"
    Write-Status "Please manually create the repository:"
    Write-Host "  1. Go to: https://github.com/new"
    Write-Host "  2. Repository name: $RepoName"
    Write-Host "  3. Visibility: $Visibility"
    Write-Host "  4. Then run these commands:"
    Write-Host ""
    Write-Host "     git remote add origin https://github.com/$GitHubUser/$RepoName.git"
    Write-Host "     git push -u origin main"
    Write-Host ""
}

# Cleanup
Write-Host ""
Write-Status "Cleaning up..."
Set-Location $ScriptDir
Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
Write-Success "Cleanup complete"

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Repository: https://github.com/$GitHubUser/$RepoName" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Visit the repository page"
Write-Host "  2. Click on 'Actions' tab"
Write-Host "  3. Wait for the build to complete (5-10 minutes)"
Write-Host "  4. Download WinMerge-AI-x64 artifact"
Write-Host ""
Write-Host "Usage:"
Write-Host "  1. Download and extract WinMergeU.exe"
Write-Host "  2. Run WinMergeU.exe"
Write-Host "  3. Go to Edit -> Options -> AI Auto Merge"
Write-Host "  4. Enable AI Auto Merge and select strategy"
Write-Host ""

Read-Host "Press Enter to exit"
