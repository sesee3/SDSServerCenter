//
//  ConfsController.swift
//  sds-portal
//
//  Created by Sese on 15/11/25.
//

import Foundation
import Vapor

struct ConfsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let conferences = routes.grouped("conferences")
        conferences.get(use: index)
        
        conferences.get("sub", use: subIndex)
        
    }
    
    func index(req: Request) throws -> String {
        return "List of conferences"
    }
    
    func subIndex(req: Request) throws -> String {
        return "Sub index of conferences"
    }
    
}
