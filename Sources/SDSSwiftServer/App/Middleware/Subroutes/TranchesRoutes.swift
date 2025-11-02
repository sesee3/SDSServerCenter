import Vapor

struct TranchesRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tranches = routes.grouped("data", dataVersion.versionPath, "tranches")
        tranches.get(use: getAll)
        tranches.post("add", use: add)
        tranches.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> String {
        "accessed to tranches data"
    }
    func add(req: Request) async throws -> String {
        "added tranche (simulazione)"
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "tranche non trovata" }
        return "edited tranche con id: \(id) (simulazione)"
    }
}
