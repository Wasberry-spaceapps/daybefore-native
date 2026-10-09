import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import '../../models/journal_entry.dart';
import '../../models/issue.dart';
import '../../models/core_point.dart';

class MarkdownExport {
  static Uint8List generateZip({
    required List<JournalEntry> entries,
    required List<Issue> issues,
    required List<CorePoint> corePoints,
    required bool includeJournal,
    required bool includeIssues,
    required bool includeCorePoints,
  }) {
    final archive = Archive();
    final dateFmt = DateFormat('yyyy-MM-dd');
    final dateTimeFmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
    final prefix = 'DayBefore-export-${dateFmt.format(DateTime.now())}';

    archive.addFile(ArchiveFile(
      '$prefix/README.md',
      utf8.encode(_readme(DateTime.now())).length,
      utf8.encode(_readme(DateTime.now())),
    ));

    if (includeJournal) {
      for (final entry in entries) {
        final dateStr = dateFmt.format(DateTime.fromMillisecondsSinceEpoch(entry.createdAt));
        final slug = _slugify(dateStr);
        final filename = '$slug.md';
        final content = _journalMd(entry, dateTimeFmt);
        archive.addFile(ArchiveFile(
          '$prefix/journal/$filename',
          utf8.encode(content).length,
          utf8.encode(content),
        ));
      }
    }

    if (includeIssues) {
      for (final issue in issues) {
        final filename = '${_slugify(issue.name)}.md';
        final content = _issueMd(issue, dateFmt);
        archive.addFile(ArchiveFile(
          '$prefix/issues/$filename',
          utf8.encode(content).length,
          utf8.encode(content),
        ));
      }
    }

    if (includeCorePoints && corePoints.isNotEmpty) {
      final content = _corePointsMd(corePoints);
      archive.addFile(ArchiveFile(
        '$prefix/core-points.md',
        utf8.encode(content).length,
        utf8.encode(content),
      ));
    }

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static String _slugify(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  static String _readme(DateTime now) {
    final dateFmt = DateFormat('d MMMM yyyy');
    return '''# Day Before export

Exported on ${dateFmt.format(now)}.

This folder contains your journal entries, issues, and core points
exported from Day Before (daybefore.app).

- journal/ — one Markdown file per entry
- issues/ — one Markdown file per issue
- core-points.md — your core points

You can open these files in any text editor, Obsidian, Notion, or
any other Markdown-compatible tool.
''';
  }

  static String _journalMd(JournalEntry entry, DateFormat dateTimeFmt) {
    final created = dateTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(entry.createdAt));
    final updated = dateTimeFmt.format(DateTime.fromMillisecondsSinceEpoch(entry.updatedAt));
    return '''---
created: $created
updated: $updated
---

${entry.content}
''';
  }

  static String _issueMd(Issue issue, DateFormat dateFmt) {
    final created = dateFmt.format(DateTime.fromMillisecondsSinceEpoch(issue.createdAt));
    final buffer = StringBuffer();
    buffer.writeln('# ${issue.name}\n');
    buffer.writeln('Started: $created\n');
    buffer.writeln(issue.content);
    return buffer.toString();
  }

  static String _corePointsMd(List<CorePoint> corePoints) {
    final buffer = StringBuffer();
    buffer.writeln('# Core Points\n');
    for (int i = 0; i < corePoints.length; i++) {
      buffer.writeln('${i + 1}. **${corePoints[i].name}**\n   ${corePoints[i].content}');
    }
    buffer.writeln();
    return buffer.toString();
  }
}
