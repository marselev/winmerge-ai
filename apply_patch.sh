#!/bin/bash
# WinMerge AI Auto Merge Patch Installer
# This script applies the AI Auto Merge patch to WinMerge source code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}WinMerge AI Auto Merge Patch Installer${NC}"
echo "========================================"
echo ""

# Check if we're in the WinMerge source directory
if [ ! -f "Src/MergeDoc.cpp" ]; then
    echo -e "${RED}Error: This script must be run from the WinMerge source root directory${NC}"
    echo "Please cd to the WinMerge source directory and run:"
    echo "  bash /path/to/apply_patch.sh"
    exit 1
fi

WINMERGE_ROOT=$(pwd)
PATCH_DIR=$(dirname "$0")

echo "WinMerge root: $WINMERGE_ROOT"
echo "Patch directory: $PATCH_DIR"
echo ""

# Step 1: Copy new files
echo -e "${YELLOW}Step 1: Copying new source files...${NC}"
if [ -f "$PATCH_DIR/AIAutoMerge.h" ]; then
    cp "$PATCH_DIR/AIAutoMerge.h" "$WINMERGE_ROOT/Src/"
    echo "  - AIAutoMerge.h copied"
fi

if [ -f "$PATCH_DIR/AIAutoMerge.cpp" ]; then
    cp "$PATCH_DIR/AIAutoMerge.cpp" "$WINMERGE_ROOT/Src/"
    echo "  - AIAutoMerge.cpp copied"
fi

if [ -f "$PATCH_DIR/PropAIAutoMerge.h" ]; then
    cp "$PATCH_DIR/PropAIAutoMerge.h" "$WINMERGE_ROOT/Src/"
    echo "  - PropAIAutoMerge.h copied"
fi

if [ -f "$PATCH_DIR/PropAIAutoMerge.cpp" ]; then
    cp "$PATCH_DIR/PropAIAutoMerge.cpp" "$WINMERGE_ROOT/Src/"
    echo "  - PropAIAutoMerge.cpp copied"
fi

echo ""
echo -e "${YELLOW}Step 2: Applying patches...${NC}"

# Function to apply a patch
apply_patch() {
    local patch_file=$1
    local target_file=$2
    
    if [ -f "$PATCH_DIR/$patch_file" ]; then
        echo "  - Applying $patch_file..."
        cd "$WINMERGE_ROOT"
        if patch -p1 --dry-run < "$PATCH_DIR/$patch_file" > /dev/null 2>&1; then
            patch -p1 < "$PATCH_DIR/$patch_file"
            echo -e "    ${GREEN}Success${NC}"
        else
            echo -e "    ${YELLOW}Warning: Could not apply $patch_file (may already be patched)${NC}"
        fi
    fi
}

# Apply all patches
apply_patch "OptionsDef.h.patch" "Src/OptionsDef.h"
apply_patch "OptionsInit.cpp.patch" "Src/OptionsInit.cpp"
apply_patch "MergeDoc.h.patch" "Src/MergeDoc.h"
apply_patch "MergeDoc.cpp.patch" "Src/MergeDoc.cpp"
apply_patch "MergeEditView.h.patch" "Src/MergeEditView.h"
apply_patch "MergeEditView.cpp.patch" "Src/MergeEditView.cpp"
apply_patch "resource.h.patch" "Src/resource.h"
apply_patch "resource.h.menu.patch" "Src/resource.h"
apply_patch "Merge.rc.patch" "Src/Merge.rc"
apply_patch "Merge.rc.menu.patch" "Src/Merge.rc"
apply_patch "Merge2.rc.patch" "Src/Merge2.rc"
apply_patch "Merge.vcxproj.patch" "Src/Merge.vcxproj"

echo ""
echo -e "${GREEN}Patch installation completed!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open WinMerge.sln in Visual Studio"
echo "  2. Build the solution (Build -> Build Solution)"
echo "  3. Run WinMerge to test the AI Auto Merge feature"
echo ""
echo "Usage:"
echo "  - Go to Edit -> Options -> AI Auto Merge to configure"
echo "  - Use Merge -> AI Auto Merge in file compare window"
echo ""
