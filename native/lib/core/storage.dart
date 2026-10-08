
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class LocalDb {
  late Database _db;

  Future<void> init(String accountId) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/daybefore_data_$accountId.db';
    _db = await openDatabase(dbPath, version: 1,
        onCreate: (db, v) async {
      await db.execute('''CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE core_points (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE issues (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, content TEXT DEFAULT '',
        isArchived INTEGER DEFAULT 0,
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE issue_entries (
        id TEXT PRIMARY KEY, issueId TEXT NOT NULL, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
    });

    if (!await verifyDatabaseIntegrity(_db)) {
      await _db.close();
      final corruptPath = '${dir.path}/daybefore_data_${accountId}_corrupt_${DateTime.now().millisecondsSinceEpoch}.db';
      await File(dbPath).rename(corruptPath);
      throw Exception('DATABASE_CORRUPT');
    }
  }

  Future<bool> verifyDatabaseIntegrity(Database db) async {
    final result = await db.rawQuery('PRAGMA integrity_check');
    final status = result.first.values.first as String;
    return status == 'ok';
  }

  Future<List<Map<String, dynamic>>> getAll(String table, {String orderBy = 'createdAt DESC'}) async =>
      _db.query(table, orderBy: orderBy);

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final rows = await _db.query(table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsert(String table, Map<String, dynamic> row) async =>
      _db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> upsertIfNewer(String table, Map<String, dynamic> row) async {
    final existing = await getById(table, row['id']);
    if (existing == null || (existing['updatedAt'] ?? 0) < (row['updatedAt'] ?? 0)) {
      await upsert(table, row);
    }
  }

  Future<void> delete(String table, String id) async =>
      _db.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getChangedSince(String table, int since) async =>
      _db.query(table, where: 'updatedAt > ?', whereArgs: [since]);

  Future<Map<String, dynamic>> exportAll() async {
    final journals = await getAll('journal_entries');
    final corePoints = await getAll('core_points');
    final issues = await getAll('issues');
    final issueEntries = await getAll('issue_entries');
    return {
      'version': 1,
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'journalEntries': journals,
      'corePoints': corePoints,
      'issues': issues,
      'issueEntries': issueEntries,
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final tables = {
      'journal_entries': (data['journalEntries'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      'core_points': (data['corePoints'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      'issues': (data['issues'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      'issue_entries': (data['issueEntries'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    };
    await _db.transaction((txn) async {
      for (final entry in tables.entries) {
        for (final row in entry.value) {
          await txn.insert(entry.key, row, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  Future<int> entryCount() async {
    final r = await _db.rawQuery('SELECT COUNT(*) as c FROM journal_entries');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<void> deleteAccount() async {
    await _db.transaction((txn) async {
      for (final t in ['journal_entries', 'core_points', 'issues', 'issue_entries']) {
        await txn.delete(t);
      }
    });
  }
}
