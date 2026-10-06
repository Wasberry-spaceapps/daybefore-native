import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/ui/app_shell.dart';
import 'package:provider/provider.dart';
import 'package:daybefore/features/auth/auth_provider.dart';
import 'package:daybefore/core/api.dart';
import 'package:daybefore/core/storage.dart';

void main() {
  testWidgets('AppShell shows Drawer when width < 600', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;

    final db = LocalDb();
    final api = ApiClient();
    final auth = AuthProvider(api: api);
    final state = AppState(db: db, auth: auth);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: state),
        ],
        child: MaterialApp(
          home: AppShell(child: Container()),
        ),
      ),
    );

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.byType(Sidebar), findsNothing); // inside drawer, not rendered until opened
    
    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('AppShell shows 240px Sidebar when 600 <= width < 900', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;

    final db = LocalDb();
    final api = ApiClient();
    final auth = AuthProvider(api: api);
    final state = AppState(db: db, auth: auth);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: state),
        ],
        child: MaterialApp(
          home: AppShell(child: Container()),
        ),
      ),
    );

    expect(find.byType(Drawer), findsNothing);
    expect(find.byType(Sidebar), findsOneWidget);
    final sidebarSizedBox = tester.widget<SizedBox>(find.ancestor(of: find.byType(Sidebar), matching: find.byType(SizedBox)).first);
    expect(sidebarSizedBox.width, 240);
    
    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('AppShell shows 320px Sidebar when width >= 900', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;

    final db = LocalDb();
    final api = ApiClient();
    final auth = AuthProvider(api: api);
    final state = AppState(db: db, auth: auth);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: state),
        ],
        child: MaterialApp(
          home: AppShell(child: Container()),
        ),
      ),
    );

    expect(find.byType(Drawer), findsNothing);
    expect(find.byType(Sidebar), findsOneWidget);
    final sidebarSizedBox = tester.widget<SizedBox>(find.ancestor(of: find.byType(Sidebar), matching: find.byType(SizedBox)).first);
    expect(sidebarSizedBox.width, 320);
    
    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
