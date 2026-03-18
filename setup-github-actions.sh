#!/bin/bash
# Setup GitHub Actions for WinMerge AI Auto Merge
# This script helps you create a GitHub repository with AI Auto Merge

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}WinMerge AI Auto Merge - GitHub Actions Setup${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Check prerequisites
check_prereq() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed${NC}"
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}Warning: GitHub CLI (gh) is not installed${NC}"
        echo "Install from: https://cli.github.com/"
    fi
}

check_prereq

# Get GitHub username
echo -e "${BLUE}Step 1: GitHub Configuration${NC}"
echo ""
read -p "Enter your GitHub username: " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}Error: GitHub username is required${NC}"
    exit 1
fi

# Get repository name
echo ""
read -p "Enter repository name [winmerge-ai]: " REPO_NAME
REPO_NAME=${REPO_NAME:-winmerge-ai}

# Get repository visibility
echo ""
read -p "Make repository private? [y/N]: " PRIVATE_ANSWER
if [[ $PRIVATE_ANSWER =~ ^[Yy]$ ]]; then
    REPO_VISIBILITY="--private"
else
    REPO_VISIBILITY="--public"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$HOME/winmerge-ai-build-$$"

echo ""
echo -e "${BLUE}Step 2: Creating Repository${NC}"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clone WinMerge
echo "Cloning WinMerge repository..."
git clone --depth 1 https://github.com/winmerge/winmerge.git "$REPO_NAME"
cd "$REPO_NAME"

# Remove original git history
echo "Setting up new repository..."
rm -rf .git
git init
git config user.email "ai-merge@example.com"
git config user.name "AI Merge Setup"

# Copy AI Auto Merge files
echo ""
echo -e "${BLUE}Step 3: Applying AI Auto Merge Patch${NC}"
echo ""

echo "Copying new source files..."
cp "$SCRIPT_DIR/AIAutoMerge.h" Src/
cp "$SCRIPT_DIR/AIAutoMerge.cpp" Src/
cp "$SCRIPT_DIR/PropAIAutoMerge.h" Src/
cp "$SCRIPT_DIR/PropAIAutoMerge.cpp" Src/

echo "Applying patches..."
apply_patch() {
    local patch_file="$SCRIPT_DIR/$1"
    if [ -f "$patch_file" ]; then
        if git apply "$patch_file" 2>/dev/null; then
            echo "  [OK] Applied $1"
        else
            echo "  [WARN] $1 may already be applied or failed"
        fi
    else
        echo "  [WARN] $1 not found"
    fi
}

apply_patch "OptionsDef.h.patch"
apply_patch "OptionsInit.cpp.patch"
apply_patch "MergeDoc.h.patch"
apply_patch "MergeDoc.cpp.patch"
apply_patch "MergeEditView.h.patch"
apply_patch "MergeEditView.cpp.patch"
apply_patch "resource.h.patch"
apply_patch "resource.h.menu.patch"
apply_patch "Merge.rc.patch"
apply_patch "Merge.rc.menu.patch"
apply_patch "Merge2.rc.patch"
apply_patch "Merge.vcxproj.patch"

# Copy GitHub Actions workflow
echo ""
echo -e "${BLUE}Step 4: Setting up GitHub Actions${NC}"
echo ""

mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'EOF'
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
EOF

echo "  [OK] Created GitHub Actions workflow"

# Create README
cat > README.md << EOF
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
\`\`\`bash
# Clone repository
git clone https://github.com/$GITHUB_USER/$REPO_NAME.git
cd $REPO_NAME

# Restore packages
nuget restore WinMerge.sln

# Build
msbuild WinMerge.sln /p:Configuration=Release /p:Platform=x64
\`\`\`

## License

GPL-2.0-or-later (same as WinMerge)
EOF

echo "  [OK] Created README.md"

# Commit changes
echo ""
echo -e "${BLUE}Step 5: Committing Changes${NC}"
echo ""

git add .
git commit -m "Add AI Auto Merge feature

- Add AIAutoMergeManager with 4 merge strategies
- Add settings dialog for configuration
- Add menu integration
- Add GitHub Actions workflow for automated builds"

# Create GitHub repository and push
echo ""
echo -e "${BLUE}Step 6: Creating GitHub Repository${NC}"
echo ""

if command -v gh &> /dev/null; then
    # Login check
    if ! gh auth status &> /dev/null; then
        echo "Please login to GitHub CLI:"
        gh auth login
    fi
    
    # Create repository
    echo "Creating GitHub repository: $REPO_NAME"
    gh repo create "$REPO_NAME" $REPO_VISIBILITY --source=. --remote=origin --push
    
    echo ""
    echo -e "${GREEN}Repository created: https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
else
    echo "GitHub CLI not found. Please manually create repository:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Create repository: $REPO_NAME"
    echo "  3. Run the following commands:"
    echo ""
    echo "     git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "     git push -u origin main"
fi

# Cleanup
echo ""
echo -e "${BLUE}Step 7: Cleanup${NC}"
echo ""

cd "$SCRIPT_DIR"
rm -rf "$BUILD_DIR"

echo "  [OK] Cleaned up temporary files"

# Summary
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Repository: ${BLUE}https://github.com/$GITHUB_USER/$REPO_NAME${NC}"
echo ""
echo "Next steps:"
echo "  1. Visit the repository page"
echo "  2. Click on 'Actions' tab"
echo "  3. Wait for the build to complete"
echo "  4. Download WinMerge-AI-x64 artifact"
echo ""
echo "Usage:"
echo "  1. Download and extract WinMergeU.exe"
echo "  2. Run WinMergeU.exe"
echo "  3. Go to Edit → Options → AI Auto Merge"
echo "  4. Enable AI Auto Merge and select strategy"
echo ""
