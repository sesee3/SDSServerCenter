//
//  User.swift
//  SDSSwiftServer
//
//  Created for authentication system
//

import Foundation
import Vapor
import Fluent

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "passwordHash")
    var passwordHash: String

    @Field(key: "loggedDevices")
    var loggedDevices: [String]
    
    init() {}

    init(id: UUID? = nil, username: String, passwordHash: String, loggedDevices: [String] = []) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.loggedDevices = loggedDevices
    }
}

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("passwordHash", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}

extension User: @unchecked Sendable {}
