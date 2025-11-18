//
//  UserStore.swift
//  sds-portal
//
//  Created by Sese on 16/11/25.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
import Vapor

public let userDirectory = FileManager.default.currentDirectoryPath.appending("users.encrypted")
public let activitiesDirectory = FileManager.default.currentDirectoryPath.appending("activities_log.encrypted")

public final class UserStore: Sendable {
    
    private let usersFilePath = userDirectory
    private let activityRecordPath = activitiesDirectory
    private let key: SymmetricKey
    
    public init() {
            // Prova a caricare da variabile d'ambiente
            if let envKey = Environment.get("ENCRYPTION_KEY") {
                var keyData = Data(envKey.utf8)
                
                
                if keyData.count < 32 {
                    keyData.append(Data(repeating: 0, count: 32 - keyData.count))
                } else if keyData.count > 32 {
                    keyData = keyData.prefix(32)
                }
                self.key = SymmetricKey(data: keyData)
            } else {
                let keyString = "/eTWahJeDwnQF375J6Tzxkk7ad8VO3Ns"
                let keyData = Data(keyString.utf8)
                assert(keyData.count == 32, "La chiave deve essere esattamente 32 byte")
                self.key = SymmetricKey(data: keyData)
                
                print("⚠️  WARNING: Usando chiave di crittografia di default!")
                print("⚠️  Imposta la variabile d'ambiente ENCRYPTION_KEY in produzione")
            }
        }
        
        // Metodo per generare una nuova chiave casuale
        static func generateNewKey() -> String {
            let key = SymmetricKey(size: .bits256)
            return key.withUnsafeBytes { bytes in
                Data(bytes).base64EncodedString()
            }
        }
    
    private func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
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
        return String(data: decrypted, encoding: .utf8)!
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
    
//    func findUser(username: String) throws -> User? {
//        return try loadUsers().first(where: { $0.username.lowercased() == username })
//    }
//    
//    func addUser(_ user: User) throws {
//        var users = try loadUsers()
//        if users.contains(where: { $0.username.lowercased() == user.username.lowercased() }) {
//            throw Abort(.conflict, reason: "User already exists")
//        }
//        
//        users.append(user)
//        try saveUsers(users)
//    }
//    
//    func updateUser(_ user: User) throws {
//        var users = try loadUsers()
//        if let idx = users.firstIndex(where: { $0.id == user.id }) {
//            users[idx] = user
//            try saveUsers(users)
//        } else {
//            throw Abort(.notFound, reason: "User not found among signed up users")
//        }
//    }
    
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
