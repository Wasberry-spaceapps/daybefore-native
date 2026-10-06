import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Palette ──────────────────────────────────────────────────────
class Palette {
  final Color ground;
  final Color sidebar;
  final Color raised;
  final Color sunken;
  final Color hover;
  final Color pressed;
  final Color hairline;
  final Color hairlineBold;
  final Color text;
  final Color muted;
  final Color faint;
  final Color ghost;
  final Color accent;
  final Color accentMuted;
  final Color accentInk;
  final Color danger;
  final Color dangerMuted;
  final Color success;
  final Color successMuted;
  final Color buttonBg;
  final Color buttonInk;
  final Color buttonHover;
  final Color buttonPressed;
  final Color quietButtonHover;
  final Color quietButtonPressed;
  final Color overlay;
  final Color skeleton;
  final Color skeletonShimmer;
  final Color focusRing;
  final Brightness brightness;

  const Palette({
    required this.ground,
    required this.sidebar,
    required this.raised,
    required this.sunken,
    required this.hover,
    required this.pressed,
    required this.hairline,
    required this.hairlineBold,
    required this.text,
    required this.muted,
    required this.faint,
    required this.ghost,
    required this.accent,
    required this.accentMuted,
    required this.accentInk,
    required this.danger,
    required this.dangerMuted,
    required this.success,
    required this.successMuted,
    required this.buttonBg,
    required this.buttonInk,
    required this.buttonHover,
    required this.buttonPressed,
    required this.quietButtonHover,
    required this.quietButtonPressed,
    required this.overlay,
    required this.skeleton,
    required this.skeletonShimmer,
    required this.focusRing,
    required this.brightness,
  });

