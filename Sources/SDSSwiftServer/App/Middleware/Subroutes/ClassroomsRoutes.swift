import Vapor

struct ClassroomsRoutes: RouteCollection {
    
    
    
    func boot(routes: RoutesBuilder) throws {
        let classrooms = routes.grouped("data", dataVersion.versionPath, "classrooms")
        classrooms.get(use: getAll)
        classrooms.post("add", use: add)
        classrooms.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> String {
        "accessed to classrooms data"
    }
    func add(req: Request) async throws -> String {
        "added classroom (simulazione)"
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "classe non trovata" }
        return "edited classroom con id: \(id) (simulazione)"
    }
}
