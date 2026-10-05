
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class DayBeforeCrypto {
  static final _rng = Random.secure();

  static Future<String> hashPassword(String passphrase) async {
    final sha256 = Sha256();
    final hash = await sha256.hash(utf8.encode(passphrase));
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List generateSalt() =>
      Uint8List.fromList(List.generate(16, (_) => _rng.nextInt(256)));

  static Future<SecretKey> deriveKey(String passphrase, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static Future<String> encryptObject(Map<String, dynamic> obj, SecretKey key) async {
    final aes = AesGcm.with256bits();
    final plaintext = utf8.encode(jsonEncode(obj));
    final secretBox = await aes.encrypt(plaintext, secretKey: key);
    final nonce = secretBox.nonce;
    final ct = secretBox.cipherText;
    final mac = secretBox.mac.bytes;
    final payload = Uint8List(12 + ct.length + 16);
    payload.setAll(0, nonce);
    payload.setAll(12, ct);
    payload.setAll(12 + ct.length, mac);
    return base64Encode(payload);
  }

  static Future<Map<String, dynamic>> decryptObject(String base64Payload, SecretKey key) async {
    final aes = AesGcm.with256bits();
    final payload = base64Decode(base64Payload);
    final nonce = payload.sublist(0, 12);
    final cipherAndTag = payload.sublist(12);
    final cipherText = cipherAndTag.sublist(0, cipherAndTag.length - 16);
    final mac = Mac(cipherAndTag.sublist(cipherAndTag.length - 16));
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final plainBytes = await aes.decrypt(secretBox, secretKey: key);
    return jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
  }

  static String saltToBase64(Uint8List salt) => base64Encode(salt);
  static Uint8List saltFromBase64(String b64) =>
      Uint8List.fromList(base64Decode(b64));
}
