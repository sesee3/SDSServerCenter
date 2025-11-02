import Vapor

struct PacksRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let packs = routes.grouped("data", dataVersion.versionPath, "packs")
        packs.get(use: getAll)
        packs.post("add", use: add)
        packs.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> String {
        "accessed to packs data"
    }
    func add(req: Request) async throws -> String {
        "added pack (simulazione)"
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "pack non trovato" }
        return "edited pack con id: \(id) (simulazione)"
    }
}
