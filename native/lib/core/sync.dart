
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'crypto.dart';
import 'storage.dart';
import 'package:cryptography/cryptography.dart';

class SyncEngine {
  final ApiClient api;
  final LocalDb db;
  final SecretKey encryptionKey;

  SyncEngine({required this.api, required this.db, required this.encryptionKey});

  static const _collections = {
    'journalEntries': 'journal_entries',
    'corePoints': 'core_points',
    'issues': 'issues',
    'issueEntries': 'issue_entries',
  };

  Future<bool> sync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt('daybefore_lastSync') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    bool success = true;

    for (final entry in _collections.entries) {
      final apiName = entry.key;
      final tableName = entry.value;

      try {
        final remoteItems = await api.pullSync(apiName, lastSync);
        for (final item in remoteItems) {
          final decrypted = await DayBeforeCrypto.decryptObject(
              item['encrypted_data'] as String, encryptionKey);
          decrypted['id'] = item['record_id'];
          decrypted['updatedAt'] = item['updated_at'];
          await db.upsertIfNewer(tableName, decrypted);
        }
      } on SubscriptionRequired {
        return false;
      } catch (e) {
        success = false;
      }

      try {
        final localChanges = await db.getChangedSince(tableName, lastSync);
        if (localChanges.isNotEmpty) {
          final pushItems = await Future.wait(localChanges.map((record) async {
            final encrypted = await DayBeforeCrypto.encryptObject(record, encryptionKey);
            return {
              'record_id': record['id'],
              'encrypted_data': encrypted,
              'updated_at': record['updatedAt'],
            };
          }));
          await api.pushSync(apiName, pushItems);
        }
      } on SubscriptionRequired {
        return false;
      } catch (e) {
        success = false;
      }
    }
    
    if (success) {
      await prefs.setInt('daybefore_lastSync', now);
    }
    return true;
  }
}
