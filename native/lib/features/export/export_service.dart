import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:archive/archive.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/journal_entry.dart';
import '../../models/core_point.dart';
import '../../models/issue.dart';

class ExportService {
  static Future<void> exportToZip(List<JournalEntry> journals, List<CorePoint> corePoints, List<Issue> issues) async {
    final location = await getSaveLocation(suggestedName: 'daybefore_export.zip');
    if (location == null) return;

    final archive = Archive();

    for (var j in journals) {
      final d = DateTime.fromMillisecondsSinceEpoch(j.createdAt);
      final name = 'journals/${d.year}-${d.month}-${d.day}_${d.hour}${d.minute}.md';
      archive.addFile(ArchiveFile(name, j.content.length, j.content.codeUnits));
    }
    
    for (var c in corePoints) {
      archive.addFile(ArchiveFile('core/${c.name}.md', c.content.length, c.content.codeUnits));
    }
    
    for (var i in issues) {
      archive.addFile(ArchiveFile('issues/${i.name}.md', i.content.length, i.content.codeUnits));
    }

    final bytes = ZipEncoder().encode(archive);
    if (bytes != null) {
      final file = File(location.path);
      await file.writeAsBytes(bytes);
    }
  }

  static Future<void> exportToPdf(List<JournalEntry> journals, List<CorePoint> corePoints, List<Issue> issues) async {
    final location = await getSaveLocation(suggestedName: 'daybefore_export.pdf');
    if (location == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          final widgets = <pw.Widget>[];
          
          widgets.add(pw.Header(level: 0, child: pw.Text('Day Before Export')));
          
          widgets.add(pw.Header(level: 1, child: pw.Text('Core Points')));
          for (var c in corePoints) {
            widgets.add(pw.Header(level: 2, child: pw.Text(c.name)));
            widgets.add(pw.Paragraph(text: c.content));
          }

          widgets.add(pw.Header(level: 1, child: pw.Text('Issues')));
          for (var i in issues) {
            widgets.add(pw.Header(level: 2, child: pw.Text(i.name)));
            widgets.add(pw.Paragraph(text: i.content));
          }
          
          widgets.add(pw.Header(level: 1, child: pw.Text('Journals')));
          for (var j in journals) {
            final d = DateTime.fromMillisecondsSinceEpoch(j.createdAt);
            widgets.add(pw.Header(level: 2, child: pw.Text('${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}')));
            widgets.add(pw.Paragraph(text: j.content));
          }

          return widgets;
        },
      ),
    );

    final file = File(location.path);
    await file.writeAsBytes(await pdf.save());
  }
}
