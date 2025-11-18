// swift-tools-version:6.0
import PackageDescription

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }

let package = Package(
    name: "sds-portal",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
        
            .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),

    ],
    targets: [
        .executableTarget(
            name: "sds-portal",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                                .product(name: "Vapor", package: "vapor"),
                                .product(name: "NIOCore", package: "swift-nio"),
                                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "JWT", package: "jwt"),
                
                    .product(name: "Fluent", package: "fluent"),
                    .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "Tests",
            dependencies: [
                .target(name: "sds-portal"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)
