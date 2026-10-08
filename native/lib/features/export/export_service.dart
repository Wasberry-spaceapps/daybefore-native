import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/journal_entry.dart';
import '../../models/issue.dart';
import '../../models/core_point.dart';
import 'markdown_export.dart';
import 'pdf_export.dart';
import 'json_export.dart';

class ExportService {
  static Future<void> performExport({
    required List<JournalEntry> entries,
    required List<Issue> issues,
    required List<CorePoint> corePoints,
    required int format, // 0=markdown, 1=pdf, 2=json
    required bool includeJournal,
    required bool includeIssues,
    required bool includeCorePoints,
    required void Function(String) onResult,
  }) async {
    Uint8List bytes;
    String extension;
    String suggestedName;
    String mimeType;

    if (format == 0) {
      bytes = MarkdownExport.generateZip(
        entries: entries,
        issues: issues,
        corePoints: corePoints,
        includeJournal: includeJournal,
        includeIssues: includeIssues,
        includeCorePoints: includeCorePoints,
      );
      extension = 'zip';
      suggestedName = 'DayBefore-export.zip';
      mimeType = 'application/zip';
    } else if (format == 1) {
      bytes = await PdfExport.generate(
        entries: entries,
        issues: issues,
        corePoints: corePoints,
        includeJournal: includeJournal,
        includeIssues: includeIssues,
        includeCorePoints: includeCorePoints,
      );
      extension = 'pdf';
      suggestedName = 'DayBefore-export.pdf';
      mimeType = 'application/pdf';
    } else {
      bytes = JsonExport.generate(
        entries: entries,
        issues: issues,
        corePoints: corePoints,
        includeJournal: includeJournal,
        includeIssues: includeIssues,
        includeCorePoints: includeCorePoints,
      );
      extension = 'json';
      suggestedName = 'DayBefore-export.json';
      mimeType = 'application/json';
    }

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: [
          XTypeGroup(label: 'Export File', extensions: [extension]),
        ],
      );
      if (location != null) {
        final file = XFile.fromData(bytes, name: location.path, mimeType: mimeType);
        await file.saveTo(location.path);
        onResult('Saved to ${location.path}');
      }
    } else {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$suggestedName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
      onResult('Shared');
    }
  }
}
