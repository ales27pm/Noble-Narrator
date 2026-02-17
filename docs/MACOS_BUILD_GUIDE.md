# macOS Build Guide for Noble Narrator

Complete guide for setting up, compiling, and running the Noble Narrator iOS app on macOS.

## 📋 Prerequisites

### Required Software

- **macOS** 12.0 or later
- **Xcode** 15.0 or later (from Mac App Store)
- **Command Line Tools** (installed via `xcode-select --install`)
- **Node.js** 18 or later
- **Bun** (JavaScript runtime)
- **CocoaPods** (iOS dependency manager)

### Recommended Software

- **Watchman** (file watching for development)
- **EAS CLI** (Expo Application Services)

## 🚀 Quick Start

### Option 1: Automated Pipeline (Recommended)

Run the complete build pipeline with one command:

```bash
# From workspace root
./scripts/macos-pipeline.sh
```

This will:
1. Set up your macOS environment
2. Prebuild the iOS project
3. Compile the app
4. Run it on the iOS Simulator

### Option 2: Step-by-Step

```bash
# 1. Validate environment
./scripts/macos-validate.sh

# 2. Set up macOS development environment
./scripts/macos-setup.sh

# 3. Prebuild iOS project
./scripts/macos-prebuild.sh

# 4. Build the app
./scripts/macos-build.sh

# 5. Run on simulator
./scripts/macos-run.sh
```

## 📂 Project Structure

```
workspace/
├── mobile/                          # React Native app
│   ├── modules/
│   │   └── narrator-turbo/          # Native TTS module
│   │       ├── ios/
│   │       │   ├── NarratorTurboModule.swift
│   │       │   └── NarratorTurboModule.mm
│   │       ├── android/
│   │       └── narrator-turbo-module.podspec
│   ├── ios/                         # Generated iOS project (after prebuild)
│   │   ├── noblenarrator.xcworkspace
│   │   ├── Podfile
│   │   └── Pods/
│   ├── src/                         # React Native source code
│   ├── app.json                     # Expo configuration
│   └── package.json
├── backend/                         # Hono backend (optional)
├── scripts/                         # Build automation scripts
│   ├── macos-setup.sh              # Environment setup
│   ├── macos-validate.sh           # Validation
│   ├── macos-prebuild.sh           # iOS project generation
│   ├── macos-build.sh              # Xcode compilation
│   ├── macos-run.sh                # Run on simulator/device
│   └── macos-pipeline.sh           # Complete pipeline
└── docs/
    └── MACOS_BUILD_GUIDE.md        # This file
```

## 🔧 Detailed Setup Instructions

### 1. Install Xcode

1. Download Xcode from the Mac App Store
2. Open Xcode and accept the license agreement
3. Install Command Line Tools:
   ```bash
   sudo xcode-select --install
   ```

### 2. Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Node.js

```bash
brew install node
```

Or use nvm for version management:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

### 4. Install Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

### 5. Install CocoaPods

```bash
sudo gem install cocoapods
```

### 6. Install Watchman (Optional)

```bash
brew install watchman
```

### 7. Install iOS Simulators

1. Open Xcode
2. Go to **Xcode > Settings > Platforms**
3. Download desired iOS simulators (e.g., iOS 17.0+)

## 🏗️ Build Process Explained

### Step 1: Environment Setup (`macos-setup.sh`)

This script:
- Verifies Xcode installation
- Installs Homebrew (if needed)
- Installs Node.js, Bun, CocoaPods
- Configures iOS simulators
- Installs development tools

### Step 2: Prebuild (`macos-prebuild.sh`)

This script:
- Installs JavaScript dependencies via Bun
- Generates the native iOS project using Expo Prebuild
- Installs CocoaPods dependencies
- Links the custom native module (narrator-turbo)
- Configures Xcode build settings

**What happens during prebuild:**
```bash
cd mobile

# Install JS dependencies
bun install

# Generate iOS project from app.json
npx expo prebuild --platform ios --clean

# Install native dependencies
cd ios
pod install
cd ..
```

The generated `ios/` folder contains:
- `noblenarrator.xcworkspace` - Xcode workspace
- `Podfile` - CocoaPods dependencies
- `Pods/` - Installed native libraries

