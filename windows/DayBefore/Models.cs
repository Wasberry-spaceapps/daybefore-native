namespace DayBefore;

public record JournalEntry
{
    public string Id { get; init; } = "";
    public string Content { get; init; } = "";
    public long CreatedAt { get; init; }
    public long UpdatedAt { get; init; }

    public string DisplayDate
    {
        get
        {
            var d = DateTimeOffset.FromUnixTimeMilliseconds(CreatedAt).LocalDateTime;
            return $"{d:yyyy-MM-dd HHmm}";
        }
    }

    public string Snippet => Content.Length > 30 ? Content[..30] : Content.Length > 0 ? Content : "...";
}

public record CorePoint
{
    public string Id { get; init; } = "";
    public string Name { get; init; } = "";
    public string Content { get; init; } = "";
    public long CreatedAt { get; init; }
    public long UpdatedAt { get; init; }

    public string Snippet => Content.Length > 30 ? Content[..30] : Content.Length > 0 ? Content : "...";
}

public record Issue
{
    public string Id { get; init; } = "";
    public string Name { get; init; } = "";
    public string Content { get; init; } = "";
    public bool IsArchived { get; init; }
    public long CreatedAt { get; init; }
    public long UpdatedAt { get; init; }

    public string Snippet => (Content ?? "").Length > 30 ? Content![..30] : (Content ?? "").Length > 0 ? Content! : "...";
}

public record IssueEntry
{
    public string Id { get; init; } = "";
    public string IssueId { get; init; } = "";
    public string Content { get; init; } = "";
    public long CreatedAt { get; init; }
    public long UpdatedAt { get; init; }
}
