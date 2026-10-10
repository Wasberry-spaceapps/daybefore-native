using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace DayBefore;

public static class CryptoService
{
    private const int Iterations = 100000;
    private const int KeySize = 32;
    private const int IvSize = 12;
    private const int TagSize = 16;

    public static string HashPassword(string password)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(password));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    public static byte[] GenerateSalt() => RandomNumberGenerator.GetBytes(16);

    public static byte[] DeriveKey(string password, byte[] salt)
    {
        using var pbkdf2 = new Rfc2898DeriveBytes(
            Encoding.UTF8.GetBytes(password),
            salt,
            Iterations,
            HashAlgorithmName.SHA256);
        return pbkdf2.GetBytes(KeySize);
    }

    public static byte[] GenerateDataKey() => RandomNumberGenerator.GetBytes(KeySize);

    public static string GenerateRecoveryKey()
    {
        var bytes = RandomNumberGenerator.GetBytes(16);
        var hex = Convert.ToHexString(bytes).ToLowerInvariant();
        return string.Join("-", Enumerable.Range(0, 8).Select(i => hex.Substring(i * 4, 4)));
    }

    public static byte[] DeriveRecoveryKey(string recoveryKeyStr)
    {
        var hex = recoveryKeyStr.Replace("-", "");
        var bytes = new byte[hex.Length / 2];
        for (int i = 0; i < bytes.Length; i++)
            bytes[i] = Convert.ToByte(hex.Substring(i * 2, 2), 16);
        return bytes;
    }

    public static string WrapDataKey(byte[] dataKey, byte[] wrappingKey)
    {
        var iv = RandomNumberGenerator.GetBytes(IvSize);
        var ciphertext = new byte[dataKey.Length];
        var tag = new byte[TagSize];

        using var aes = new AesGcm(wrappingKey, TagSize);
        aes.Encrypt(iv, dataKey, ciphertext, tag);

        var payload = new byte[IvSize + ciphertext.Length + TagSize];
        Buffer.BlockCopy(iv, 0, payload, 0, IvSize);
        Buffer.BlockCopy(ciphertext, 0, payload, IvSize, ciphertext.Length);
        Buffer.BlockCopy(tag, 0, payload, IvSize + ciphertext.Length, TagSize);

        return Convert.ToBase64String(payload);
    }

    public static byte[] UnwrapDataKey(string wrappedB64, byte[] unwrappingKey)
    {
        var payload = Convert.FromBase64String(wrappedB64);
        var iv = payload[..IvSize];
        var tag = payload[^TagSize..];
        var ciphertext = payload[IvSize..^TagSize];
        var plaintext = new byte[ciphertext.Length];

        using var aes = new AesGcm(unwrappingKey, TagSize);
        aes.Decrypt(iv, ciphertext, tag, plaintext);
        return plaintext;
    }

    public static string EncryptData(string plaintext, byte[] key)
    {
        var iv = RandomNumberGenerator.GetBytes(IvSize);
        var plaintextBytes = Encoding.UTF8.GetBytes(plaintext);
        var ciphertext = new byte[plaintextBytes.Length];
        var tag = new byte[TagSize];

        using var aes = new AesGcm(key, TagSize);
        aes.Encrypt(iv, plaintextBytes, ciphertext, tag);

        var payload = new byte[IvSize + ciphertext.Length + TagSize];
        Buffer.BlockCopy(iv, 0, payload, 0, IvSize);
        Buffer.BlockCopy(ciphertext, 0, payload, IvSize, ciphertext.Length);
        Buffer.BlockCopy(tag, 0, payload, IvSize + ciphertext.Length, TagSize);

        return Convert.ToBase64String(payload);
    }

    public static string DecryptData(string ciphertextB64, byte[] key)
    {
        var payload = Convert.FromBase64String(ciphertextB64);
        var iv = payload[..IvSize];
        var tag = payload[^TagSize..];
        var ciphertext = payload[IvSize..^TagSize];
        var plaintext = new byte[ciphertext.Length];

        using var aes = new AesGcm(key, TagSize);
        aes.Decrypt(iv, ciphertext, tag, plaintext);
        return Encoding.UTF8.GetString(plaintext);
    }

    public static string EncryptObject(object obj, byte[] key)
    {
        var json = JsonSerializer.Serialize(obj);
        return EncryptData(json, key);
    }

    public static T? DecryptObject<T>(string ciphertext, byte[] key)
    {
        var json = DecryptData(ciphertext, key);
        return JsonSerializer.Deserialize<T>(json);
    }
}