### Step 3: Build (`macos-build.sh`)

This script:
- Cleans previous build artifacts
- Compiles Swift/Objective-C code
- Builds the app binary
- Supports Debug and Release configurations

**Build commands:**

```bash
# Debug build for simulator
./scripts/macos-build.sh --simulator

# Release build for simulator
./scripts/macos-build.sh --release --simulator

# Build for device (requires code signing)
./scripts/macos-build.sh --device
```

### Step 4: Run (`macos-run.sh`)

This script:
- Lists available iOS simulators
- Launches the app on the selected simulator
- Starts the Metro bundler

**Run commands:**

```bash
# Run on default simulator
./scripts/macos-run.sh

# Run on specific simulator
./scripts/macos-run.sh --device "iPhone 15 Pro"
```

## 🎯 Native Module Compilation

The **narrator-turbo** module is a custom native module that provides advanced Text-to-Speech functionality.

### Module Structure

```
modules/narrator-turbo/
├── ios/
│   ├── NarratorTurboModule.swift   # Main module implementation
│   └── NarratorTurboModule.mm      # Objective-C bridge
├── android/
│   ├── build.gradle
│   └── src/
├── src/
│   └── index.ts                    # JavaScript interface
└── narrator-turbo-module.podspec   # CocoaPods specification
```

### iOS Implementation Details

**NarratorTurboModule.swift:**
- Uses `AVSpeechSynthesizer` for TTS
- Implements `RCTEventEmitter` for events
- Supports:
  - Multiple voices and languages
  - Real-time word boundary callbacks
  - Pause/resume/stop controls
  - Audio session management
  - Neural/Premium voice selection

**Build Configuration:**
- Swift version: 5.0
- Minimum iOS: 13.4
- React Native New Architecture ready
- Optimized for development (can be changed for production)

### Linking Process

1. **Auto-linking via Expo:**
   - Expo detects the module via `package.json` in `modules/narrator-turbo/`
   - Adds it to `Podfile` automatically

2. **CocoaPods installation:**
   - `pod install` compiles the Swift/Objective-C code
   - Links it with React Native bridge
   - Creates `.xcworkspace` with all dependencies

3. **Xcode compilation:**
   - Swift code is compiled to binary
   - Linked with app executable
   - Available to JavaScript via React Native bridge

## 🔍 Troubleshooting

### Common Issues

#### 1. "Command not found" errors

**Solution:** Ensure PATH is configured correctly. Add to `~/.zshrc` or `~/.bash_profile`:

```bash
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
eval "$(/usr/local/bin/brew shellenv)"     # Intel

# Bun
export PATH="$HOME/.bun/bin:$PATH"

# Node
export PATH="/usr/local/bin:$PATH"
```

#### 2. "xcodebuild: error: unable to find utility \"xcodebuild\""

**Solution:**
```bash
sudo xcode-select --reset
sudo xcode-select --install
```

#### 3. CocoaPods installation fails

**Solution:**
```bash
# Update RubyGems
sudo gem update --system

# Install CocoaPods
sudo gem install cocoapods

# Update CocoaPods repo
pod repo update
```

#### 4. "No iOS simulators found"

**Solution:**
1. Open Xcode
2. Go to **Xcode > Settings > Platforms**
3. Download iOS 17.0+ simulator
4. Verify: `xcrun simctl list devices available`

#### 5. "Module not found" for narrator-turbo

**Solution:**
```bash
cd mobile
rm -rf node_modules ios
bun install
npx expo prebuild --platform ios --clean
cd ios
pod install
```

#### 6. Swift compilation errors

**Solution:**
- Ensure Xcode is up to date
- Check Swift version: `swift --version` (should be 5.x)
- Clean build: `./scripts/macos-build.sh` (auto-cleans)

#### 7. Code signing errors (when building for device)

**Solution:**
- For development without signing:
  ```bash
  xcodebuild build \
    -workspace "mobile/ios/noblenarrator.xcworkspace" \
    -scheme "noblenarrator" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO
  ```
- For real device: Configure in Xcode > Signing & Capabilities

