//
//  File.swift
//  SDSSwiftServer
//
//  Created by Sese on 08/07/25.
//

import Foundation
import Vapor
import FluentPostgresDriver


final class ClassroomData: Model, Content, @unchecked Sendable {
    
    static let schema: String = "classrooms"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "formal") var formal: String
    @Field(key: "num") var num: String
    
    @Field(key: "studentsNum") var studentsNum: Int
    @Field(key: "available") var available: Bool
    @Field(key: "max") var max: Int
    
    @Field(key: "position") var position: String
    @Field(key: "entrance") var entrance: String
    @Field(key: "plex") var plex: String
    
}

struct ClassroomsBuilder: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("classrooms")
            .id()
            .field("name", .string)
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("students").delete()
    }
}
