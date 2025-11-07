import Vapor

struct DaysRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let days = routes.grouped("data", dataVersion.versionPath, "days")
        days.get(use: getAll)
        days.post("add", use: add)
        days.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> String {
        "accessed to days data"
    }
    func add(req: Request) async throws -> String {
        "added day (simulazione)"
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "giorno non trovato" }
        return "edited day con id: \(id) (simulazione)"
    }
}
