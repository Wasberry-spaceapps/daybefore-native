import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:daybefore/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic smoke test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final hasLock = find.text('Enter your password to open your journal.');
    final hasHome = find.text('Write the day down.');
    expect(hasLock.evaluate().isNotEmpty || hasHome.evaluate().isNotEmpty, isTrue);

    if (hasHome.evaluate().isNotEmpty) {
      await tester.tap(find.text('New entry'));
      await tester.pumpAndSettle();
      expect(find.text('Untitled'), findsOneWidget);
    }
  });
}
