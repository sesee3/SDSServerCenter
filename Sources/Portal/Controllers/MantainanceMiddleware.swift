//
//  MantainanceMiddleware.swift
//  sds-portal
//
//  Created by Sese on 15/11/25.
//

import Foundation
import Vapor

struct MantainanceMiddleware: Middleware {
    
    ///Un array di percorsi da escludere dalla manutenzione
    let exceptions: [String]
    
    init(exceptions: [String] = [
        "/wait",
        "/css",
        "/images",
        "/favicon.ico",
        "/conferences",
        "/login",
        "/signup",
        "/login_revoked",
        "/user",
        "/auth"
    ]) {
        self.exceptions = exceptions
    }
    
    func respond(to request: Request, chainingTo next: any Responder) -> EventLoopFuture<Response> {
        let isException = exceptions.contains { route in
            request.url.path.starts(with: route)
        }
        
        if isException {
            //Continua con la richiesta se è un eccezione
            return next.respond(to: request)
        }
        
        //Restituisci la pagina di manutenzione
        return request.view.render("wait").flatMap { view in
            return view.encodeResponse(for: request)
                .map { response in
                    
                    //Setup mantainence code
                    
                    response.status = .serviceUnavailable
                    return response
                }
        }
        
    }
    
}
