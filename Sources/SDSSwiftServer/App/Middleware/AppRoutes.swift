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
        
        data.get("subscriptionportal") { req async throws -> Response in
            // Redirect the browser to the static subscription page
            // Ensure `subscription.html` is located under the `Public/` directory
            return req.redirect(to: "/subscription.portal.html", type: .normal)
        }
        
    }
    
}

struct APIAvailibityResponse: Content {
    
    var result: String
    var message: String?
    
}
