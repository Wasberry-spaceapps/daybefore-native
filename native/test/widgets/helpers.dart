import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:daybefore/ui/theme_provider.dart';
import 'package:daybefore/ui/tokens.dart';

/// Wraps [child] with PaletteProvider, MediaQuery, and a minimal GoRouter
/// so that screens that call context.go / context.goNamed / GoRouterState.maybeOf
/// don't throw in tests.
Widget wrapForTest(Widget child, {Size size = const Size(1280, 800)}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: child),
        routes: [
          GoRoute(path: 'entry/:id',      name: 'entry',          builder: (_, __) => const SizedBox()),
          GoRoute(path: 'issue/:id',      name: 'issue',          builder: (_, __) => const SizedBox()),
          GoRoute(path: 'core/:id',       name: 'core',           builder: (_, __) => const SizedBox()),
          GoRoute(path: 'sign-in',        name: 'sign-in',        builder: (_, __) => const SizedBox()),
          GoRoute(path: 'switch-account', name: 'switch-account', builder: (_, __) => const SizedBox()),
          GoRoute(path: 'minute',         name: 'minute',         builder: (_, __) => const SizedBox()),
          GoRoute(path: 'account',        name: 'account',        builder: (_, __) => const SizedBox()),
          GoRoute(path: 'export',         name: 'export',         builder: (_, __) => const SizedBox()),
        ],
      ),
    ],
  );

  return MediaQuery(
    data: MediaQueryData(size: size),
    child: PaletteProvider(
      palette: Palette.day,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void testAtBothSizes(String description, Future<void> Function(WidgetTester tester, Size size) body) {
  testWidgets('$description (Phone)', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    await body(tester, const Size(390, 844));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
  testWidgets('$description (Desktop)', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    await body(tester, const Size(1280, 800));
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
