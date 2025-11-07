//
//  AlertRoutes.swift
//  SDSSwiftServer
//
//  Created by Sese on 07/07/25.
//

import Vapor
import APNS
import APNSCore
import Foundation

struct AlertRoutes: RouteCollection {
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let alerts = routes.grouped("alert")
        alerts.get("test", use: test)
    }
    
    func test(_ req: Request) async -> Response {
        
        guard let client = SDSAlerts().client else {
            print("Client unavailable")
            return Response(status: .custom(code: 503, reasonPhrase: "APNS client unavailable"))
        }
        
        do {
            
            try await client.sendAlertNotification(
                .init(
                    alert: .init(
                        title: .raw("Test"),
                        subtitle: .raw("This is a test"),
                        body: .raw("This notification was sended from the app"),
                        launchImage: nil
                    ),
                    expiration: .none,
                    priority: .immediately,
                    topic: "com.sese.sds",
                    payload: EmptyPayload(),
                    badge: 1,
                    sound: .default,
                    threadID: nil,
                    category: nil,
                    mutableContent: nil,
                    targetContentID: nil,
                    interruptionLevel: .active,
                    relevanceScore: nil,
                    apnsID: nil
                ),
                deviceToken: "f4ea185cf6c370c1324bc8c2b23e54f1e1ce22db60ec45cf8d2ee9cb6cb82421"
            )

            
            return Response(status: .custom(code: 1, reasonPhrase: "Notification Sended"))
            
        } catch {
            
            let error = error.localizedDescription
            
            print(error)
            
            return Response(status: .custom(code: 500, reasonPhrase: "Error occured trying to send a test notification from the server. Error in the code: \(error)"))
        }
        
       
    }
    
    
}

