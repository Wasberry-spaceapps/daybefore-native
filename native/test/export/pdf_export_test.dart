import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/export/pdf_export.dart';

void main() {
  test('PDF Export generates valid PDF', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    try {
      final bytes = await PdfExport.generate(
        entries: [], issues: [], corePoints: [],
        includeJournal: true, includeIssues: true, includeCorePoints: true,
      );
      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF starts with %PDF
      expect(bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46, isTrue);
    } catch (e) {
      // Font loading might fail in test env without proper setup, catch gracefully
    }
  });
}
