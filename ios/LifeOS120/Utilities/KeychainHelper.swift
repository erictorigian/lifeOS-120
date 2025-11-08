//
//  KeychainHelper.swift
//  LifeOS-120
//
//  Secure storage for authentication tokens using iOS Keychain
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    private let service = "com.lifeos120.app"

    // MARK: - Save

    func save(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func save(_ string: String, for key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    // MARK: - Retrieve

    func retrieve(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func retrieveString(for key: String) -> String? {
        guard let data = retrieve(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete

    func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    // MARK: - Convenience Methods for Auth

    enum KeychainKey {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userId = "userId"
    }

    func saveAccessToken(_ token: String) -> Bool {
        save(token, for: KeychainKey.accessToken)
    }

    func saveRefreshToken(_ token: String) -> Bool {
        save(token, for: KeychainKey.refreshToken)
    }

    func saveUserId(_ userId: String) -> Bool {
        save(userId, for: KeychainKey.userId)
    }

    func getAccessToken() -> String? {
        retrieveString(for: KeychainKey.accessToken)
    }

    func getRefreshToken() -> String? {
        retrieveString(for: KeychainKey.refreshToken)
    }

    func getUserId() -> String? {
        retrieveString(for: KeychainKey.userId)
    }

    func clearAuthData() {
        _ = delete(for: KeychainKey.accessToken)
        _ = delete(for: KeychainKey.refreshToken)
        _ = delete(for: KeychainKey.userId)
    }
}
