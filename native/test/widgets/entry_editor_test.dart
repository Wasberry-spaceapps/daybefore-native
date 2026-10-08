import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/journal/entry_editor_screen.dart';
import 'package:daybefore/models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('entry editor interaction', (tester, size) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(wrapForTest(const EntryEditorScreen(id: 'new'), size: size));
      
      // Fields render
      expect(find.text('Untitled'), findsOneWidget);
      expect(find.text('Write the day, or only a line of it.'), findsOneWidget);
      
      // Type in title
      await tester.enterText(find.byType(TextField).first, 'My Title');
      await tester.pump();
      expect(find.text('My Title'), findsOneWidget);
      
      // Type in body
      await tester.enterText(find.byType(TextField).last, 'My body text');
      await tester.pump();
      expect(find.text('My body text'), findsOneWidget);
    });
  });
}
