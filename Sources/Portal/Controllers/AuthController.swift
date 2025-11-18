    //
    //  AuthController.swift
    //  sds-portal
    //
    //  Created by Sese on 16/11/25.
    //

    import Foundation
    import Vapor
    import JWTKit

        ///Una struttura dati unificata per signin e signup
    struct AuthRequest: Content {
        let username: String
        let password: String
    }

    ///Una struttura dati unificata per signing e signup dopo aver passato l'autenticazione
    struct AuthResponse: Content {
        var token: String
        var username: String
        var userID: String
    }

    ///Una struttura dati che rappresenta una sessione di un utente
    struct SessionResponse: Content {
        var id: String
        var deviceInfo: DeviceInfo
        var firstLog: Date
        var lastLog: Date
        var ipAddress: String
        var isCurrent: Bool
        
        init(id: String = UUID().uuidString, deviceInfo: DeviceInfo, firstLog: Date, lastLog: Date, ipAddress: String, isCurrent: Bool) {
            self.id = id
            self.deviceInfo = deviceInfo
            self.firstLog = firstLog
            self.lastLog = lastLog
            self.ipAddress = ipAddress
            self.isCurrent = isCurrent
        }
        
    }

    struct AuthController: RouteCollection {
        
        func boot(routes: any RoutesBuilder) throws {
            let auth = routes.grouped("auth")
            auth.post("signup", use: signupAPI)
            auth.post("signin", use: signinAPI)
            
            let protected = auth.grouped(VerificationMiddleware())
            protected.get("sessions", use: getSessions)
            protected.delete("sessions", ":sessionID", use: deleteSession)
            protected.post("logout", use: logout)
            protected.get("verify", use: verifyToken)
            
        }
        
       
        @Sendable func signupAPI(req: Request) async throws -> AuthResponse {
            
            print("[DEBUG] 1. Inizio richiesta Signup")
            
            let authData = try req.content.decode(AuthRequest.self)
            print("[DEBUG] 2. Dati ricevuti per username: \(authData.username)")
            
            let store = req.application.userStore
            var users = try store.loadUsers()
            
            if users.contains(where: { $0.username == authData.username }) {
                print("[DEBUG] Errore: Username già in uso")
                throw Abort(.badRequest, reason: "Questo username è gia in uso")
            }
            
            // --- DEBUG HASHING ---
            print("[DEBUG] 3. Inizio Hashing Password...")
            let passwordHash: String
            do {
                passwordHash = try await req.password.async.hash(authData.password)
                print("[DEBUG] 4. Hashing completato con successo.")
            } catch {
                print("[DEBUG] CRITICO: Errore durante Hashing password: \(error)")
                throw error
            }
            
            // Generiamo gli ID subito
            let sessionID = UUID().uuidString
            let userID = UUID()
            
            // --- DEBUG JWT ---
            print("[DEBUG] 5. Preparazione Payload JWT...")
            let payload = AuthPayload(
                subject: .init(value: authData.username),
                expiration: .init(value: .now.addingTimeInterval(31536000)),
                userID: userID.uuidString, // Usa l'ID generato qui
                sessionID: sessionID
            )
            
            // Controllo preventivo della chiave (solo per debug)
            if let key = Environment.get("JWT_SECRET") {
                print("[DEBUG] INFO: JWT_SECRET trovata nelle env variables (lunghezza: \(key.count))")
            } else {
                print("[DEBUG] ATTENZIONE: JWT_SECRET non trovata o nil!")
            }
            
            print("[DEBUG] 6. Tentativo Firma JWT...")
            let token: String
            do {
                // Se crasha qui con errore 503316581, è colpa dell'algoritmo in configure.swift
                token = try await req.jwt.sign(payload, kid: nil)
                print("[DEBUG] 7. Firma JWT riuscita!")
            } catch {
                print("[DEBUG] CRITICO: Errore durante la firma JWT: \(error)")
                throw Abort(.internalServerError, reason: "Errore interno durante la generazione del token")
            }
            
            // --- CREAZIONE OGGETTI ---
            print("[DEBUG] 8. Creazione oggetti User e Session...")
            let deviceInfo = getDevice(from: req)
            
            let session = UserSession(
                id: sessionID,
                token: token, // Inseriamo il token generato PRIMA
                deviceInfo: deviceInfo,
                loggedAt: .now,
                lastLogAt: .now,
                ipAddress: req.headers.first(name: "X-Forwarded-For") ?? req.remoteAddress?.ipAddress ?? "unknown"
            )
            
            let user = User(
                id: userID.uuidString,
                username: authData.username,
                passwordHash: passwordHash,
                createdAt: .now,
                sessions: [session]
            )
            
            // --- SALVATAGGIO ---
            print("[DEBUG] 9. Salvataggio su UserStore...")
            users.append(user)
            try store.saveUsers(users)
            
            print("[DEBUG] 10. Aggiunta Activity Log...")
            try store.addActivity(
                Activity(
                    userID: user.id,
                    username: user.username,
                    action: "Signed Up",
                    timestamp: .now,
                    ipAddress: session.ipAddress,
                    deviceInfo: deviceInfo
                )
            )
            
            print("[DEBUG] 11. Signup completato con successo!")
            
            return AuthResponse(
                token: token,
                username: user.username,
                userID: user.id
            )
        }
        
        @Sendable func signinAPI(req: Request) async throws -> AuthResponse {
            let loginData = try req.content.decode(AuthRequest.self)
            let store = req.application.userStore
            var users = try store.loadUsers()
            
            guard let user = users.first(where: { $0.username == loginData.username }) else {
                throw Abort(.unauthorized, reason: "Credenziali non valide")
            }
            
            guard try await req.password.async.verify(loginData.password, created: user.passwordHash) else {
                throw Abort(.unauthorized, reason: "Credenziali non valide")
            }
            
            let deviceInfo = getDevice(from: req)
            
            let session = UserSession(
                token: "",
                deviceInfo: deviceInfo,
                loggedAt: .now,
                lastLogAt: .now,
                ipAddress: req.headers.first(name: "X-Forwarded-For") ?? req.remoteAddress?.ipAddress ?? "unknown"
            )
            
                //JWT
            let payload = AuthPayload(
                subject: .init(value: user.username),
                expiration: .init(value: Date().addingTimeInterval(30 * 24 * 60 * 60)),
                userID: user.id,
                sessionID: session.id
            )
            
            let token = try await req.jwt.sign(payload, kid: nil)
            
                // Aggiungi sessione all'utente
            if let userIDX = users.firstIndex(where: { $0.id == user.id }) {
                var updatedSession = session
                updatedSession.token = token
                users[userIDX].sessions.append(updatedSession)
                try store.saveUsers(users)
            }
            
                // Log attività
            try store.addActivity(
                Activity(
                    userID: user.id,
                    username: user.username,
                    action: "Login",
                    timestamp: .now,
                    ipAddress: session.ipAddress,
                    deviceInfo: deviceInfo
                )
            )
            
            return AuthResponse(
                token: token,
                username: user.username,
                userID: user.id
            )
        }
        
        @Sendable func getSessions(req: Request) async throws -> [SessionResponse] {
            let store = req.application.userStore
            let payload = try req.auth.require(AuthPayload.self)
            let users = try store.loadUsers()
            
            guard let user = users.first(where: { $0.id == payload.userID }) else {
                throw Abort(.notFound)
            }
            
            return user.sessions.map { session in
                SessionResponse(
                    deviceInfo: session.deviceInfo,
                    firstLog: session.loggedAt,
                    lastLog: session.lastLogAt,
                    ipAddress: session.ipAddress,
                    isCurrent: session.id == payload.sessionID
                )
            }
        }
        
        @Sendable func deleteSession(req: Request) async throws -> HTTPStatus {
            let store = req.application.userStore
            let payload = try req.auth.require(AuthPayload.self)
                    guard let sessionId = req.parameters.get("sessionID") else {
                        throw Abort(.badRequest)
                    }
                    
                    var users = try store.loadUsers()
                    
                    guard let userIndex = users.firstIndex(where: { $0.id == payload.userID }) else {
                        throw Abort(.notFound)
                    }
                    
                    users[userIndex].sessions.removeAll { $0.id == sessionId }
                    try store.saveUsers(users)
                    
                    // Log attività
                    try store.addActivity(Activity(
                        userID: payload.userID,
                        username: users[userIndex].username,
                        action: "Sessione eliminata",
                        timestamp: Date(),
                        ipAddress: req.headers.first(name: "X-Forwarded-For") ?? req.remoteAddress?.ipAddress ?? "unknown",
                        deviceInfo: getDevice(from: req)
                    ))
                    
                    return .noContent
        }
        
        @Sendable func logout(req: Request) async throws -> HTTPStatus {
            let store = req.application.userStore
            let payload = try req.auth.require(AuthPayload.self)
            
            var users = try store.loadUsers()
            guard let userIDX = users.firstIndex(where: { $0.id == payload.userID }) else {
                throw Abort(.notFound)
            }
            
            users[userIDX].sessions.removeAll(where: { $0.id == payload.sessionID })
            try store.saveUsers(users)
            
            return .noContent
            
        }

        @Sendable func verifyToken(req: Request) async throws -> Response {
            let payload = try req.auth.require(AuthPayload.self)
            let string = "\(payload.userID), \(payload.sessionID)"
            return .init(status: .accepted, body: .init(stringLiteral: string))
        }
        
        
        private func getDevice(from req: Request) -> DeviceInfo {
                let userAgent = req.headers.first(name: .userAgent) ?? "Unknown"
                
                // Header personalizzati dall'app nativa
                let appPlatform = req.headers.first(name: "X-App-Platform")
                let appVersion = req.headers.first(name: "X-App-Version")
                let deviceModel = req.headers.first(name: "X-Device-Model")
                let deviceName = req.headers.first(name: "X-Device-Name")
                
                var browser = "App Nativa"
                var os = "Unknown"
                var device = "Unknown"
                
                // Se proviene da app nativa
                if let platform = appPlatform {
                    browser = "App Nativa"
                    if let version = appVersion {
                        browser += " v\(version)"
                    }
                    
                    switch platform.lowercased() {
                    case "ios":
                        os = "iOS"
                        device = deviceModel ?? (userAgent.contains("iPad") ? "iPad" : "iPhone")
                        if let name = deviceName {
                            device = name
                        }
                    case "ipados":
                        os = "iPadOS"
                        device = deviceModel ?? "iPad"
                        if let name = deviceName {
                            device = name
                        }
                    case "macos":
                        os = "macOS"
                        device = deviceModel ?? "Mac"
                        if let name = deviceName {
                            device = name
                        }
                    case "watchos":
                        os = "watchOS"
                        device = "Apple Watch"
                    case "tvos":
                        os = "tvOS"
                        device = "Apple TV"
                    case "visionos":
                        os = "visionOS"
                        device = "Apple Vision Pro"
                    default:
                        os = platform
                    }
                }
                // Altrimenti estrai dal User-Agent (browser)
                else {
                    if userAgent.contains("Chrome") { browser = "Chrome" }
                    else if userAgent.contains("Safari") && !userAgent.contains("Chrome") { browser = "Safari" }
                    else if userAgent.contains("Firefox") { browser = "Firefox" }
                    else if userAgent.contains("Edge") { browser = "Edge" }
                    else if userAgent.contains("Opera") { browser = "Opera" }
                    
                    if userAgent.contains("Windows") {
                        os = "Windows"
                        device = "PC"
                    }
                    else if userAgent.contains("Mac OS X") || userAgent.contains("Macintosh") {
                        os = "macOS"
                        device = "Mac"
                    }
                    else if userAgent.contains("Linux") {
                        os = "Linux"
                        device = "PC"
                    }
                    else if userAgent.contains("iPad") {
                        os = userAgent.contains("OS 13") || userAgent.contains("OS 1[4-9]") ? "iPadOS" : "iOS"
                        device = "iPad"
                        
                        // Estrai modello iPad dal User-Agent
                        if let range = userAgent.range(of: "iPad[0-9,]+") {
                            device = String(userAgent[range])
                        }
                    }
                    else if userAgent.contains("iPhone") {
                        os = "iOS"
                        device = "iPhone"
                        
                        // Estrai modello iPhone dal User-Agent
                        if let range = userAgent.range(of: "iPhone[0-9,]+") {
                            device = String(userAgent[range])
                        }
                    }
                    else if userAgent.contains("Android") {
                        os = "Android"
                        device = userAgent.contains("Mobile") ? "Android Phone" : "Android Tablet"
                    }
                }
                
                return DeviceInfo(browser: browser, os: os, device: device, userAgent: userAgent)
            }
        
        private func getCurrentUser(req: Request) async throws -> User {
            let store = req.application.userStore
            let payload = try req.auth.require(AuthPayload.self)
            let users = try store.loadUsers()
            
            guard let user = users.first(where: { $0.id == payload.userID }) else {
                throw Abort(.notFound)
            }
            
            return user
        }
        
        
    }

    extension AuthController: @unchecked Sendable {}
