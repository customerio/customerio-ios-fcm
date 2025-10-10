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
         .package(url: "https://github.com/customerio/customerio-ios.git", branch: "test-wrapper"),
         .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "12.0.0"))
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
