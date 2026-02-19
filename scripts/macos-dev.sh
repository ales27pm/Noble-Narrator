#!/bin/bash

###############################################################################
# macOS Development Mode
# Runs Metro bundler and opens simulator for active development
###############################################################################

set -e

echo "🔥 Starting Development Mode"
echo "============================="
echo ""

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

###############################################################################
# Check if iOS project exists
###############################################################################

if [ ! -d "ios/Pods" ]; then
    print_error "iOS project not built yet"
    echo ""
    echo "Please run prebuild first:"
    echo "  ./scripts/macos-prebuild.sh"
    echo ""
    exit 1
fi

###############################################################################
# Start Metro Bundler
###############################################################################

print_step "Starting Metro bundler..."
echo "Press Ctrl+C to stop Metro"
echo ""

bunx expo start --ios
