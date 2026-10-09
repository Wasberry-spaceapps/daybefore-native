import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/export/export_screen.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('export screen interaction', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const ExportScreen(), size: size));
    
    expect(find.text('Markdown'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('JSON'), findsOneWidget);
    
    // Tap PDF
    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();
    
    expect(find.text('Export'), findsWidgets);
    await tester.tap(find.text('Export').first);
    await tester.pump();
  });
}
