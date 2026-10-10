import Foundation

struct LoginResponse: Codable {
    let token: String?
    let salt: String?
    let wrappedKeyPwd: String?
    let error: String?
}

struct AccountInfo: Codable {
    let subscriptionStatus: String?
}

struct PortalResponse: Codable {
    let url: String?
}

struct SyncItem: Codable {
    let record_id: String
    let encrypted_data: String
    let updated_at: Int64

    enum CodingKeys: String, CodingKey {
        case record_id, encrypted_data, updated_at
    }
}

struct SyncResponse: Codable {
    let items: [SyncItem]
}

struct ResetResponse: Codable {
    let wrappedKeyRecovery: String?
    let salt: String?
    let error: String?
}

class ApiService {
    static let shared = ApiService()
    private let baseURL = "https://daybefore-backend.officialmutairu.workers.dev/api"

    func login(email: String, passwordHash: String) async throws -> LoginResponse {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["email": email, "passwordHash": passwordHash])

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func register(email: String, passwordHash: String, salt: String, wrappedKeyPwd: String, wrappedKeyRecovery: String) async throws -> LoginResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": email,
            "passwordHash": passwordHash,
            "salt": salt,
            "wrappedKeyPwd": wrappedKeyPwd,
            "wrappedKeyRecovery": wrappedKeyRecovery
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func getAccountInfo(token: String) async throws -> AccountInfo {
        let url = URL(string: "\(baseURL)/account/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AccountInfo.self, from: data)
    }

    func getPortalUrl(token: String) async throws -> String? {
        let url = URL(string: "\(baseURL)/portal")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PortalResponse.self, from: data)
        return response.url
    }

    func migrateV2(token: String, wrappedKeyPwd: String, wrappedKeyRecovery: String) async throws {
        let url = URL(string: "\(baseURL)/auth/migrate-v2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: String] = ["wrappedKeyPwd": wrappedKeyPwd, "wrappedKeyRecovery": wrappedKeyRecovery]
        request.httpBody = try JSONEncoder().encode(body)

        _ = try await URLSession.shared.data(for: request)
    }

    func fetchSyncItems(token: String, collection: String, since: Int64) async throws -> [SyncItem] {
        let url = URL(string: "\(baseURL)/sync/\(collection)?since=\(since)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SyncResponse.self, from: data)
        return response.items
    }

    func pushSyncItems(token: String, collection: String, items: [SyncItem]) async throws {
        let url = URL(string: "\(baseURL)/sync/\(collection)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(["items": items])

        _ = try await URLSession.shared.data(for: request)
    }
}
