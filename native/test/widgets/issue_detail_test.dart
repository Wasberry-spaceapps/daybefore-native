import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/issues/issue_detail_screen.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('issue detail tabs', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const IssueDetailScreen(id: '1'), size: size));
    
    expect(find.text('Theory'), findsOneWidget);
    expect(find.text('Returns'), findsOneWidget);
    expect(find.text('Read it back'), findsOneWidget);
    
    // Tap Returns
    await tester.tap(find.text('Returns'));
    await tester.pumpAndSettle();
    
    // Tap Theory
    await tester.tap(find.text('Theory'));
    await tester.pumpAndSettle();
    
    // Theory has text field
    expect(find.byType(TextField), findsWidgets);
  });
}
