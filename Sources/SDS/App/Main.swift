
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
            // Ensure the Application is shutdown before it gets deinitialized to avoid Vapor assertion
            // NOTE: we cannot call async/throwing functions from inside a `defer` body. Instead,
            // call shutdown explicitly after `serviceGroup.run()` completes (or fails).
        
        let serverServices = try await configure(app)
        let services: [Service] = [serverServices]
        let serviceGroup = ServiceGroup(
            services: services,
            gracefulShutdownSignals: [.sigint],
            cancellationSignals: [.sigterm],
            logger: app.logger
        )
        
            // Run the service group and ensure we shutdown the Application afterwards.
        do {
            try await serviceGroup.run()
        } catch {
                // Attempt graceful shutdown; don't swallow the original error.
            do {
                try await app.asyncShutdown()
            } catch {
                app.logger.error("Application shutdown failed: \(error.localizedDescription)")
            }
            throw error
        }
        
            // Normal shutdown path
        do {
            try await app.asyncShutdown()
        } catch {
            app.logger.error("Application shutdown failed: \(error.localizedDescription)")
        }
        
    }
}
