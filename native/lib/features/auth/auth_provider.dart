
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../../core/api.dart';
import '../../core/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  String? token;
  SecretKey? encryptionKey;
  bool get isLoggedIn => token != null;

  AuthProvider({required this.api});

  Future<void> login(String email, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final data = await api.login(email, pwHash);
    token = data['token'] as String;
    api.setToken(token!);
    final salt = DayBeforeCrypto.saltFromBase64(data['salt'] as String);
    encryptionKey = await DayBeforeCrypto.deriveKey(password, salt);
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'salt', value: data['salt'] as String);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final salt = DayBeforeCrypto.generateSalt();
    final saltB64 = DayBeforeCrypto.saltToBase64(salt);
    final data = await api.register(email, pwHash, saltB64);
    token = data['token'] as String;
    api.setToken(token!);
    encryptionKey = await DayBeforeCrypto.deriveKey(password, salt);
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'salt', value: data['salt'] as String);
    notifyListeners();
  }

  Future<void> tryRestoreSession(String password) async {
    final storage = const FlutterSecureStorage();
    token = await storage.read(key: 'token');
    final saltB64 = await storage.read(key: 'salt');
    if (token != null && saltB64 != null) {
      api.setToken(token!);
      encryptionKey = await DayBeforeCrypto.deriveKey(
          password, DayBeforeCrypto.saltFromBase64(saltB64));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    encryptionKey = null;
    await const FlutterSecureStorage().deleteAll();
    notifyListeners();
  }

  Future<bool> verifyPassword(String password) async {
    if (encryptionKey == null) return false;
    final storage = const FlutterSecureStorage();
    final saltB64 = await storage.read(key: 'salt');
    if (saltB64 == null) return false;
    final testKey = await DayBeforeCrypto.deriveKey(
        password, DayBeforeCrypto.saltFromBase64(saltB64));
    final currentBytes = await encryptionKey!.extractBytes();
    final testBytes = await testKey.extractBytes();
    return listEquals(currentBytes, testBytes);
  }
}
