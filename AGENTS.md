# Customer.io Firebase wrapper for iOS

FCM companion to `customerio-ios`. From customerio-ios 5.0.0 the `CioFirebaseWrapper` adapter ships inside `customerio-ios`. This repo serves the 1.x releases, which require customerio-ios below 5.0.0 and do not support 5.0 or later (`README.md`, `Package.swift`).

## Layout
- `Sources/`: `CioFirebaseWrapper.swift` and `MessagingPushFCM+Init.swift`
- `Tests/`: XCTest tests
- `Package.swift`, `CioFirebaseWrapper.podspec`: SwiftPM and CocoaPods packaging
- `scripts/`: version update and CocoaPods push scripts

## Commands
Run from the repo root.
- Lint: `make lint`
- Format: `make format`
- Both go through `./binny`, which is gitignored and pins its tools in `binny-tools.yml`. The lint workflow installs it by downloading the `binny-macos-m1` asset from the `customerio/binny` releases (the "Install binny" step in `customerio/mobile-ci-tools/.github/workflows/ios-lint.yml`).
- Tests: CI calls the reusable `ios-test.yml` from `customerio/mobile-ci-tools` with scheme `CioFirebaseWrapper` (`.github/workflows/test.yml`).

## Gotchas
- `lefthook.yml` runs `make format` on pre-commit and `make lint` on pre-push. The pre-push command ends in `|| echo`, so a lint failure there only prints a warning.
