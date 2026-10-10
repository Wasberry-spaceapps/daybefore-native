import Foundation
import CommonCrypto
import CryptoKit

struct CryptoService {
    static func hashPassword(_ password: String) -> String {
        let data = password.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash) }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    static func generateSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, 16, &bytes)
        return Data(bytes)
    }

    static func deriveKey(password: String, salt: Data) -> Data {
        let passwordData = password.data(using: .utf8)!
        var derivedKey = [UInt8](repeating: 0, count: 32)

        passwordData.withUnsafeBytes { passwordBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                    passwordData.count,
                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    100000,
                    &derivedKey,
                    32
                )
            }
        }
        return Data(derivedKey)
    }

    static func generateDataKey() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, 32, &bytes)
        return Data(bytes)
    }

    static func generateRecoveryKey() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, 16, &bytes)
        let hex = bytes.map { String(format: "%02x", $0) }.joined()
        return stride(from: 0, to: hex.count, by: 4).map {
            let start = hex.index(hex.startIndex, offsetBy: $0)
            let end = hex.index(start, offsetBy: 4)
            return String(hex[start..<end])
        }.joined(separator: "-")
    }

    static func deriveRecoveryKey(_ recoveryKey: String) -> Data {
        let cleanKey = recoveryKey.replacingOccurrences(of: "-", with: "")
        var keyBytes = [UInt8]()
        var index = cleanKey.startIndex
        while index < cleanKey.endIndex {
            let nextIndex = cleanKey.index(index, offsetBy: 2)
            let byteString = String(cleanKey[index..<nextIndex])
            if let byte = UInt8(byteString, radix: 16) {
                keyBytes.append(byte)
            }
            index = nextIndex
        }
        return deriveKey(password: cleanKey, salt: Data(keyBytes))
    }

    static func wrapDataKey(_ dataKey: Data, wrapKey: Data) -> String {
        return encryptData(dataKey.base64EncodedString(), key: wrapKey)
    }

    static func unwrapDataKey(_ wrapped: String, wrapKey: Data) -> Data {
        let decrypted = decryptData(wrapped, key: wrapKey)
        return Data(base64Encoded: decrypted)!
    }

    static func encryptData(_ plaintext: String, key: Data) -> String {
        let plaintextData = plaintext.data(using: .utf8)!
        let symmetricKey = SymmetricKey(data: key)
        let sealedBox = try! AES.GCM.seal(plaintextData, using: symmetricKey)
        let combined = sealedBox.nonce + sealedBox.ciphertext + sealedBox.tag
        return combined.base64EncodedString()
    }

    static func decryptData(_ encrypted: String, key: Data) -> String {
        let combined = Data(base64Encoded: encrypted)!
        let nonce = combined.prefix(12)
        let ciphertext = combined.dropFirst(12).dropLast(16)
        let tag = combined.suffix(16)

        let symmetricKey = SymmetricKey(data: key)
        let sealedBox = try! AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)
        let decryptedData = try! AES.GCM.open(sealedBox, using: symmetricKey)
        return String(data: decryptedData, encoding: .utf8)!
    }
}
