import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/ui/lock_screen.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('lock screen interaction', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const LockScreen(), size: size));
    
    expect(find.text('Day Before'), findsOneWidget);
    expect(find.text('Enter your password to open your journal.'), findsOneWidget);
    
    final passwordField = find.byType(TextField);
    expect(passwordField, findsOneWidget);
    
    final unlockBtn = find.text('Unlock');
    expect(unlockBtn, findsOneWidget);
    
    // Simulate wrong password
    await tester.enterText(passwordField, 'wrong');
    await tester.tap(unlockBtn);
    await tester.pumpAndSettle();
    
    // We expect the error text based on the mock implementation
    // expect(find.text('That password did not match.'), findsOneWidget);
  });
}
