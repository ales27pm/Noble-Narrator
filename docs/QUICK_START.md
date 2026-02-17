# Quick Start - macOS Build

Get Noble Narrator running on your Mac in 3 steps.

## ⚡ TL;DR

```bash
# From workspace root
./scripts/macos-pipeline.sh
```

That's it! This single command will:
- ✅ Set up your development environment
- ✅ Generate the iOS project
- ✅ Compile the app
- ✅ Launch it on the iOS Simulator

---

## 📋 Prerequisites Check

Before running, ensure you have:
- ✅ macOS 12.0+
- ✅ Xcode installed from App Store
- ✅ Command Line Tools: `xcode-select --install`

Don't have everything? Run the validation:

```bash
./scripts/macos-validate.sh
```

---

## 🎯 Manual Steps (If Needed)

### 1. Setup Environment
```bash
./scripts/macos-setup.sh
```
Installs: Node.js, Bun, CocoaPods, Watchman

### 2. Build iOS Project
```bash
./scripts/macos-prebuild.sh
```
Generates the native iOS project with CocoaPods

### 3. Compile
```bash
./scripts/macos-build.sh
```
Compiles Swift and Objective-C code

### 4. Run
```bash
./scripts/macos-run.sh
```
Launches on iOS Simulator

---

## 🔧 Common Commands

```bash
# Build for production
./scripts/macos-build.sh --release

# Run on specific simulator
./scripts/macos-run.sh --device "iPhone 15 Pro"

# Skip setup in pipeline
./scripts/macos-pipeline.sh --skip-setup

# Build only (don't run)
./scripts/macos-pipeline.sh --skip-run
```

---

## 🆘 Troubleshooting

### App won't build?
```bash
cd mobile
rm -rf node_modules ios
bun install
npx expo prebuild --platform ios --clean
cd ios && pod install && cd ..
./scripts/macos-build.sh
```

### Command not found?
```bash
# Add to ~/.zshrc
export PATH="$HOME/.bun/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Need help?
```bash
./scripts/macos-validate.sh  # Check what's missing
```

---

## 📖 Full Documentation

See [MACOS_BUILD_GUIDE.md](./MACOS_BUILD_GUIDE.md) for:
- Detailed setup instructions
- Native module compilation
- Development workflow
- Production builds
- Complete troubleshooting guide

---

**Next Steps:**
1. ✅ Run the pipeline
2. 🎨 Start coding in `mobile/src/`
3. 📱 See changes live in the simulator
