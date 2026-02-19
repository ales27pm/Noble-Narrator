# Noble Narrator

Advanced on-device text-to-speech mobile app built with Expo and React Native.

## 🚀 Quick Start

### macOS Development

Build and run the iOS app in one command:

```bash
./scripts/macos-pipeline.sh
```

See [Quick Start Guide](./docs/QUICK_START.md) for details.

## 📁 Project Structure

```
workspace/
├── mobile/               # React Native Expo app
│   ├── modules/
│   │   └── narrator-turbo/  # Custom native TTS module
│   ├── src/             # App source code
│   └── app.json         # Expo configuration
├── backend/             # Hono API server (optional)
├── scripts/             # Build automation scripts
│   ├── macos-pipeline.sh      # Complete build pipeline
│   ├── macos-setup.sh         # Environment setup
│   ├── macos-prebuild.sh      # iOS project generation
│   ├── macos-build.sh         # Xcode compilation
│   ├── macos-run.sh           # Run on simulator
│   └── macos-validate.sh      # Environment validation
└── docs/
    ├── QUICK_START.md         # Quick reference
    └── MACOS_BUILD_GUIDE.md   # Complete build guide
```

## 🛠️ Prerequisites

- macOS 12.0+
- Xcode 15.0+
- Node.js 18+
- Bun
- CocoaPods

Check your environment:
```bash
./scripts/macos-validate.sh
```

## 📖 Documentation

- **[Quick Start](./docs/QUICK_START.md)** - Get running in minutes
- **[macOS Build Guide](./docs/MACOS_BUILD_GUIDE.md)** - Complete documentation
  - Environment setup
  - Native module compilation
  - Troubleshooting
  - Production builds

## 🎯 Key Features

- **On-Device TTS**: Custom native module using AVSpeechSynthesizer
- **Neural Voices**: Premium voice quality support
- **Real-time Word Tracking**: Word boundary callbacks
- **Audio Session Management**: Background audio support
- **Expo SDK 53**: Latest React Native features
- **New Architecture**: React Native 0.79.6

## 🔧 Development

### Run Development Server
```bash
cd mobile
bun start
```

### Build iOS App
```bash
./scripts/macos-build.sh
```

### Run on Simulator
```bash
./scripts/macos-run.sh
```

### Production Build
```bash
./scripts/macos-build.sh --release
```

## 📦 Native Module

The app includes a custom native module (`narrator-turbo`) that provides:
- Advanced text-to-speech with AVSpeechSynthesizer
- Multiple voice and language support
- Pause/resume/stop controls
- Word-by-word callbacks for highlighting
- Audio session configuration

Location: `mobile/modules/narrator-turbo/`

## 🏗️ Build Scripts

| Script | Purpose |
|--------|---------|
| `macos-validate.sh` | Validate development environment |
| `macos-setup.sh` | Install required tools |
| `macos-prebuild.sh` | Generate iOS project |
| `macos-build.sh` | Compile native code |
| `macos-run.sh` | Launch on simulator |
| `macos-pipeline.sh` | Run complete build pipeline |

All scripts are located in `scripts/` and are executable.

## 🚢 Deployment

### Local Build
```bash
./scripts/macos-build.sh --release --device
```

### EAS Build (Recommended)
```bash
eas build --platform ios
```

## 🆘 Troubleshooting

### Clean Build
```bash
cd mobile
rm -rf node_modules ios
bun install
npx expo prebuild --platform ios --clean
cd ios && pod install && cd ..
```

### Validation
```bash
./scripts/macos-validate.sh
```

See [Troubleshooting Guide](./docs/MACOS_BUILD_GUIDE.md#-troubleshooting) for more help.

## 📱 Tech Stack

- **Frontend**: React Native 0.79.6, Expo SDK 53
- **Backend**: Hono, Bun, Prisma, SQLite
- **Native**: Swift 5.0, Objective-C
- **Styling**: NativeWind (TailwindCSS)
- **State**: Zustand
- **Navigation**: Expo Router
- **iOS**: AVFoundation, AVSpeechSynthesizer

## 🔗 Resources

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Docs](https://reactnative.dev/)
- [AVSpeechSynthesizer](https://developer.apple.com/documentation/avfoundation/avspeechsynthesizer)

## 📄 License

MIT

---

**Version**: 1.0.0
**Expo SDK**: 53
**React Native**: 0.79.6
=======
# Noble-Narrator
