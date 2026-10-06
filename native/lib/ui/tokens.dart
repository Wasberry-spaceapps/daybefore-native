import 'package:flutter/material.dart';

class Palette {
  final Color ground, sidebar, raised, hover, hairline, text, muted, faint, accent, accentInk, danger, success, buttonBg, buttonInk;
  const Palette({required this.ground, required this.sidebar, required this.raised, required this.hover, required this.hairline,
    required this.text, required this.muted, required this.faint, required this.accent, required this.accentInk,
    required this.danger, required this.success, required this.buttonBg, required this.buttonInk});
  static const night = Palette(
    ground: Color(0xFF131211), sidebar: Color(0xFF0F0E0D), raised: Color(0xFF1B1A18), hover: Color(0xFF1D1B19),
    hairline: Color(0xFF2A2724), text: Color(0xFFF2EEE6), muted: Color(0xFFA39D92), faint: Color(0xFF6E6960),
    accent: Color(0xFFD4A25A), accentInk: Color(0xFF1A1307), danger: Color(0xFFE07A6B), success: Color(0xFF8DB87A),
    buttonBg: Color(0xFFF2EEE6), buttonInk: Color(0xFF131211));
  static const day = Palette(
    ground: Color(0xFFF6F1E8), sidebar: Color(0xFFEEE7DA), raised: Color(0xFFFBF8F2), hover: Color(0xFFE9E1D2),
    hairline: Color(0xFFDDD4C4), text: Color(0xFF1E1A15), muted: Color(0xFF6A6358), faint: Color(0xFF9A9283),
    accent: Color(0xFFA8691F), accentInk: Color(0xFFFFF8EC), danger: Color(0xFFB5483A), success: Color(0xFF4F7A3E),
    buttonBg: Color(0xFF1E1A15), buttonInk: Color(0xFFF6F1E8));
}
class S { static const x4 = 4.0, x8 = 8.0, x12 = 12.0, x16 = 16.0, x24 = 24.0, x32 = 32.0, x48 = 48.0, x64 = 64.0; }
class R { static const control = 8.0, card = 14.0; }
class Mo { static const fast = Duration(milliseconds: 140), base = Duration(milliseconds: 220), slow = Duration(milliseconds: 360);
  static const curve = Cubic(0.2, 0.0, 0.0, 1.0); }
class Ty {
  static const serif = 'Gelasio', sans = 'Inter';
  static TextStyle display(Color c, {bool phone = false}) => TextStyle(fontFamily: serif, fontSize: phone ? 34 : 44, height: phone ? 40 / 34 : 50 / 44, letterSpacing: -0.8, color: c);
  static TextStyle title(Color c) => TextStyle(fontFamily: serif, fontSize: 30, height: 38 / 30, letterSpacing: -0.4, color: c);
  static TextStyle heading(Color c) => TextStyle(fontFamily: serif, fontSize: 21, height: 28 / 21, fontWeight: FontWeight.w500, color: c);
  static TextStyle writing(Color c, {bool phone = false}) => TextStyle(fontFamily: serif, fontSize: phone ? 18 : 19, height: phone ? 29 / 18 : 31 / 19, color: c);
  static TextStyle body(Color c) => TextStyle(fontFamily: sans, fontSize: 15, height: 22 / 15, color: c);
  static TextStyle label(Color c) => TextStyle(fontFamily: sans, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, color: c);
  static TextStyle overline(Color c) => TextStyle(fontFamily: sans, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w600, letterSpacing: 0.9, color: c);
  static TextStyle caption(Color c) => TextStyle(fontFamily: sans, fontSize: 12, height: 16 / 12, color: c);
}
