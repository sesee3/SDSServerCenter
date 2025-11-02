//
//  MachineHealthRoutes.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor

struct MachinePerformanceRoutes: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        routes.get("health", use: health)
    }
    
    func health(req: Request) async throws -> String {
        return "ok\n"
    }
    
}

struct MachinePerformanceContent: Content {
    
    var timestamp: Date
    var os: String
    var ram: String
    
}
