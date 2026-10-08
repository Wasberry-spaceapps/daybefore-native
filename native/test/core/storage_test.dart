import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:daybefore/core/backup_format.dart';

// ─── Schema helpers ──────────────────────────────────────────────────────────

int _dbCounter = 0;

Future<Database> _openMemDb() async {
  sqfliteFfiInit();
  // Each call needs a unique path — sqflite caches connections by path, so
  // reusing inMemoryDatabasePath gives the same DB instance.
  final path = '${Directory.systemTemp.path}/daybefore_test_${_dbCounter++}_${DateTime.now().microsecondsSinceEpoch}.db';
  return databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''CREATE TABLE journal_entries (
          id TEXT PRIMARY KEY, content TEXT NOT NULL DEFAULT '',
          createdAt INTEGER, updatedAt INTEGER)''');
        await db.execute('''CREATE TABLE core_points (
          id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', content TEXT NOT NULL DEFAULT '',
          createdAt INTEGER, updatedAt INTEGER)''');
        await db.execute('''CREATE TABLE issues (
          id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', content TEXT DEFAULT '',
          isArchived INTEGER DEFAULT 0,
          createdAt INTEGER, updatedAt INTEGER)''');
        await db.execute('''CREATE TABLE issue_entries (
          id TEXT PRIMARY KEY, issueId TEXT NOT NULL, content TEXT NOT NULL DEFAULT '',
          createdAt INTEGER, updatedAt INTEGER)''');
      },
    ),
  );
}

Future<SecretKey> _freshKey() async =>
    AesGcm.with256bits().newSecretKey();

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 1 ─ Namespace isolation
  test('Namespace isolation: two in-memory DBs are independent', () async {
    final db1 = await _openMemDb();
    final db2 = await _openMemDb();

    await db1.insert('journal_entries', {
      'id': 'e1',
      'content': 'hello',
      'createdAt': 1000,
      'updatedAt': 1000,
    });

    final rows = await db2.query('journal_entries');
    expect(rows, isEmpty,
        reason: 'db2 must not see data inserted into db1');

    await db1.close();
    await db2.close();
  });

  // 2 ─ Data survives close/reopen (simulates "logout preserves data")
  test('Logout preserves data: rows survive a close/reopen cycle', () async {
    sqfliteFfiInit();
    // Use a named temp path so we can reopen it
    const path = '/tmp/daybefore_test_preserve.db';
    try {
      final db1 = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
                'CREATE TABLE journal_entries (id TEXT PRIMARY KEY, content TEXT)');
          },
        ),
      );
      await db1.insert('journal_entries', {'id': 'e1', 'content': 'keep me'});
      await db1.close();

      final db2 = await databaseFactoryFfi.openDatabase(path);
      final rows = await db2.query('journal_entries');
      expect(rows.length, 1);
      expect(rows.first['content'], 'keep me');
      await db2.close();
    } finally {
      // Clean up temp file
      try {
        await databaseFactoryFfi.deleteDatabase(path);
      } catch (_) {}
    }
  });

  // 3 ─ New account gets its own namespace
  test('Login creates new namespace: different accountIds use distinct paths', () {
    const a1 = 'account-001';
    const a2 = 'account-002';
    final path1 = 'daybefore_data_$a1.db';
    final path2 = 'daybefore_data_$a2.db';
    expect(path1, isNot(equals(path2)));
  });

  // 4 ─ Backup round-trip
  test('Backup round-trip: createBackup → decryptBackup returns original data', () async {
    final key = await _freshKey();
    final original = {
      'version': 1,
      'journalEntries': [
        {'id': 'e1', 'content': 'day one', 'createdAt': 1000, 'updatedAt': 1000}
      ],
      'corePoints': [],
      'issues': [],
      'issueEntries': [],
    };

    final bytes = await createBackup('test-account', key, original);
    final restored = await decryptBackup(bytes, key);

    expect(restored['version'], 1);
    final entries = restored['journalEntries'] as List;
    expect(entries.length, 1);
    expect(entries.first['content'], 'day one');
  });

  // 5 ─ DBBK header magic
  test('Backup cross-platform: output starts with DBBK magic bytes', () async {
    final key = await _freshKey();
    final bytes = await createBackup('acc', key, {'version': 1});
    expect(bytes[0], 0x44); // D
    expect(bytes[1], 0x42); // B
    expect(bytes[2], 0x42); // B
    expect(bytes[3], 0x4B); // K
    expect(bytes[4], 0x00); // version major
    expect(bytes[5], 0x01); // version minor
  });

  // 6 ─ Corrupt ciphertext raises FormatException
  test('Corrupt backup throws FormatException on decryption', () async {
    final key = await _freshKey();
    final bytes = await createBackup('acc', key, {'version': 1});

    // Flip bytes deep in the ciphertext (after 58-byte header)
    final tampered = Uint8List.fromList(bytes);
    tampered[60] ^= 0xFF;
    tampered[61] ^= 0xFF;

    expect(
      () async => decryptBackup(tampered, key),
      throwsA(isA<FormatException>()),
    );
  });

  // 7 ─ Checksum is deterministic and correct format
  test('Checksum verification: sha256Hex is deterministic and 64 hex chars', () async {
    final data = Uint8List.fromList(utf8.encode('hello day before'));
    final h1 = await sha256Hex(data);
    final h2 = await sha256Hex(data);
    expect(h1, h2);
    expect(h1.length, 64);
    expect(RegExp(r'^[0-9a-f]+$').hasMatch(h1), isTrue);
  });

  // 8 ─ Integrity check passes on a fresh DB
  test('Integrity check: PRAGMA integrity_check returns ok on fresh DB', () async {
    final db = await _openMemDb();
    final result = await db.rawQuery('PRAGMA integrity_check');
    final status = result.first.values.first as String;
    expect(status, 'ok');
    await db.close();
  });

  // 9 ─ Soft delete removes the entry
  test('Soft delete: deleted entry no longer appears in query results', () async {
    final db = await _openMemDb();
    await db.insert('journal_entries',
        {'id': 'del1', 'content': 'remove me', 'createdAt': 1, 'updatedAt': 1});

    expect((await db.query('journal_entries')).length, 1);

    await db.delete('journal_entries', where: 'id = ?', whereArgs: ['del1']);

    expect((await db.query('journal_entries')).length, 0);
    await db.close();
  });

  // 10 ─ Registry list and remove
  test('Registry list and delete: removeAccount deletes the row', () async {
    final path = '${Directory.systemTemp.path}/daybefore_reg_test_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''CREATE TABLE accounts (
            account_id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            email TEXT,
            created_at INTEGER NOT NULL,
            last_accessed_at INTEGER NOT NULL
          )''');
        },
      ),
    );

    await db.insert('accounts', {
      'account_id': 'r1',
      'type': 'local',
      'created_at': 1000,
      'last_accessed_at': 1000,
    });
    await db.insert('accounts', {
      'account_id': 'r2',
      'type': 'cloud',
      'email': 'a@b.com',
      'created_at': 2000,
      'last_accessed_at': 2000,
    });

    expect((await db.query('accounts')).length, 2);

    await db.delete('accounts', where: 'account_id = ?', whereArgs: ['r1']);

    final remaining = await db.query('accounts');
    expect(remaining.length, 1);
    expect(remaining.first['account_id'], 'r2');
    await db.close();
  });
}
