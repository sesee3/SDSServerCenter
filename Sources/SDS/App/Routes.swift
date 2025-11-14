//
//  Routes.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor
import Fluent

func routes(_ app: Application) throws {
    
        ///Routes for machine performance, health and diagnostics checks
    try app.register(collection: MachinePerformanceRoutes())
    
        ///Routes for database's data and collections
    try app.register(collection: ClassroomsRoutes())
    try app.register(collection: StudentsRoutes())
    try app.register(collection: PacksRoutes())
    try app.register(collection: DaysRoutes())
    try app.register(collection: TranchesRoutes())
    try app.register(collection: ConferencesRoutes())
    
    try app.register(collection: AuthRoutes())
    
//    try app.register(collection: Queries())
    
    try app.register(collection: AppRoutes())
    
    try app.register(collection: AlertRoutes())
    
    
    // Protected routes example
    let protected = app.grouped(ProtectedMiddleware())
    protected.get("protected-info") { req async throws -> String in
        return "Sensitive data only for authenticated users."
    }
    
    
    //TODO: Da vedere
    app.get(apiVersion.versionPath, "subscriptionportal") { req async throws -> Response in
        let path = app.directory.publicDirectory + "subportal.html"
        
        app.logger.info(.init(stringLiteral: path))
        
        if FileManager.default.fileExists(atPath: path) {
            return try await req.fileio.asyncStreamFile(at: path, mediaType: .html)
        } else {
            return Response(status: .notFound)
        }}
    
    
}

public let apiVersion = ServerVersion.v1
public let dataVersion = DataVersion.v1

public enum ServerVersion: String, @unchecked Sendable {
    
    case v1
    
    var version: String {
        return rawValue
    }
    
    var versionPath: PathComponent {
        return "\(rawValue)"
    }
    
}

public enum DataVersion: String, @unchecked Sendable {
    case v1
    
    var version: String {
        return rawValue
    }
    
    var versionPath: PathComponent {
        return "\(rawValue)"
    }
}
