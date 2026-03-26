// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KirtHealthSync",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .executable(
            name: "KirtHealthSync",
            targets: ["App"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ],
            path: "Sources/App"
        )
    ]
)
