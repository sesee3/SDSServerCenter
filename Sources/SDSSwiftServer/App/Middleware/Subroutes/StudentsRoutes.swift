import Vapor

struct StudentsRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let classrooms = routes.grouped("data", dataVersion.versionPath, "students")
        classrooms.get(use: getAll)
        classrooms.post("add", use: add)
        classrooms.put("edit", ":id", use: edit)
    }

    func getAll(req: Request) async throws -> [StudentData] {
        
        try await StudentData.query(on: req.db).all()
        
    }
    func add(req: Request) async throws -> Response {
        
        let student = try req.content.decode(StudentData.self)
        try await student.save(on: req.db)
        return Response(status: .ok, body: Response.Body(stringLiteral: "Student added!"))
        
    }
    func edit(req: Request) async throws -> String {
        guard let id = req.parameters.get("id") else { return "classe non trovata" }
        return "edited classroom con id: \(id) (simulazione)"
    }
}
