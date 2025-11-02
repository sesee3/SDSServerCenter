//
//  AppRoutes.swift
//  SDSSwiftServer
//
//  Created by Sese on 05/07/25.
//

import Foundation
import Vapor

struct AppRoutes: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let data = routes.grouped("api")
        
        data.get("availability") { _ async throws -> Response in
            
            let response = APIAvailibityResponse(result: "available")
            let encodedResponse = try JSONEncoder().encode(response)
            
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")
            
            return .init(status: .ok, headers: headers, body: .init(data: encodedResponse))
        }
        
    }
    
}

struct APIAvailibityResponse: Content {
    
    var result: String
    var message: String?
    
}
