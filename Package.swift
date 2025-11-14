    // swift-tools-version: 6.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.

    import PackageDescription

    let package = Package(
        name: "sds-portal",
        platforms: [
            .macOS(.v13)
        ],
        dependencies: [
            .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
            .package(url: "https://github.com/swift-server-community/APNSwift.git", from: "6.0.0"),
            .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.1.0"),
            
            .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
            .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-log", from: "1.5.2"),
            
            .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
            .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
            
            .package(url: "https://github.com/apple/swift-system.git", from: "1.2.1"),
            .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
            
        ],
        targets: [
            .executableTarget(name: "SDSServer", dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "APNS", package: "apnswift"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                
                .product(name: "Logging", package: "swift-log"),
                
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Crypto", package: "swift-crypto")
            ], resources: [
                .copy("AuthKey_89C7VG72JF.p8")
            ])
        ]
    )
