import 'dart:io';
import 'dart:typed_data';
import 'backup_manager.dart';

class FoundBackup {
  final String source;
  final String name;
  final int size;
  final int date;

  FoundBackup({required this.source, required this.name, required this.size, required this.date});
}

class BackupScanner {
  static Future<List<FoundBackup>> scan(String accountId, String dbPath) async {
    final found = <FoundBackup>[];
    
    if (File(dbPath).existsSync()) return []; 
    
    final backupManager = BackupManager(accountId: accountId, exportEncrypted: () async => Uint8List(0));
    final localBackups = await backupManager.listBackups();
    for (final b in localBackups) {
      found.add(FoundBackup(source: 'device', name: b.name, size: b.size, date: b.modified));
    }
    
    found.sort((a, b) => b.date.compareTo(a.date));
    return found;
  }
}
