import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'backup_format.dart' show sha256Hex;

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

class BackupManager extends ChangeNotifier {
  static const _channel = MethodChannel('com.daybefore.backup');

  final String accountId;
  final Future<Uint8List> Function() exportEncrypted;
  Timer? _periodicTimer;
  bool _dirty = false;
  int _lastBackupTime = 0;
  bool _isBackingUp = false;

  int get lastBackupTime => _lastBackupTime;
  bool get isBackingUp => _isBackingUp;
  bool get hasBackup => _lastBackupTime > 0;

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
    _isBackingUp = true;
    notifyListeners();
    try {
      final data = await exportEncrypted();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'DayBefore-backup-$accountId-$timestamp.enc';
      final checksumFileName = '$fileName.sha256';
      final checksum = await sha256Hex(data);
      final checksumContent = Uint8List.fromList('$checksum  $fileName'.codeUnits);

      if (Platform.isAndroid) {
        await _channel.invokeMethod('writeBackup', {
          'accountId': accountId,
          'data': data,
          'fileName': fileName,
        });
        await _channel.invokeMethod('writeBackup', {
          'accountId': accountId,
          'data': checksumContent,
          'fileName': checksumFileName,
        });
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final dir = await getDesktopBackupDir();
        await File(p.join(dir.path, fileName)).writeAsBytes(data);
        await File(p.join(dir.path, checksumFileName)).writeAsBytes(checksumContent);
      } else if (Platform.isIOS) {
        final docs = await getApplicationDocumentsDirectory();
        await File(p.join(docs.path, fileName)).writeAsBytes(data);
        await File(p.join(docs.path, checksumFileName)).writeAsBytes(checksumContent);
      }

      _dirty = false;
      _lastBackupTime = timestamp;
      await _cleanOldBackups();
    } catch (_) {
      // Non-fatal — backup failure does not interrupt the user
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  Future<List<BackupInfo>> listBackups() async {
    if (Platform.isAndroid) {
      final list = await _channel.invokeMethod<List>('listBackups', {'accountId': accountId});
      return (list ?? []).map((m) => BackupInfo.fromMap(Map<String, dynamic>.from(m))).toList();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final dir = await getDesktopBackupDir();
      final files = dir.listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith('DayBefore-backup-$accountId-') && f.path.endsWith('.enc'))
          .map((f) => BackupInfo(
                name: p.basename(f.path),
                size: f.lengthSync(),
                modified: f.lastModifiedSync().millisecondsSinceEpoch,
              ))
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

  Future<void> deleteBackup(String fileName) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('deleteBackup', {'fileName': fileName});
      try { await _channel.invokeMethod('deleteBackup', {'fileName': '$fileName.sha256'}); } catch (_) {}
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final dir = await getDesktopBackupDir();
      final f = File(p.join(dir.path, fileName));
      if (await f.exists()) await f.delete();
      final sha = File(p.join(dir.path, '$fileName.sha256'));
      if (await sha.exists()) await sha.delete();
    }
  }

  Future<void> _cleanOldBackups() async {
    final backups = await listBackups();
    for (final old in backups.skip(3)) {
      await deleteBackup(old.name);
    }
  }
}
