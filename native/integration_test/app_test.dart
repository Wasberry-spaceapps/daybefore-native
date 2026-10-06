import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:daybefore/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('basic smoke test', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Day Before'), findsWidgets);
  });
}
