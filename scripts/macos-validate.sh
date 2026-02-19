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

check_optional_command() {
    if command -v "$1" &> /dev/null; then
        VERSION=$("${@:2}")
        echo -e "${GREEN}✓ $1${NC} - $VERSION"
    else
        echo -e "${YELLOW}⚠ $1 not found${NC}"
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
check_command "brew" brew --version | head -n 1
echo ""

###############################################################################
# Check Xcode Setup
###############################################################################

echo "Xcode Setup:"
echo "-----------"
XCODE_PATH=$(xcode-select -p 2>/dev/null)
if [ -n "$XCODE_PATH" ]; then
    echo -e "${GREEN}✓ Xcode selected${NC} - $XCODE_PATH"
else
    echo -e "${RED}✗ Xcode not selected${NC}"
    ((ERRORS++))
fi

# Check if Xcode command line tools are installed
if xcodebuild -license check &> /dev/null; then
    echo -e "${GREEN}✓ Xcode license accepted${NC}"
else
    echo -e "${YELLOW}⚠ Xcode license not accepted${NC}"
    echo "  Run: sudo xcodebuild -license accept"
fi
echo ""

###############################################################################
# Check Project Files
###############################################################################

echo "Project Files:"
echo "-------------"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$WORKSPACE_DIR/mobile"

check_file "$WORKSPACE_DIR/package.json"
check_file "$MOBILE_DIR/package.json"
echo ""

###############################################################################
# Check Optional Tools
###############################################################################

echo "Optional Tools:"
echo "---------------"
check_optional_command "watchman" watchman --version
check_optional_command "eas" eas --version
echo ""

###############################################################################
# Check iOS Simulators
###############################################################################

echo "iOS Simulators:"
echo "---------------"

SIMULATOR_COUNT=$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone" || echo "0")
if [ "$SIMULATOR_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $SIMULATOR_COUNT iPhone simulator(s)${NC}"
else
    echo -e "${YELLOW}⚠ No iPhone simulators found${NC}"
    echo "  Open Xcode and install simulators via Preferences > Components"
fi
echo ""

###############################################################################
# Summary
###############################################################################

echo "==========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Environment validation passed!${NC}"
    echo "You're ready to build Noble Narrator."
    exit 0
else
    echo -e "${RED}❌ Environment validation failed!${NC}"
    echo "Found $ERRORS error(s) that must be fixed."
    echo ""
    echo "Run setup script to install missing tools:"
    echo "  ./scripts/macos-setup.sh"
    exit 1
fi
