import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

void main() {
  testAtBothSizes('account screen interaction', (tester, size) async {
    await tester.pumpWidget(wrapForTest(const AccountScreen(), size: size));
    
    final rows = ['Email', 'Plan and sync', 'Export your entries', 'Privacy lock', 'Appearance', 'Sign in'];
    for (final r in rows) {
      final item = find.text(r);
      expect(item, findsOneWidget);
      await tester.tap(item);
      await tester.pump();
    }
  });
}
