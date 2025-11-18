//
//  Classroom.swift
//  SDSSwiftServer
//
//  Created by Sese on 08/07/25.
//

import Foundation
import Vapor

struct Classroom: Content {
    
//    static let schema: String = "classrooms"
    
    var id: String
    
    var formal: String
    var num: String
    
    var studentsNum: Int
    var available: Bool
    var max: Int
    
    var position: String
    var entrance: String
    var plex: String
    
    init(id: String = UUID().uuidString, formal: String, num: String, studentsNum: Int, available: Bool, max: Int, position: String, entrance: String, plex: String) {
        self.id = id
        self.formal = formal
        self.num = num
        self.studentsNum = studentsNum
        self.available = available
        self.max = max
        self.position = position
        self.entrance = entrance
        self.plex = plex
    }
    
}

//struct ClassroomsBuilder: Migration {
//    func prepare(on database: any Database) -> EventLoopFuture<Void> {
//        database.schema("classrooms")
//            .id()
//            .field("name", .string)
//            .create()
//    }
//    
//    func revert(on database: any Database) -> EventLoopFuture<Void> {
//        database.schema("students").delete()
//    }
//}
