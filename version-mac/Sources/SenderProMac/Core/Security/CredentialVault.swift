import Foundation
import Security
import CryptoKit

// MARK: - Secure Credential Vault (macOS Keychain + AES-GCM 256 Encrypted Fallback — Zero Cleartext Passwords)
@MainActor
public final class CredentialVault {
    public static let shared = CredentialVault()

    private let serviceName = "com.senderpro.mac.v4.credentials"
    private let vaultFileURL: URL
    private let keyFileURL: URL
    private var cachedMap: [String: String] = [:]

    private init() {
        let baseDir = PersistenceManager.shared.appSupportDir
        self.vaultFileURL = baseDir.appendingPathComponent("credentials_vault.aesgcm")
        self.keyFileURL = baseDir.appendingPathComponent(".vault_master_key")
        loadEncryptedVault()
    }

    /// Stores a secret securely in macOS Keychain and AES-GCM encrypted vault, returning a vault reference token.
    /// Never stores cleartext passwords in SQLite or JSON.
    public func storeSecret(_ plaintext: String, forKey accountKey: String) -> String {
        guard !plaintext.isEmpty else { return "" }
        if plaintext.hasPrefix("__VAULT_REF__:") {
            return plaintext
        }
        let cleanKey = accountKey.trimmingCharacters(in: .whitespacesAndNewlines)
        cachedMap[cleanKey] = plaintext
        saveToKeychain(secret: plaintext, account: cleanKey)
        saveEncryptedVault()
        return "__VAULT_REF__:\(cleanKey)"
    }

    /// Resolves a vault reference token (`__VAULT_REF__:<key>`) or account key back to the decrypted secret in memory.
    public func retrieveSecret(forRefOrKey refOrKey: String, fallbackKey: String = "") -> String {
        let lookupKey: String
        if refOrKey.hasPrefix("__VAULT_REF__:") {
            lookupKey = String(refOrKey.dropFirst("__VAULT_REF__:".count))
        } else if !fallbackKey.isEmpty {
            lookupKey = fallbackKey
        } else {
            return refOrKey
        }

        if let mem = cachedMap[lookupKey], !mem.isEmpty {
            return mem
        }
        if let kc = readFromKeychain(account: lookupKey), !kc.isEmpty {
            cachedMap[lookupKey] = kc
            return kc
        }
        return ""
    }

    public func deleteSecret(forKey accountKey: String) {
        cachedMap.removeValue(forKey: accountKey)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(query as CFDictionary)
        saveEncryptedVault()
    }

    /// Verifies that a stored string on disk/SQLite is a vault reference and does not contain the raw secret.
    public nonisolated func isRedactedVaultReference(_ value: String) -> Bool {
        return value.isEmpty || value.hasPrefix("__VAULT_REF__:")
    }

    // MARK: - macOS Keychain Native Operations
    private func saveToKeychain(secret: String, account: String) {
        guard let data = secret.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    private func readFromKeychain(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - CryptoKit AES-GCM 256-Bit Encrypted Vault Persistence
    private func getOrCreateSymmetricKey() -> SymmetricKey {
        if let keyData = try? Data(contentsOf: keyFileURL), keyData.count == 32 {
            return SymmetricKey(data: keyData)
        }
        let newKey = SymmetricKey(size: .bits256)
        let rawBytes = newKey.withUnsafeBytes { Data($0) }
        try? rawBytes.write(to: keyFileURL, options: .atomic)
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: keyFileURL.path)
        return newKey
    }

    private func saveEncryptedVault() {
        guard let plainData = try? JSONEncoder().encode(cachedMap) else { return }
        let key = getOrCreateSymmetricKey()
        if let sealed = try? AES.GCM.seal(plainData, using: key),
           let combined = sealed.combined {
            try? combined.write(to: vaultFileURL, options: .atomic)
            try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: vaultFileURL.path)
        }
    }

    private func loadEncryptedVault() {
        guard let combined = try? Data(contentsOf: vaultFileURL) else { return }
        let key = getOrCreateSymmetricKey()
        if let box = try? AES.GCM.SealedBox(combined: combined),
           let plainData = try? AES.GCM.open(box, using: key),
           let map = try? JSONDecoder().decode([String: String].self, from: plainData) {
            self.cachedMap = map
        }
    }
}
