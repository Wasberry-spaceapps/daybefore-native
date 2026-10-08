import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AccountRegistry {
  late Database _db;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase('${dir.path}/daybefore_registry.db', version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS accounts (
            account_id TEXT PRIMARY KEY,
            type TEXT NOT NULL CHECK (type IN ('cloud', 'local')),
            email TEXT,
            display_name TEXT,
            created_at INTEGER NOT NULL,
            last_accessed_at INTEGER NOT NULL,
            entry_count INTEGER DEFAULT 0,
            storage_bytes INTEGER DEFAULT 0
          )
        ''');
      }
    );
  }

  Future<String?> getActiveAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('daybefore_active_account');
  }

  Future<void> setActiveAccountId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daybefore_active_account', id);
  }

  Future<String> getOrCreateLocalAccount() async {
    String? current = await getActiveAccountId();
    if (current != null) {
      final acc = await _db.query('accounts', where: 'account_id = ?', whereArgs: [current]);
      if (acc.isNotEmpty) return current;
    }
    
    final id = const Uuid().v4();
    await _db.insert('accounts', {
      'account_id': id,
      'type': 'local',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'last_accessed_at': DateTime.now().millisecondsSinceEpoch,
    });
    await setActiveAccountId(id);
    return id;
  }

  Future<void> recordLogin(String accountId, String? email, String? displayName) async {
    final existing = await _db.query('accounts', where: 'account_id = ?', whereArgs: [accountId]);
    if (existing.isEmpty) {
      await _db.insert('accounts', {
        'account_id': accountId,
        'type': 'cloud',
        'email': email,
        'display_name': displayName,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'last_accessed_at': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await _db.update('accounts', {
        'email': email ?? existing.first['email'],
        'display_name': displayName ?? existing.first['display_name'],
        'last_accessed_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'account_id = ?', whereArgs: [accountId]);
    }
    await setActiveAccountId(accountId);
  }

  Future<void> updateLastAccessed(String accountId) async {
    await _db.update('accounts', {
      'last_accessed_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'account_id = ?', whereArgs: [accountId]);
  }

  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    return await _db.query('accounts', orderBy: 'last_accessed_at DESC');
  }

  Future<void> removeAccount(String accountId) async {
    await _db.delete('accounts', where: 'account_id = ?', whereArgs: [accountId]);
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getString('daybefore_active_account');
    if (active == accountId) {
      await prefs.remove('daybefore_active_account');
    }
  }

  Future<void> updateEntryCount(String accountId, int count) async {
    await _db.update('accounts', {'entry_count': count},
        where: 'account_id = ?', whereArgs: [accountId]);
  }
}

final registry = AccountRegistry();
