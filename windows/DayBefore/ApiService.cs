using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace DayBefore;

public class LoginResponse
{
    [JsonPropertyName("token")] public string Token { get; set; } = "";
    [JsonPropertyName("salt")] public string? Salt { get; set; }
    [JsonPropertyName("wrappedKeyPwd")] public string? WrappedKeyPwd { get; set; }
    [JsonPropertyName("error")] public string? Error { get; set; }
}

public class AccountInfo
{
    [JsonPropertyName("subscriptionStatus")] public string? SubscriptionStatus { get; set; }
}

public class PortalResponse
{
    [JsonPropertyName("url")] public string? Url { get; set; }
}

public class SyncResponse
{
    [JsonPropertyName("items")] public List<SyncItem> Items { get; set; } = [];
}

public class SyncItem
{
    [JsonPropertyName("record_id")] public string RecordId { get; set; } = "";
    [JsonPropertyName("encrypted_data")] public string EncryptedData { get; set; } = "";
    [JsonPropertyName("updated_at")] public long UpdatedAt { get; set; }
}

public class ResetPasswordResponse
{
    [JsonPropertyName("wrappedKeyRecovery")] public string? WrappedKeyRecovery { get; set; }
    [JsonPropertyName("salt")] public string? Salt { get; set; }
    [JsonPropertyName("error")] public string? Error { get; set; }
}

public static class ApiService
{
    private const string ApiUrl = "https://daybefore-backend.officialmutairu.workers.dev/api";
    private static readonly HttpClient _http = new();

    public static async Task<LoginResponse> Login(string email, string passwordHash)
    {
        var body = JsonSerializer.Serialize(new { email, passwordHash });
        var res = await _http.PostAsync($"{ApiUrl}/auth/login",
            new StringContent(body, Encoding.UTF8, "application/json"));
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<LoginResponse>(json) ?? new LoginResponse();
        if (!res.IsSuccessStatusCode && string.IsNullOrEmpty(data.Error))
            data.Error = $"HTTP {(int)res.StatusCode}";
        return data;
    }

    public static async Task<LoginResponse> Register(string email, string passwordHash, string salt, string wrappedKeyPwd, string wrappedKeyRecovery)
    {
        var body = JsonSerializer.Serialize(new { email, passwordHash, salt, wrappedKeyPwd, wrappedKeyRecovery });
        var res = await _http.PostAsync($"{ApiUrl}/auth/register",
            new StringContent(body, Encoding.UTF8, "application/json"));
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<LoginResponse>(json) ?? new LoginResponse();
        if (!res.IsSuccessStatusCode && string.IsNullOrEmpty(data.Error))
            data.Error = $"HTTP {(int)res.StatusCode}";
        return data;
    }

    public static async Task<AccountInfo?> GetAccountInfo(string token)
    {
        var req = new HttpRequestMessage(HttpMethod.Get, $"{ApiUrl}/account/me");
        req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var res = await _http.SendAsync(req);
        if (!res.IsSuccessStatusCode) return null;
        var json = await res.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<AccountInfo>(json);
    }

    public static async Task<string?> GetPortalUrl(string token)
    {
        var req = new HttpRequestMessage(HttpMethod.Post, $"{ApiUrl}/portal");
        req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var res = await _http.SendAsync(req);
        if (!res.IsSuccessStatusCode) return null;
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<PortalResponse>(json);
        return data?.Url;
    }

    public static async Task<List<SyncItem>> FetchSyncItems(string token, string collection, long since)
    {
        var req = new HttpRequestMessage(HttpMethod.Get, $"{ApiUrl}/sync/{collection}?since={since}");
        req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var res = await _http.SendAsync(req);
        if (!res.IsSuccessStatusCode) return [];
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<SyncResponse>(json);
        return data?.Items ?? [];
    }

    public static async Task<bool> PushSyncItems(string token, string collection, List<SyncItem> items)
    {
        var body = JsonSerializer.Serialize(new { items });
        var req = new HttpRequestMessage(HttpMethod.Post, $"{ApiUrl}/sync/{collection}")
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json")
        };
        req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var res = await _http.SendAsync(req);
        return res.IsSuccessStatusCode;
    }

    public static async Task<ResetPasswordResponse> ResetPassword(string email, string recoveryKey)
    {
        var body = JsonSerializer.Serialize(new { email = email.Trim().ToLower(), recoveryKey = recoveryKey.Trim() });
        var res = await _http.PostAsync($"{ApiUrl}/auth/reset-password",
            new StringContent(body, Encoding.UTF8, "application/json"));
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<ResetPasswordResponse>(json) ?? new ResetPasswordResponse();
        if (!res.IsSuccessStatusCode && string.IsNullOrEmpty(data.Error))
            data.Error = $"HTTP {(int)res.StatusCode}";
        return data;
    }

    public static async Task<string?> UpdatePassword(string email, string newPasswordHash, string salt, string wrappedKeyPwd, string wrappedKeyRecovery)
    {
        var body = JsonSerializer.Serialize(new { email, passwordHash = newPasswordHash, salt, wrappedKeyPwd, wrappedKeyRecovery });
        var res = await _http.PostAsync($"{ApiUrl}/auth/update-password",
            new StringContent(body, Encoding.UTF8, "application/json"));
        if (res.IsSuccessStatusCode) return null;
        var json = await res.Content.ReadAsStringAsync();
        var data = JsonSerializer.Deserialize<ResetPasswordResponse>(json);
        return data?.Error ?? $"HTTP {(int)res.StatusCode}";
    }

    public static async Task MigrateV2(string token, string wrappedKeyPwd, string wrappedKeyRecovery)
    {
        var body = JsonSerializer.Serialize(new { wrappedKeyPwd, wrappedKeyRecovery });
        var req = new HttpRequestMessage(HttpMethod.Post, $"{ApiUrl}/auth/migrate-v2")
        {
            Content = new StringContent(body, Encoding.UTF8, "application/json")
        };
        req.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        await _http.SendAsync(req);
    }
}
