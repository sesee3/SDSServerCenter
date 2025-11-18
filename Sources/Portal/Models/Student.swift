//
//  Student.swift
//  SDSSwiftServer
//
//  Created by Sese on 08/07/25.
//

import Foundation
import Vapor
//import Fluent

struct Student: Content {
    
//    static let schema: String = "students"
    
    var id: UUID?
    
    var name: String
    var surname: String
    
    var classroom: String
    
    var attendedPacks: [String]
    var isGuardian: [String]
    var isIgnored: String
    
    var ignores: [StudentException] {
        get {
            (try? JSONDecoder().decode([StudentException].self, from: isIgnored.data(using: .utf8)!)) ?? []
        } set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            isIgnored = String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    var isModerator: [String]
    
    init(id: UUID? = UUID(), name: String, surname: String, classroom: String, attendedPacks: [String], isGuardian: [String], isIgnored: String, isModerator: [String]) {
        self.id = id
        self.name = name
        self.surname = surname
        self.classroom = classroom
        self.attendedPacks = attendedPacks
        self.isGuardian = isGuardian
        self.isIgnored = isIgnored
        self.isModerator = isModerator
    }
    
    
    
}

struct StudentException: Content, Codable {
    
    var day: String
    var additionalNotes: String
    var ignoranceSummary: String
    
    init(day: String, additionalNotes: String, ignoranceSummary: String) {
        self.day = day
        self.additionalNotes = additionalNotes
        self.ignoranceSummary = ignoranceSummary
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.day = try container.decode(String.self, forKey: .day)
        self.additionalNotes = try container.decode(String.self, forKey: .additionalNotes)
        self.ignoranceSummary = try container.decode(String.self, forKey: .ignoranceSummary)
    }
    
    enum CodingKeys: CodingKey {
        case day
        case additionalNotes
        case ignoranceSummary
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.day, forKey: .day)
        try container.encode(self.additionalNotes, forKey: .additionalNotes)
        try container.encode(self.ignoranceSummary, forKey: .ignoranceSummary)
    }
    
}
