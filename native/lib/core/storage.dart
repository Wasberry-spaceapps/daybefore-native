
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class LocalDb {
  late Database _db;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase('${dir.path}/daybefore.db', version: 1,
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
}
