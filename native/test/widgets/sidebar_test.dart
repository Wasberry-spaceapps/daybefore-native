import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/shell/day_sidebar.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('sidebar interactions', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const DaySidebar(width: 256), size: size));
    
    // Header text
    expect(find.text('Day Before'), findsOneWidget);
    
    // New entry button
    final newEntry = find.text('New entry');
    expect(newEntry, findsOneWidget);
    await tester.tap(newEntry);
    await tester.pump();
    
    // Sections collapse/expand
    final journalHeader = find.text('JOURNAL');
    expect(journalHeader, findsOneWidget);
    await tester.tap(journalHeader);
    await tester.pumpAndSettle();
    
    // Footer rows
    expect(find.text('Take a minute'), findsOneWidget);
    await tester.tap(find.text('Take a minute'));
    await tester.pump();

    expect(find.text('Export'), findsOneWidget);
    await tester.tap(find.text('Export'));
    await tester.pump();

    // Verify exclusions
    expect(find.text('Subscribe on website'), findsNothing);
    expect(find.text('Sign In / Sync'), findsNothing);
  });
}
