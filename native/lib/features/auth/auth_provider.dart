
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../../core/api.dart';
import '../../core/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  String? token;
  String? email;
  SecretKey? encryptionKey;
  bool get isLoggedIn => token != null;

  static const _storage = FlutterSecureStorage();

  AuthProvider({required this.api});

  /// Login. Returns a recovery key string if V1→V2 migration happened, null otherwise.
  Future<String?> login(String emailAddr, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final data = await api.login(emailAddr, pwHash);
    token = data['token'] as String;
    api.setToken(token!);
    email = emailAddr;

    final saltB64 = data['salt'] as String;
    final salt = DayBeforeCrypto.saltFromBase64(saltB64);
    final pwdKey = await DayBeforeCrypto.deriveKey(password, salt);

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'salt', value: saltB64);
    await _storage.write(key: 'email', value: emailAddr);

    if (data['wrappedKeyPwd'] != null) {
      // V2 Login
      final wrappedKeyPwd = data['wrappedKeyPwd'] as String;
      await _storage.write(key: 'wrappedKeyPwd', value: wrappedKeyPwd);
      encryptionKey = await DayBeforeCrypto.unwrapDataKey(wrappedKeyPwd, pwdKey);
      notifyListeners();
      return null;
    } else {
      // V1 Legacy Login + Migrate
      encryptionKey = pwdKey;
      final recoveryKey = DayBeforeCrypto.generateRecoveryKey();
      final recKeyObj = await DayBeforeCrypto.deriveRecoveryKey(recoveryKey);
      final wrappedKeyPwd = await DayBeforeCrypto.wrapDataKey(pwdKey, pwdKey);
      final wrappedKeyRecovery = await DayBeforeCrypto.wrapDataKey(pwdKey, recKeyObj);
      await _storage.write(key: 'wrappedKeyPwd', value: wrappedKeyPwd);
      try {
        await api.migrateV2(wrappedKeyPwd, wrappedKeyRecovery);
      } catch (_) {
        // Migration failed silently; wrappedKeyPwd is saved locally for lock unlock
      }
      notifyListeners();
      return recoveryKey;
    }
  }

  /// Register. Returns the recovery key the user must save.
  Future<String> register(String emailAddr, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final salt = DayBeforeCrypto.generateSalt();
    final saltB64 = DayBeforeCrypto.saltToBase64(salt);
    final pwdKey = await DayBeforeCrypto.deriveKey(password, salt);
    final dataKey = await DayBeforeCrypto.generateDataKey();
    final recoveryKey = DayBeforeCrypto.generateRecoveryKey();
    final recKeyObj = await DayBeforeCrypto.deriveRecoveryKey(recoveryKey);
    final wrappedKeyPwd = await DayBeforeCrypto.wrapDataKey(dataKey, pwdKey);
    final wrappedKeyRecovery = await DayBeforeCrypto.wrapDataKey(dataKey, recKeyObj);

    final data = await api.register(emailAddr, pwHash, saltB64,
        wrappedKeyPwd: wrappedKeyPwd, wrappedKeyRecovery: wrappedKeyRecovery);
    token = data['token'] as String;
    api.setToken(token!);
    email = emailAddr;
    encryptionKey = dataKey;

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'salt', value: saltB64);
    await _storage.write(key: 'email', value: emailAddr);
    await _storage.write(key: 'wrappedKeyPwd', value: wrappedKeyPwd);

    notifyListeners();
    return recoveryKey;
  }

  /// Unlock the key after the lock screen. Throws if password is wrong.
  Future<void> unlock(String password) async {
    final saltB64 = await _storage.read(key: 'salt');
    final wrappedKeyPwd = await _storage.read(key: 'wrappedKeyPwd');
    if (saltB64 == null || wrappedKeyPwd == null) throw Exception('No session data found.');
    final salt = DayBeforeCrypto.saltFromBase64(saltB64);
    final pwdKey = await DayBeforeCrypto.deriveKey(password, salt);
    encryptionKey = await DayBeforeCrypto.unwrapDataKey(wrappedKeyPwd, pwdKey);
    notifyListeners();
  }

  /// Restore token on cold start. Key is null until user unlocks.
  Future<void> tryRestoreSession() async {
    token = await _storage.read(key: 'token');
    email = await _storage.read(key: 'email');
    if (token != null) api.setToken(token!);
    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    email = null;
    encryptionKey = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
