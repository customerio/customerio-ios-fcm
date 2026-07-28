// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CioFirebaseWrapper",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CioFirebaseWrapper",
            targets: ["CioFirebaseWrapper"]
        )
    ],
    dependencies: [
         // TEMPORARY SCAFFOLD — branch `inbox/overlay-inbox-pin`, do not merge, do not release.
         //
         // Exists only so the wrapper SDKs can consume the unreleased Visual Notification Inbox
         // (`MessagingInbox`) from customerio-ios `feat/overlay-inbox` while it is still in review.
         // SwiftPM refuses to resolve a package that one dependency requires by BRANCH and another
         // requires by VERSION, so a wrapper that branch-pins customerio-ios cannot also depend on a
         // customerio-ios-fcm that version-pins it (`from: "4.0.0"` on main). Matching the branch
         // requirement here gives one package identity with no version requirement.
         //
         // Delete this branch once the inbox ships; `main` keeps the version pin.
         .package(url: "https://github.com/customerio/customerio-ios.git", branch: "feat/overlay-inbox"),
         .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "8.7.0"..<"13.0.0")
    ],
    targets: [
        .target(
            name: "CioFirebaseWrapper",
            dependencies: [
                .product(name: "MessagingPushFCM", package: "customerio-ios"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CioFirebaseWrapperTests",
            dependencies: [
                "CioFirebaseWrapper",
                .product(name: "MessagingPushFCM", package: "customerio-ios")
            ],
            path: "Tests"
        )
    ]
)
