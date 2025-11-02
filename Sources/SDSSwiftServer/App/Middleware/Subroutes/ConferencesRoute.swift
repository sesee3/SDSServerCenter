import Vapor

struct ConferencesRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let conferences = routes.grouped("data", dataVersion.versionPath, "conferences")
        conferences.get(use: getAll)
        conferences.post("add", use: add)
        conferences.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> String {
        "accessed to conferences data"
    }
    func add(req: Request) async throws -> String {
        "added conference (simulazione)"
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "conference non trovata" }
        return "edited conference con id: \(id) (simulazione)"
    }
}
