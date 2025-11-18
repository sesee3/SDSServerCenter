//
//  File.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Vapor
import JWT

struct ActivityController: RouteCollection {
    let store = UserStore()
    
    func boot(routes: any RoutesBuilder) throws {
        let activities = routes.grouped("api", "v1", "activities")
        let protected = activities.grouped(VerificationMiddleware())
        protected.get(use: getActivities)
    }
    
    func getActivities(req: Request) async throws -> [Activity] {
        let payload = try req.auth.require(AuthPayload.self)
        let activities = try store.loadActivities()
        
        // Log attività di visualizzazione
        let users = try store.loadUsers()
        if let user = users.first(where: { $0.id == payload.userID }) {
            try store.addActivity(
                Activity(
                    userID: payload.userID,
                    username: user.username,
                    action: "Visualizzazione attività",
                    timestamp: .now,
                    ipAddress: req.headers.first(name: "X-Forwarded-For") ?? req.remoteAddress?.ipAddress ?? "unknown",
                    deviceInfo: DeviceInfo(browser: "Unknown", os: "Unknown", device: "Unknown", userAgent: req.headers.first(name: .userAgent) ?? "")
                )
            )
        }
        
        return activities
    }
}
