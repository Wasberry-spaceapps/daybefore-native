import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:daybefore/features/export/markdown_export.dart';
import 'package:daybefore/features/export/json_export.dart';

void main() {
  test('Markdown Export Zip', () {
    final bytes = MarkdownExport.generateZip(
      entries: [], issues: [], corePoints: [],
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    final archive = ZipDecoder().decodeBytes(bytes);
    expect(archive.files.any((f) => f.name.endsWith('README.md')), isTrue);
  });
  test('JSON Export', () {
    final bytes = JsonExport.generate(
      entries: [], issues: [], corePoints: [],
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    expect(bytes.isNotEmpty, isTrue);
  });
}
