import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/features/shell/day_sidebar.dart';
import 'helpers.dart';

void main() {
  testWidgets('sidebar renders correctly', (tester) async {
    await tester.pumpWidget(wrapForTest(const DaySidebar(width: 256)));
    expect(find.text('Day Before'), findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
    expect(find.text('Subscribe on website'), findsNothing);
    expect(find.text('Sign In / Sync'), findsNothing);
  });
}
