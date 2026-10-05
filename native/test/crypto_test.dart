
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/core/crypto.dart';

void main() {
  test('hashPassword matches web SHA-256 hex', () async {
    final hash = await DayBeforeCrypto.hashPassword('test');
    expect(hash, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08');
  });

  test('encrypt then decrypt round-trip', () async {
    final salt = Uint8List.fromList(List.generate(16, (i) => i));
    final key = await DayBeforeCrypto.deriveKey('mypassphrase', salt);
    final original = {'id': 'abc', 'content': 'hello world', 'createdAt': 1234, 'updatedAt': 5678};
    final encrypted = await DayBeforeCrypto.encryptObject(original, key);
    final decrypted = await DayBeforeCrypto.decryptObject(encrypted, key);
    expect(decrypted['content'], 'hello world');
    expect(decrypted['id'], 'abc');
  });

  // Generated via node crypto API simulating Web Crypto AES-GCM
  test('decrypts web-encrypted fixture', () async {
    const webEncrypted = 'AAECAwQFBgcICQoLllMNmmG4Au1HwrigQ6Pr1lCvepJfyovZkmzGj9ki6Ijw8gJIgaVIe59ONDf/rqgxsOGjZr8KMgIWoDnxUeC2Gg1Zuhx76RMdKPdiWtW9e9mXoR2kVw=='; 
    final salt = Uint8List.fromList(List.generate(16, (i) => i));
    final key = await DayBeforeCrypto.deriveKey('testpass', salt);
    final decrypted = await DayBeforeCrypto.decryptObject(webEncrypted, key);
    expect(decrypted['content'], 'cross-platform');
  });
}
