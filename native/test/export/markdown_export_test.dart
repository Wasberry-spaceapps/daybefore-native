import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:daybefore/features/export/markdown_export.dart';
import 'package:daybefore/models/journal_entry.dart';
import 'package:daybefore/models/issue.dart';
import 'package:daybefore/models/core_point.dart';

void main() {
  test('Markdown Export generates valid zip', () {
    final entries = [JournalEntry(id: '1', content: 'Test body', createdAt: 0, updatedAt: 0)];
    final issues = [Issue(id: '1', name: 'Test Issue', content: 'Th', isArchived: 0, createdAt: 0, updatedAt: 0)];
    final points = [CorePoint(id: '1', name: 'Point 1', content: 'Details', createdAt: 0, updatedAt: 0)];

    final bytes = MarkdownExport.generateZip(
      entries: entries, issues: issues, corePoints: points,
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );

    final archive = ZipDecoder().decodeBytes(bytes);

    expect(archive.files.any((f) => f.name.endsWith('README.md')), isTrue);
    expect(archive.files.any((f) => f.name.contains('journal/')), isTrue);
    expect(archive.files.any((f) => f.name.contains('issues/') && f.name.endsWith('test-issue.md')), isTrue);
    expect(archive.files.any((f) => f.name.endsWith('core-points.md')), isTrue);

    final entryFile = archive.files.firstWhere((f) => f.name.contains('journal/'));
    final content = String.fromCharCodes(entryFile.content as List<int>);
    expect(content.startsWith('---'), isTrue);
    expect(content.contains('Test body'), isTrue);
  });
}
