//
//  File.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Foundation
import Vapor
import Fluent

/// Fluent models are reference types with mutable properties; mark as @unchecked Sendable to satisfy Swift 6 concurrency checks.
final class Conference: Model, Content, @unchecked Sendable {
    
    static let schema: String = "conferences"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "title") var title: String
    @Field(key: "abstract") var abstract: String
    
        ///Determina se la conferenza si terrà online o in presenza
    @Field(key: "isOnline") var isOnline: Bool
    
        ///L'indirizzo URL del meeting, se la conferenza si tiene online
    @Field(key: "url") var url: String?
    
        ///I relatori
    @Field(key: "attendences") var attendences: [String]
    @Field(key: "usefulContacts") var usefulContacts: [String]
    
    @Field(key: "isExternal") var isExternal: Bool
    @Field(key: "externalNotes") var externalNotes: String
    
    @Field(key: "availableSlots") var availableSlots: [HourSlot]
    

    init() {  }
    
    init(id: UUID? = UUID(), title: String, abstract: String, isOnline: Bool, url: String? = nil, attendences: [String], usefulContacts: [String], isExternal: Bool, externalNotes: String, availableSlots: [HourSlot]) {
        self.id = id
        self.title = title
        self.abstract = abstract
        self.isOnline = isOnline
        self.url = url
        self.attendences = attendences
        self.usefulContacts = usefulContacts
        self.isExternal = isExternal
        self.externalNotes = externalNotes
        self.availableSlots = availableSlots
    }
    
    
}

struct HourSlot: Content, Codable {
    let date: String
    let start: String
    let end: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case start
        case end
    }
}
