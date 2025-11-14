//
//  ProtectedMiddleware.swift
//  SDSSwiftServer
//
//  Middleware for session-based token authentication
//

import Vapor

struct ProtectedMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let sessionID = request.session.data["userID"],
              let _ = request.session.data["token"] else {
            throw Abort(.unauthorized, reason: "Authentication required")
        }
        // You can add additional checks with userID and token if needed
        return try await next.respond(to: request)
    }
}
