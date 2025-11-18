//
//  Activity.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Foundation
import Vapor

struct Activity: Codable, Content {
    var id: String
    var userID: String
    var username: String
    var action: String
    var timestamp: Date
    var ipAddress: String
    var deviceInfo: DeviceInfo
    
    init(id: String = UUID().uuidString, userID: String, username: String, action: String, timestamp: Date, ipAddress: String, deviceInfo: DeviceInfo) {
        self.id = id
        self.userID = userID
        self.username = username
        self.action = action
        self.timestamp = timestamp
        self.ipAddress = ipAddress
        self.deviceInfo = deviceInfo
    }
    
}
