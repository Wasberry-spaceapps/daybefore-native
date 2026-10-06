import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/journal/home_screen.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('home screen interaction', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const HomeScreen(), size: size));
    
    expect(find.text('Write the day down.'), findsOneWidget);
    
    final newEntry = find.text('New entry');
    expect(newEntry, findsOneWidget);
    await tester.tap(newEntry);
    await tester.pump();
    
    final openIssue = find.text('Open an issue');
    expect(openIssue, findsOneWidget);
    await tester.tap(openIssue);
    await tester.pump();
  });
}
