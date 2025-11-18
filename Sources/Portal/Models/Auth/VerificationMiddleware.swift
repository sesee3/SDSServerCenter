//
//  VerificationMiddleware.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Foundation
import Vapor
import JWTKit


///La risposta del server quando un nuovo utente crea una nuova chiave di accesso o accede al server con le sue credenziali
struct AuthPayload: JWTPayload, Authenticatable {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userID: String
    var sessionID: String
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
    
}

///Un middleware di autenticazione usato per proteggere API sensibili
struct VerificationMiddleware: AsyncMiddleware {
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "User was not authenticated and not have a token")
        }
        
        let store = request.application.userStore
        
        do {
            let payload = try await request.jwt.verify(token, as: AuthPayload.self)
            
            let users = try store.loadUsers()
            guard let user = users.first(where: { $0.id == payload.userID }),
                  let _ = user.sessions.first(where: { $0.id == payload.sessionID }) else {
                throw Abort(.unauthorized, reason: "Sessione revocata")
            }
            
            var updatedUsers = users
            if let userIDX = updatedUsers.firstIndex(where: { $0.id == payload.userID }),
               let sessionIDX = updatedUsers[userIDX].sessions.firstIndex(where: { $0.id == payload.sessionID }) {
                
                updatedUsers[userIDX].sessions[sessionIDX].lastLogAt = .now
                try store.saveUsers(updatedUsers)
                
            }
            
            request.auth.login(payload)
            return try await next.respond(to: request)
            
        } catch let jwtError as JWTError {
            throw Abort(.unauthorized, reason: "Token non valido o sessione revocata, \(jwtError)")
        } catch let abort as any AbortError where abort.status == .unauthorized {
            throw abort
        }
        
    }
}
