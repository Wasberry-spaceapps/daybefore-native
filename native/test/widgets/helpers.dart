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
