#!/bin/bash

###############################################################################
# macOS Development Environment Setup Script
# For Noble Narrator - Expo React Native App
###############################################################################

set -e  # Exit on error

echo "🚀 Setting up macOS development environment for Noble Narrator"
echo "================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

print_success "Running on macOS"

###############################################################################
# 1. Check Xcode Installation
###############################################################################

print_step "Checking Xcode installation..."

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed"
    echo "Please install Xcode from the App Store, then run:"
    echo "  sudo xcode-select --install"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
print_success "Found $XCODE_VERSION"

# Accept Xcode license if needed
if ! sudo xcodebuild -license check &> /dev/null; then
    print_warning "Xcode license needs to be accepted"
    sudo xcodebuild -license accept
fi

# Install command line tools if needed
if ! xcode-select -p &> /dev/null; then
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install
    read -p "Press Enter after Command Line Tools installation completes..."
fi

print_success "Xcode setup complete"

###############################################################################
# 2. Check Homebrew
###############################################################################

print_step "Checking Homebrew installation..."

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew already installed"
    brew update
fi

###############################################################################
# 3. Install Node.js via nvm
###############################################################################

print_step "Checking Node.js installation..."

if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. Installing via Homebrew..."
    brew install node
fi

NODE_VERSION=$(node --version)
print_success "Node.js $NODE_VERSION installed"

###############################################################################
# 4. Install Bun
###############################################################################

print_step "Checking Bun installation..."

if ! command -v bun &> /dev/null; then
    print_warning "Bun not found. Installing..."
    curl -fsSL https://bun.sh/install | bash

    # Source bun
    if [ -f "$HOME/.bun/bin/bun" ]; then
        export PATH="$HOME/.bun/bin:$PATH"
    fi
else
    print_success "Bun already installed"
fi

BUN_VERSION=$(bun --version)
print_success "Bun $BUN_VERSION ready"

###############################################################################
# 5. Install CocoaPods
###############################################################################

print_step "Checking CocoaPods installation..."

if ! command -v pod &> /dev/null; then
    print_warning "CocoaPods not found. Installing..."
    sudo gem install cocoapods
else
    print_success "CocoaPods already installed"
fi

POD_VERSION=$(pod --version)
print_success "CocoaPods $POD_VERSION ready"

###############################################################################
# 6. Install iOS Simulators
###############################################################################

print_step "Checking iOS Simulators..."

SIMULATORS=$(xcrun simctl list devices available | grep -c "iPhone" || true)
if [ "$SIMULATORS" -eq 0 ]; then
    print_warning "No iOS simulators found"
    echo "Opening Xcode to install simulators..."
    echo "Go to: Xcode > Settings > Platforms"
    open -a Xcode
else
    print_success "Found $SIMULATORS iOS simulator(s)"
fi

###############################################################################
# 7. Install Watchman (optional but recommended)
###############################################################################

print_step "Checking Watchman installation..."

if ! command -v watchman &> /dev/null; then
    print_warning "Watchman not found. Installing for better file watching..."
    brew install watchman
else
    print_success "Watchman already installed"
fi

###############################################################################
# 8. Install EAS CLI
###############################################################################

print_step "Checking EAS CLI installation..."

if ! command -v eas &> /dev/null; then
    print_warning "EAS CLI not found. Installing..."
    npm install -g eas-cli
else
    print_success "EAS CLI already installed"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "================================================================"
echo -e "${GREEN}✓ macOS development environment setup complete!${NC}"
echo "================================================================"
echo ""
echo "Installed tools:"
echo "  • Xcode: $XCODE_VERSION"
echo "  • Node.js: $NODE_VERSION"
echo "  • Bun: $BUN_VERSION"
echo "  • CocoaPods: $POD_VERSION"
echo ""
echo "Next steps:"
echo "  1. Run: cd mobile && bun install"
echo "  2. Run: ./scripts/macos-prebuild.sh"
echo "  3. Run: ./scripts/macos-build.sh"
echo ""
