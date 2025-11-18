//
//  User.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Foundation

struct User: Codable {
    
    var id: String
    var username: String
    var passwordHash: String
    var createdAt: Date
    var sessions: [UserSession]
    
    init(id: String = UUID().uuidString, username: String, passwordHash: String, createdAt: Date, sessions: [UserSession]) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.createdAt = createdAt
        self.sessions = sessions
    }
    
}

struct UserSession: Codable {
    
    var id: String
    var token: String
    var deviceInfo: DeviceInfo
    var loggedAt: Date
    var lastLogAt: Date
    var ipAddress: String
    
    init(id: String = UUID().uuidString, token: String, deviceInfo: DeviceInfo, loggedAt: Date, lastLogAt: Date, ipAddress: String) {
        self.id = id
        self.token = token
        self.deviceInfo = deviceInfo
        self.loggedAt = loggedAt
        self.lastLogAt = lastLogAt
        self.ipAddress = ipAddress
    }
    
}

struct DeviceInfo: Codable {
    var browser: String
    var os: String
    var device: String
    var userAgent: String
}


