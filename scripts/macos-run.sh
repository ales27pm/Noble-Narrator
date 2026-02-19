#!/bin/bash

###############################################################################
# macOS Run Script
# Runs the app on iOS Simulator or Device
###############################################################################

set -e

echo "📱 Running Noble Narrator on iOS"
echo "================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$WORKSPACE_DIR/mobile"

cd "$MOBILE_DIR"

# Parse arguments
DEVICE_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            DEVICE_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--device \"iPhone 15 Pro\"]"
            exit 1
            ;;
    esac
done

###############################################################################
# 1. List Available Simulators
###############################################################################

print_step "Listing available iOS simulators..."
xcrun simctl list devices available | grep -E "iPhone|== Devices ==" || true
echo ""

###############################################################################
# 2. Run on Simulator
###############################################################################

if [ -z "$DEVICE_NAME" ]; then
    print_step "Launching app on default simulator..."
    bunx expo run:ios
    print_success "App launched on simulator"
else
    print_step "Launching app on simulator: $DEVICE_NAME"
    bunx expo run:ios --device "$DEVICE_NAME"
    print_success "App launched on $DEVICE_NAME"
fi
