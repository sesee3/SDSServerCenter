import Foundation
import Vapor
import CryptoKit

public struct StoredUser: Codable, Sendable {
    public var id: UUID
    public var username: String
    public var passwordHash: String
    public var loggedDevices: [String]
}

public enum EncryptedUserStoreError: Error {
    case userAlreadyExists
    case userNotFound
    case invalidKeyMaterial
    case corruptedStore
}

public actor EncryptedUserStore {
    private let fileURL: URL
    private let key: SymmetricKey
    private let logger: Logger
    private var usersByName: [String: StoredUser] = [:]

    /// Create the store backed by an encrypted JSON file. Loads existing content if present.
    public init(fileURL: URL, key: SymmetricKey, logger: Logger) async throws {
        self.fileURL = fileURL
        self.key = key
        self.logger = logger
        try await self.loadFromDisk()
    }

    /// Returns the user for a username if it exists.
    public func getUser(username: String) -> StoredUser? {
        usersByName[username]
    }

    /// Creates a new user with the given password hash. Throws if the username already exists.
    @discardableResult
    public func createUser(username: String, passwordHash: String, loggedDevices: [String]) throws -> StoredUser {
        guard usersByName[username] == nil else { throw EncryptedUserStoreError.userAlreadyExists }
        let stored = StoredUser(id: UUID(), username: username, passwordHash: passwordHash, loggedDevices: loggedDevices)
        usersByName[username] = stored
        try persistToDisk()
        return stored
    }

    /// Updates the password hash for an existing user.
    public func updatePassword(username: String, newPasswordHash: String) throws {
        guard var u = usersByName[username] else { throw EncryptedUserStoreError.userNotFound }
        u.passwordHash = newPasswordHash
        usersByName[username] = u
        try persistToDisk()
    }

    /// Adds a device identifier to the user's logged devices list.
    public func addLoggedDevice(username: String, device: String) throws {
        guard var u = usersByName[username] else { throw EncryptedUserStoreError.userNotFound }
        if !u.loggedDevices.contains(device) {
            u.loggedDevices.append(device)
            usersByName[username] = u
            try persistToDisk()
        }
    }

    // MARK: - Persistence

    private func loadFromDisk() async throws {
        let fm = FileManager.default
        if !fm.fileExists(atPath: fileURL.path) {
            usersByName = [:]
            return
        }
        let data = try Data(contentsOf: fileURL)
        if data.isEmpty {
            usersByName = [:]
            return
        }
        do {
            let sealed = try AES.GCM.SealedBox(combined: data)
            let opened = try AES.GCM.open(sealed, using: key)
            let decoder = JSONDecoder()
            let users = try decoder.decode([StoredUser].self, from: opened)
            var map: [String: StoredUser] = [:]
            for u in users { map[u.username] = u }
            usersByName = map
        } catch {
            logger.error("Failed to decrypt/decode user store: \(String(describing: error))")
            throw EncryptedUserStoreError.corruptedStore
        }
    }

    private func persistToDisk() throws {
        let encoder = JSONEncoder()
        if #available(macOS 13.0, *) {
            encoder.outputFormatting.insert(.sortedKeys)
            encoder.outputFormatting.insert(.withoutEscapingSlashes)
        } else {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        let list = Array(usersByName.values)
        let json = try encoder.encode(list)
        let sealed = try AES.GCM.seal(json, using: key)
        guard let combined = sealed.combined else {
            throw EncryptedUserStoreError.corruptedStore
        }
        try combined.write(to: fileURL, options: .atomic)
    }
}

// MARK: - Application integration

private struct UserStoreKey: StorageKey { typealias Value = EncryptedUserStore }

public extension Application {
    var userStore: EncryptedUserStore {
        get {
            guard let store = self.storage[UserStoreKey.self] else {
                fatalError("EncryptedUserStore has not been configured. Set app.userStore in configure(_:) before using it.")
            }
            return store
        }
        set { self.storage[UserStoreKey.self] = newValue }
    }
}

public extension SymmetricKey {
    /// Initialize a symmetric key from a base64-encoded 32-byte value.
    init?(base64Encoded: String) {
        guard let data = Data(base64Encoded: base64Encoded), data.count == 32 else { return nil }
        self = SymmetricKey(data: data)
    }
}
