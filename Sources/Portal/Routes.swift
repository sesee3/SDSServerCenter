import Vapor
import Leaf
import JWTKit

func routes(_ app: Application) async throws {

    let api = app.grouped("api", "v1")
        
    let conferences = ConfsController()
    try api.register(collection: conferences)
    
    try api.register(collection: AuthController())
    
    
    //MARK: Web Pages
    //Main Page
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }
    
    //Conferences Page
    app.get("conferences") { req -> EventLoopFuture<View> in
        return req.view.render("conferences")
    }

    //Manutenzione
    app.get("wait") { req -> EventLoopFuture<View> in
        return req.view.render("wait")
    }
    
    //Users's
    
    app.get("login") { req -> EventLoopFuture<View> in
        return req.view.render("login")
    }
    
    app.get("signup") { req -> EventLoopFuture<View> in
        return req.view.render("signup")
    }
    
    app.get("user", "dashboard") { req -> EventLoopFuture<View> in
        return req.view.render("user_dashboard")
    }
    
    app.get("user", "sessions") { req -> EventLoopFuture<View> in
        return req.view.render("user_sessions")
    }
    
    app.get("user", "activities") { req -> EventLoopFuture<View> in
        return req.view.render("activities.log")
    }
    
    app.get("login_revoked") { req -> EventLoopFuture<View> in
        return req.view.render("revoked_log")
    }
    
    
    
}
