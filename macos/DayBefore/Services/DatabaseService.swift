import Foundation
import SQLite3

class DatabaseService: ObservableObject {
    static let shared = DatabaseService()
    private var db: OpaquePointer?

    @Published var journalEntries: [JournalEntry] = []
    @Published var corePoints: [CorePoint] = []
    @Published var issues: [Issue] = []

    init() {
        openDatabase()
        createTables()
        loadAll()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("DayBefore")

        try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)

        let dbPath = fileURL.appendingPathComponent("daybefore.db").path
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    private func createTables() {
        let tables = [
            """
            CREATE TABLE IF NOT EXISTS journal_entries (
                id TEXT PRIMARY KEY,
                content TEXT,
                createdAt INTEGER,
                updatedAt INTEGER
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS core_points (
                id TEXT PRIMARY KEY,
                name TEXT,
                content TEXT,
                createdAt INTEGER,
                updatedAt INTEGER
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS issues (
                id TEXT PRIMARY KEY,
                name TEXT,
                content TEXT,
                isArchived INTEGER,
                createdAt INTEGER,
                updatedAt INTEGER
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS issue_entries (
                id TEXT PRIMARY KEY,
                issueId TEXT,
                content TEXT,
                createdAt INTEGER,
                updatedAt INTEGER
            )
            """
        ]

        for sql in tables {
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }

    func loadAll() {
        journalEntries = getJournalEntries()
        corePoints = getCorePoints()
        issues = getIssues()
    }

    func getJournalEntries() -> [JournalEntry] {
        var entries: [JournalEntry] = []
        let sql = "SELECT id, content, createdAt, updatedAt FROM journal_entries ORDER BY createdAt DESC"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let content = String(cString: sqlite3_column_text(stmt, 1))
                let createdAt = sqlite3_column_int64(stmt, 2)
                let updatedAt = sqlite3_column_int64(stmt, 3)
                entries.append(JournalEntry(id: id, content: content, createdAt: createdAt, updatedAt: updatedAt))
            }
        }
        sqlite3_finalize(stmt)
        return entries
    }

    func saveJournalEntry(_ entry: JournalEntry) {
        let sql = "INSERT OR REPLACE INTO journal_entries (id, content, createdAt, updatedAt) VALUES (?, ?, ?, ?)"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, entry.id, -1, nil)
            sqlite3_bind_text(stmt, 2, entry.content, -1, nil)
            sqlite3_bind_int64(stmt, 3, entry.createdAt)
            sqlite3_bind_int64(stmt, 4, entry.updatedAt)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }

    func deleteJournalEntry(_ id: String) {
        let sql = "DELETE FROM journal_entries WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, id, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }

    func getCorePoints() -> [CorePoint] {
        var points: [CorePoint] = []
        let sql = "SELECT id, name, content, createdAt, updatedAt FROM core_points ORDER BY createdAt ASC"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let content = String(cString: sqlite3_column_text(stmt, 2))
                let createdAt = sqlite3_column_int64(stmt, 3)
                let updatedAt = sqlite3_column_int64(stmt, 4)
                points.append(CorePoint(id: id, name: name, content: content, createdAt: createdAt, updatedAt: updatedAt))
            }
        }
        sqlite3_finalize(stmt)
        return points
    }

    func saveCorePoint(_ point: CorePoint) {
        let sql = "INSERT OR REPLACE INTO core_points (id, name, content, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?)"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, point.id, -1, nil)
            sqlite3_bind_text(stmt, 2, point.name, -1, nil)
            sqlite3_bind_text(stmt, 3, point.content, -1, nil)
            sqlite3_bind_int64(stmt, 4, point.createdAt)
            sqlite3_bind_int64(stmt, 5, point.updatedAt)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }

    func deleteCorePoint(_ id: String) {
        let sql = "DELETE FROM core_points WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, id, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }

    func getIssues() -> [Issue] {
        var items: [Issue] = []
        let sql = "SELECT id, name, content, isArchived, createdAt, updatedAt FROM issues WHERE isArchived = 0 ORDER BY createdAt ASC"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let contentPtr = sqlite3_column_text(stmt, 2)
                let content = contentPtr != nil ? String(cString: contentPtr!) : nil
                let isArchived = sqlite3_column_int(stmt, 3) != 0
                let createdAt = sqlite3_column_int64(stmt, 4)
                let updatedAt = sqlite3_column_int64(stmt, 5)
                items.append(Issue(id: id, name: name, content: content, isArchived: isArchived, createdAt: createdAt, updatedAt: updatedAt))
            }
        }
        sqlite3_finalize(stmt)
        return items
    }

    func saveIssue(_ issue: Issue) {
        let sql = "INSERT OR REPLACE INTO issues (id, name, content, isArchived, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?)"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, issue.id, -1, nil)
            sqlite3_bind_text(stmt, 2, issue.name, -1, nil)
            if let content = issue.content {
                sqlite3_bind_text(stmt, 3, content, -1, nil)
            } else {
                sqlite3_bind_null(stmt, 3)
            }
            sqlite3_bind_int(stmt, 4, issue.isArchived ? 1 : 0)
            sqlite3_bind_int64(stmt, 5, issue.createdAt)
            sqlite3_bind_int64(stmt, 6, issue.updatedAt)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }

    func deleteIssue(_ id: String) {
        let sql = "DELETE FROM issues WHERE id = ?"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, id, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        loadAll()
    }
}
