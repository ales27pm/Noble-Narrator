# Build Scripts

Automated build scripts for macOS iOS development.

## Quick Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `macos-validate.sh` | Check environment | `./macos-validate.sh` |
| `macos-setup.sh` | Install tools | `./macos-setup.sh` |
| `macos-prebuild.sh` | Generate iOS project | `./macos-prebuild.sh` |
| `macos-build.sh` | Compile app | `./macos-build.sh [--release] [--simulator\|--device]` |
| `macos-run.sh` | Launch app | `./macos-run.sh [--device "iPhone 15 Pro"]` |
| `macos-pipeline.sh` | Complete pipeline | `./macos-pipeline.sh [--skip-setup] [--skip-run] [--release]` |
| `macos-dev.sh` | Development mode | `./macos-dev.sh` |
| `macos-clean.sh` | Clean build | `./macos-clean.sh [--deep]` |

## Getting Started

```bash
# First time setup (complete pipeline)
./macos-pipeline.sh

# Daily development
./macos-dev.sh
```

## Full Documentation

See [../docs/MACOS_BUILD_GUIDE.md](../docs/MACOS_BUILD_GUIDE.md) for complete documentation.
