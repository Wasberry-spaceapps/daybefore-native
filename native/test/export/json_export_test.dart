import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:daybefore/features/export/json_export.dart';
import 'package:daybefore/models/journal_entry.dart';

void main() {
  test('JSON Export generates valid JSON', () {
    final entries = [JournalEntry(id: '1', date: DateTime.now(), createdAt: 0, updatedAt: 0, title: 'Test', body: 'Test', isSynced: false, isDeleted: false)];
    final bytes = JsonExport.generate(
      entries: entries, issues: [], corePoints: [],
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    
    final jsonStr = utf8.decode(bytes);
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    expect(map.containsKey('journal'), isTrue);
    expect((map['journal'] as List).length, 1);
  });
}
