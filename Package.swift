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
         .package(url: "https://github.com/customerio/customerio-ios.git", from: "4.0.0"),
         // Upper bound capped below 12.13.0: that release added a trailing comma in a
         // function-call argument list to its Package.swift (Swift 6.1 syntax), which
         // the Xcode 16.2 toolchain used by CI rejects with
         //   /Package.swift:199:5: error: unexpected ',' separator
         // Lift the cap once CI is on Xcode 16.3+ (Swift 6.1).
         .package(url: "https://github.com/firebase/firebase-ios-sdk.git", "8.7.0"..<"12.13.0")
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
