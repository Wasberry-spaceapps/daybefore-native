using System.IO;
using System.Text.Json;

namespace DayBefore;

public class AppSettings
{
    public string? Token { get; set; }
    public string? Salt { get; set; }
    public string? WrappedKeyPwd { get; set; }
    public string? Email { get; set; }
    public long LastSync { get; set; }
}

public static class SettingsService
{
    private static readonly string _dir = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "DayBefore");
    private static readonly string _path = Path.Combine(_dir, "settings.json");
    private static AppSettings? _cache;

    public static AppSettings Load()
    {
        if (_cache != null) return _cache;
        Directory.CreateDirectory(_dir);
        if (!File.Exists(_path))
        {
            _cache = new AppSettings();
            return _cache;
        }
        var json = File.ReadAllText(_path);
        _cache = JsonSerializer.Deserialize<AppSettings>(json) ?? new AppSettings();
        return _cache;
    }

    public static void Save(AppSettings settings)
    {
        _cache = settings;
        Directory.CreateDirectory(_dir);
        var json = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(_path, json);
    }

    public static void Clear()
    {
        _cache = new AppSettings();
        if (File.Exists(_path)) File.Delete(_path);
    }
}
