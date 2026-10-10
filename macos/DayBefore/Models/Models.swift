import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: String
    var content: String
    var createdAt: Int64
    var updatedAt: Int64

    init(id: String = UUID().uuidString, content: String = "", createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000), updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var displayDate: String {
        let date = Date(timeIntervalSince1970: Double(createdAt) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HHmm"
        return formatter.string(from: date)
    }

    var snippet: String {
        let text = String(content.prefix(30))
        return text.isEmpty ? "..." : text
    }
}

struct CorePoint: Identifiable, Codable {
    let id: String
    var name: String
    var content: String
    var createdAt: Int64
    var updatedAt: Int64

    init(id: String = UUID().uuidString, name: String = "", content: String = "", createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000), updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)) {
        self.id = id
        self.name = name
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var snippet: String {
        let text = String(content.prefix(30))
        return text.isEmpty ? "..." : text
    }
}

struct Issue: Identifiable, Codable {
    let id: String
    var name: String
    var content: String?
    var isArchived: Bool
    var createdAt: Int64
    var updatedAt: Int64

    init(id: String = UUID().uuidString, name: String = "", content: String? = nil, isArchived: Bool = false, createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000), updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)) {
        self.id = id
        self.name = name
        self.content = content
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var snippet: String {
        let text = String((content ?? "").prefix(30))
        return text.isEmpty ? "..." : text
    }
}

struct IssueEntry: Identifiable, Codable {
    let id: String
    var issueId: String
    var content: String
    var createdAt: Int64
    var updatedAt: Int64

    init(id: String = UUID().uuidString, issueId: String = "", content: String = "", createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000), updatedAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)) {
        self.id = id
        self.issueId = issueId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
