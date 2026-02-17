#!/bin/bash

###############################################################################
# macOS Environment Validation Script
# Validates that all required tools are installed
###############################################################################

echo "🔍 Validating macOS Development Environment"
echo "==========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

check_command() {
    if command -v "$1" &> /dev/null; then
        VERSION=$("${@:2}")
        echo -e "${GREEN}✓ $1${NC} - $VERSION"
    else
        echo -e "${RED}✗ $1 not found${NC}"
        ((ERRORS++))
    fi
}

check_file() {
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1 not found${NC}"
        ((ERRORS++))
    fi
}

###############################################################################
# Check Required Tools
###############################################################################

echo "Required Tools:"
echo "---------------"
check_command "xcodebuild" xcodebuild -version | head -n 1
check_command "node" node --version
check_command "bun" bun --version
check_command "pod" pod --version
check_command "git" git --version
echo ""

###############################################################################
# Check Optional Tools
###############################################################################

echo "Optional Tools:"
echo "---------------"
check_command "watchman" watchman --version || echo "(Recommended for development)"
check_command "eas" eas --version || echo "(Required for EAS builds)"
echo ""

###############################################################################
# Check iOS Simulators
###############################################################################

echo "iOS Simulators:"
echo "---------------"

SIMULATOR_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone" || echo "0")
if [ "$SIMULATOR_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $SIMULATOR_COUNT iOS simulator(s)${NC}"
    xcrun simctl list devices available | grep "iPhone" | head -n 5
else
    echo -e "${YELLOW}⚠ No iOS simulators found${NC}"
    echo "  Install via: Xcode > Settings > Platforms"
fi
echo ""

###############################################################################
# Check Project Structure
###############################################################################

echo "Project Structure:"
echo "------------------"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

check_file "$WORKSPACE_DIR/mobile/package.json"
check_file "$WORKSPACE_DIR/mobile/app.json"
check_file "$WORKSPACE_DIR/mobile/modules/narrator-turbo/package.json"
check_file "$WORKSPACE_DIR/mobile/modules/narrator-turbo/ios/NarratorTurboModule.swift"
check_file "$WORKSPACE_DIR/mobile/modules/narrator-turbo/narrator-turbo-module.podspec"
echo ""

###############################################################################
# Summary
###############################################################################

echo "==========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Environment validation passed!${NC}"
    echo ""
    echo "You're ready to build. Run:"
    echo "  ./scripts/macos-pipeline.sh"
else
    echo -e "${RED}✗ Found $ERRORS error(s)${NC}"
    echo ""
    echo "Please run setup first:"
    echo "  ./scripts/macos-setup.sh"
fi
echo "==========================================="
echo ""
