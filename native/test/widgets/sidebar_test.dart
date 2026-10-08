import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/ui/shell/day_sidebar.dart';
import 'package:daybefore/ui/app_shell.dart' show AppState;
import 'package:daybefore/core/storage.dart';
import 'package:daybefore/features/auth/auth_provider.dart';
import 'package:daybefore/core/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers.dart';

class _FakeDb extends LocalDb {
  @override Future<void> init(String id) async {}
  @override Future<List<Map<String, dynamic>>> getAll(String t,
      {String orderBy = 'createdAt DESC'}) async => [];
  @override Future<Map<String, dynamic>?> getById(String t, String id) async => null;
  @override Future<void> upsert(String t, Map<String, dynamic> row) async {}
  @override Future<void> delete(String t, String id) async {}
  @override Future<int> entryCount() async => 0;
  @override Future<void> deleteAccount() async {}
  @override Future<Map<String, dynamic>> exportAll() async => {};
}

class _FakeState extends AppState {
  _FakeState() : super(db: _FakeDb(), auth: AuthProvider(api: ApiClient()));
  @override Future<void> loadAll() async {}
}

Widget wrapWithState(Widget child, {Size size = const Size(1280, 800)}) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => _FakeState(),
    child: wrapForTest(child, size: size),
  );
}

void main() {
  testAtBothSizes('sidebar interactions', (tester, size) async {
    await tester.pumpWidget(wrapWithState(const DaySidebar(width: 256), size: size));
    await tester.pumpAndSettle();

    expect(find.text('Day Before'), findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
    expect(find.text('JOURNAL'), findsOneWidget);
    expect(find.text('ISSUES'), findsOneWidget);
    expect(find.text('CORE POINTS'), findsOneWidget);
    expect(find.text('Take a minute'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    // Old stock sidebar strings must be gone
    expect(find.text('Subscribe on website'), findsNothing);
    expect(find.text('Sign In / Sync'), findsNothing);
  });
}
