import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../models/journal_entry.dart';
import '../../models/issue.dart';
import '../../models/core_point.dart';

class PdfExport {
  static Future<Uint8List> generate({
    required List<JournalEntry> entries,
    required List<Issue> issues,
    required List<CorePoint> corePoints,
    required bool includeJournal,
    required bool includeIssues,
    required bool includeCorePoints,
  }) async {
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Newsreader-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Newsreader-SemiBold.ttf'));
    final italic = pw.Font.ttf(await rootBundle.load('assets/fonts/Newsreader-Italic.ttf'));

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold, italic: italic),
    );

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(60),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Day Before', style: pw.TextStyle(font: bold, fontSize: 36)),
            pw.SizedBox(height: 16),
            pw.Text(
              'Exported ${_formatDate(DateTime.now())}',
              style: pw.TextStyle(font: regular, fontSize: 14, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    ));

    if (includeJournal && entries.isNotEmpty) {
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        header: (context) => pw.Text('Journal', style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.grey500)),
        build: (context) => [
          for (final entry in entries) ...[
            pw.Text(
              _formatDateMs(entry.createdAt),
              style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey500),
            ),
            pw.SizedBox(height: 8),
            pw.Text(entry.content, style: pw.TextStyle(font: regular, fontSize: 12, lineSpacing: 6)),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 24),
          ],
        ],
      ));
    }

    if (includeIssues && issues.isNotEmpty) {
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        header: (context) => pw.Text('Issues', style: pw.TextStyle(font: bold, fontSize: 12, color: PdfColors.grey500)),
        build: (context) => [
          for (final issue in issues) ...[
            pw.Text(issue.name, style: pw.TextStyle(font: bold, fontSize: 18)),
            pw.SizedBox(height: 8),
            pw.Text(issue.content, style: pw.TextStyle(font: regular, fontSize: 12, lineSpacing: 6)),
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 24),
          ],
        ],
      ));
    }

    if (includeCorePoints && corePoints.isNotEmpty) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(60),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Core Points', style: pw.TextStyle(font: bold, fontSize: 18)),
            pw.SizedBox(height: 16),
            for (int i = 0; i < corePoints.length; i++)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Text(
                  '${i + 1}. ${corePoints[i].name}: ${corePoints[i].content}',
                  style: pw.TextStyle(font: regular, fontSize: 12, lineSpacing: 6),
                ),
              ),
          ],
        ),
      ));
    }

    return pdf.save();
  }

  static String _formatDate(DateTime date) => DateFormat('d MMMM yyyy').format(date);
  static String _formatDateMs(int ms) => _formatDate(DateTime.fromMillisecondsSinceEpoch(ms));
}
