import os

os.makedirs("test/widgets", exist_ok=True)
os.makedirs("test/export", exist_ok=True)
os.makedirs("integration_test", exist_ok=True)

test_helpers = """
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/ui/theme_provider.dart';
import 'package:daybefore/ui/tokens.dart';

Widget wrapForTest(Widget child, {Size size = const Size(1280, 800)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: PaletteProvider(
      palette: Palette.day,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}
"""
with open("test/widgets/helpers.dart", "w") as f:
    f.write(test_helpers)

sidebar_test = """import 'package:flutter_test/flutter_test.dart';
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
"""
with open("test/widgets/sidebar_test.dart", "w") as f:
    f.write(sidebar_test)

export_test = """import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:daybefore/features/export/markdown_export.dart';
import 'package:daybefore/features/export/json_export.dart';

void main() {
  test('Markdown Export Zip', () {
    final bytes = MarkdownExport.generateZip(
      entries: [], issues: [], corePoints: [],
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    final archive = ZipDecoder().decodeBytes(bytes);
    expect(archive.files.any((f) => f.name.endsWith('README.md')), isTrue);
  });
  test('JSON Export', () {
    final bytes = JsonExport.generate(
      entries: [], issues: [], corePoints: [],
      includeJournal: true, includeIssues: true, includeCorePoints: true,
    );
    expect(bytes.isNotEmpty, isTrue);
  });
}
"""
with open("test/export/export_test.dart", "w") as f:
    f.write(export_test)

integration_test = """import 'package:flutter_test/flutter_test.dart';
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
"""
with open("integration_test/app_test.dart", "w") as f:
    f.write(integration_test)
