//
//  Main.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor
import ServiceLifecycle

@main
struct EntryPoint {
    static func main() async throws {
        
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        app.http.server.configuration.address = .hostname("0.0.0.0", port: 3000)
        
        
        let serverServices = try configure(app)
        let services: [Service] = [serverServices]
        let serviceGroup = ServiceGroup(
            services: services,
            gracefulShutdownSignals: [.sigint],
            cancellationSignals: [.sigterm],
            logger: app.logger
        )

        try await serviceGroup.run()
        
        
        
    }
}
