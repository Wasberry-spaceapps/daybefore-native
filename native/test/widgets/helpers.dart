
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
