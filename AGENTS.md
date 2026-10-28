# Customer.io Firebase wrapper for iOS

FCM companion to `customerio-ios`. From customerio-ios 5.0.0 the `CioFirebaseWrapper` adapter ships inside `customerio-ios`. This repo serves the 1.x releases for customerio-ios 4.x and does not support 5.0 or later. `Package.swift` requires customerio-ios below 5.0.0. On CocoaPods, release 1.0.0 has no upper bound (`README.md`).

## Layout
- `Sources/`: `CioFirebaseWrapper.swift` and `MessagingPushFCM+Init.swift`
- `Tests/`: XCTest tests
- `Package.swift`, `CioFirebaseWrapper.podspec`: SwiftPM and CocoaPods packaging
- `scripts/`: version update and CocoaPods push scripts

## Commands
Run from the repo root.
- Lint: `make lint`
- Format: `make format`
- Both go through `./binny`, which is gitignored and pins its tools in `binny-tools.yml`. To install it locally, run `curl -fL --output binny https://github.com/customerio/binny/releases/download/latest/binny-macos-m1 && chmod +x binny`. The lint workflow installs it by downloading the `binny-macos-m1` asset from the `customerio/binny` releases (the "Install binny" step in `customerio/mobile-ci-tools/.github/workflows/ios-lint.yml`).
- Tests: CI calls the reusable `ios-test.yml` from `customerio/mobile-ci-tools` with scheme `CioFirebaseWrapper` (`.github/workflows/test.yml`).

## Gotchas
- `lefthook.yml` defines a pre-commit hook (`make format`) and a pre-push hook (`make lint`). Both run only after `lefthook install`, so run `make format` before committing: the lint workflow runs `make format && git diff --exit-code`. The pre-push command ends in `|| echo`, so a lint failure there only prints a warning.
