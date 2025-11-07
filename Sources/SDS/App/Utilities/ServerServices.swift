//
//  ServerService.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor
import ServiceLifecycle

struct ServerService: Service {
    var app: Application
    func run() async throws {
        try await app.execute()
    }
}
