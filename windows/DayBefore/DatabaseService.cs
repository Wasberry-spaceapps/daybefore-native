using System.IO;
using Microsoft.Data.Sqlite;

namespace DayBefore;

public class DatabaseService
{
    private readonly string _connStr;

    public DatabaseService()
    {
        var dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "DayBefore");
        Directory.CreateDirectory(dir);
        _connStr = $"Data Source={Path.Combine(dir, "journal.db")}";
        InitDb();
    }

    private void InitDb()
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = @"
            CREATE TABLE IF NOT EXISTS journal_entries (
                id TEXT PRIMARY KEY,
                content TEXT NOT NULL DEFAULT '',
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS core_points (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL DEFAULT '',
                content TEXT NOT NULL DEFAULT '',
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS issues (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL DEFAULT '',
                content TEXT NOT NULL DEFAULT '',
                is_archived INTEGER NOT NULL DEFAULT 0,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS issue_entries (
                id TEXT PRIMARY KEY,
                issue_id TEXT NOT NULL,
                content TEXT NOT NULL DEFAULT '',
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            );";
        cmd.ExecuteNonQuery();
    }

    // Journal Entries
    public List<JournalEntry> GetJournalEntries()
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, content, created_at, updated_at FROM journal_entries ORDER BY created_at DESC";
        using var r = cmd.ExecuteReader();
        var list = new List<JournalEntry>();
        while (r.Read())
            list.Add(new JournalEntry { Id = r.GetString(0), Content = r.GetString(1), CreatedAt = r.GetInt64(2), UpdatedAt = r.GetInt64(3) });
        return list;
    }

    public JournalEntry? GetJournalEntry(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, content, created_at, updated_at FROM journal_entries WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        using var r = cmd.ExecuteReader();
        return r.Read() ? new JournalEntry { Id = r.GetString(0), Content = r.GetString(1), CreatedAt = r.GetInt64(2), UpdatedAt = r.GetInt64(3) } : null;
    }

    public void SaveJournalEntry(JournalEntry e)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "INSERT INTO journal_entries (id, content, created_at, updated_at) VALUES (@id, @c, @ca, @ua) ON CONFLICT(id) DO UPDATE SET content=@c, updated_at=@ua";
        cmd.Parameters.AddWithValue("@id", e.Id);
        cmd.Parameters.AddWithValue("@c", e.Content);
        cmd.Parameters.AddWithValue("@ca", e.CreatedAt);
        cmd.Parameters.AddWithValue("@ua", e.UpdatedAt);
        cmd.ExecuteNonQuery();
    }

    public void DeleteJournalEntry(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "DELETE FROM journal_entries WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    public List<JournalEntry> GetJournalEntriesUpdatedAfter(long since)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, content, created_at, updated_at FROM journal_entries WHERE updated_at > @since";
        cmd.Parameters.AddWithValue("@since", since);
        using var r = cmd.ExecuteReader();
        var list = new List<JournalEntry>();
        while (r.Read())
            list.Add(new JournalEntry { Id = r.GetString(0), Content = r.GetString(1), CreatedAt = r.GetInt64(2), UpdatedAt = r.GetInt64(3) });
        return list;
    }

    // Core Points
    public List<CorePoint> GetCorePoints()
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, created_at, updated_at FROM core_points ORDER BY created_at ASC";
        using var r = cmd.ExecuteReader();
        var list = new List<CorePoint>();
        while (r.Read())
            list.Add(new CorePoint { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) });
        return list;
    }

    public CorePoint? GetCorePoint(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, created_at, updated_at FROM core_points WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        using var r = cmd.ExecuteReader();
        return r.Read() ? new CorePoint { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) } : null;
    }

    public void SaveCorePoint(CorePoint p)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "INSERT INTO core_points (id, name, content, created_at, updated_at) VALUES (@id, @n, @c, @ca, @ua) ON CONFLICT(id) DO UPDATE SET name=@n, content=@c, updated_at=@ua";
        cmd.Parameters.AddWithValue("@id", p.Id);
        cmd.Parameters.AddWithValue("@n", p.Name);
        cmd.Parameters.AddWithValue("@c", p.Content);
        cmd.Parameters.AddWithValue("@ca", p.CreatedAt);
        cmd.Parameters.AddWithValue("@ua", p.UpdatedAt);
        cmd.ExecuteNonQuery();
    }

    public void DeleteCorePoint(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "DELETE FROM core_points WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    public List<CorePoint> GetCorePointsUpdatedAfter(long since)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, created_at, updated_at FROM core_points WHERE updated_at > @since";
        cmd.Parameters.AddWithValue("@since", since);
        using var r = cmd.ExecuteReader();
        var list = new List<CorePoint>();
        while (r.Read())
            list.Add(new CorePoint { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) });
        return list;
    }

    // Issues
    public List<Issue> GetIssues()
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, is_archived, created_at, updated_at FROM issues ORDER BY created_at ASC";
        using var r = cmd.ExecuteReader();
        var list = new List<Issue>();
        while (r.Read())
            list.Add(new Issue { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), IsArchived = r.GetInt64(3) == 1, CreatedAt = r.GetInt64(4), UpdatedAt = r.GetInt64(5) });
        return list;
    }

    public Issue? GetIssue(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, is_archived, created_at, updated_at FROM issues WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        using var r = cmd.ExecuteReader();
        return r.Read() ? new Issue { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), IsArchived = r.GetInt64(3) == 1, CreatedAt = r.GetInt64(4), UpdatedAt = r.GetInt64(5) } : null;
    }

    public void SaveIssue(Issue i)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "INSERT INTO issues (id, name, content, is_archived, created_at, updated_at) VALUES (@id, @n, @c, @a, @ca, @ua) ON CONFLICT(id) DO UPDATE SET name=@n, content=@c, is_archived=@a, updated_at=@ua";
        cmd.Parameters.AddWithValue("@id", i.Id);
        cmd.Parameters.AddWithValue("@n", i.Name);
        cmd.Parameters.AddWithValue("@c", i.Content ?? "");
        cmd.Parameters.AddWithValue("@a", i.IsArchived ? 1 : 0);
        cmd.Parameters.AddWithValue("@ca", i.CreatedAt);
        cmd.Parameters.AddWithValue("@ua", i.UpdatedAt);
        cmd.ExecuteNonQuery();
    }

    public void DeleteIssue(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "DELETE FROM issues WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    public List<Issue> GetIssuesUpdatedAfter(long since)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, name, content, is_archived, created_at, updated_at FROM issues WHERE updated_at > @since";
        cmd.Parameters.AddWithValue("@since", since);
        using var r = cmd.ExecuteReader();
        var list = new List<Issue>();
        while (r.Read())
            list.Add(new Issue { Id = r.GetString(0), Name = r.GetString(1), Content = r.GetString(2), IsArchived = r.GetInt64(3) == 1, CreatedAt = r.GetInt64(4), UpdatedAt = r.GetInt64(5) });
        return list;
    }

    // Issue Entries
    public List<IssueEntry> GetIssueEntries()
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, issue_id, content, created_at, updated_at FROM issue_entries ORDER BY created_at ASC";
        using var r = cmd.ExecuteReader();
        var list = new List<IssueEntry>();
        while (r.Read())
            list.Add(new IssueEntry { Id = r.GetString(0), IssueId = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) });
        return list;
    }

    public IssueEntry? GetIssueEntry(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, issue_id, content, created_at, updated_at FROM issue_entries WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        using var r = cmd.ExecuteReader();
        return r.Read() ? new IssueEntry { Id = r.GetString(0), IssueId = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) } : null;
    }

    public void SaveIssueEntry(IssueEntry e)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "INSERT INTO issue_entries (id, issue_id, content, created_at, updated_at) VALUES (@id, @iid, @c, @ca, @ua) ON CONFLICT(id) DO UPDATE SET issue_id=@iid, content=@c, updated_at=@ua";
        cmd.Parameters.AddWithValue("@id", e.Id);
        cmd.Parameters.AddWithValue("@iid", e.IssueId);
        cmd.Parameters.AddWithValue("@c", e.Content);
        cmd.Parameters.AddWithValue("@ca", e.CreatedAt);
        cmd.Parameters.AddWithValue("@ua", e.UpdatedAt);
        cmd.ExecuteNonQuery();
    }

    public void DeleteIssueEntry(string id)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "DELETE FROM issue_entries WHERE id = @id";
        cmd.Parameters.AddWithValue("@id", id);
        cmd.ExecuteNonQuery();
    }

    public List<IssueEntry> GetIssueEntriesUpdatedAfter(long since)
    {
        using var conn = new SqliteConnection(_connStr);
        conn.Open();
        using var cmd = conn.CreateCommand();
        cmd.CommandText = "SELECT id, issue_id, content, created_at, updated_at FROM issue_entries WHERE updated_at > @since";
        cmd.Parameters.AddWithValue("@since", since);
        using var r = cmd.ExecuteReader();
        var list = new List<IssueEntry>();
        while (r.Read())
            list.Add(new IssueEntry { Id = r.GetString(0), IssueId = r.GetString(1), Content = r.GetString(2), CreatedAt = r.GetInt64(3), UpdatedAt = r.GetInt64(4) });
        return list;
    }
}
