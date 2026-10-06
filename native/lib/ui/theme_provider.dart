import 'package:flutter/material.dart';
import 'tokens.dart';

class PaletteProvider extends InheritedWidget {
  final Palette palette;
  const PaletteProvider({super.key, required this.palette, required super.child});

  static Palette of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PaletteProvider>();
    assert(provider != null, 'No PaletteProvider found in context');
    return provider!.palette;
  }

  @override
  bool updateShouldNotify(PaletteProvider old) => palette != old.palette;
}
