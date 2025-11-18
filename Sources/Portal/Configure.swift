import Leaf
import Vapor
import JWTKit
import NIOPosix

import Fluent
import FluentMongoDriver

let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)


public func configure(_ app: Application) async throws {

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.databases.use(.mongo(connectionString: "mongodb://localhost:27017/sds-portal-db"), as: .mongo)
    
    //MARK: Security & JWT
    let jwtKey = Environment.get("JWT_SECRET") ??
    "0xa3b9c91f2d44b0f87cf03daad34ed8b19b4e78a3f812e238d32a917bb320df09"

    await app.jwt.keys.add(
        hmac: .init(from: jwtKey),
        digestAlgorithm: .sha256
    )
    
//    app.middleware.use(MantainanceMiddleware())
    
    app.storage[UserStoreKey.self] = UserStore()
    
    //MARK: Others
    app.views.use(.leaf)
    
    try app.register(collection: AuthController())
    try app.register(collection: ActivityController())

    // register routes
    try await routes(app)
}


extension Application {
    var userStore: UserStore {
        guard let store = self.storage[UserStoreKey.self] else {
            fatalError("UserStore non configurato, impossibile procedere")
        }
        return store
    }
}
