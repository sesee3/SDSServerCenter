//
//  ConfsController.swift
//  sds-portal
//
//  Created by Sese on 15/11/25.
//

import Foundation
import Vapor

import Fluent

//TODO: Add Error Middleware: ChatGPT, cerca "APIError.swift — definizione errori standard"

struct ConfsController: RouteCollection {
    
    private let collection = "conferences"
    private let db = "sds-portal-db"
    let store = UserStore()
    
    func boot(routes: any RoutesBuilder) throws {
        let conferences = routes.grouped("conferences")
        
        conferences.get(use: getConferences)
        
        let protectedGroup = conferences.grouped(VerificationMiddleware())
        
        protectedGroup.post("create", use: create)
        protectedGroup.put(":id", use: update)
        protectedGroup.delete(":id", use: delete)
        
    }
    
    func getConferences(req: Request) async throws -> [Conference] {
        try await Conference.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Conference {
        let conference = try req.content.decode(Conference.self)
        try await conference.create(on: req.db)
        return conference
    }
    
    func update(req: Request) async throws -> Conference {
        // Extract and validate ID
        guard let idString = req.parameters.get("id"), let conferenceID = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "ID richiesto non valido")
        }

        // Decode incoming PATCH-style payload (optional fields)
        let dto = try req.content.decode(UpdateConferenceDTO.self)

        // Fetch existing model
        guard let conference = try await Conference.find(conferenceID, on: req.db) else {
            throw Abort(.notFound, reason: "Nessuna conferenza trovata con questo ID")
        }

        // Apply only provided fields
        conference.apply(dto)

        // Persist changes
        try await conference.update(on: req.db)

        // Return updated model
        return conference
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id"),
              let conferenceID = UUID(uuidString: id) else {
            throw Abort(.badRequest, reason: "ID non valido")
        }
        
        guard let conference = try await Conference.find(conferenceID, on: req.db) else {
            throw Abort(.notFound, reason: "Nessuan conferenza trovata con questo id")
        }
        
        try await conference.delete(on: req.db)
        
        return .accepted
        
    }
    
}

let api = PathComponent.constant("api/v1")

struct UpdateConferenceDTO: Content {
    var title: String?
    var abstract: String?
    var isOnline: Bool?
    var url: String?
    var attendences: [String]?
    var usefulContacts: [String]?
    var isExternal: Bool?
    var externalNotes: String?
    var availableSlots: [HourSlot]?
}

extension Conference {
    func apply(_ dto: UpdateConferenceDTO) {
        if let v = dto.title { self.title = v }
        if let v = dto.abstract { self.abstract = v }
        if let v = dto.isOnline { self.isOnline = v }
        if let v = dto.url { self.url = v }
        if let v = dto.attendences { self.attendences = v }
        if let v = dto.usefulContacts { self.usefulContacts = v }
        if let v = dto.isExternal { self.isExternal = v }
        if let v = dto.externalNotes { self.externalNotes = v }
        if let v = dto.availableSlots { self.availableSlots = v }
    }
}
