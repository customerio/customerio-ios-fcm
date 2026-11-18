# Review guidance

Read by the local Claude review (`cio-code-review`) and by human reviewers. It adds context for this repo; it does not relax any review rule.

## What this repo is
- A thin Firebase Cloud Messaging adapter for customerio-ios 4.x apps. It serves the 1.x releases only. From customerio-ios 5.0.0 the adapter ships inside customerio-ios.
- Customers compile it into their apps through SwiftPM and CocoaPods. Every `public` symbol in `Sources/` is API that customer code may call.

## Treat as Important
- A change to a `public` declaration's name, signature, optionality or behavior. Customers upgrade within 1.x expecting no source changes.
- Blocking or slow work on the main thread in token or installation-ID paths. These run during app launch and push registration.
- A completion handler that can be called more than once, or never, on any path, including errors from Firebase.
- Logging or forwarding a push token, FCM token, installation ID or message payload anywhere other than the Customer.io SDK APIs that already receive them.
- Code that only compiles against one end of the supported ranges: customerio-ios `>= 4.11.0, < 5.0.0` and Firebase `>= 8.7.0, < 13.0.0`. Prefer APIs present across the whole range.

## Conventions
- SwiftPM (`Package.swift`) and CocoaPods (`CioFirebaseWrapper.podspec`) must allow the same dependency versions. CI checks this, and changes to either file always get a human review.
- Formatting and lint come from `make format` and `make lint`. Don't report style issues those tools own.
- Tests live in `Tests/` and use XCTest.
