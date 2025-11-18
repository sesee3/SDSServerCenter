import Leaf
import Vapor
import JWTKit
import NIOPosix

import Fluent
import FluentMongoDriver

let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)


public func configure(_ app: Application) async throws {

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let uri = Environment.get("DATABASE_URI") ?? "NO URI"
    print(uri)
    try app.databases.use(.mongo(connectionString: uri), as: .mongo)
    
        // Assicurati che jwtKey sia caricata dall'ambiente
        guard let rawKey = Environment.get("JWT_SECRET") else {
            fatalError("JWT_SECRET non trovata!")
        }

        // 1. PULIZIA: Rimuovi spazi e accapo (Cruciale su Linux/Systemd)
        let cleanKey = rawKey.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. CONVERSIONE: Trasforma la stringa in Data (bytes) esplicita
        // Questo bypassa l'ambiguità di codifica delle stringhe su Linux
        guard let keyData = cleanKey.data(using: .utf8) else {
            fatalError("Impossibile convertire la JWT Key in UTF8 data")
        }

        // 3. REGISTRAZIONE
        await app.jwt.keys.add(
            hmac: .init(from: keyData), // <--- Passa 'keyData', non la stringa
            digestAlgorithm: .sha256
        )

        print("[SYSTEM] Chiave HMAC registrata correttamente su Linux. Lunghezza bytes: \(keyData.count)")
    
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