  SystemUiOverlayStyle get systemOverlayStyle => brightness == Brightness.dark
      ? SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: ground,
          statusBarColor: Colors.transparent,
        )
      : SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: ground,
          statusBarColor: Colors.transparent,
        );

  static const night = Palette(
    ground:             Color(0xFF131211),
    sidebar:            Color(0xFF0F0E0D),
    raised:             Color(0xFF1B1A18),
    sunken:             Color(0xFF0B0A09),
    hover:              Color(0xFF1D1B19),
    pressed:            Color(0xFF242220),
    hairline:           Color(0xFF2A2724),
    hairlineBold:       Color(0xFF3A3733),
    text:               Color(0xFFF2EEE6),
    muted:              Color(0xFFA39D92),
    faint:              Color(0xFF6E6960),
    ghost:              Color(0xFF3E3A35),
    accent:             Color(0xFFD4A25A),
    accentMuted:        Color(0x33D4A25A),
    accentInk:          Color(0xFF1A1307),
    danger:             Color(0xFFE07A6B),
    dangerMuted:        Color(0x33E07A6B),
    success:            Color(0xFF8DB87A),
    successMuted:       Color(0x338DB87A),
    buttonBg:           Color(0xFFF2EEE6),
    buttonInk:          Color(0xFF131211),
    buttonHover:        Color(0xFFE6E0D5),
    buttonPressed:      Color(0xFFD9D2C5),
    quietButtonHover:   Color(0xFF1D1B19),
    quietButtonPressed: Color(0xFF242220),
    overlay:            Color(0xCC000000),
    skeleton:           Color(0xFF1B1A18),
    skeletonShimmer:    Color(0xFF2A2724),
    focusRing:          Color(0xFFD4A25A),
    brightness:         Brightness.dark,
  );

  static const day = Palette(
    ground:             Color(0xFFF6F1E8),
    sidebar:            Color(0xFFEEE7DA),
    raised:             Color(0xFFFBF8F2),
    sunken:             Color(0xFFE4DDD0),
    hover:              Color(0xFFE9E1D2),
    pressed:            Color(0xFFDDD4C4),
    hairline:           Color(0xFFDDD4C4),
    hairlineBold:       Color(0xFFC8BFB0),
    text:               Color(0xFF1E1A15),
    muted:              Color(0xFF6A6358),
    faint:              Color(0xFF9A9283),
    ghost:              Color(0xFFC8BFB0),
    accent:             Color(0xFFA8691F),
    accentMuted:        Color(0x33A8691F),
    accentInk:          Color(0xFFFFF8EC),
    danger:             Color(0xFFB5483A),
    dangerMuted:        Color(0x33B5483A),
    success:            Color(0xFF4F7A3E),
    successMuted:       Color(0x334F7A3E),
    buttonBg:           Color(0xFF1E1A15),
    buttonInk:          Color(0xFFF6F1E8),
    buttonHover:        Color(0xFF2C2720),
    buttonPressed:      Color(0xFF3A3430),
    quietButtonHover:   Color(0xFFE9E1D2),
    quietButtonPressed: Color(0xFFDDD4C4),
    overlay:            Color(0x99000000),
    skeleton:           Color(0xFFE9E1D2),
    skeletonShimmer:    Color(0xFFF6F1E8),
    focusRing:          Color(0xFFA8691F),
    brightness:         Brightness.light,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────
class Sp {
  static const double x2  = 2;
  static const double x4  = 4;
  static const double x6  = 6;
  static const double x8  = 8;
  static const double x10 = 10;
  static const double x12 = 12;
  static const double x14 = 14;
  static const double x16 = 16;
  static const double x20 = 20;
  static const double x24 = 24;
  static const double x32 = 32;
  static const double x40 = 40;
  static const double x48 = 48;
  static const double x56 = 56;
  static const double x64 = 64;
  static const double x80 = 80;
  static const double x96 = 96;
}

// ─── Radii ────────────────────────────────────────────────────────
class Rad {
  static const double xs   = 4;
  static const double sm   = 6;
  static const double md   = 8;
  static const double lg   = 12;
  static const double xl   = 16;
  static const double card = 14;
  static const double modal = 20;
  static const double pill = 999;
  static BorderRadius bXs   = BorderRadius.circular(xs);
  static BorderRadius bSm   = BorderRadius.circular(sm);
  static BorderRadius bMd   = BorderRadius.circular(md);
  static BorderRadius bLg   = BorderRadius.circular(lg);
  static BorderRadius bXl   = BorderRadius.circular(xl);
  static BorderRadius bCard = BorderRadius.circular(card);
  static BorderRadius bModal = BorderRadius.circular(modal);
  static BorderRadius bPill  = BorderRadius.circular(pill);
}

// ─── Motion ───────────────────────────────────────────────────────
class Mo {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast    = Duration(milliseconds: 140);
  static const Duration base    = Duration(milliseconds: 220);
  static const Duration slow    = Duration(milliseconds: 360);
  static const Duration slower  = Duration(milliseconds: 500);
  static const Duration drawer  = Duration(milliseconds: 280);
  static const Duration page    = Duration(milliseconds: 360);
  static const Curve ease       = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve easeIn     = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve easeOut    = Cubic(0.0, 0.0, 0.2, 1.0);
}

// ─── Depth (shadows) ──────────────────────────────────────────────
class Depth {
  static List<BoxShadow> sm(Palette p) => [
    BoxShadow(color: p.ground.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> md(Palette p) => [
    BoxShadow(color: p.ground.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 1)),
    BoxShadow(color: p.ground.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> lg(Palette p) => [
    BoxShadow(color: p.ground.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
    BoxShadow(color: p.ground.withOpacity(0.14), blurRadius: 24, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> overlay(Palette p) => [
    BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 32, offset: const Offset(0, 12)),
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
  ];
}

// ─── Typography ───────────────────────────────────────────────────
class Ty {
  static const String serif = 'Gelasio';
  static const String sans  = 'Inter';

  // Display: hero text, lock screen title, empty-state headlines
  static TextStyle displayLg(Color c) => TextStyle(
    fontFamily: serif, fontSize: 44, height: 50 / 44,
    letterSpacing: -0.8, fontWeight: FontWeight.w400, color: c,
  );
  static TextStyle displaySm(Color c) => TextStyle(
    fontFamily: serif, fontSize: 34, height: 40 / 34,
    letterSpacing: -0.6, fontWeight: FontWeight.w400, color: c,
  );

  // Title: screen titles, issue names, large labels
  static TextStyle titleLg(Color c) => TextStyle(
    fontFamily: serif, fontSize: 28, height: 36 / 28,
    letterSpacing: -0.4, fontWeight: FontWeight.w400, color: c,
  );
  static TextStyle titleSm(Color c) => TextStyle(
    fontFamily: serif, fontSize: 22, height: 28 / 22,
    letterSpacing: -0.2, fontWeight: FontWeight.w500, color: c,
  );

  // Heading: section names inside a screen, card titles
  static TextStyle heading(Color c) => TextStyle(
    fontFamily: serif, fontSize: 18, height: 24 / 18,
    letterSpacing: -0.1, fontWeight: FontWeight.w500, color: c,
  );

  // Writing: journal entry body, issue theory body, reading text
  static TextStyle writingLg(Color c) => TextStyle(
    fontFamily: serif, fontSize: 19, height: 31 / 19,
    letterSpacing: 0.0, fontWeight: FontWeight.w400, color: c,
  );
  static TextStyle writingSm(Color c) => TextStyle(
    fontFamily: serif, fontSize: 17, height: 28 / 17,
    letterSpacing: 0.0, fontWeight: FontWeight.w400, color: c,
  );

  // Body: descriptions, helper text, longer labels
  static TextStyle body(Color c) => TextStyle(
    fontFamily: sans, fontSize: 15, height: 22 / 15,
    letterSpacing: 0.0, fontWeight: FontWeight.w400, color: c,
  );
  static TextStyle bodyMedium(Color c) => TextStyle(
    fontFamily: sans, fontSize: 15, height: 22 / 15,
    letterSpacing: 0.0, fontWeight: FontWeight.w500, color: c,
  );

  // Label: button text, sidebar items, form labels, navigation items
  static TextStyle label(Color c) => TextStyle(
    fontFamily: sans, fontSize: 14, height: 20 / 14,
    letterSpacing: 0.0, fontWeight: FontWeight.w500, color: c,
  );
  static TextStyle labelSm(Color c) => TextStyle(
    fontFamily: sans, fontSize: 13, height: 18 / 13,
    letterSpacing: 0.0, fontWeight: FontWeight.w500, color: c,
  );

  // Caption: timestamps, metadata, hints, secondary info
  static TextStyle caption(Color c) => TextStyle(
    fontFamily: sans, fontSize: 12, height: 16 / 12,
    letterSpacing: 0.0, fontWeight: FontWeight.w400, color: c,
  );
  static TextStyle captionMedium(Color c) => TextStyle(
    fontFamily: sans, fontSize: 12, height: 16 / 12,
    letterSpacing: 0.0, fontWeight: FontWeight.w500, color: c,
  );

  // Overline: section labels in all caps, sidebar section headers
  static TextStyle overline(Color c) => TextStyle(
    fontFamily: sans, fontSize: 11, height: 16 / 11,
    letterSpacing: 0.8, fontWeight: FontWeight.w600, color: c,
  );

  // Mono: recovery key, error codes
  static TextStyle mono(Color c) => TextStyle(
    fontFamily: 'monospace', fontSize: 14, height: 20 / 14,
    letterSpacing: 0.5, fontWeight: FontWeight.w400, color: c,
  );
}
