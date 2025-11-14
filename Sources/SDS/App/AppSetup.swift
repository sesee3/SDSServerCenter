//
//  AppSetup.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor

import Fluent
import FluentPostgresDriver

import APNS

/// Custom error type for SDS Swift Server
enum SDSAppError: Error, LocalizedError {
    case missingAPNSKeyFile
    case databaseConnectionFailed
    case migrationFailed
    case invalidRequest(String)
    case apnsClientUnavailable
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .missingAPNSKeyFile:
            return "The APNS authentication key file could not be found."
        case .databaseConnectionFailed:
            return "Failed to connect to the database."
        case .migrationFailed:
            return "A database migration failed."
        case .invalidRequest(let details):
            return "Invalid request: \(details)"
        case .unknown:
            return "An unknown error has occurred."
        case .apnsClientUnavailable:
            return "APNS client is unavailable or not initialized"
        }
    }
}


func configure(_ app: Application) async throws -> ServerService {
    
    let file = FileMiddleware(publicDirectory: app.directory.publicDirectory)
    
    
    
    app.middleware.use(RequestLoggerInjectionMiddleware())
    
    app.middleware.use(file)
    
    app.userStore = try await EncryptedUserStore(fileURL: URL(string: "users")!, key: .init(base64Encoded: "3JvYwW+haXX6ukYbtf/h9Ff+y4GBqLv9gV9+ONrfcpM=")!, logger: .current)
    
    try routes(app)
    
    let wsQueue = DispatchQueue(label: "ws_queue")
    
    app.webSocket("ws") { req, ws in
        app.logger.info("Client Connected")
        
        ws.onClose.whenCompleteBlocking(onto: wsQueue) { result in
            app.logger.info("Client Disconnected")
        }
        
    }
    
    let postgresConfig = SQLPostgresConfiguration(hostname: "localhost", port: 5432, username: "sese", password: "dev", database: "sese", tls: .disable)

    app.databases.use(
        .postgres(configuration: postgresConfig, maxConnectionsPerEventLoop: 10, connectionPoolTimeout: .hours(1), sqlLogLevel: .notice),
        as: .psql
    )
    
    app.migrations.add(StudentBuilder())
    app.migrations.add(CreateUser())
    
    
    try await app.autoMigrate().get()
    
    return ServerService(app: app)
    
}


struct StudentBuilder: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("students")
            .id()
            .field("name", .string)
            .field("surname", .string)
            .field("classroom", .string)
            .field("attendedPacks", .array(of: .string))
            .field("isGuardian", .array(of: .string))
            .field("isIgnored", .custom("JSONB"))
            .field("isModerator", .array(of: .string))
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("students").delete()
    }
}





public class SDSAlerts {
    
    var client: APNSClient<JSONDecoder, JSONEncoder>?
    
    init() {
        do {
            guard let keyFileURL = Bundle.module.url(forResource: "AuthKey_89C7VG72JF", withExtension: ".p8") else {
                print("NO!, \(Bundle.main.bundlePath)")
                throw SDSAppError.missingAPNSKeyFile
            }
            
            if keyFileURL.startAccessingSecurityScopedResource() {
                
                let pemString = try String(contentsOf: keyFileURL)
                client = APNSClient(
                    configuration: .init(
                        authenticationMethod: .jwt(
                            privateKey: try .loadFrom(string: pemString),
                            keyIdentifier: "89C7VG72JF",
                            teamIdentifier: "2GPCGT95C4"
                        ),
                        environment: .development
                    ),
                    eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: 2)),
                    responseDecoder: JSONDecoder(),
                    requestEncoder: JSONEncoder()
                )
                
            }
        } catch {
            print("Error, \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let client {
            Task {
                try? await client.shutdown()
            }
        } else {
            print("No client initiaded")
        }
    }
}

