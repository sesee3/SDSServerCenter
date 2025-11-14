//
//  AuthRoutes.swift
//  SDSSwiftServer
//
//  Handles user registration and login for authentication
//

import Foundation
import Vapor
import Fluent

struct AuthRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("signup", use: signup)
        auth.post("signin", use: signin)
        auth.post("change-password", use: changePassword)
    }

    struct SignupRequest: Content {
        let username: String
        let password: String
    }
    
    struct SigninRequest: Content {
        let username: String
        let password: String
    }
    
    struct ChangePasswordRequest: Content {
        let username: String
        let oldPassword: String
        let newPassword: String
    }

    struct TokenResponse: Content {
        let token: String
    }

    func signup(req: Request) async throws -> HTTPStatus {
        let signup = try req.content.decode(SignupRequest.self)
        let hash = try Bcrypt.hash(signup.password)
        do {
            try await req.application.userStore.createUser(username: signup.username, passwordHash: hash, loggedDevices: [])
            return .created
        } catch EncryptedUserStoreError.userAlreadyExists {
            throw Abort(.conflict, reason: "User already exists")
        }
    }

    func signin(req: Request) async throws -> TokenResponse {
        let signin = try req.content.decode(SigninRequest.self)
        guard let user = await req.application.userStore.getUser(username: signin.username) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        guard try Bcrypt.verify(signin.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        let token = [UInt8].random(count: 32).base64
        req.session.data["userID"] = user.id.uuidString
        req.session.data["token"] = token
        return TokenResponse(token: token)
    }

    func changePassword(req: Request) async throws -> HTTPStatus {
        let changeReq = try req.content.decode(ChangePasswordRequest.self)
        guard let user = await req.application.userStore.getUser(username: changeReq.username) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        guard try Bcrypt.verify(changeReq.oldPassword, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Old password is incorrect")
        }
        let newHash = try Bcrypt.hash(changeReq.newPassword)
        try await req.application.userStore.updatePassword(username: changeReq.username, newPasswordHash: newHash)
        return .ok
    }
}

