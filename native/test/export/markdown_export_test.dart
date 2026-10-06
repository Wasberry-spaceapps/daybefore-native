import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:daybefore/features/export/markdown_export.dart';
import 'package:daybefore/models/journal_entry.dart';
import 'package:daybefore/models/issue.dart';
import 'package:daybefore/models/core_point.dart';

void main() {
  test('Markdown Export generates valid zip', () {
    final entries = [JournalEntry(id: '1', date: DateTime.now(), createdAt: 0, updatedAt: 0, title: 'Test Title', body: 'Test body', isSynced: false, isDeleted: false)];
    final issues = [Issue(id: '1', name: 'Test Issue', createdAt: 0, updatedAt: 0, isSynced: false, isDeleted: false, currentTheory: 'Th', revisions: [], returns: [])];
    final points = [CorePoint(id: '1', text: 'Point 1', createdAt: 0, updatedAt: 0, isSynced: false, isDeleted: false)];
    
    final bytes = MarkdownExport.generateZip(
      entries: entries, issues: issues, corePoints: points,
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    
    final archive = ZipDecoder().decodeBytes(bytes);
    
    expect(archive.files.any((f) => f.name.endsWith('README.md')), isTrue);
    expect(archive.files.any((f) => f.name.contains('journal/') && f.name.endsWith('test-title.md')), isTrue);
    expect(archive.files.any((f) => f.name.contains('issues/') && f.name.endsWith('test-issue.md')), isTrue);
    expect(archive.files.any((f) => f.name.endsWith('core-points.md')), isTrue);
    
    final entryFile = archive.files.firstWhere((f) => f.name.contains('journal/') && f.name.endsWith('test-title.md'));
    final content = String.fromCharCodes(entryFile.content as List<int>);
    expect(content.startsWith('---'), isTrue);
    expect(content.contains('title: "Test Title"'), isTrue);
  });
}
