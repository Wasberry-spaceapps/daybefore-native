import 'dart:convert';
import 'dart:typed_data';
import '../../models/journal_entry.dart';
import '../../models/issue.dart';
import '../../models/core_point.dart';

class JsonExport {
  static Uint8List generate({
    required List<JournalEntry> entries,
    required List<Issue> issues,
    required List<CorePoint> corePoints,
    required bool includeJournal,
    required bool includeIssues,
    required bool includeCorePoints,
  }) {
    final data = <String, dynamic>{
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'Day Before',
      'version': '1.0.0',
    };
    
    if (includeJournal) data['journal'] = entries.map((e) => e.toJson()).toList();
    if (includeIssues) data['issues'] = issues.map((i) => i.toJson()).toList();
    if (includeCorePoints) data['core_points'] = corePoints.map((c) => c.toJson()).toList();

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    return utf8.encode(jsonStr);
  }
}
