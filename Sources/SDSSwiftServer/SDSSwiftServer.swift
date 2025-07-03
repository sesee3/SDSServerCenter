// The Swift Programming Language
// https://docs.swift.org/swift-book

import Vapor
import Foundation
import ServiceLifecycle
import Logging


@main
struct EntryPoint {
    
    static func main() async throws {
        
        _ = try Environment.detect()
        
        let app = try await Vapor.Application.make()
        app.http.server.configuration.address = .hostname("0.0.0.0", port: 8000)
        
        let serverService = try await setupServer(app)
                   
        //start
        let services: [Service] = [serverService]
        let serviceGroup = ServiceGroup(
            services: services,
            gracefulShutdownSignals: [.sigint],
            cancellationSignals: [.sigterm],
            logger: app.logger
        )
        try await serviceGroup.run()
        
    }
    
}

func setupServer(_ app: Application) async throws -> ServerService {
    app.middleware.use(RequestLoggerInjectionMiddleware())
    app.get("health") { _ in
        "ok\n"
    }
    
    app.get("hi") { req in
        [
            "element": "hi, back"
        ]
    }
    
    app.get("docs") { req in
        "accessed to docs"
    }
    
    app.get("data/students") { req in
        "accessed to students data"
    }
    
    app.get("data/classrooms") { req in
        "accessed to classrooms data"
    }
    
    app.get("data/packs") { req in
        "accessed to packs data"
    }
    
    app.get("data/days") { req in
        "accessed to days data"
    }
    
    app.get("data/tranches") { req in
        "accessed to tranches data"
    }
    
    app.get("data/conferences") { req in
        "accessed to conferences data"
    }
    
    return ServerService(app: app)
}

struct ServerService: Service {
    var app: Application
    func run() async throws {
        try await app.execute()
    }
}


func configureTelemetryServices(env: inout Environment) async throws {
    try LoggingSystem.bootstrap(from: &env)
}

extension Logger {
    @TaskLocal
    static var _current: Logger?

    static var current: Logger {
        get throws {
            guard let _current else {
                struct NoCurrentLoggerError: Error {}
                throw NoCurrentLoggerError()
            }
            return _current
        }
    }
}

struct RequestLoggerInjectionMiddleware: Vapor.AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        try await Logger.$_current.withValue(request.logger) {
            try await next.respond(to: request)
        }
    }
}
