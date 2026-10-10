using System.Text.Json;

namespace DayBefore;

public static class SyncService
{
    private static readonly string[] Collections = ["journalEntries", "corePoints", "issues", "issueEntries"];

    public static async Task SyncAll(string token, byte[] dataKey, DatabaseService db)
    {
        var settings = SettingsService.Load();
        var lastSync = settings.LastSync;
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        foreach (var collection in Collections)
        {
            try
            {
                var remoteItems = await ApiService.FetchSyncItems(token, collection, lastSync);

                foreach (var item in remoteItems)
                {
                    try
                    {
                        var json = CryptoService.DecryptData(item.EncryptedData, dataKey);
                        MergeRemoteItem(collection, item.RecordId, item.UpdatedAt, json, db);
                    }
                    catch { }
                }

                var localItems = GetLocalItemsUpdatedAfter(collection, lastSync, db);
                if (localItems.Count > 0)
                {
                    var pushItems = new List<SyncItem>();
                    foreach (var (id, updatedAt, obj) in localItems)
                    {
                        var encrypted = CryptoService.EncryptData(obj, dataKey);
                        pushItems.Add(new SyncItem { RecordId = id, EncryptedData = encrypted, UpdatedAt = updatedAt });
                    }
                    await ApiService.PushSyncItems(token, collection, pushItems);
                }
            }
            catch { }
        }

        settings.LastSync = now;
        SettingsService.Save(settings);
    }

    private static void MergeRemoteItem(string collection, string recordId, long remoteUpdatedAt, string json, DatabaseService db)
    {
        switch (collection)
        {
            case "journalEntries":
                var je = JsonSerializer.Deserialize<SyncJournalEntry>(json);
                if (je == null) return;
                var existingJe = db.GetJournalEntry(recordId);
                if (existingJe == null || existingJe.UpdatedAt < remoteUpdatedAt)
                    db.SaveJournalEntry(new JournalEntry { Id = recordId, Content = je.content ?? "", CreatedAt = je.createdAt, UpdatedAt = remoteUpdatedAt });
                break;

            case "corePoints":
                var cp = JsonSerializer.Deserialize<SyncCorePoint>(json);
                if (cp == null) return;
                var existingCp = db.GetCorePoint(recordId);
                if (existingCp == null || existingCp.UpdatedAt < remoteUpdatedAt)
                    db.SaveCorePoint(new CorePoint { Id = recordId, Name = cp.name ?? "", Content = cp.content ?? "", CreatedAt = cp.createdAt, UpdatedAt = remoteUpdatedAt });
                break;

            case "issues":
                var iss = JsonSerializer.Deserialize<SyncIssue>(json);
                if (iss == null) return;
                var existingIss = db.GetIssue(recordId);
                if (existingIss == null || existingIss.UpdatedAt < remoteUpdatedAt)
                    db.SaveIssue(new Issue { Id = recordId, Name = iss.name ?? "", Content = iss.content ?? "", IsArchived = iss.isArchived, CreatedAt = iss.createdAt, UpdatedAt = remoteUpdatedAt });
                break;

            case "issueEntries":
                var ie = JsonSerializer.Deserialize<SyncIssueEntry>(json);
                if (ie == null) return;
                var existingIe = db.GetIssueEntry(recordId);
                if (existingIe == null || existingIe.UpdatedAt < remoteUpdatedAt)
                    db.SaveIssueEntry(new IssueEntry { Id = recordId, IssueId = ie.issueId ?? "", Content = ie.content ?? "", CreatedAt = ie.createdAt, UpdatedAt = remoteUpdatedAt });
                break;
        }
    }

    private static List<(string Id, long UpdatedAt, string Json)> GetLocalItemsUpdatedAfter(string collection, long since, DatabaseService db)
    {
        var result = new List<(string, long, string)>();
        switch (collection)
        {
            case "journalEntries":
                foreach (var e in db.GetJournalEntriesUpdatedAfter(since))
                    result.Add((e.Id, e.UpdatedAt, JsonSerializer.Serialize(new { id = e.Id, content = e.Content, createdAt = e.CreatedAt, updatedAt = e.UpdatedAt })));
                break;
            case "corePoints":
                foreach (var e in db.GetCorePointsUpdatedAfter(since))
                    result.Add((e.Id, e.UpdatedAt, JsonSerializer.Serialize(new { id = e.Id, name = e.Name, content = e.Content, createdAt = e.CreatedAt, updatedAt = e.UpdatedAt })));
                break;
            case "issues":
                foreach (var e in db.GetIssuesUpdatedAfter(since))
                    result.Add((e.Id, e.UpdatedAt, JsonSerializer.Serialize(new { id = e.Id, name = e.Name, content = e.Content, isArchived = e.IsArchived, createdAt = e.CreatedAt, updatedAt = e.UpdatedAt })));
                break;
            case "issueEntries":
                foreach (var e in db.GetIssueEntriesUpdatedAfter(since))
                    result.Add((e.Id, e.UpdatedAt, JsonSerializer.Serialize(new { id = e.Id, issueId = e.IssueId, content = e.Content, createdAt = e.CreatedAt, updatedAt = e.UpdatedAt })));
                break;
        }
        return result;
    }
}

file record SyncJournalEntry(string? id, string? content, long createdAt, long updatedAt);
file record SyncCorePoint(string? id, string? name, string? content, long createdAt, long updatedAt);
file record SyncIssue(string? id, string? name, string? content, bool isArchived, long createdAt, long updatedAt);
file record SyncIssueEntry(string? id, string? issueId, string? content, long createdAt, long updatedAt);
