    //
    //  UserStore.swift
    //  sds-portal
    //
    //  Created by Sese on 16/11/25.
    //

    import Foundation
    import Crypto
    import Vapor

    public let userDirectory = FileManager.default.currentDirectoryPath.appending("/users.encrypted")
    public let activitiesDirectory = FileManager.default.currentDirectoryPath.appending("/activities_log.encrypted")

    public final class UserStore: @unchecked Sendable {
        
        private let usersFilePath = userDirectory
        private let activityRecordPath = activitiesDirectory
        private let key: SymmetricKey
        
        public init() {
            // 1. Recupera la chiave o usa quella di default
            let rawKeyString = Environment.get("ENCRYPTION_KEY") ?? "/eTWahJeDwnQF375J6Tzxkk7ad8VO3Ns"

            // 2. PULIZIA (Cruciale su Linux: rimuove \n e spazi invisibili)
            let cleanKeyString = rawKeyString.trimmingCharacters(in: .whitespacesAndNewlines)

            // 3. Conversione in Data
            guard let inputData = cleanKeyString.data(using: .utf8) else {
                fatalError("Impossibile convertire la stringa della chiave in Data UTF8")
            }

            let hashedKey = SHA256.hash(data: inputData)
            let hashedData = Data(hashedKey)

            // 5. Creazione della SymmetricKey (usando i bytes SHA256)
            self.key = SymmetricKey(data: hashedData)

    
        }
        
            static func generateNewKey() -> String {
                let key = SymmetricKey(size: .bits256)
                return key.withUnsafeBytes { bytes in
                    Data(bytes).base64EncodedString()
                }
            }
        
        private func encrypt(_ data: Data) throws -> Data {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw Abort(.internalServerError, reason: "Failed to seal data")
            }
            return combined
        }
        
        private func decrypt(_ data: Data) throws -> Data {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        }
        
        public func encryptString(_ string: String) throws -> Data {
            try encrypt(Data(string.utf8))
        }
        
        public func decryptString(_ data: Data) throws -> String {
            let decrypted = try decrypt(data)
            guard let s = String(data: decrypted, encoding: .utf8) else {
                throw Abort(.internalServerError, reason: "Failed to decode decrypted data as UTF8")
            }
            return s
        }
        
        func loadUsers() throws -> [User] {
            guard FileManager.default.fileExists(atPath: usersFilePath) else {
                print("Users file does not exist")
                return []
            }
            
            let encrypted = try Data(contentsOf: URL(filePath: usersFilePath))
            let json = try decrypt(encrypted)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let users = try decoder.decode([User].self, from: json)
            return users
            
        }
        
        func saveUsers(_ users: [User]) throws {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let json = try encoder.encode(users)
            let encrypted = try encrypt(json)
            try encrypted.write(to: URL(filePath: usersFilePath))
        }
        
        func saveActivities(_ activities: [Activity]) throws {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(activities)
            let encrypted = try encrypt(jsonData)
            try encrypted.write(to: URL(filePath: activityRecordPath))
            
        }
        
        func loadActivities() throws -> [Activity] {
            guard FileManager.default.fileExists(atPath: activityRecordPath) else {
                print("Activity records file not foun")
                return []
            }
            
            let encrypted = try Data(contentsOf: URL(filePath: activityRecordPath))
            let decrypted = try decrypt(encrypted)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode([Activity].self, from: decrypted)
            
        }
        
        func addActivity(_ activity: Activity) throws {
            var activities = try loadActivities()
            activities.append(activity)
            try saveActivities(activities)
        }
        
    }
