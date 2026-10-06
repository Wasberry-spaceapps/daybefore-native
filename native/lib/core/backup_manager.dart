import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class BackupInfo {
  final String name;
  final int size;
  final int modified;

  BackupInfo({required this.name, required this.size, required this.modified});

  factory BackupInfo.fromMap(Map<String, dynamic> map) {
    return BackupInfo(
      name: map['name'] as String,
      size: map['size'] as int,
      modified: map['modified'] as int,
    );
  }
}

class BackupManager {
  static const _channel = MethodChannel('com.daybefore.backup');

  final String accountId;
  final Future<Uint8List> Function() exportEncrypted;
  Timer? _periodicTimer;
  bool _dirty = false;

  BackupManager({required this.accountId, required this.exportEncrypted});

  void markDirty() => _dirty = true;

  void start() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (_dirty) writeBackup();
    });
  }

  void stop() => _periodicTimer?.cancel();

  Future<Directory> getDesktopBackupDir() async {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    final backupDir = Directory(p.join(home, 'Documents', 'DayBefore'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<void> writeBackup() async {
    final data = await exportEncrypted();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'DayBefore-backup-$accountId-$timestamp.enc';

    if (Platform.isAndroid) {
      await _channel.invokeMethod('writeBackup', {
        'accountId': accountId,
        'data': data,
        'fileName': fileName,
      });
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final dir = await getDesktopBackupDir();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(data);
    } else if (Platform.isIOS) {
      // Need iCloud path, simplified fallback
      final docs = await getApplicationDocumentsDirectory();
      final file = File(p.join(docs.path, fileName));
      await file.writeAsBytes(data);
    }

    _dirty = false;
    await _cleanOldBackups();
  }

  Future<List<BackupInfo>> listBackups() async {
    if (Platform.isAndroid) {
      final list = await _channel.invokeMethod<List>('listBackups', {'accountId': accountId});
      return (list ?? []).map((m) => BackupInfo.fromMap(Map<String, dynamic>.from(m))).toList();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final dir = await getDesktopBackupDir();
      final files = dir.listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith('DayBefore-backup-$accountId-'))
          .map((f) => BackupInfo(name: p.basename(f.path), size: f.lengthSync(), modified: f.lastModifiedSync()))
          .toList();
      files.sort((a, b) => b.modified.compareTo(a.modified));
      return files;
    }
    return [];
  }

  Future<Uint8List?> readBackup(String fileName) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod<Uint8List>('readBackup', {'fileName': fileName});
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final dir = await getDesktopBackupDir();
      final file = File(p.join(dir.path, fileName));
      if (await file.exists()) return await file.readAsBytes();
      return null;
    }
    return null;
  }

  Future<void> _cleanOldBackups() async {
    final backups = await listBackups();
    for (final old in backups.skip(3)) {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('deleteBackup', {'fileName': old.name});
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final dir = await getDesktopBackupDir();
        final file = File(p.join(dir.path, old.name));
        if (await file.exists()) await file.delete();
      }
    }
  }
}
