# Customer.io Firebase Wrapper SDK for iOS

> [!IMPORTANT]
> From customerio-ios [5.0.0](https://github.com/customerio/customerio-ios/releases/tag/5.0.0), the FCM adapter `CioFirebaseWrapper` ships in [customerio-ios](https://github.com/customerio/customerio-ios), versioned with the SDK. On customerio-ios 5.0 or later, install it from there:
>
> - Swift Package Manager: remove this package and add the `CioFirebaseWrapper` product from the `customerio-ios` package. That package doesn't depend on Firebase, so add FirebaseMessaging 8.7.0 or later yourself if your app doesn't already.
> - CocoaPods: change your `CioFirebaseWrapper` line to `pod 'CioFirebaseWrapper', '~> 5.0'`, which brings in FirebaseMessaging. Use `pod 'CioFirebaseWrapper/Core', '~> 5.0'` if your app gets Firebase another way.
>
> The 1.x releases of this repo stay available for apps on customerio-ios 4.x and don't support 5.0. Their `Package.swift` requires customerio-ios below 5.0.0. On CocoaPods, 1.0.0 has no upper bound, so a Podfile that keeps `'~> 1.0'` while moving CustomerIO to 5.0 resolves to wrapper 1.0.0 instead of failing; change that line to `'~> 5.0'`.

Customer.io SDK to abstract iOS Firebase Cloud Messaging (FCM) integration from the main SDK.

## customerio-ios 4.x

Everything below is for this repo's 1.x releases, which work with customerio-ios 4.x.

### Requirements

- iOS 15.0+
- Xcode 26.2+ when using Firebase 12.12 or later

### Installation

#### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/customerio/customerio-ios-fcm.git", from: "1.0.0")
]
```

#### CocoaPods

```ruby
pod 'CioFirebaseWrapper', '~> 1.0'
```

## License

MIT License. See LICENSE file for details.