### Validation Commands

```bash
# Verify all prerequisites
./scripts/macos-validate.sh

# Check Xcode
xcodebuild -version
xcode-select -p

# Check Node/Bun
node --version
bun --version

# Check CocoaPods
pod --version

# List iOS simulators
xcrun simctl list devices available | grep iPhone

# Check native module
ls -la mobile/modules/narrator-turbo/ios/
```

## 📱 Running on Physical Device

### Prerequisites
- Apple Developer account
- Device registered in developer portal
- Provisioning profile configured

### Steps

1. **Connect device via USB**

2. **Trust computer on device**

3. **Configure signing in Xcode:**
   ```bash
   open mobile/ios/noblenarrator.xcworkspace
   ```
   - Select project > Signing & Capabilities
   - Choose your team
   - Enable "Automatically manage signing"

4. **Build and run:**
   ```bash
   npx expo run:ios --device
   ```

## 🚢 Production Builds

### Local Build

```bash
# Build release configuration
./scripts/macos-build.sh --release

# Archive for distribution
cd mobile/ios
xcodebuild archive \
  -workspace noblenarrator.xcworkspace \
  -scheme noblenarrator \
  -configuration Release \
  -archivePath build/noblenarrator.xcarchive
```

### EAS Build (Recommended)

```bash
# Install EAS CLI
npm install -g eas-cli

# Login
eas login

# Configure build
eas build:configure

# Build for iOS
eas build --platform ios
```

## 🔄 Development Workflow

### Typical Daily Workflow

```bash
# 1. Start Metro bundler
cd mobile
bun start

# 2. In another terminal, run on simulator
./scripts/macos-run.sh

# 3. Make code changes
# - JavaScript changes: Auto-reload
# - Native changes: Rebuild required

# 4. Rebuild after native changes
./scripts/macos-build.sh --simulator
```

### Native Code Changes

When you modify Swift/Objective-C code:

1. **Stop the app**
2. **Rebuild:**
   ```bash
   ./scripts/macos-build.sh
   ```
3. **Run again:**
   ```bash
   ./scripts/macos-run.sh
   ```

### Clean Build

If you encounter strange issues:

```bash
# Clean everything
cd mobile
rm -rf ios node_modules

# Rebuild from scratch
bun install
npx expo prebuild --platform ios --clean
cd ios
pod install
cd ../..
./scripts/macos-build.sh
```

## 📊 Build Performance

Typical build times on M1 MacBook Pro:

| Step | Time |
|------|------|
| Setup (first time) | ~5-10 min |
| Prebuild | ~2-3 min |
| Build (clean) | ~1-2 min |
| Build (incremental) | ~30-60 sec |
| Total (first build) | ~10-15 min |

## 🎓 Additional Resources

- [Expo Documentation](https://docs.expo.dev/)
- [React Native iOS Guide](https://reactnative.dev/docs/running-on-device)
- [Xcode Documentation](https://developer.apple.com/xcode/)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [AVSpeechSynthesizer Docs](https://developer.apple.com/documentation/avfoundation/avspeechsynthesizer)

## 📝 Script Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `macos-validate.sh` | Check environment | `./scripts/macos-validate.sh` |
| `macos-setup.sh` | Install tools | `./scripts/macos-setup.sh` |
| `macos-prebuild.sh` | Generate iOS project | `./scripts/macos-prebuild.sh` |
| `macos-build.sh` | Compile app | `./scripts/macos-build.sh [--release] [--simulator\|--device]` |
| `macos-run.sh` | Launch app | `./scripts/macos-run.sh [--device "iPhone 15 Pro"]` |
| `macos-pipeline.sh` | Complete pipeline | `./scripts/macos-pipeline.sh [--skip-setup] [--skip-run] [--release]` |

## 🤝 Support

If you encounter issues:

1. Run validation: `./scripts/macos-validate.sh`
2. Check logs in `mobile/ios/build/`
3. Review troubleshooting section above
4. Contact Vibecode support

---

**Last Updated:** February 2026
**App Version:** 1.0.0
**Expo SDK:** 53
**React Native:** 0.79.6
