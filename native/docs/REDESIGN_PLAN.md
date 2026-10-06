# Prompt 3: Bespoke redesign of all Day Before native apps

This prompt replaces ALL previous UI and design work in the Flutter apps. The website is finished and must not be touched. Time limit: up to 3 hours. Do not ask me questions. Where a value is given, use it exactly. Where a Flutter widget or package is named, use that widget or package. Do not substitute, do not improvise, do not use Material defaults. Every pixel is deliberate.

---

CONTEXT
You built Day Before (daybefore.app), its Cloudflare backend, and the Flutter apps in /native in this chat. The current apps look like stock Flutter scaffolds with default widgets, default fonts, a generic icon, and no design thinking. They are being thrown away visually and rebuilt from scratch as a bespoke product, the way a multidisciplinary team of designers and engineers would build one. The functionality is already there; this prompt replaces the presentation layer.

The website is the visual reference: warm dark ground, Georgia serif, gold accent, generous whitespace, hairline borders, calm motion. The apps must feel like the same product as the website, not a Flutter demo that happens to share its data.

Do NOT touch the website, the backend, the crypto, or the sync logic. Only the Flutter UI layer and its supporting files change.

Save this entire brief to docs/REDESIGN_PLAN.md. Create docs/REDESIGN_PROGRESS.md. Re-read both at the start of every phase. Commit and push after each phase.

## DESIGN PHILOSOPHY

Read this section before writing any code. It governs every decision.

**What makes an app feel hand-crafted instead of generated.**

The Libby app by OverDrive does not use stock iOS or Android components. Every element, the book covers, the loan cards, the shelf background, the tag ribbons, the reading progress arc, the page-turn animation, was drawn and coded from nothing. The result feels like opening a physical object designed by one mind, not a software form assembled from a kit.

Claude's interface does something similar with less ornamentation: a warm dark ground that is not pure black, serif type that signals reading rather than software, generous vertical space that lets each element breathe, hairline borders so thin they feel like pencil lines, and motion so slow and quiet you barely notice it. Every control looks like it was placed by hand and checked against its neighbours.

Day Before must feel like both of these: warm, calm, unhurried, and precise. The user opens it to sit with difficult thoughts about themselves. The interface must not compete with that. It must feel like opening a private notebook that was bound by someone who cared about the paper weight and the thread colour.

**Five principles. Follow them when any specification below is ambiguous.**

1. QUIET OVER CLEVER. No bouncy animations, no slide-up cards, no scale-on-tap, no gradient backgrounds, no blur effects, no frosted glass, no parallax. Motion exists only to show a state change and it ends before the user notices it.

2. WARM OVER NEUTRAL. The palette is brown-gold, not blue-grey. The ground is tinted, not flat. The text is cream, not white. The accent is burnished gold, not electric yellow. This is a journal, not a dashboard.

3. SERIF OVER SANS. Every piece of text the user writes or reads back uses the serif (Gelasio). The sans (Inter) exists only for small structural labels: section headers, timestamps, button text, metadata. If you are not sure, use the serif.

4. SPACE OVER DENSITY. Content floats in the middle of generous margins. The writing column never exceeds 680px. Lists have 16px between rows, not 8. Sections have 48px of vertical breathing room. The sidebar has 16px of horizontal padding. Nothing touches a screen edge.

5. DRAWN OVER STOCK. Every illustration, icon and empty-state graphic is a custom SVG defined in this prompt. Every component is a custom widget. No Material `ElevatedButton`, no `ListTile`, no `AppBar`, no `Drawer`, no `BottomNavigationBar`, no `Card`, no `Chip`, no `SnackBar`, no `AlertDialog`, no `Switch`, no `Checkbox`, no `TextField` with Material decoration. If a Material widget is named below, it is because the raw Flutter widget (like `GestureDetector`, `AnimatedContainer`, `CustomPaint`) is insufficient and the Material one is being used as a foundation with ALL default styling stripped and replaced.

---

## PHASE 0 — AUDIT AND STRIP (30 min)

**Goal: remove every trace of stock Flutter styling so there is a blank canvas.**

STEP 0.1: Inventory.
1. `grep -rn "AppBar\|ListTile\|ElevatedButton\|TextButton\|OutlinedButton\|FloatingActionButton\|BottomNavigationBar\|NavigationBar\|NavigationRail\|Drawer\|Card\|Chip\|SnackBar\|AlertDialog\|SimpleDialog\|Switch\|Checkbox\|Radio\|TextField\|TextFormField\|DropdownButton\|PopupMenuButton\|TabBar\|Slider\|CircularProgressIndicator\|LinearProgressIndicator\|Tooltip\|ExpansionTile\|DataTable\|Divider\|Scaffold(" native/lib/ > docs/MATERIAL_AUDIT.txt`
2. Count the hits: `wc -l docs/MATERIAL_AUDIT.txt`. Write the number into REDESIGN_PROGRESS.md.

STEP 0.2: Scaffold replacement.
`Scaffold` stays but is stripped: `backgroundColor: palette.ground`, no `appBar`, no `floatingActionButton`, no `bottomNavigationBar`, no `drawer` (we build our own). Every screen is a `Scaffold(body: ...)` with nothing else, or a bare `ColoredBox(color: palette.ground, child: ...)` where no safe-area padding is needed.

STEP 0.3: Delete all Material widget usage listed in 0.1 and replace each with a `Placeholder()` widget wrapped in a `// TODO: REDESIGN` comment. Do not fix layout yet. The app will look broken; that is correct. Run `flutter analyze` and fix only analysis errors (unused imports, missing overrides), not the visual mess.

STEP 0.4: Delete all existing custom theme configuration (any `ThemeData(...)` block that sets Material defaults). Replace with:
```dart
ThemeData(
  useMaterial3: false,
  brightness: isNight ? Brightness.dark : Brightness.light,
  scaffoldBackgroundColor: palette.ground,
  canvasColor: palette.ground,
  splashFactory: NoSplash.splashFactory,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  focusColor: Colors.transparent,
  dividerColor: palette.hairline,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: palette.accent,
    selectionColor: palette.accent.withOpacity(0.25),
    selectionHandleColor: palette.accent,
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStatePropertyAll(palette.faint.withOpacity(0.3)),
    thickness: WidgetStatePropertyAll(4.0),
    radius: const Radius.circular(2),
    thumbVisibility: WidgetStatePropertyAll(false),
  ),
  fontFamily: 'Inter',
)
```

STEP 0.5: Commit. Message: `strip all Material defaults, blank canvas for redesign`.

Accept: `flutter analyze` passes with zero errors. The app launches and shows coloured backgrounds with Placeholder widgets.

---

## PHASE 1 — FOUNDATIONS (45 min)

### 1A. Design tokens

Create `lib/ui/tokens.dart` exactly as follows. Do not change any value.

```dart
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
```

### 1B. Palette provider

Create `lib/ui/theme_provider.dart`:
```dart
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
```
Use `PaletteProvider.of(context)` everywhere. Never import a palette directly.

### 1C. Fonts

Bundle these exact font files in `native/assets/fonts/`:
- Gelasio-Regular.ttf (weight 400)
- Gelasio-Italic.ttf (weight 400, italic)
- Gelasio-Medium.ttf (weight 500)
- Gelasio-SemiBold.ttf (weight 600)
- Inter-Regular.ttf (weight 400)
- Inter-Medium.ttf (weight 500)
- Inter-SemiBold.ttf (weight 600)

Obtain them from Google Fonts CDN:
```bash
mkdir -p native/assets/fonts
curl -L "https://fonts.google.com/download?family=Gelasio" -o /tmp/gelasio.zip
curl -L "https://fonts.google.com/download?family=Inter" -o /tmp/inter.zip
cd /tmp && unzip -o gelasio.zip -d gelasio_unzipped && unzip -o inter.zip -d inter_unzipped
cp gelasio_unzipped/Gelasio/Gelasio-Regular.ttf native/assets/fonts/
cp gelasio_unzipped/Gelasio/Gelasio-Italic.ttf native/assets/fonts/
cp gelasio_unzipped/Gelasio/Gelasio-Medium.ttf native/assets/fonts/
cp gelasio_unzipped/Gelasio/Gelasio-SemiBold.ttf native/assets/fonts/
```
For Inter, the static TTFs are in `inter_unzipped/Inter/static/`:
```bash
cp inter_unzipped/Inter/static/Inter-Regular.ttf native/assets/fonts/
cp inter_unzipped/Inter/static/Inter-Medium.ttf native/assets/fonts/
cp inter_unzipped/Inter/static/Inter-SemiBold.ttf native/assets/fonts/
```
If the zip structure differs, find the files and copy them. The names in pubspec.yaml must match exactly.

pubspec.yaml (under `flutter:`):
```yaml
  fonts:
    - family: Gelasio
      fonts:
        - asset: assets/fonts/Gelasio-Regular.ttf
          weight: 400
        - asset: assets/fonts/Gelasio-Italic.ttf
          weight: 400
          style: italic
        - asset: assets/fonts/Gelasio-Medium.ttf
          weight: 500
        - asset: assets/fonts/Gelasio-SemiBold.ttf
          weight: 600
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
```

### 1D. Icons

Use the `lucide_icons_flutter` package (add to pubspec.yaml). All icons are stroke-style, size 18, strokeWidth 1.5, color from the palette. If a specific icon name does not exist in Lucide, pick the closest match and note the substitution in REDESIGN_PROGRESS.md.

Icon assignments (use these exact Lucide icon names):
- New entry: `LucideIcons.plus`
- Journal section: `LucideIcons.bookOpen`
- Issues section: `LucideIcons.repeat`
- Core points section: `LucideIcons.compass`
- Take a minute (game): `LucideIcons.wind`
- Export: `LucideIcons.download`
- Account: `LucideIcons.user`
- Settings gear: `LucideIcons.settings`
- Back/close: `LucideIcons.arrowLeft` (back), `LucideIcons.x` (close modals)
- Lock: `LucideIcons.lock`
- Unlock: `LucideIcons.lockOpen`
- Sign in: `LucideIcons.logIn`
- Sign out: `LucideIcons.logOut`
- Delete: `LucideIcons.trash2`
- Edit: `LucideIcons.pencil`
- Calendar/date: `LucideIcons.calendar`
- Search: `LucideIcons.search`
- Sync active: `LucideIcons.refreshCw`
- Sync off: `LucideIcons.cloudOff`
- Chevron right: `LucideIcons.chevronRight`
- Chevron down: `LucideIcons.chevronDown`
- Check/success: `LucideIcons.check`
- Warning: `LucideIcons.alertTriangle`
- Error/danger: `LucideIcons.alertCircle`
- Info: `LucideIcons.info`
- Eye (show password): `LucideIcons.eye`
- Eye off (hide password): `LucideIcons.eyeOff`
- External link: `LucideIcons.externalLink`
- Copy: `LucideIcons.copy`
- Menu (hamburger): `LucideIcons.menu`
- Moon (night theme): `LucideIcons.moon`
- Sun (day theme): `LucideIcons.sun`
- Monitor (system theme): `LucideIcons.monitor`
- File text: `LucideIcons.fileText`
- File JSON: `LucideIcons.fileJson`
- Printer/PDF: `LucideIcons.printer`
- Shield: `LucideIcons.shield`
- Key: `LucideIcons.key`
- Mail: `LucideIcons.mail`
- Star/core point: `LucideIcons.star`
- History/timeline: `LucideIcons.history`

### 1E. Brand assets

Create `native/assets/brand/symbol.svg`:
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" fill="none">
  <path d="M20 56a28 28 0 0 1 56 0Z" fill="currentColor" opacity="0.9"/>
  <rect x="12" y="56" width="72" height="4" rx="2" fill="currentColor"/>
  <rect x="26" y="66" width="44" height="2.5" rx="1.25" fill="currentColor" opacity="0.45"/>
</svg>
```
The symbol is rendered in code as a `CustomPainter` called `DayBeforeSymbol` so it can be coloured from the palette. Do NOT use an SVG renderer package for this single asset; paint it directly:

```dart
class DayBeforeSymbol extends CustomPainter {
  final Color color;
  final double opacity;
  DayBeforeSymbol({required this.color, this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 96;
    // Half disc
    final discPaint = Paint()..color = color.withOpacity(0.9 * opacity);
    final discRect = Rect.fromLTWH(20 * s, 28 * s, 56 * s, 56 * s);
    canvas.drawArc(discRect, 3.14159, 3.14159, true, discPaint);
    // Horizon line
    final linePaint = Paint()..color = color.withOpacity(opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(12 * s, 56 * s, 72 * s, 4 * s), Radius.circular(2 * s)),
      linePaint,
    );
    // Shorter bar
    final barPaint = Paint()..color = color.withOpacity(0.45 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(26 * s, 66 * s, 44 * s, 2.5 * s), Radius.circular(1.25 * s)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(DayBeforeSymbol old) => color != old.color || opacity != old.opacity;
}
```

### 1F. Illustration system

All empty-state and onboarding illustrations are abstract, geometric, and use only the palette colours: `accent`, `accentMuted`, `muted`, `faint`, `ghost`, and `hairline`. They are drawn with `CustomPainter`, not SVG files. They consist of:
- Thin lines (strokeWidth 1.0 to 1.5)
- Small circles (radii 2 to 6)
- Gentle arcs
- Scattered dots in `ghost` at 30% to 50% opacity
- The half-disc symbol at varying sizes as a recurring motif
- No fills heavier than 15% opacity except for the symbol's disc

Each illustration fits a 240x240 logical pixel canvas, centred in its empty-state container. Specific illustrations are defined per-screen in the SCREENS section (Phase 3).

### 1G. Reduced motion

Wrap all custom animations in a check:
```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;
```
If `reduceMotion` is true, set all durations to `Duration.zero` and skip any opacity fades or position shifts. The layout change still happens; only the transition is removed.

### 1H. Commit.
Message: `add design tokens, palette provider, fonts, icons, brand assets`. Run `flutter analyze` — must pass.

---

## PHASE 2 — CUSTOM COMPONENT LIBRARY (90 min)

Create all components in `lib/ui/components/`. Each file is named after the component in snake_case. Every component reads the palette from `PaletteProvider.of(context)`. No component imports Material widgets other than the ones explicitly listed. Every component is stateless or uses a private State class. All animations use `Mo.ease` unless a different curve is specified.

### 2A. DayButton — `lib/ui/components/day_button.dart`

Three variants: `DayButton.primary`, `DayButton.quiet`, `DayButton.danger`.

Structure: `StatefulWidget`. Inner: `GestureDetector` > `AnimatedContainer` > `Row(mainAxisSize: MainAxisSize.min)`.

**Primary button:**
- Height: 44
- Horizontal padding: 20
- Border radius: `Rad.md` (8)
- Background idle: `palette.buttonBg`
- Background hover: `palette.buttonHover`
- Background pressed: `palette.buttonPressed`
- Text: `Ty.label(palette.buttonInk)` (Inter 14/20, w500)
- Icon (optional, left of text): 16px, color `palette.buttonInk`, gap 8 to text
- Disabled: opacity 0.35 on the entire widget, `ignorePointer: true`
- Focus ring: 2px outline in `palette.focusRing` with 2px offset (a 2px transparent gap between the button edge and the ring), shown only on keyboard focus (use `FocusNode` and check `HardwareKeyboard.instance.logicalKeysPressed` is not empty on focus)
- Transition: background colour animates over `Mo.fast` (140ms) with `Mo.ease`
- Minimum width: 0 (button hugs its content)
- Cursor: `SystemMouseCursors.click` on desktop

**Quiet button:**
- Same structure and size
- Background idle: `Colors.transparent`
- Background hover: `palette.quietButtonHover`
- Background pressed: `palette.quietButtonPressed`
- Border: 1px `palette.hairline` (idle), 1px `palette.hairlineBold` (hover)
- Text: `Ty.label(palette.text)`
- Icon colour: `palette.muted`

**Danger button:**
- Same structure and size
- Background idle: `Colors.transparent`
- Background hover: `palette.dangerMuted`
- Background pressed: `palette.danger.withOpacity(0.25)`
- Border: 1px `palette.danger.withOpacity(0.4)` (idle)
- Text: `Ty.label(palette.danger)`

**All variants:**
- `onTap` callback (nullable; null = disabled)
- `label` (String, required)
- `icon` (IconData?, optional)
- `isLoading` (bool, default false): replaces label with a 16x16 custom spinner (three dots fading in sequence over 600ms, drawn with `CustomPainter`, in the text colour). Button stays its full width during loading. `onTap` is ignored.
- Minimum hit target: 44x44 on phone, 40x40 on desktop (wrap in `SizedBox` with `constraints`)
- Mouse hover state tracked via `MouseRegion` on desktop. On mobile, only pressed state exists.

### 2B. DayIconButton — `lib/ui/components/day_icon_button.dart`

A square tappable icon with no label.

- Size: 40x40 on desktop, 44x44 on phone (determined by the same `isPhone` breakpoint: `MediaQuery.of(context).size.width < 600`)
- Border radius: `Rad.sm` (6)
- Background idle: `Colors.transparent`
- Background hover: `palette.hover`
- Background pressed: `palette.pressed`
- Icon: Lucide, size 18, strokeWidth 1.5, colour `palette.muted` idle, `palette.text` on hover
- Transition: background `Mo.fast`, icon colour `Mo.fast`
- Focus ring: same as DayButton
- Tooltip: use `Overlay` to show a small `Ty.caption(palette.buttonInk)` label on a `palette.buttonBg` background with `Rad.xs` and 6px horizontal padding, 4px vertical, appearing 4px below the button, after a 600ms hover delay, fading in over `Mo.fast`. Position with `CompositedTransformFollower`. No Material `Tooltip`.

### 2C. DayTextField — `lib/ui/components/day_text_field.dart`

A custom text input for single-line fields (email, password, search).

Structure: `StatefulWidget`. Inner: `Column(crossAxisAlignment: start)` containing an optional label, the field container, and an optional error/helper.

- Label (optional): `Ty.labelSm(palette.muted)`, bottom margin 6
- Container: height 44, border radius `Rad.md` (8), background `palette.raised`, border 1px `palette.hairline`
- Container focused: border 1px `palette.accent`
- Container error: border 1px `palette.danger`
- Container hover (unfocused, no error): border 1px `palette.hairlineBold`
- Inner padding: horizontal 14, vertical 0 (vertically centred by line height)
- Text style: `Ty.body(palette.text)` (Inter 15/22)
- Placeholder: `Ty.body(palette.faint)`
- Cursor: `palette.accent`, width 1.5
- Selection: `palette.accent` at 25% opacity
- Suffix icon (for password toggle): `DayIconButton` size 32x32, inset 6 from right edge
- Error text: `Ty.caption(palette.danger)`, top margin 6, preceded by `LucideIcons.alertCircle` size 12 with 4px gap
- Helper text: `Ty.caption(palette.faint)`, top margin 6
- Transition: border colour `Mo.fast`
- Inner Flutter widget: `EditableText` wrapped in a `Semantics` widget, NOT `TextField` or `TextFormField`. Use `TextEditingController` and `FocusNode` passed in or created internally. Handle `onChanged`, `onSubmitted`, `obscureText` (for passwords).
- For password fields: a show/hide toggle using `LucideIcons.eye` / `LucideIcons.eyeOff` as the suffix

### 2D. DayTextArea — `lib/ui/components/day_text_area.dart`

For journal entry bodies, issue theories, and any multi-line writing.

- No visible border or container in writing mode (the text floats on the page background)
- Optionally show a 1px `palette.hairline` bottom border when the field is focused (for form contexts like issue theory editing)
- Text style: `Ty.writingLg(palette.text)` on desktop, `Ty.writingSm(palette.text)` on phone
- Placeholder: same style but in `palette.faint`
- Cursor: `palette.accent`, width 1.5
- Min height: 120 (grows with content)
- Padding: 0 (the parent provides margins)
- Inner Flutter widget: `EditableText` with `maxLines: null`, `expands: false`
- Autosave support: accepts `onChanged` with a debounce timer (600ms) managed internally. A "Saved" indicator is NOT part of this widget (it is managed by the screen).

### 2E. DayToggle — `lib/ui/components/day_toggle.dart`

A custom on/off toggle switch. No Material `Switch`.

- Track size: 44x24
- Track radius: `Rad.pill` (fully round)
- Track off: `palette.ghost`
- Track on: `palette.accent`
- Thumb: 18x18 circle, white (#FFFFFF), centred vertically, positioned 3px from left (off) or 3px from right (on)
- Thumb shadow: `Depth.sm`
- Transition: thumb position and track colour over `Mo.base` (220ms) with `Mo.ease`
- Hit target: 44x44 minimum (the track plus surrounding padding)
- Optional label to the left: `Ty.body(palette.text)`, gap 12
- Cursor: `SystemMouseCursors.click`
- Implementation: `GestureDetector` > `AnimatedContainer` for the track, `AnimatedPositioned` for the thumb, painted with `DecoratedBox` and `BoxDecoration`

### 2F. DaySelect — `lib/ui/components/day_select.dart`

A dropdown selector. No Material `DropdownButton`.

- Trigger: same dimensions and styling as `DayTextField` (height 44, radius 8, `palette.raised`, 1px `palette.hairline`)
- Trigger text: selected value in `Ty.body(palette.text)`, or placeholder in `Ty.body(palette.faint)`
- Trigger right icon: `LucideIcons.chevronDown`, size 16, colour `palette.muted`, rotates 180 degrees over `Mo.fast` when open
- Dropdown: positioned below the trigger using `Overlay` and `CompositedTransformFollower`
- Dropdown container: background `palette.raised`, border 1px `palette.hairline`, radius `Rad.md`, shadow `Depth.md`, max height 240 (scrollable)
- Dropdown items: height 40, padding horizontal 14, text `Ty.body(palette.text)`, hover `palette.hover`, selected item has `LucideIcons.check` 16px in `palette.accent` at right
- Open/close animation: the dropdown fades in and shifts down 4px over `Mo.fast`, fades out over `Mo.instant`
- Closes on: tap outside, tap on an item, Escape key

### 2G. DayCard — `lib/ui/components/day_card.dart`

A container with a subtle raised appearance.

- Background: `palette.raised`
- Border: 1px `palette.hairline`
- Border radius: `Rad.card` (14)
- Padding: 20 all sides
- Shadow: none by default; `Depth.sm` when `elevated: true`
- No hover state unless `onTap` is provided; if tappable: hover background `palette.hover`, transition `Mo.fast`
- Child: any widget
- Variants via named constructors:
  - `DayCard({child})` — static
  - `DayCard.tappable({child, onTap})` — adds hover/pressed

### 2H. DayListRow — `lib/ui/components/day_list_row.dart`

A single row in a list (sidebar items, account settings, entry lists).

- Height: 40 (compact) or 52 (settings)
- Padding: horizontal 12 (compact) or horizontal 16 (settings)
- Border radius: `Rad.sm` (6) on compact, `Rad.md` (8) on settings
- Background idle: transparent
- Background hover: `palette.hover`
- Background pressed: `palette.pressed`
- Background selected: `palette.hover`
- Selected indicator: a 3px wide, 20px tall rounded rectangle (`Rad.pill`) in `palette.accent`, positioned 0px from left edge, vertically centred, opacity animates from 0 to 1 over `Mo.fast`
- Content: `Row` with optional leading icon (18px, `palette.muted`, becomes `palette.text` when selected), gap 10, expanded text in `Ty.label` (compact) or `Ty.body` (settings), optional trailing widget (icon, status text, or chevron)
- Text overflow: `TextOverflow.ellipsis`, single line
- Transition: background colour `Mo.fast`
- On tap: `VoidCallback`

### 2I. DaySidebarSection — `lib/ui/components/day_sidebar_section.dart`

A collapsible section in the sidebar (Journal, Issues, Core Points).

- Header: height 28, padding horizontal 12
- Header text: `Ty.overline(palette.muted)` (Inter 11/16, w600, uppercase, letterSpacing 0.8)
- Header right side: a 24x24 icon button (plus icon, `LucideIcons.plus`, 14px, `palette.faint`, hover `palette.muted`) and a 24x24 chevron (`LucideIcons.chevronDown`, 14px, `palette.faint`)
- Chevron rotation: 0 degrees when expanded, -90 degrees when collapsed, animated over `Mo.base` with `Mo.ease` using `AnimatedRotation`
- Top margin above header: 20
- Content: a `ClipRect` > `AnimatedAlign` (alignment topCenter, heightFactor 0.0 to 1.0 over `Mo.base`) > `Column` of `DayListRow.compact` items
- Collapsed: heightFactor 0.0, header still visible
- Default state: expanded

### 2J. DayTab — `lib/ui/components/day_tab.dart`

A horizontal tab row (used for Journal/Issues/Core Points on narrow desktop, and for yearly/monthly toggle on pricing).

- Container: height 36, background `palette.sunken`, border radius `Rad.md`, padding 3 all sides
- Each tab: height 30, border radius `Rad.sm`, horizontal padding 14, text `Ty.labelSm`
- Inactive tab: transparent background, text `palette.muted`
- Active tab: `palette.raised` background, text `palette.text`, shadow `Depth.sm`
- Active indicator animation: use a `Stack` with an `AnimatedPositioned` white/raised background rectangle that slides to the active tab's position over `Mo.base` with `Mo.ease`
- Gap between tabs: 0 (they sit flush)

### 2K. DayModal — `lib/ui/components/day_modal.dart`

A centred dialog overlay. No Material `AlertDialog` or `showDialog`.

- Overlay: `palette.overlay` (Night: 0xCC000000, Day: 0x99000000), fades in over `Mo.base`
- Container: background `palette.raised`, border radius `Rad.modal` (20), shadow `Depth.overlay`, max width 440, max height `0.85 * screenHeight`
- Padding: 24 all sides, 20 top
- Title: `Ty.titleSm(palette.text)`, bottom margin 8
- Body: `Ty.body(palette.muted)`, bottom margin 24
- Actions: `Row(mainAxisAlignment: end)`, gap 12 between buttons
- Close: `DayIconButton` with `LucideIcons.x` at top right (position: 12 from top, 12 from right)
- Enter animation: container fades in and scales from 0.97 to 1.0 over `Mo.base` with `Mo.ease`
- Exit: fades out over `Mo.fast`
- Closes on: tapping overlay, close button, Escape key
- Implementation: show via `Navigator.of(context).push(PageRouteBuilder(...))` with a transparent page route

### 2L. DayBottomSheet — `lib/ui/components/day_bottom_sheet.dart`

Slides up from the bottom on phones. On desktop (width >= 600), renders as a `DayModal` instead.

- Overlay: same as DayModal
- Sheet: background `palette.raised`, top-left and top-right radius `Rad.xl` (16), bottom radius 0
- Handle: a 36x4 rounded rectangle in `palette.ghost`, centred horizontally, 8px from top
- Padding: 20 horizontal, 24 bottom, 16 top (below handle)
- Max height: `0.92 * screenHeight`
- Enter: slides up from offscreen over `Mo.slow` (360ms) with `Mo.ease`
- Exit: slides down over `Mo.base`
- Drag to dismiss: `GestureDetector` on the handle and the top 40px of the sheet, dismiss when dragged down more than 100px
- Safe area: respect `MediaQuery.of(context).viewInsets.bottom` for keyboard

### 2M. DayToast — `lib/ui/components/day_toast.dart`

A brief, non-blocking notification.

- Position: centred horizontally, 32px from bottom on phone, 24px from bottom on desktop
- Container: background `palette.raised`, border 1px `palette.hairline`, radius `Rad.lg` (12), shadow `Depth.md`, padding horizontal 16, vertical 10
- Icon (optional): 16px, left of text, gap 8. Use `palette.success` for success, `palette.danger` for error, `palette.accent` for info
- Text: `Ty.labelSm(palette.text)`
- Max width: 360
- Enter: fades in and slides up 8px over `Mo.base`
- Auto-dismiss: after 3 seconds (configurable), fades out and slides down 8px over `Mo.fast`
- Stacking: only one toast at a time; new toasts replace the current one
- Implementation: managed by a `ToastController` (ChangeNotifier) injected via provider; displayed via an `Overlay` entry in the app shell

### 2N. DayBanner — `lib/ui/components/day_banner.dart`

A persistent bar at the top of a screen for important messages (e.g. "Sync is paused", "No connection").

- Height: 40
- Background: `palette.accentMuted` (info), `palette.dangerMuted` (error), `palette.successMuted` (success)
- Text: `Ty.labelSm(palette.text)`, centred
- Optional leading icon: 16px, gap 8
- Optional trailing close button: `DayIconButton` size 28x28
- Border bottom: 1px `palette.hairline`
- Enter: slides down from 0 height over `Mo.base` using `AnimatedContainer`
- Dismiss: slides up over `Mo.fast`

### 2O. DayEmptyState — `lib/ui/components/day_empty_state.dart`

Shown when a section has no content.

- Layout: `Column(mainAxisAlignment: center, crossAxisAlignment: center)`
- Custom illustration: 240x240, rendered by a `CustomPainter` (specific painter passed in or selected by an enum)
- Bottom margin below illustration: 24
- Headline: `Ty.heading(palette.text)`, textAlign centre
- Bottom margin below headline: 8
- Body: `Ty.body(palette.muted)`, textAlign centre, max width 320
- Bottom margin below body: 24
- Optional action button: `DayButton.primary` or `DayButton.quiet`
- The entire widget is offset upward by 24px from true centre (looks more balanced)

### 2P. DaySkeleton — `lib/ui/components/day_skeleton.dart`

A loading placeholder that shimmers.

- Shape: rounded rectangle, radius `Rad.sm` (6)
- Base colour: `palette.skeleton`
- Shimmer colour: `palette.skeletonShimmer`
- Animation: a linear gradient that moves from left to right over 1200ms, repeating. The gradient is 200% wide with three stops: `skeleton` at 0%, `skeletonShimmer` at 50%, `skeleton` at 100%. Animate the gradient's `begin` from `Alignment(-2, 0)` to `Alignment(2, 0)`. Use `AnimationController` with `repeat()`.
- Variants via constructor:
  - `DaySkeleton.line(width, height: 14)` — a single text-line placeholder
  - `DaySkeleton.circle(diameter)` — a circular placeholder
  - `DaySkeleton.rect(width, height)` — a rectangular placeholder
- Group widget `DaySkeletonGroup`: wraps children so they share one animation controller (performance)
- Reduced motion: no shimmer, just the static base colour

### 2Q. DayFormError — `lib/ui/components/day_form_error.dart`

An inline error message below a form field.

- Layout: `Row(crossAxisAlignment: start)`, gap 4
- Icon: `LucideIcons.alertCircle`, size 14, colour `palette.danger`, top-aligned with text
- Text: `Ty.caption(palette.danger)`, wrapping
- Enter animation: fades in and expands from 0 height over `Mo.fast` using `AnimatedCrossFade` (first child: `SizedBox.shrink()`, second child: the error row)

### 2R. DayStatusPill — `lib/ui/components/day_status_pill.dart`

A small pill showing a status label (e.g. "Synced", "Local only", "Expired").

- Height: 22
- Horizontal padding: 8
- Border radius: `Rad.pill`
- Background: determined by variant:
  - `neutral`: `palette.ghost`
  - `accent`: `palette.accentMuted`
  - `success`: `palette.successMuted`
  - `danger`: `palette.dangerMuted`
- Text: `Ty.captionMedium` in matching colour (`palette.faint` for neutral, `palette.accent` for accent, `palette.success` for success, `palette.danger` for danger)
- Optional left dot: 6x6 circle, same colour as text, gap 6

### 2S. DayDateChip — `lib/ui/components/day_date_chip.dart`

A date label used in entry lists and the Issues timeline.

- Height: 22
- Horizontal padding: 8
- Border radius: `Rad.sm` (6)
- Background: `palette.sunken`
- Text: `Ty.captionMedium(palette.faint)`
- Format: "Mon 6 Oct" (short weekday, day, short month) for dates in the current year, "6 Oct 2025" for older dates. Use `intl` package `DateFormat`.

### 2T. DaySectionHeader — `lib/ui/components/day_section_header.dart`

Used inside screens to separate content sections.

- Height: 32
- Padding: horizontal matches parent padding (passed in or inherited)
- Text: `Ty.overline(palette.muted)` (all caps)
- Optional trailing action: `Ty.captionMedium(palette.accent)`, tappable with `GestureDetector`, cursor click
- Bottom: 1px `palette.hairline` border
- Top margin: `Sp.x32` (32) when not the first item

### 2U. DayDivider — `lib/ui/components/day_divider.dart`

A simple 1px line.

- Height: 1
- Colour: `palette.hairline`
- Horizontal margin: passed in (default 0)
- No Material `Divider`.

### 2V. DayAvatar — `lib/ui/components/day_avatar.dart`

Shows user initials when there is no profile image.

- Size: 32 (default), 40, or 24 (via constructor)
- Shape: circle
- Background: `palette.ghost`
- Text: `Ty.captionMedium(palette.muted)` for size 32, scaled proportionally for other sizes
- Content: first letter of the email address, uppercased. If no email, show `LucideIcons.user` at 60% of the avatar size.

### 2W. DayScrollIndicator — `lib/ui/components/day_scroll_indicator.dart`

A subtle top/bottom fade when content is scrollable.

- Top fade: a 24px tall `DecoratedBox` with a `LinearGradient` from `palette.ground` (opacity 1.0) to `palette.ground` (opacity 0.0), positioned at the top of the scroll area
- Bottom fade: same gradient, reversed, at the bottom
- Only visible when there is content to scroll in that direction (listen to `ScrollController.position`)
- Enter/exit: opacity over `Mo.fast`
- Implementation: a wrapper widget that takes a `ScrollController` and a child, and adds the fade overlays with a `Stack`

### 2X. DayPullToRefresh — `lib/ui/components/day_pull_to_refresh.dart`

For synced content on phones.

- Trigger distance: 80px pull-down
- Indicator: three small dots (4px circles) in `palette.accent` that appear at the top of the list and animate in a wave pattern (each dot scales from 0.5 to 1.0 and back, staggered by 100ms) during refresh
- Override distance: `palette.accent` colour on the dots. No Material refresh indicator.
- Implementation: `NotificationListener<ScrollNotification>` wrapping the list; track overscroll and trigger the callback when released past 80px; show the dots in an `AnimatedContainer` that slides down from -40px to the desired position

### 2Y. DaySnackbar — `lib/ui/components/day_snackbar.dart`

A full-width bar at the bottom for actions that can be undone (e.g. "Entry deleted" with "Undo").

- Position: fixed to bottom, above safe area
- Height: 48
- Background: `palette.buttonBg`
- Text: `Ty.label(palette.buttonInk)`, left-aligned with 16px padding
- Action: `Ty.label(palette.accent)` (or `palette.accentInk` depending on contrast with buttonBg), tappable, right-aligned with 16px padding
- Enter: slides up over `Mo.base`
- Auto-dismiss: 5 seconds, slides down over `Mo.fast`
- Only one at a time

### 2Z. Shared utilities — `lib/ui/components/utils.dart`

```dart
bool isPhone(BuildContext context) => MediaQuery.of(context).size.width < 600;
bool isTablet(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  return w >= 600 && w < 900;
}
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;
double sidebarWidth(BuildContext context) => isDesktop(context) ? 288.0 : 256.0;
double contentMaxWidth() => 680.0;
EdgeInsets screenPadding(BuildContext context) =>
    isPhone(context) ? const EdgeInsets.symmetric(horizontal: 20) : const EdgeInsets.symmetric(horizontal: 32);
```

### PHASE 2 ACCEPTANCE

1. Create `lib/ui/components/component_gallery.dart`: a scrollable screen (route `/design`) that displays every component in both palettes (Night and Day, toggled by a DayToggle at the top), in every state (idle, hover, pressed, disabled, error, loading, selected). Buttons, text fields (empty, filled, focused, error), toggles (on, off), cards, list rows (normal, selected), tabs, a modal trigger, a toast trigger, banners (info, error, success), empty states, skeletons, status pills, date chips, section headers, dividers, avatars, and the pull-to-refresh indicator.
2. Run `flutter analyze` — zero errors.
3. Run `flutter test` — all existing tests pass (components that replaced Material widgets should not break existing logic tests; if they do, fix the test to use the new widget keys).
4. Take a screenshot of the `/design` gallery on a 1280x800 window and a 390x844 window. Save to `docs/screens/design-night-desktop.png`, `docs/screens/design-night-phone.png`, `docs/screens/design-day-desktop.png`, `docs/screens/design-day-phone.png`.
5. Commit. Message: `complete custom component library, all 26 components`.
6. Write into REDESIGN_PROGRESS.md: the component count, any Lucide icon substitutions, and any issues.

---

The component library is complete. Phases 3 through 8 follow below.

## PHASE 3 — CUSTOM ILLUSTRATIONS AND ICONOGRAPHY (45 min)

Every visual element the user sees repeatedly must feel drawn, not downloaded. This phase replaces the most-seen icons with hand-crafted SVGs stored in the repo, adds six spot illustrations for empty and special states, and wires them into Flutter widgets that respect theming.

---

### 3A. Custom icon set

These 8 icons appear in the sidebar, the bottom navigation, the lock screen and the editor toolbar. They set the visual identity more than any other element. Store each as `native/assets/icons/<name>.svg`. All share the same anatomy:

- ViewBox: `0 0 24 24`
- Stroke width: `1.5`
- Stroke linecap: `round`
- Stroke linejoin: `round`
- Fill: `none`
- Stroke colour: `currentColor` (so Flutter can tint them)

The style is a ruling-pen line: confident, single-weight, with very slight asymmetry in curves (not robotic circles, not wobbly either). Think of an architect's freehand circle — almost perfect, recognisably human.

---

#### 1. `journal.svg` — an open book, pages fanning slightly left

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- spine -->
  <path d="M12 4v16"/>
  <!-- left cover, slight fan -->
  <path d="M12 4C10.5 4 5 3.5 3 5v14c2 -1.2 7.5 -0.8 9 0"/>
  <!-- right cover -->
  <path d="M12 4c1.5 0 7 -0.5 9 1.5v14c-2 -1.2 -7.5 -0.8 -9 0"/>
  <!-- left page line -->
  <path d="M7.5 8.5c1.5 -0.3 3 -0.2 4.5 0"/>
  <!-- left page line lower -->
  <path d="M7.5 12c1.5 -0.3 3 -0.2 4.5 0"/>
</svg>
```

#### 2. `issues.svg` — a thread making a loose loop

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- single continuous thread: enters left, loops once, exits right -->
  <path d="M3 12c2 0 3 -4 5 -4s2 4 4 4 2 -4 4 -4 3 4 5 4"/>
  <!-- a small knot/crossing in the centre -->
  <circle cx="12" cy="12" r="2.5"/>
</svg>
```

#### 3. `core-points.svg` — a four-pointed compass star

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- four diamond points, hand-drawn feel via slight offsets -->
  <path d="M12 2l1.8 7.2L21 12l-7.2 1.8L12 22l-1.8 -7.2L3 12l7.2 -1.8Z"/>
  <!-- small centre dot -->
  <circle cx="12" cy="12" r="1.2"/>
</svg>
```

#### 4. `new-entry.svg` — a page with a small plus

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- page body with folded corner -->
  <path d="M6 3h8l4 4v14a1 1 0 0 1 -1 1H6a1 1 0 0 1 -1 -1V4a1 1 0 0 1 1 -1z"/>
  <!-- fold -->
  <path d="M14 3v4h4"/>
  <!-- plus sign -->
  <path d="M10 13h4"/>
  <path d="M12 11v4"/>
</svg>
```

#### 5. `export.svg` — an open box with pages rising out

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- box base -->
  <path d="M4 14h16v6a1 1 0 0 1 -1 1H5a1 1 0 0 1 -1 -1z"/>
  <!-- box opening flaps -->
  <path d="M4 14l2 -3h12l2 3"/>
  <!-- page rising centre -->
  <path d="M12 12V5"/>
  <!-- page arrow tip -->
  <path d="M9 7.5L12 5l3 2.5"/>
</svg>
```

#### 6. `lock.svg` — a closed padlock with keyhole

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- lock body -->
  <rect x="5" y="11" width="14" height="10" rx="2"/>
  <!-- shackle -->
  <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
  <!-- keyhole circle -->
  <circle cx="12" cy="15.5" r="1.5"/>
  <!-- keyhole slot -->
  <path d="M12 17v2"/>
</svg>
```

#### 7. `take-a-minute.svg` — a gentle breeze (three curved lines)

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- top gust, shortest -->
  <path d="M3 8h10a2 2 0 0 0 0 -4"/>
  <!-- middle gust, longest -->
  <path d="M3 12h14a2.5 2.5 0 0 1 0 5"/>
  <!-- bottom gust, medium -->
  <path d="M3 16h8a2 2 0 0 0 0 4"/>
</svg>
```

#### 8. `horizon.svg` — brand symbol: half-disc above a line

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- half-disc (sunrise) -->
  <path d="M7 14a5 5 0 0 1 10 0"/>
  <!-- horizon line -->
  <path d="M3 14h18"/>
  <!-- short ground line -->
  <path d="M8 18h8"/>
</svg>
```

---

#### 3A-impl. Flutter implementation — `lib/ui/icons/day_icons.dart`

Use `flutter_svg` (already added in Phase 3C below) to render these at runtime. Do NOT use CustomPainter for the icons — `flutter_svg` is cleaner and already handles tinting.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DayIconName {
  journal,
  issues,
  corePoints,
  newEntry,
  export_,
  lock,
  takeAMinute,
  horizon,
}

class DayIcon extends StatelessWidget {
  final DayIconName name;
  final double size;
  final Color color;

  const DayIcon({
    super.key,
    required this.name,
    this.size = 24,
    required this.color,
  });

  String get _assetPath {
    const map = {
      DayIconName.journal: 'assets/icons/journal.svg',
      DayIconName.issues: 'assets/icons/issues.svg',
      DayIconName.corePoints: 'assets/icons/core-points.svg',
      DayIconName.newEntry: 'assets/icons/new-entry.svg',
      DayIconName.export_: 'assets/icons/export.svg',
      DayIconName.lock: 'assets/icons/lock.svg',
      DayIconName.takeAMinute: 'assets/icons/take-a-minute.svg',
      DayIconName.horizon: 'assets/icons/horizon.svg',
    };
    return map[name]!;
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      package: null, // assets are in the app itself
    );
  }
}
```

Register the asset directory in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/icons/
    - assets/illustrations/
```

Where a Lucide icon was assigned in Phase 1 for one of these 8 roles (sidebar Journal, sidebar Issues, sidebar Core Points, New Entry button, Export, Lock, Take a Minute, the brand symbol), replace it with `DayIcon(name: DayIconName.xxx, size: 18, color: palette.muted)` (or whichever colour the context requires). All other icons remain Lucide.

---

### 3B. Spot illustrations

Six larger illustrations (120x120 logical pixels) for empty states and special screens. Each is an SVG in `native/assets/illustrations/`. The drawing style: the same 1.5px ruling-pen line as the icons, but with one or two areas filled in accent gold (`#D4A25A` in Night, `#A8691F` in Day). No gradients, no filters, no raster effects. Under 8 path elements each. Under 1 KB each.

---

#### 1. `empty_journal.svg` — open book with pen beside it, ink pooling at the nib

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- book spine -->
  <path d="M60 30v60"/>
  <!-- left pages -->
  <path d="M60 30c-5 0 -25 -2 -32 4v56c7 -4 27 -3 32 0"/>
  <!-- right pages -->
  <path d="M60 30c5 0 25 -2 32 4v56c-7 -4 -27 -3 -32 0"/>
  <!-- pen angled bottom-right -->
  <path d="M82 95l12 -18"/>
  <path d="M80 93l2 2 14 -18 -2 -2z"/>
  <!-- ink dot at nib — gold accent -->
  <circle cx="82" cy="95" r="2.5" fill="#D4A25A" stroke="none"/>
</svg>
```

#### 2. `empty_issues.svg` — tangled thread becoming straight, straightened part in gold

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- tangled section left -->
  <path d="M10 60c6 -14 8 10 14 -6s4 18 10 2c4 -10 6 8 10 -4"/>
  <!-- crossing loop in the tangle -->
  <path d="M30 52c4 8 -2 16 6 12"/>
  <!-- straightened section right — gold -->
  <path d="M54 56h56" stroke="#D4A25A"/>
  <!-- small knot where tangle meets straight -->
  <circle cx="54" cy="58" r="3" stroke="currentColor"/>
</svg>
```

#### 3. `empty_core_points.svg` — compass with gold needle tip

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- compass body circle -->
  <circle cx="60" cy="60" r="38"/>
  <!-- tick marks N E S W -->
  <path d="M60 22v8"/>
  <path d="M60 90v8"/>
  <path d="M22 60h8"/>
  <path d="M90 60h8"/>
  <!-- needle pointing north — top half gold -->
  <path d="M60 32l4 28h-8z" fill="#D4A25A" stroke="none"/>
  <!-- needle bottom half -->
  <path d="M60 88l4 -28h-8z" fill="none" stroke="currentColor"/>
  <!-- centre pin -->
  <circle cx="60" cy="60" r="2.5"/>
</svg>
```

#### 4. `welcome.svg` — horizon sunrise with text-lines below, half-disc gold

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- half-disc sunrise — gold fill -->
  <path d="M35 58a25 25 0 0 1 50 0" fill="#D4A25A" stroke="none"/>
  <!-- horizon line -->
  <path d="M15 58h90"/>
  <!-- three short text lines below the horizon -->
  <path d="M38 72h44"/>
  <path d="M42 82h36"/>
  <path d="M48 92h24"/>
</svg>
```

#### 5. `export_done.svg` — pages fanning out of an open box, gold checkmark on one

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- box base -->
  <path d="M25 70h70v25a3 3 0 0 1 -3 3H28a3 3 0 0 1 -3 -3z"/>
  <!-- box flaps -->
  <path d="M25 70l8 -8h54l8 8"/>
  <!-- page left -->
  <rect x="36" y="26" width="20" height="30" rx="2" transform="rotate(-8 46 41)"/>
  <!-- page centre -->
  <rect x="48" y="22" width="20" height="30" rx="2"/>
  <!-- page right, slightly rotated -->
  <rect x="62" y="26" width="20" height="30" rx="2" transform="rotate(8 72 41)"/>
  <!-- gold checkmark on centre page -->
  <path d="M53 35l3 4 7 -8" stroke="#D4A25A" stroke-width="2"/>
</svg>
```

#### 6. `lock_screen.svg` — closed journal with a gold clasp

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" fill="none"
     stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <!-- book cover -->
  <rect x="28" y="18" width="64" height="84" rx="4"/>
  <!-- spine edge -->
  <path d="M36 18v84"/>
  <!-- horizontal page lines -->
  <path d="M44 42h36"/>
  <path d="M44 54h28"/>
  <path d="M44 66h32"/>
  <!-- clasp — gold -->
  <rect x="86" y="52" width="10" height="16" rx="3" fill="#D4A25A" stroke="none"/>
  <!-- clasp keyhole -->
  <circle cx="91" cy="60" r="2" fill="none" stroke="#131211" stroke-width="1.2"/>
</svg>
```

---

### 3C. Flutter illustration widget — `lib/ui/illustrations/day_illustrations.dart`

Add `flutter_svg` to pubspec.yaml if not already present:
```yaml
dependencies:
  flutter_svg: ^2.0.10
```

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DayIllustrationName {
  emptyJournal,
  emptyIssues,
  emptyCorePoints,
  welcome,
  exportDone,
  lockScreen,
}

class DayIllustration extends StatelessWidget {
  final DayIllustrationName name;
  final double size;

  const DayIllustration({
    super.key,
    required this.name,
    this.size = 120,
  });

  String get _assetPath {
    const map = {
      DayIllustrationName.emptyJournal: 'assets/illustrations/empty_journal.svg',
      DayIllustrationName.emptyIssues: 'assets/illustrations/empty_issues.svg',
      DayIllustrationName.emptyCorePoints: 'assets/illustrations/empty_core_points.svg',
      DayIllustrationName.welcome: 'assets/illustrations/welcome.svg',
      DayIllustrationName.exportDone: 'assets/illustrations/export_done.svg',
      DayIllustrationName.lockScreen: 'assets/illustrations/lock_screen.svg',
    };
    return map[name]!;
  }

  @override
  Widget build(BuildContext context) {
    // PaletteProvider is defined in Phase 1 tokens.dart
    // It provides the current Palette via an InheritedWidget.
    final palette = PaletteProvider.of(context);
    final isNight = palette.ground == const Color(0xFF131211);

    // The SVGs use currentColor for lines and #D4A25A for gold accents.
    // In Night mode those values are correct as-is.
    // In Day mode we need to swap:
    //   currentColor lines  -> #1E1A15
    //   #D4A25A gold        -> #A8691F
    //
    // flutter_svg does not support per-colour replacement, so we use
    // a two-SVG approach: the SVGs are authored with Night colours, and
    // in Day mode we apply string replacement before parsing.

    if (isNight) {
      return SvgPicture.asset(
        _assetPath,
        width: size,
        height: size,
        theme: const SvgTheme(currentColor: Color(0xFFF2EEE6)),
      );
    }

    // Day mode: load SVG string, replace colours, parse.
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(_assetPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox(width: size, height: size);
        final svg = snapshot.data!
            .replaceAll('#D4A25A', '#A8691F')
            .replaceAll('#131211', '#1E1A15');
        return SvgPicture.string(
          svg,
          width: size,
          height: size,
          theme: const SvgTheme(currentColor: Color(0xFF1E1A15)),
        );
      },
    );
  }
}
```

Optimisation note: `DefaultAssetBundle.loadString` caches across the process, so rebuilds are cheap. If profiling shows the `FutureBuilder` causes frame drops on theme toggle, move the Day-mode SVG strings into a static cache map and pre-load them in `main()` before `runApp`.

---

### 3D. App icon refinement

The app icon SVG already lives at `native/assets/icon/icon.svg` (from Prompt 1). Do not change it. Two additional files are needed for Android's adaptive-icon system:

**Foreground only** — `native/assets/icon/icon_foreground.svg`

This is the half-disc, line, and bar WITHOUT the dark rounded-rect background, centred on a transparent 1024x1024 canvas. The shapes occupy 60% of the width (614px), centred, leaving room inside the 66% adaptive-icon safe zone.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <!-- all shapes shifted to centre and scaled to ~60% of canvas -->
  <path d="M367 572A145 145 0 0 1 657 572Z" fill="#D4A25A"/>
  <rect x="307" y="572" width="410" height="20" rx="10" fill="#F2EEE6"/>
  <rect x="380" y="620" width="264" height="12" rx="6" fill="#6E6960"/>
</svg>
```

Generate the PNG:
```bash
cd native
node -e "require('sharp')('assets/icon/icon_foreground.svg').resize(1024,1024).png().toFile('assets/icon/icon_foreground.png')"
```

Ensure `pubspec.yaml` has:
```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  remove_alpha_ios: true
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#17120D"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
    icon_size: 256
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

Then run:
```bash
dart run flutter_launcher_icons
```

Verify: on an Android emulator or device, the adaptive icon shows the gold half-disc on the dark `#17120D` background, properly masked in circle, squircle, and rounded-square shapes without clipping.

---

### 3E. Acceptance

1. `flutter analyze` — zero errors related to icon or illustration imports.
2. Open the `/design` gallery (from Phase 2) and add a section at the bottom titled "Icons & Illustrations" that renders:
   - All 8 `DayIcon` widgets at size 24 and size 36 in both Night and Day palettes.
   - All 6 `DayIllustration` widgets at size 120 in both Night and Day palettes.
3. Visually confirm on a 1280x800 window and a 390x844 window:
   - Every SVG is crisp, not blurry (vector rendering, no rasterisation artefacts).
   - Gold accent touches are visible and correctly coloured per theme.
   - Line colour switches from cream (`#F2EEE6`) in Night to near-black (`#1E1A15`) in Day.
4. Confirm that the sidebar Journal, Issues, Core Points rows, the New Entry button, the Export row, Take a Minute row, and the Lock screen each use the corresponding `DayIcon` instead of a Lucide icon.
5. Screenshots: `docs/screens/icons-night.png`, `docs/screens/icons-day.png`, `docs/screens/illustrations-night.png`, `docs/screens/illustrations-day.png`.
6. Commit: `custom iconography and spot illustrations — 8 icons, 6 illustrations, themed`.
7. Write to REDESIGN_PROGRESS.md: icon count, illustration count, any SVG rendering issues found and fixed.

---

## PHASE 4 — SCREEN-BY-SCREEN REBUILD (90 min)

Every screen below is a bespoke widget. No Material `AppBar`, `Drawer`, `BottomNavigationBar`, `ListTile`, `Card`, `AlertDialog`, `TextField`, or any other stock widget with default styling. Where a raw `TextField` is used for text input, wrap it in `InputDecorator`-free configuration: `decoration: InputDecoration.collapsed(hintText: ...)` or `decoration: const InputDecoration(border: InputBorder.none, ...)`. Every colour, size, radius, padding, and animation value comes from the tokens in `lib/ui/tokens.dart`. If a value is written below, use it literally.

Use `go_router` (add `go_router: ^14.0.0` to pubspec.yaml). All routes are named. The router lives in `lib/ui/router.dart`.

```dart
// lib/ui/router.dart — route table (pseudocode, implement fully)
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final locked = ref.read(lockProvider);
    if (locked && state.matchedLocation != '/lock') return '/lock';
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/entry/:id', name: 'entry', builder: (_, state) => EntryEditorScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/issue/:id', name: 'issue', builder: (_, state) => IssueDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/core/:id', name: 'core', builder: (_, state) => CorePointScreen(id: state.pathParameters['id']!)),
      ],
    ),
    GoRoute(path: '/account', name: 'account', builder: (_, __) => const AccountScreen()),
    GoRoute(path: '/plan', name: 'plan', builder: (_, __) => const PlanScreen()),
    GoRoute(path: '/sign-in', name: 'sign-in', builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/lock', name: 'lock', builder: (_, __) => const LockScreen()),
    GoRoute(path: '/minute', name: 'minute', builder: (_, __) => const MinuteScreen()),
    GoRoute(path: '/export', name: 'export', builder: (_, __) => const ExportScreen()),
    GoRoute(path: '/student', name: 'student', builder: (_, __) => const StudentScreen()),
  ],
);
```

Page transitions per platform:
- Android: `ZoomPageTransitionsBuilder()` — 360ms
- iOS / macOS: `CupertinoPageTransitionsBuilder()` — 360ms
- Windows / Linux: `FadeUpwardsPageTransitionsBuilder()` — 360ms
Override in `ThemeData.pageTransitionsTheme`.

---

### 4A. Navigation Shell — `lib/ui/shell/app_shell.dart`

The shell wraps the `ShellRoute` children only: `/`, `/entry/:id`, `/issue/:id`, `/core/:id`. Every other route (`/account`, `/plan`, `/sign-in`, `/lock`, `/minute`, `/export`, `/student`) is a top-level `GoRoute` rendered full-screen with NO sidebar, NO drawer, and NO bottom navigation.

```dart
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final w = MediaQuery.of(context).size.width;

    if (w >= 600) {
      // Desktop (>=900) or Tablet (600–899)
      final sideW = w >= 900 ? 288.0 : 256.0;
      return ColoredBox(
        color: palette.ground,
        child: Row(
          children: [
            SizedBox(width: sideW, child: DaySidebar(width: sideW)),
            Container(width: 1, color: palette.hairline),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone (<600)
    return Scaffold(
      backgroundColor: palette.ground,
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 40,
      drawerScrimColor: Colors.black54,
      drawer: SizedBox(
        width: (w * 0.86).clamp(0, 340),
        child: ColoredBox(
          color: palette.sidebar,
          child: SafeArea(child: DaySidebar(width: (w * 0.86).clamp(0, 340))),
        ),
      ),
      body: Column(
        children: [
          const DayTopBar(),
          Expanded(child: child),
          const DayBottomNav(),
        ],
      ),
    );
  }
}
```

Key constraints:
- The `Scaffold.drawer` is used ONLY for the phone layout because Flutter's `Scaffold` provides the swipe-to-open gesture. On tablet and desktop, the sidebar is always visible and there is no drawer.
- Safe area insets are respected on every platform.
- The 1px vertical divider between the sidebar and content uses `palette.hairline`, not `Divider` or `VerticalDivider` (those carry Material defaults). Use a plain `Container(width: 1, color: palette.hairline)`.

---

### 4B. Sidebar — `lib/ui/shell/day_sidebar.dart`

File: `lib/ui/shell/day_sidebar.dart`. Background: `palette.sidebar`. The entire sidebar is a `Column` with `crossAxisAlignment: CrossAxisAlignment.stretch`.

**Structure, top to bottom, with exact spacing:**

```
┌─────────────────────────────┐
│  Header (h:64, padL:16)     │  ← symbol + "Day Before"
│                             │
│  SizedBox(h:12)             │
│                             │
│  New entry button (mx:12)   │  ← h:40, r:8, raised bg, hairline border
│                             │
│  SizedBox(h:20)             │
│                             │
│  ╔═ JOURNAL section ═══════╗│  ← overline header + collapsible items
│  ║  SizedBox(h:20) above   ║│
│  ║  header row (h:28)      ║│
│  ║  AnimatedSize items     ║│
│  ╚═════════════════════════╝│
│                             │
│  ╔═ ISSUES section ════════╗│
│  ║  SizedBox(h:20) above   ║│
│  ║  header row (h:28)      ║│
│  ║  AnimatedSize items     ║│
│  ╚═════════════════════════╝│
│                             │
│  ╔═ CORE POINTS section ═══╗│
│  ║  SizedBox(h:20) above   ║│
│  ║  header row (h:28)      ║│
│  ║  AnimatedSize items     ║│
│  ╚═════════════════════════╝│
│                             │
│  Spacer()                   │  ← pushes footer to bottom
│                             │
│  Footer (hairline + rows)   │  ← Take a minute, Export, Account
└─────────────────────────────┘
```

**Header (height 64)**
```dart
Container(
  height: 64,
  padding: const EdgeInsets.only(left: 16),
  alignment: Alignment.centerLeft,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DayIcon('horizon', size: 22, color: palette.accent),
      const SizedBox(width: 10),
      Text('Day Before',
        style: TextStyle(fontFamily: 'Gelasio', fontSize: 20, height: 26 / 20,
          fontWeight: FontWeight.w600, color: palette.text)),
    ],
  ),
)
```

**New entry button (margin horizontal 12)**
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: DayButton.custom(
    height: 40,
    borderRadius: 8,
    background: palette.raised,
    border: BorderSide(color: palette.hairline, width: 1),
    hoverBackground: palette.hover,
    pressScale: 0.98,
    pressDuration: const Duration(milliseconds: 80),
    onTap: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DayIcon('new-entry', size: 18, color: palette.muted),
        const SizedBox(width: 10),
        Text('New entry',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14,
            fontWeight: FontWeight.w500, color: palette.text)),
      ],
    ),
  ),
)
```

**Collapsible section (repeat for Journal, Issues, Core Points)**

Each section is a `_SidebarSection` widget. The 20px gap goes ABOVE each section header, not below.

```dart
class _SidebarSection extends StatefulWidget {
  final String title;           // "JOURNAL", "ISSUES", "CORE POINTS"
  final List<SidebarItem> items;
  final String? selectedId;
  final VoidCallback onAdd;

  // ...
}

class _SidebarSectionState extends State<_SidebarSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                Text(widget.title,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 16 / 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.9,
                    color: palette.muted)),
                const Spacer(),
                // Add button
                _HoverContainer(
                  size: 28, borderRadius: 6, hoverColor: palette.hover,
                  onTap: widget.onAdd,
                  child: DayIcon('plus', size: 16, color: palette.muted),
                ),
                const SizedBox(width: 4),
                // Collapse chevron
                _HoverContainer(
                  size: 28, borderRadius: 6, hoverColor: palette.hover,
                  onTap: () => setState(() => _collapsed = !_collapsed),
                  child: AnimatedRotation(
                    turns: _collapsed ? 0.0 : 0.25,
                    duration: const Duration(milliseconds: 220),
                    curve: Mo.curve,
                    child: DayIcon('chevron-right', size: 16, color: palette.faint),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Collapsible item list
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Mo.curve,
          clipBehavior: Clip.hardEdge,
          child: _collapsed
            ? const SizedBox.shrink()
            : Column(
                children: widget.items.map((item) => _SidebarItem(
                  label: item.label,
                  selected: item.id == widget.selectedId,
                  onTap: () => item.onTap(),
                )).toList(),
              ),
        ),
      ],
    );
  }
}
```

**Sidebar item row**
```dart
class _SidebarItem extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  // ...
}

// Build:
SizedBox(
  height: 32,
  child: Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: widget.onTap,
      hoverColor: palette.hover,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: widget.selected
          ? BoxDecoration(color: palette.hover, borderRadius: BorderRadius.circular(4))
          : null,
        child: Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 14, height: 20 / 14,
            color: widget.selected ? palette.text : palette.muted,
          ),
        ),
      ),
    ),
  ),
)
```

Item label rules:
- **Journal items:** the first non-empty line of the entry text. If blank, format the date: `"Mon 5 Oct"` (abbreviated weekday, day, abbreviated month).
- **Issue items:** the issue name.
- **Core Point items:** the point text, truncated to one line.

**Footer (pinned to bottom)**
```dart
Column(
  children: [
    const Spacer(), // <-- this pushes footer to the bottom of the Column
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(height: 1, color: palette.hairline),
    ),
    const SizedBox(height: 8),
    _FooterRow(icon: 'take-a-minute', label: 'Take a minute', onTap: () => context.go('/minute')),
    _FooterRow(icon: 'export', label: 'Export', onTap: () => context.go('/export')),
    _FooterRow(
      leading: DayAvatar(size: 28, email: authState.email),
      label: authState.email ?? 'Not signed in',
      onTap: () => context.go('/account'),
    ),
    const SizedBox(height: 12),
  ],
)
```

Each `_FooterRow`:
```dart
SizedBox(
  height: 36,
  child: Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: onTap,
      hoverColor: palette.hover,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            leading ?? DayIcon(icon!, size: 18, color: palette.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14,
                  color: palette.muted)),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

**BANNED from the sidebar:** the strings "Subscribe on website", "Sign In", "Sign In / Sync", "Sync", "Upgrade", "Go Pro", or any variant. These words DO NOT appear anywhere in the sidebar under any circumstance.

---

### 4C. Phone top bar — `lib/ui/shell/day_top_bar.dart`

```dart
class DayTopBar extends StatelessWidget {
  const DayTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final sectionName = _currentSectionName(context); // "Journal", "Issues", "Core Points"
    return Container(
      height: 56,
      color: palette.ground,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          // Menu button — opens the drawer
          SizedBox(
            width: 44, height: 44,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                customBorder: const CircleBorder(),
                hoverColor: palette.hover,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Center(child: DayIcon('menu', size: 22, color: palette.text)),
              ),
            ),
          ),
          // Centered title
          Expanded(
            child: Center(
              child: Text(sectionName,
                style: TextStyle(fontFamily: 'Gelasio', fontSize: 18, height: 24 / 18,
                  fontWeight: FontWeight.w500, color: palette.text)),
            ),
          ),
          // New entry button
          SizedBox(
            width: 44, height: 44,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
                customBorder: const CircleBorder(),
                hoverColor: palette.hover,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Center(child: DayIcon('new-entry', size: 22, color: palette.text)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

The top bar sits above the `SafeArea` content zone. Apply `MediaQuery.of(context).padding.top` as top padding inside the Container so it extends under the status bar with the ground colour.

---

### 4D. Phone drawer

The drawer is provided by `Scaffold.drawer` in the phone shell (section 4A). Configuration on the `Scaffold`:

```dart
drawerEnableOpenDragGesture: true,
drawerEdgeDragWidth: 40,
drawerScrimColor: Colors.black54,
```

Drawer widget:
```dart
SizedBox(
  width: (MediaQuery.of(context).size.width * 0.86).clamp(0.0, 340.0),
  child: ColoredBox(
    color: palette.sidebar,
    child: SafeArea(
      child: DaySidebar(
        width: (MediaQuery.of(context).size.width * 0.86).clamp(0.0, 340.0),
      ),
    ),
  ),
)
```

The drawer content is the exact same `DaySidebar` widget used on tablet and desktop. Every tap inside the drawer that navigates to a new route must also close the drawer: `Navigator.of(context).pop()` before `context.go(...)`, or use `Scaffold.of(context).closeDrawer()`.

Swiping from the left edge (0 to 40px) MUST smoothly open the drawer, tracking the finger. This is Flutter's built-in behaviour when `drawerEnableOpenDragGesture: true` and `drawerEdgeDragWidth: 40`. Do NOT override it with a custom `GestureDetector`.

---

### 4E. Phone bottom navigation — `lib/ui/shell/day_bottom_nav.dart`

Do NOT use `BottomNavigationBar`, `NavigationBar`, or `NavigationRail`. Build from scratch.

```dart
class DayBottomNav extends StatelessWidget {
  const DayBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 64 + bottomPad,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: palette.ground,
        border: Border(top: BorderSide(color: palette.hairline, width: 1)),
      ),
      child: Row(
        children: [
          _NavItem(icon: 'journal', label: 'Journal', active: currentRoute == '/' || currentRoute.startsWith('/entry'), onTap: () => context.go('/')),
          _NavItem(icon: 'issues', label: 'Issues', active: currentRoute.startsWith('/issue'), onTap: () => context.go('/issues')),
          _NavItem(icon: 'core-points', label: 'Core Points', active: currentRoute.startsWith('/core'), onTap: () => context.go('/core-points')),
          _NavItem(icon: 'account', label: 'Account', active: currentRoute == '/account', onTap: () => context.go('/account')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final color = active ? palette.accent : palette.muted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Active pill indicator
                AnimatedOpacity(
                  opacity: active ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 140),
                  child: Container(
                    width: 48, height: 32,
                    decoration: BoxDecoration(
                      color: palette.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                DayIcon(icon, size: 22, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 16 / 11,
                fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
```

The bottom nav is shown ONLY on the phone layout, ONLY on shell routes (/, /entry/:id, /issue/:id, /core/:id). It is NOT shown on full-screen routes (/account, /plan, /sign-in, /lock, /minute, /export).

---

### 4F. Home / Empty state — `lib/ui/screens/home_screen.dart`

Route: `/` when there are no entries, or when no entry is selected on desktop (the content pane of the shell).

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final phone = isPhone(context);
    final entries = context.watch<JournalProvider>().entries;

    if (entries.isNotEmpty && !phone) {
      return const JournalListScreen(); // desktop: show list in content pane
    }
    if (entries.isNotEmpty && phone) {
      return const JournalListScreen(); // phone: show list
    }

    // Empty state
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DayIllustration(name: DayIllustrationName.welcome, size: 80),
                const SizedBox(height: 24),
                Text('Write the day down.',
                  textAlign: TextAlign.center,
                  style: Ty.display(palette.text, phone: phone)),
                const SizedBox(height: 12),
                Text('Or return to something that keeps coming back.',
                  textAlign: TextAlign.center,
                  style: Ty.body(palette.muted)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DayButton(
                      label: 'New entry',
                      variant: DayButtonVariant.primary,
                      onTap: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
                    ),
                    const SizedBox(width: 12),
                    DayButton(
                      label: 'Open an issue',
                      variant: DayButtonVariant.quiet,
                      onTap: () => context.goNamed('issue', pathParameters: {'id': 'new'}),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 4G. Journal list — `lib/ui/screens/journal_list_screen.dart`

A `CustomScrollView` with `SliverStickyHeader`-style month groups. Use the `sliver_tools` package (`sliver_tools: ^0.2.0`) for `SliverStickyHeader`, or implement with `SliverPersistentHeader`.

```
Month header (sticky):
  ├─ padding: top 24 (except first group: 0), bottom 8, horizontal 16 (desktop: 32)
  ├─ text: Gelasio 15/20 w500, palette.muted
  └─ e.g. "October 2026"

Entry card:
  ├─ DayCard (background: palette.raised, borderRadius: 14, border: 1px palette.hairline)
  │   ├─ padding: 16 all sides
  │   ├─ Date line: overline style (Inter 11/16 w600, uppercase, palette.muted)
  │   │   e.g. "MONDAY 5 OCTOBER"
  │   ├─ SizedBox(height: 6)
  │   ├─ Title: Gelasio 18/24 w500, palette.text, maxLines 1, ellipsis
  │   │   If no title: "Untitled" in palette.faint
  │   ├─ SizedBox(height: 4)
  │   └─ Preview: Inter 14/20, palette.muted, maxLines 2, ellipsis
  └─ onTap: context.goNamed('entry', pathParameters: {'id': entry.id})

Between cards: SizedBox(height: 12)
List padding: horizontal 16 (phone) or 32 (desktop), vertical 16
```

Empty state (when the journal has zero entries):
```dart
DayEmptyState(
  illustration: DayIllustrationName.emptyJournal,
  text: 'Nothing here yet. Write the day, or only a line of it, whichever you have.',
)
```

---

### 4H. Entry editor — `lib/ui/screens/entry_editor_screen.dart`

Route: `/entry/:id` where `id` is a UUID or the string `"new"`.

Layout:
```
┌──────────────────────────────────────────────────────┐
│  ← (back, phone only)              "Saved" ⋮ (menu) │
│                                                      │
│           TUESDAY 6 OCTOBER 2026                     │  ← overline
│                                                      │
│           Untitled                                    │  ← title field, Gelasio 30/38 w500
│                                                      │
│           Write the day, or only a                    │  ← body field, Gelasio 19/31
│           line of it.                                 │
│                                                      │
│                                                      │
│                                                      │
└──────────────────────────────────────────────────────┘
```

```dart
class EntryEditorScreen extends StatefulWidget {
  final String id;
  const EntryEditorScreen({super.key, required this.id});
  // ...
}

// Build method core:
SingleChildScrollView(
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isPhone(context) ? 20.0 : 32.0,
        ).copyWith(
          top: isPhone(context) ? 20.0 : 56.0,
          bottom: 120, // room to scroll past the text
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button row (phone, or always if this is a full-screen push)
            if (isPhone(context)) ...[
              Row(
                children: [
                  DayIconButton(icon: 'back', size: 44, onTap: () => context.pop()),
                  const Spacer(),
                  _SavedIndicator(visible: _justSaved),
                  const SizedBox(width: 8),
                  _OverflowMenu(onDelete: _confirmDelete),
                ],
              ),
              const SizedBox(height: 8),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _SavedIndicator(visible: _justSaved),
                  const SizedBox(width: 8),
                  _OverflowMenu(onDelete: _confirmDelete),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Date
            Text(
              _formatDate(entry.createdAt), // "TUESDAY 6 OCTOBER 2026"
              style: Ty.overline(palette.muted),
            ),
            const SizedBox(height: 16),
            // Title
            TextField(
              controller: _titleController,
              style: Ty.title(palette.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Untitled',
                hintStyle: Ty.title(palette.faint),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: palette.accent,
              selectionControls: _selectionControls(palette),
              onChanged: (_) => _scheduleAutosave(),
            ),
            const SizedBox(height: 16),
            // Body
            TextField(
              controller: _bodyController,
              style: isPhone(context) ? Ty.writing(palette.text, phone: true) : Ty.writing(palette.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write the day, or only a line of it.',
                hintStyle: isPhone(context) ? Ty.writing(palette.faint, phone: true) : Ty.writing(palette.faint),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              cursorColor: palette.accent,
              selectionControls: _selectionControls(palette),
              onChanged: (_) => _scheduleAutosave(),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

Selection colour: `palette.accent.withOpacity(0.3)`. Set via `TextSelectionThemeData` on the local `Theme`.

Autosave: after 600ms of no keystrokes, encrypt and save to local storage. Show the "Saved" indicator.

**"Saved" indicator:**
```dart
class _SavedIndicator extends StatelessWidget {
  final bool visible;
  const _SavedIndicator({required this.visible});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: visible ? 140 : 300),
      child: Text('Saved', style: Ty.caption(palette.faint)),
    );
  }
}
```
Logic: set `_justSaved = true` on save, then after 1200ms set it to `false`. The fade-in is 140ms, the fade-out is 300ms (controlled by the ternary on duration).

**Overflow menu** (three-dot icon top right): a `DayIconButton` that opens a small positioned dropdown (NOT `PopupMenuButton`). Build with `OverlayEntry`:
- "Delete entry" — text in `palette.danger` — tapping opens a `DayModal` confirmation: "Delete this entry? This cannot be undone." with "Cancel" (quiet) and "Delete" (danger) buttons.

On phone: the same overflow menu is available. Alternatively, long-press on the entry in the journal list can show a context menu with "Delete."

---

### 4I. Issues list — `lib/ui/screens/issues_list_screen.dart`

Similar structure to the journal list, but each card has a left accent thread.

```
Issue card:
  ├─ DayCard (raised bg, borderRadius 14, hairline border)
  │   ├─ Stack
  │   │   ├─ Positioned(left: 0, top: 8, bottom: 8)
  │   │   │   └─ Container(width: 3, borderRadius: 1.5, color: palette.accent)
  │   │   └─ Padding(left: 16 + 12 = 28, top: 16, right: 16, bottom: 16)
  │   │       ├─ Name: Gelasio 18/24 w500, palette.text, maxLines 1, ellipsis
  │   │       ├─ SizedBox(height: 4)
  │   │       ├─ Theory preview: Inter 14/20, palette.muted, maxLines 2, ellipsis
  │   │       ├─ SizedBox(height: 8)
  │   │       └─ Row:
  │   │           ├─ Text("3 returns", Inter 12/16, palette.faint)
  │   │           ├─ SizedBox(width: 16)
  │   │           └─ Text("Last: 12 Oct", Inter 12/16, palette.faint)
  └─ onTap: context.goNamed('issue', pathParameters: {'id': issue.id})
```

The accent thread is a 3px-wide Container with `borderRadius: BorderRadius.circular(1.5)` in `palette.accent`, positioned at the left edge of the card, inset 8px from the top and bottom. It visually connects to the Issue detail's timeline.

Cards separated by `SizedBox(height: 12)`. List padding matches journal list.

Empty state:
```dart
DayEmptyState(
  illustration: DayIllustrationName.emptyIssues,
  text: 'Name something you keep getting wrong.',
)
```

---

### 4J. Issue detail — `lib/ui/screens/issue_detail_screen.dart`

Route: `/issue/:id`. This is the core of the product: the loop of name → theory → return → revise → read back.

Layout:
```
┌──────────────────────────────────────────────────────┐
│  ← Issues → A short temper          (breadcrumb, dt) │
│  ← (back button, phone)                              │
│                                                      │
│  A short temper                                      │  ← editable name, Gelasio 30/38 w500
│                                                      │
│  ┌─────────┬──────────┬───────────────┐              │
│  │ Theory  │ Returns  │ Read it back  │              │  ← DayTab row
│  └─────────┴──────────┴───────────────┘              │
│                                                      │
│  (tab content below)                                 │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Breadcrumb (desktop only):**
```dart
Row(
  children: [
    GestureDetector(
      onTap: () => context.go('/'),
      child: Text('Issues', style: Ty.label(palette.muted)),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DayIcon('chevron-right', size: 14, color: palette.faint),
    ),
    Text(issue.name, style: Ty.label(palette.text)),
  ],
)
```

**Name field:**
```dart
TextField(
  controller: _nameController,
  style: Ty.title(palette.text), // Gelasio 30/38 w500
  decoration: InputDecoration(
    border: InputBorder.none,
    hintText: 'Name this issue',
    hintStyle: Ty.title(palette.faint),
    isDense: true,
    contentPadding: EdgeInsets.zero,
  ),
  cursorColor: palette.accent,
  onChanged: (_) => _scheduleAutosave(),
)
```

**Tabs:** a `DayTab` row with three labels: "Theory", "Returns", "Read it back". See the DayTab component from Phase 2. The active tab content is shown below, switched with `IndexedStack` or conditionally built.

---

**Theory tab:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const SizedBox(height: 24),
    // Current theory — editable
    TextField(
      controller: _theoryController,
      style: Ty.writing(palette.text, phone: isPhone(context)),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Write what you think causes it and what you will try.',
        hintStyle: Ty.writing(palette.faint, phone: isPhone(context)),
        isDense: true, contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
      cursorColor: palette.accent,
      onChanged: (_) => _scheduleTheorySave(), // creates a new revision on save
    ),
    const SizedBox(height: 32),
    // Revisions section
    Row(
      children: [
        Text('REVISIONS', style: Ty.overline(palette.muted)),
        const SizedBox(width: 8),
        Text('(${revisions.length})', style: Ty.caption(palette.faint)),
      ],
    ),
    const SizedBox(height: 12),
    // List of past revisions, newest first
    ...revisions.map((rev) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _RevisionCard(
        revision: rev,
        isCurrent: rev == revisions.first,
      ),
    )),
  ],
)
```

**_RevisionCard:** a `DayCard` that is collapsed by default (showing only the date overline and first-line preview). On tap, it expands with `AnimatedSize(duration: 220ms, curve: Mo.curve)` to reveal the full text. The current revision (newest) has a `DayStatusPill(label: 'Current', color: palette.accent)` beside its date.

---

**Returns tab:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    const SizedBox(height: 16),
    DayButton(
      label: 'Add a return',
      variant: DayButtonVariant.quiet,
      onTap: _addReturn,
    ),
    const SizedBox(height: 16),
    // List of returns, newest first
    ...returns.map((ret) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DayCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_formatDate(ret.date), style: Ty.overline(palette.muted)),
              const SizedBox(height: 8),
              // Editable on tap (toggle between Text and TextField)
              ret.editing
                ? TextField(
                    controller: ret.controller,
                    style: Ty.writing(palette.text, phone: isPhone(context)),
                    maxLines: null,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    cursorColor: palette.accent,
                    autofocus: true,
                    onEditingComplete: () => _saveReturn(ret),
                  )
                : GestureDetector(
                    onTap: () => _startEditing(ret),
                    child: Text(ret.text, style: Ty.writing(palette.text, phone: isPhone(context))),
                  ),
            ],
          ),
        ),
      ),
    )),
  ],
)
```

When "Add a return" is tapped, a new card appears at the top with today's date, an autofocused empty text field, and the hint "What happened this time?"

---

**Read it back tab:**

A chronological timeline (oldest first) interleaving revisions and returns.

```
Timeline layout:
  ├─ 1px vertical line (palette.accent at 40% opacity), positioned left 20px from content left
  │
  ├─ Node 1 (Revision):
  │   ├─ Circle: 8px diameter, filled palette.accent, centered on the line
  │   ├─ Date: overline, to the left of circle on desktop; above on phone
  │   └─ Card (right of line, left margin 36px):
  │       ├─ Type label: "Revision 1" in DayStatusPill (accent)
  │       ├─ SizedBox(height: 8)
  │       └─ Body text in writing style
  │
  ├─ SizedBox(height: 16) between nodes
  │
  ├─ Node 2 (Return):
  │   ├─ Circle: 8px diameter, filled palette.faint
  │   ├─ Date overline
  │   └─ Card:
  │       ├─ Type label: "Return, 12 Oct" in DayStatusPill (default/muted)
  │       └─ Body text
  │
  ├─ Node 3 (Revision):
  │   ├─ Circle: accent
  │   ├─ Date
  │   └─ Card:
  │       ├─ "Revision 2" pill (accent)
  │       ├─ Body text with CHANGED WORDS highlighted:
  │       │   background palette.accent.withOpacity(0.15) on words
  │       │   that differ from the previous revision
  │       └─ (use a simple word-level diff: split both texts by whitespace,
  │           compare token by token, wrap changed tokens in a highlighted span)
  │
  └─ ... continues chronologically
```

Implementation:
```dart
Widget _buildTimeline(List<TimelineNode> nodes) {
  return Stack(
    children: [
      // Vertical accent line
      Positioned(
        left: 20,
        top: 0,
        bottom: 0,
        child: Container(
          width: 1,
          color: palette.accent.withOpacity(0.4),
        ),
      ),
      // Nodes
      Column(
        children: nodes.asMap().entries.map((entry) {
          final i = entry.key;
          final node = entry.value;
          final isRevision = node.type == TimelineNodeType.revision;
          return Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle indicator
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRevision ? palette.accent : palette.faint,
                      ),
                    ),
                  ),
                ),
                // Content card
                Expanded(
                  child: DayCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DayStatusPill(
                                label: isRevision ? 'Revision ${node.revisionNumber}' : 'Return, ${_shortDate(node.date)}',
                                color: isRevision ? palette.accent : null,
                              ),
                              const Spacer(),
                              Text(_formatDate(node.date), style: Ty.overline(palette.muted)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          isRevision && node.diffSpans != null
                            ? _buildDiffText(node.text, node.diffSpans!, palette)
                            : Text(node.text, style: Ty.writing(palette.text, phone: isPhone(context))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}
```

Word-level diff highlighting:
```dart
Widget _buildDiffText(String text, List<DiffSpan> spans, Palette palette) {
  return Text.rich(
    TextSpan(
      children: spans.map((span) => TextSpan(
        text: span.text,
        style: Ty.writing(palette.text, phone: isPhone(context)).copyWith(
          backgroundColor: span.changed ? palette.accent.withOpacity(0.15) : null,
        ),
      )).toList(),
    ),
  );
}
```

---

### 4K. Core Points list — `lib/ui/screens/core_points_screen.dart`

Route: shown in the shell when the Core Points sidebar section is selected.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    if (!isPhone(context)) ...[
      Padding(
        padding: EdgeInsets.only(left: 32, top: 48),
        child: Text('Core Points', style: Ty.title(palette.text)),
      ),
      const SizedBox(height: 24),
    ],
    Expanded(
      child: points.isEmpty
        ? DayEmptyState(
            illustration: DayIllustrationName.emptyCorePoints,
            text: 'What are the few standards you would like to be held to?',
          )
        : ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isPhone(context) ? 20.0 : 32.0, vertical: 16,
            ),
            itemCount: points.length + 1, // +1 for the "Add" button
            separatorBuilder: (_, __) => Container(height: 1, color: palette.hairline),
            itemBuilder: (context, i) {
              if (i == points.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: DayButton(
                    label: 'Add a standard',
                    variant: DayButtonVariant.quiet,
                    onTap: _addPoint,
                  ),
                );
              }
              final point = points[i];
              return SizedBox(
                height: 52,
                child: Row(
                  children: [
                    DayIcon('core-points', size: 18, color: palette.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: point.controller,
                        style: TextStyle(fontFamily: 'Gelasio', fontSize: 18, height: 26 / 18, color: palette.text),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'A standard to hold yourself to',
                          hintStyle: TextStyle(fontFamily: 'Gelasio', fontSize: 18, height: 26 / 18, color: palette.faint),
                          isDense: true, contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 1,
                        cursorColor: palette.accent,
                        onEditingComplete: () => _save(point),
                        onTapOutside: (_) => _save(point),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    ),
  ],
)
```

---

### 4L. Account — `lib/ui/screens/account_screen.dart`

Route: `/account`. Full screen, no sidebar.

```dart
Scaffold(
  backgroundColor: palette.ground,
  body: SafeArea(
    child: Column(
      children: [
        // Top bar with back button
        SizedBox(
          height: 56,
          child: Row(
            children: [
              DayIconButton(icon: 'back', size: 44, onTap: () => context.pop()),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile
                      DayAvatar(size: 56, email: auth.email),
                      const SizedBox(height: 16),
                      Text(auth.email ?? 'Not signed in', style: Ty.body(palette.text)),
                      const SizedBox(height: 8),
                      DayStatusPill(
                        label: _planLabel(), // "Free", "Sync", "Student"
                        color: _isPaid() ? palette.accent : null,
                      ),
                      const SizedBox(height: 32),
                      // Settings rows
                      _SettingRow(label: 'Plan and sync', value: _planValue(), onTap: () => context.go('/plan')),
                      _SettingRow(label: 'Export your entries', onTap: () => context.go('/export')),
                      _SettingRow(label: 'Privacy lock', value: _lockSettingLabel(), onTap: _showLockSheet),
                      _SettingRow(label: 'Appearance', value: _themeLabel(), onTap: _showAppearanceSheet),
                      if (auth.isSignedIn) ...[
                        _SettingRow(label: 'Recovery key', onTap: _showRecoveryKey),
                        _SettingRow(label: 'Sign out', onTap: _confirmSignOut),
                        _SettingRow(label: 'Delete account', danger: true, onTap: _confirmDelete),
                      ] else
                        _SettingRow(label: 'Sign in', onTap: () => context.go('/sign-in')),
                      const SizedBox(height: 32),
                      Text('Day Before v${packageInfo.version}', style: Ty.caption(palette.faint)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
)
```

**_SettingRow:**
```dart
class _SettingRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool danger;
  final VoidCallback onTap;

  const _SettingRow({required this.label, this.value, this.danger = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            hoverColor: palette.hover,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Text(label, style: Ty.body(danger ? palette.danger : palette.text)),
                  const Spacer(),
                  if (value != null) ...[
                    Text(value!, style: Ty.body(palette.muted)),
                    const SizedBox(width: 8),
                  ],
                  if (!danger) DayIcon('chevron-right', size: 16, color: palette.faint),
                ],
              ),
            ),
          ),
        ),
        Container(height: 1, color: palette.hairline),
      ],
    );
  }
}
```

---

### 4M. Plan screen — `lib/ui/screens/plan_screen.dart`

Route: `/plan`. Full screen. **THE ONLY PLACE in the entire app where subscriptions, prices, or upsell-related content appear.** No other screen, sidebar item, banner, or popup may reference pricing.

```dart
// If NOT subscribed:
Column(
  children: [
    Text('Sync across your devices', style: Ty.title(palette.text)),
    const SizedBox(height: 16),
    Text(
      'Writing is free and stays on this device. Sync keeps your encrypted entries on every device you use.',
      style: Ty.body(palette.muted),
    ),
    const SizedBox(height: 32),
    // Yearly / Monthly toggle
    DayTab(
      labels: const ['Yearly', 'Monthly'],
      selected: _yearly ? 0 : 1,
      onChanged: (i) => setState(() => _yearly = i == 0),
    ),
    const SizedBox(height: 16),
    // Price card
    DayCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _yearly ? '\$20 a year' : '\$2 a month',
              style: Ty.heading(palette.text),
            ),
            if (_yearly) ...[
              const SizedBox(height: 4),
              Text('about \$1.67 a month', style: Ty.caption(palette.muted)),
            ],
          ],
        ),
      ),
    ),
    const SizedBox(height: 12),
    GestureDetector(
      onTap: () => context.go('/student'),
      child: Text('I am a student', style: Ty.body(palette.accent)),
    ),
    const SizedBox(height: 24),
    DayButton(
      label: 'Continue',
      variant: DayButtonVariant.primary,
      fullWidth: true,
      onTap: () async {
        await launchUrl(Uri.parse('$kSiteBase/pricing?from=app'), mode: LaunchMode.externalApplication);
        _startEntitlementPolling(); // poll GET /api/entitlement every 3s for 5 min
      },
    ),
    const SizedBox(height: 12),
    Text(
      'You will finish on the website. If sync ever ends, your entries stay on this device and you can export them.',
      style: Ty.caption(palette.faint),
      textAlign: TextAlign.center,
    ),
  ],
)

// If subscribed:
Column(
  children: [
    Text('Sync across your devices', style: Ty.title(palette.text)),
    const SizedBox(height: 24),
    DayStatusPill(label: 'Sync is on', color: palette.accent),
    const SizedBox(height: 16),
    Text('Renews ${_formatDate(sub.periodEnd)}', style: Ty.body(palette.muted)),
    const SizedBox(height: 24),
    DayButton(
      label: 'Manage on website',
      variant: DayButtonVariant.quiet,
      onTap: () => launchUrl(Uri.parse('$kSiteBase/account'), mode: LaunchMode.externalApplication),
    ),
  ],
)
```

Entitlement polling: after `Continue` is tapped and the browser opens, poll `GET /api/entitlement` every 3 seconds for up to 5 minutes. Also poll on `AppLifecycleState.resumed` (the user returning from the browser). When the entitlement becomes active, rebuild the screen to show the subscribed state.

---

### 4N. Sign in — `lib/ui/screens/sign_in_screen.dart`

Route: `/sign-in`. Full screen.

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 440),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DayIcon('horizon', size: 28, color: palette.accent),
          const SizedBox(height: 24),
          Text('Sign in', style: Ty.title(palette.text)),
          const SizedBox(height: 24),
          DayTextField(
            label: 'Email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          DayTextField(
            label: 'Password',
            controller: _passwordController,
            obscure: true,
            showEyeToggle: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            DayFormError(text: _error!),
          ],
          const SizedBox(height: 24),
          DayButton(
            label: 'Sign in',
            variant: DayButtonVariant.primary,
            fullWidth: true,
            loading: _loading,
            onTap: _signIn,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('$kSiteBase/forgot'), mode: LaunchMode.externalApplication),
            child: Text('Forgot password?', style: Ty.body(palette.accent)),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('$kSiteBase/signup'), mode: LaunchMode.externalApplication),
            child: Text('Create an account', style: Ty.body(palette.accent)),
          ),
        ],
      ),
    ),
  ),
)
```

Error handling: if the API returns 401 or a network error, show `DayFormError` with the appropriate message. Never show raw exception text. Network errors: "Can't reach Day Before. Check your connection and try again." Auth errors: "That email and password did not match."

---

### 4O. Lock screen — `lib/ui/screens/lock_screen.dart`

Route: `/lock`. Full screen. **Security-critical: this screen must appear INSTANTLY with no animation.** Override the page transition for this route:

```dart
GoRoute(
  path: '/lock',
  name: 'lock',
  pageBuilder: (context, state) => NoTransitionPage(child: const LockScreen()),
),
```

```dart
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _unlocking = false;

  Future<void> _unlock() async {
    setState(() { _unlocking = true; _error = null; });
    try {
      final success = await Isolate.run(() => deriveAndVerifyKey(_controller.text));
      if (success) {
        ref.read(lockProvider.notifier).unlock();
        context.go('/'); // or restore the previous route
      } else {
        setState(() => _error = 'That password did not match.');
        _shake();
      }
    } finally {
      setState(() => _unlocking = false);
    }
  }

  // Shake animation: translateX ±6px, 3 cycles over 300ms
  void _shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return ColoredBox(
      color: palette.ground,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _shakeAnimation, // ±6px, 3 cycles
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DayIllustration(name: DayIllustrationName.lockScreen, size: 64),
                    const SizedBox(height: 24),
                    Text('Day Before',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Gelasio', fontSize: 34, height: 40 / 34,
                        fontWeight: FontWeight.w600, color: palette.text)),
                    const SizedBox(height: 12),
                    Text(
                      _isLocalOnly
                        ? 'Enter the password for this device.'
                        : 'Enter your password to open your journal.',
                      textAlign: TextAlign.center,
                      style: Ty.body(palette.muted),
                    ),
                    const SizedBox(height: 32),
                    DayTextField(
                      controller: _controller,
                      label: 'Password',
                      obscure: true,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _unlock(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      DayFormError(text: _error!),
                    ],
                    const SizedBox(height: 24),
                    DayButton(
                      label: 'Unlock',
                      variant: DayButtonVariant.primary,
                      fullWidth: true,
                      loading: _unlocking,
                      onTap: _unlock,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('$kSiteBase/forgot'), mode: LaunchMode.externalApplication),
                          child: Text('Forgot password?', style: Ty.body(palette.muted)),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: _signOut,
                          child: Text('Sign out', style: Ty.body(palette.muted)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Shake animation:**
```dart
late final _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
late final _shakeAnimation = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
  TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
  TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
  TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
  TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
```

---

### 4P. Export — `lib/ui/screens/export_screen.dart`

Route: `/export`. Full screen.

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text('Export your entries', style: Ty.title(palette.text)),
    const SizedBox(height: 12),
    Text(
      'Everything is decrypted on this device and saved as files. Nothing is uploaded.',
      style: Ty.body(palette.muted),
    ),
    const SizedBox(height: 24),
    // Radio cards
    _ExportFormatCard(
      selected: _format == ExportFormat.markdown,
      onTap: () => setState(() => _format = ExportFormat.markdown),
      title: 'Markdown',
      pill: const DayStatusPill(label: 'recommended'),
      description: 'One file per entry, in a zip. Opens in Obsidian, Notion and any text editor.',
    ),
    const SizedBox(height: 12),
    _ExportFormatCard(
      selected: _format == ExportFormat.pdf,
      onTap: () => setState(() => _format = ExportFormat.pdf),
      title: 'PDF',
      description: 'One readable document of all your entries.',
    ),
    const SizedBox(height: 12),
    _ExportFormatCard(
      selected: _format == ExportFormat.json,
      onTap: () => setState(() => _format = ExportFormat.json),
      title: 'JSON',
      description: 'A complete backup, including every revision of every issue.',
    ),
    const SizedBox(height: 16),
    // Content checkboxes
    _ExportCheckbox(label: 'Journal', value: _includeJournal, onChanged: (v) => setState(() => _includeJournal = v)),
    _ExportCheckbox(label: 'Issues', value: _includeIssues, onChanged: (v) => setState(() => _includeIssues = v)),
    _ExportCheckbox(label: 'Core Points', value: _includeCorePoints, onChanged: (v) => setState(() => _includeCorePoints = v)),
    const SizedBox(height: 24),
    DayButton(
      label: 'Export',
      variant: DayButtonVariant.primary,
      fullWidth: true,
      loading: _exporting,
      onTap: _export,
    ),
  ],
)
```

**_ExportFormatCard:**
```dart
GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 140),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: palette.raised,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected ? palette.accent : palette.hairline,
        width: selected ? 2 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Ty.heading(palette.text)),
            if (pill != null) ...[const SizedBox(width: 8), pill!],
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: Ty.caption(palette.muted)),
      ],
    ),
  ),
)
```

Export logic: decrypt all selected entries locally, then:
- **Markdown:** create a zip (use `archive` package) with `README.md`, `journal/YYYY-MM-DD-title.md` (YAML front matter: date, created, updated; then body), `issues/<slug>.md` (name, then each revision dated, then each return dated, oldest first), `core-points.md`.
- **PDF:** use the `pdf` package. Embed Gelasio. A4, title page "Day Before, exported {date}", entries in date order, issues after.
- **JSON:** one file, all data including revisions.

Desktop: `file_selector` to pick a save location. Phone: `share_plus` to open the share sheet.

After export: show `DayToast(text: 'Saved to $path')`.

---

### 4Q. Take a minute (game) — `lib/ui/screens/minute_screen.dart`

Route: `/minute`. Full screen.

```dart
Scaffold(
  backgroundColor: palette.ground,
  body: Stack(
    children: [
      // The game canvas
      Positioned.fill(
        child: _MinuteCanvas(), // CustomPainter + Ticker
      ),
      // Close button
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        child: DayIconButton(
          icon: 'close',
          size: 44,
          color: palette.text,
          onTap: () => context.pop(),
        ),
      ),
    ],
  ),
)
```

Implementation steps:
1. Read the web source: `grep -ril "take a minute" .` and `grep -ril "canvas\|requestAnimationFrame" .` in the web app source to find the game.
2. Write `docs/GAME_SPEC.md` with exact rules, controls, visuals, and timing.
3. Implement with `CustomPainter` driven by a `Ticker`. Use the brand tokens for colours (ground, accent, text, muted). Accept mouse and touch input.
4. No scores or leaderboards unless the web version has them.

---

### 4R. Settings bottom sheets

**Privacy lock — `_showLockSheet()`:**
```dart
showDayBottomSheet(
  context: context,
  title: 'Lock when you leave',
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _LockOption(label: 'Immediately', value: LockDelay.immediately, selected: _current == LockDelay.immediately),
      _LockOption(label: 'After 1 minute', value: LockDelay.oneMinute, selected: _current == LockDelay.oneMinute),
      _LockOption(label: 'After 5 minutes', value: LockDelay.fiveMinutes, selected: _current == LockDelay.fiveMinutes),
      _LockOption(label: 'Never', value: LockDelay.never, selected: _current == LockDelay.never),
      if (_current == LockDelay.never) ...[
        const SizedBox(height: 12),
        DayBanner(
          variant: DayBannerVariant.warning,
          text: 'Anyone who picks up your device can read your journal.',
        ),
      ],
    ],
  ),
);
```

Each `_LockOption`: a tappable row, height 52, with a radio indicator (a 20px circle: 1px hairline border when unselected, filled accent when selected) on the left and the label in body style on the right.

**Appearance — `_showAppearanceSheet()`:**
```dart
showDayBottomSheet(
  context: context,
  title: 'Appearance',
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _ThemeOption(
        label: 'System',
        selected: _theme == ThemeMode.system,
        swatch: null, // show half-and-half swatch
        onTap: () => _setTheme(ThemeMode.system),
      ),
      _ThemeOption(
        label: 'Night',
        selected: _theme == ThemeMode.dark,
        swatchBg: const Color(0xFF131211),
        swatchFg: const Color(0xFFF2EEE6),
        onTap: () => _setTheme(ThemeMode.dark),
      ),
      _ThemeOption(
        label: 'Day',
        selected: _theme == ThemeMode.light,
        swatchBg: const Color(0xFFF6F1E8),
        swatchFg: const Color(0xFF1E1A15),
        onTap: () => _setTheme(ThemeMode.light),
      ),
    ],
  ),
);
```

Each `_ThemeOption`: height 52, radio indicator left, label in body style, and a 40x40 rounded square (borderRadius 8) on the right showing `swatchBg` with the letter "A" in `swatchFg` centred inside it (Gelasio 16). For System, show the swatch split diagonally: top-left triangle Night, bottom-right Day.

---

### PHASE 4 ACCEPTANCE

Run every check below. If any fails, fix it and re-run before moving on.

1. **No overflows:** launch the app on a 1280x800 window and resize it down to 390x844. At no point should a `RenderFlex overflowed` error appear. Add a test: `flutter test --dart-define=SCREEN_SIZE=390x844` and `1280x800` that navigates every route and asserts zero FlutterErrors.
2. **Every tap target works:** tap every button, link, sidebar item, tab, bottom nav item, and card on both sizes. Each must navigate to the correct route or open the correct sheet/modal/browser. Minimum hit target: 44x44 on phone, 40x40 on desktop.
3. **Sidebar sections:** collapse and expand all three sections. The AnimatedSize must be smooth (no jumps). The chevron must rotate 90 degrees.
4. **Drawer gesture:** on the phone layout, swiping from the left edge (0–40px) must smoothly open the drawer. Tapping the scrim must close it.
5. **Empty states:** with no data, every list screen (journal, issues, core points) shows its illustration and text.
6. **Journal editor:** create a new entry, type in the title and body, wait 600ms, confirm "Saved" appears. Close and reopen: the entry is there.
7. **Issue detail:** create an issue, add a theory, add a return, switch to "Read it back" and confirm both appear on the timeline in chronological order.
8. **Lock screen:** minimise the app (or simulate `AppLifecycleState.hidden` in a test), return, confirm the lock screen appears with no animation and no visible content behind it.
9. **Both themes:** toggle between Night and Day. All screens must render correctly in both. No colour leaks (e.g. white text on white ground).
10. **Screenshots:** capture every screen in both themes at both sizes. Save to `docs/screens/` with names like `journal-night-desktop.png`, `issue-detail-day-phone.png`, etc.
11. **Commit:** `git add -A && git commit -m "rebuild all screens on bespoke design system"`

## PHASE 5 — ANIMATIONS AND MICRO-INTERACTIONS (30 min)

Every animation in Day Before exists to confirm a state change, not to entertain. Motion is fast, quiet, and ends before the user thinks about it. Nothing bounces. Nothing overshoots. Nothing delays input.

Create `lib/ui/motion/day_motion.dart` containing all animation utilities referenced below.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Mo {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
  static const page = Duration(milliseconds: 400);
  static const curve = Cubic(0.16, 1, 0.3, 1);
  static const spring = SpringDescription(mass: 1, stiffness: 300, damping: 30);

  /// Returns Duration.zero when the user has enabled reduced-motion,
  /// otherwise returns the normal duration.
  static Duration dur(BuildContext context, Duration normal) =>
      MediaQuery.of(context).disableAnimations ? Duration.zero : normal;

  /// Same helper but returns a fixed short crossfade (50 ms) instead of zero,
  /// used where an instant cut would be disorienting even for reduced-motion users.
  static Duration durSoft(BuildContext context, Duration normal) =>
      MediaQuery.of(context).disableAnimations
          ? const Duration(milliseconds: 50)
          : normal;
}
```

Every animated widget in the app must use `Mo.dur(context, ...)` or `Mo.durSoft(context, ...)` for its duration. Hard-coded `Duration(milliseconds: 220)` is forbidden outside this file.

---

### 5A. Page transitions — `lib/ui/motion/day_page_transitions.dart`

Configure in `ThemeData.pageTransitionsTheme`:

```dart
pageTransitionsTheme: PageTransitionsTheme(
  builders: {
    TargetPlatform.android: const ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
    TargetPlatform.windows: const _FadeUpPageTransitionsBuilder(),
    TargetPlatform.linux: const _FadeUpPageTransitionsBuilder(),
  },
),
```

`_FadeUpPageTransitionsBuilder` (Windows and Linux): the incoming page fades from opacity 0 to 1 and translates Y from +12 logical pixels to 0, over 400 ms using `Mo.curve`. The outgoing page fades to opacity 0 over the same duration. No scale.

```dart
class _FadeUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeUpPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return FadeTransition(opacity: animation, child: child);
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Mo.curve),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),   // ~12px on an 800px viewport
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Mo.curve)),
        child: child,
      ),
    );
  }
}
```

For go_router, use `CustomTransitionPage` only on full-screen routes where the default theme transition is wrong:
- `/lock`: `transitionDuration: Duration.zero`, `reverseTransitionDuration: Duration.zero`. The lock screen must appear instantly with no visual leak of content underneath, not even for a single frame. Use `CustomTransitionPage(child: ..., transitionsBuilder: (_, __, ___, child) => child)`.
- `/minute` (the game): a slow cross-dissolve, 500 ms, `FadeTransition` only.
- All other full-screen routes (`/account`, `/plan`, `/sign-in`, `/export`, `/student`): use the theme default.

---

### 5B. Sidebar and Drawer

**Section collapse/expand.**
Each section's item list is wrapped in:
```dart
AnimatedSize(
  duration: Mo.dur(context, Mo.base),   // 220 ms
  curve: Mo.curve,
  alignment: Alignment.topCenter,
  child: collapsed
      ? const SizedBox.shrink()
      : Column(children: items),
)
```
The chevron rotates alongside:
```dart
AnimatedRotation(
  turns: collapsed ? 0.0 : 0.25,
  duration: Mo.dur(context, Mo.base),
  curve: Mo.curve,
  child: DayIcon('chevron-right', size: 16, color: palette.faint),
)
```

**Sidebar item selection.**
Each item row is an `AnimatedContainer`:
```dart
AnimatedContainer(
  duration: Mo.dur(context, Mo.fast),   // 140 ms
  curve: Mo.curve,
  decoration: BoxDecoration(
    color: selected ? palette.hover : Colors.transparent,
    borderRadius: BorderRadius.circular(4),
  ),
  child: ...
)
```
Text colour switches from `palette.muted` to `palette.text` with no intermediate animation (colour on text is cheap and instant; animating it adds complexity for no visible gain).

**New sidebar item appears** (when the user creates an entry or issue and it appears in the list):
```dart
FadeTransition(
  opacity: CurvedAnimation(parent: _controller, curve: Mo.curve),
  child: SlideTransition(
    position: Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Mo.curve)),
    child: itemWidget,
  ),
)
```
Duration: 200 ms. The item fades in while sliding down 4 px from above.

**Drawer on phone.**
Use the Scaffold's built-in drawer, which slides laterally. Configure:
```dart
Scaffold(
  drawerEnableOpenDragGesture: true,
  drawerEdgeDragWidth: 40,
  drawerScrimColor: Colors.black54,
  // Duration is controlled by the Scaffold internally (~260 ms).
  // Do not override it; the platform-default feels correct.
  ...
)
```

---

### 5C. Button micro-interactions

Create a reusable wrapper `_DayPressable` in `lib/ui/motion/day_pressable.dart`:

```dart
import 'package:flutter/material.dart';
import 'day_motion.dart';

class DayPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;     // 0.97 for buttons, 0.92 for icon buttons
  final bool enabled;

  const DayPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.97,
    this.enabled = true,
  });

  @override
  State<DayPressable> createState() => _DayPressableState();
}

class _DayPressableState extends State<DayPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.pressScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _pressing = true;
    if (!MediaQuery.of(context).disableAnimations) _ctrl.forward();
  }

  void _onUp(TapUpDetails _) { _release(); }
  void _onCancel() { _release(); }

  void _release() {
    _pressing = false;
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      onTap: widget.enabled ? widget.onTap : null,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
```

Usage in every `DayButton`:
- Primary and quiet buttons: `pressScale: 0.97`
- `DayIconButton`: `pressScale: 0.92`
- Disabled (`enabled: false`): opacity 0.4 (wrap child in `Opacity(opacity: 0.4)`), no scale, no hover, cursor `SystemMouseCursors.forbidden`

**Hover (desktop only):**
Inside every button's build method, wrap the visual container in `MouseRegion` + `AnimatedContainer`:
```dart
MouseRegion(
  cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
  onEnter: (_) => setState(() => _hovered = true),
  onExit: (_) => setState(() => _hovered = false),
  child: AnimatedContainer(
    duration: Mo.dur(context, Mo.fast),   // 140 ms
    decoration: BoxDecoration(
      color: _hovered && enabled ? hoverColor : idleColor,
      ...
    ),
    child: ...
  ),
)
```

**Focus ring:**
When the widget receives keyboard focus (wrap in `Focus` or use `FocusableActionDetector`), draw a 2 px ring in `palette.focusRing` outside the button border, offset by 2 px:
```dart
AnimatedContainer(
  duration: Mo.dur(context, const Duration(milliseconds: 100)),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(R.control + 4),   // 8 + 4 = 12
    border: Border.all(
      color: focused ? palette.focusRing : Colors.transparent,
      width: 2,
    ),
  ),
  padding: const EdgeInsets.all(2),   // the offset gap
  child: actualButton,
)
```

---

### 5D. Card interactions

**Tap — subtle shadow deepening.**
Each `DayCard` tracks a `_pressed` bool (set on `onTapDown`, cleared on `onTapUp`/`onTapCancel`):
```dart
AnimatedContainer(
  duration: Mo.dur(context, const Duration(milliseconds: 100)),
  decoration: BoxDecoration(
    color: palette.raised,
    borderRadius: BorderRadius.circular(R.card),   // 14
    border: Border.all(color: palette.hairline, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(_pressed ? 0.10 : 0.05),
        offset: Offset(0, _pressed ? 2 : 1),
        blurRadius: _pressed ? 5 : 3,
      ),
    ],
  ),
  child: child,
)
```

**Long press (phone).**
After a 300 ms hold detected via `GestureDetector.onLongPress`, show a context menu using `showMenu` (a positioned popup, not a Material dialog) with actions like "Delete" or "Move to issue". The menu fades in over 140 ms and fades out over 100 ms.

**Swipe to delete (entries and returns).**
Wrap each dismissible card in:
```dart
Dismissible(
  key: ValueKey(item.id),
  direction: DismissDirection.endToStart,
  dismissThresholds: const {DismissDirection.endToStart: 0.4},
  movementDuration: const Duration(milliseconds: 200),
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: palette.danger,
      borderRadius: BorderRadius.circular(R.card),
    ),
    child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
  ),
  onDismissed: (_) {
    // Remove from state, then show snackbar:
    DaySnackbar.show(context, message: 'Entry deleted', action: 'Undo', onAction: undoDelete);
  },
  child: cardWidget,
)
```

---

### 5E. List animations

**Initial load stagger.**
Create `lib/ui/motion/stagger_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'day_motion.dart';

class StaggerList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;

  const StaggerList({super.key, required this.itemCount, required this.itemBuilder});

  @override
  State<StaggerList> createState() => _StaggerListState();
}

class _StaggerListState extends State<StaggerList> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final count = widget.itemCount.clamp(0, 10);
    // Total animation window: 200 ms per item + 30 ms stagger × count
    final totalMs = 200 + (count * 30);
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: totalMs));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (ctx, i) {
        if (reduced || i >= 10) {
          return widget.itemBuilder(ctx, i, kAlwaysCompleteAnimation);
        }
        final start = (i * 30) / (_ctrl.duration!.inMilliseconds);
        final end = (start + 200 / _ctrl.duration!.inMilliseconds).clamp(0.0, 1.0);
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Mo.curve),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
            child: widget.itemBuilder(ctx, i, anim),
          ),
        );
      },
    );
  }
}
```

Each item fades from opacity 0 → 1 and translates Y from 8 px → 0. Duration: 200 ms per item. Stagger: 30 ms between items. Items at index 10 or beyond appear immediately (no stagger — the user will never see all ten animate in anyway, and staggering indefinitely wastes frames).

**New item added** (after user creates an entry):
Insert at the top of an `AnimatedList` or manually animate. The item slides in from `Offset(0, -0.05)` to `Offset.zero` with a fade, 200 ms, `Mo.curve`.

**Item removed** (after swipe-to-delete or undo expiration):
The item fades out to opacity 0 and translates X by -20 px (`Offset(-0.05, 0)`) over 200 ms.

---

### 5F. Theme switching

Wrap the root `MaterialApp` in a widget that supplies the palette via `InheritedWidget` and uses `AnimatedTheme`:

```dart
AnimatedTheme(
  data: currentThemeData,
  duration: Mo.durSoft(context, const Duration(milliseconds: 300)),
  curve: Mo.curve,
  child: MaterialApp.router(...)
)
```

All `palette.xxx` colours used in `AnimatedContainer`, `AnimatedDefaultTextStyle`, and `ColoredBox` cross-fade automatically because the palette is rebuilt from the new theme on every build, and the animated wrappers interpolate between old and new values.

In the Appearance bottom sheet, the three preview swatches (40 x 40 rounded rectangles showing ground + text colours) display a check icon on the currently selected option. The check fades in over 140 ms:
```dart
AnimatedOpacity(
  opacity: isSelected ? 1.0 : 0.0,
  duration: Mo.dur(context, Mo.fast),
  child: Icon(LucideIcons.check, size: 16, color: palette.accent),
)
```

---

### 5G. Editor micro-interactions

**"Saved" indicator** at the top-right of the editor content area:

```dart
class _SavedIndicator extends StatefulWidget { ... }

class _SavedIndicatorState extends State<_SavedIndicator> {
  double _opacity = 0;
  Timer? _holdTimer;

  void showSaved() {
    setState(() => _opacity = 1);           // fade in
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _opacity = 0);   // fade out
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _opacity == 1
          ? Mo.dur(context, Mo.fast)           // 140 ms fade in
          : Mo.dur(context, const Duration(milliseconds: 300)),  // 300 ms fade out
      child: Text('Saved', style: Ty.caption(palette.faint)),
    );
  }
}
```

**Saving-in-progress dot:**
A 4 px circle next to the "Saved" text, colour `palette.accent`, whose opacity oscillates between 0.4 and 1.0 over a 600 ms cycle using a repeating `AnimationController`:
```dart
AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
  ..repeat(reverse: true);
// In build:
FadeTransition(
  opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_pulseCtrl),
  child: Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: palette.accent)),
)
```
When the save completes, stop the pulse controller and call `showSaved()`.

**Cursor and selection:**
Set in `TextField`'s properties:
```dart
cursorColor: palette.accent,
selectionControls: materialTextSelectionControls,   // or cupertinoTextSelectionControls on iOS
// In the theme:
textSelectionTheme: TextSelectionThemeData(
  cursorColor: palette.accent,
  selectionColor: palette.accent.withOpacity(0.3),
  selectionHandleColor: palette.accent,
),
```

**Autosave debounce:**
In the editor's state, a `Timer? _debounce` resets on every `onChanged`:
```dart
void _onChanged(String value) {
  _debounce?.cancel();
  _showPulse();                                // start the pulsing dot
  _debounce = Timer(const Duration(milliseconds: 600), () async {
    await _save();
    _hidePulse();
    _savedIndicatorKey.currentState?.showSaved();
  });
}
```

---

### 5H. Lock screen

**Appear: INSTANT.**
The lock route uses `CustomTransitionPage` with zero duration:
```dart
CustomTransitionPage(
  key: state.pageKey,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
  child: const LockScreen(),
  transitionsBuilder: (_, __, ___, child) => child,
)
```
Security: the content behind must not be visible for even a single frame. When the lock is triggered, clear the in-memory data key and any decrypted text BEFORE navigating. The navigation happens synchronously in the same frame.

**App-switcher cover.**
An opaque ground-coloured overlay that hides the journal from the phone's recent-apps thumbnail. This sits ABOVE every other widget in the tree:

```dart
class LifecycleCover extends StatefulWidget {
  final Widget child;
  const LifecycleCover({super.key, required this.child});
  @override
  State<LifecycleCover> createState() => _LifecycleCoverState();
}

class _LifecycleCoverState extends State<LifecycleCover>
    with WidgetsBindingObserver {
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldCover =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused;
    if (shouldCover != _covered) setState(() => _covered = shouldCover);
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Stack(
      children: [
        widget.child,
        if (_covered)
          Positioned.fill(
            child: ColoredBox(color: palette.ground),
          ),
      ],
    );
  }
}
```

Wrap the entire `MaterialApp` (or its body) in `LifecycleCover`:
```dart
LifecycleCover(child: MaterialApp.router(...))
```

**Wrong-password shake.**
The password field translates horizontally through a TweenSequence:

```dart
class ShakeController {
  late final AnimationController _ctrl;
  late final Animation<double> _offset;

  ShakeController(TickerProvider vsync) {
    _ctrl = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 300));
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  Animation<double> get offset => _offset;
  void shake() { _ctrl.forward(from: 0); }
  void dispose() { _ctrl.dispose(); }
}
```

In the lock screen build:
```dart
AnimatedBuilder(
  animation: _shakeCtrl.offset,
  builder: (context, child) => Transform.translate(
    offset: Offset(_shakeCtrl.offset.value, 0),
    child: child,
  ),
  child: passwordField,
)
```
Trigger `_shakeCtrl.shake()` when the password is wrong, immediately after showing the DayFormError.

---

### 5I. Pull to refresh (phone, synced users)

Three small dots that appear above the list content when the user pulls down.

Each dot: 4 px diameter circle, `palette.accent`.

Create `lib/ui/motion/day_refresh_indicator.dart`:

```dart
class DayRefreshDots extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  const DayRefreshDots({super.key, required this.onRefresh, required this.child});
  @override
  State<DayRefreshDots> createState() => _DayRefreshDotsState();
}

class _DayRefreshDotsState extends State<DayRefreshDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dots = List.generate(3, (i) =>
    AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
  );
  bool _refreshing = false;
  double _pullDistance = 0;

  void _startWave() {
    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted && _refreshing) _dots[i].repeat(reverse: true);
      });
    }
  }

  void _stopWave() {
    for (final c in _dots) { c.stop(); c.reset(); }
  }

  @override
  void dispose() {
    for (final c in _dots) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is OverscrollNotification && n.overscroll < 0) {
          _pullDistance += n.overscroll.abs();
          setState(() {});
          if (_pullDistance >= 80 && !_refreshing) {
            _refreshing = true;
            _startWave();
            widget.onRefresh().then((_) {
              if (mounted) setState(() { _refreshing = false; _pullDistance = 0; _stopWave(); });
            });
          }
        }
        if (n is ScrollEndNotification) {
          if (!_refreshing) setState(() => _pullDistance = 0);
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_pullDistance > 0 || _refreshing)
            Positioned(
              top: _refreshing ? 16 : (-40 + (_pullDistance / 80) * 56).clamp(-40, 16),
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.2)
                        .animate(CurvedAnimation(parent: _dots[i], curve: Curves.easeInOut)),
                    child: Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PaletteProvider.of(context).accent,
                      ),
                    ),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}
```

Trigger distance: 80 px of overscroll. The dots slide from -40 px to 16 px as the user pulls. During refresh, they wave (each dot scales between 0.5 and 1.2, staggered by 100 ms, cycle 600 ms). When refresh completes, the dots shrink and vanish.

---

### 5J. Toast and Snackbar

**DayToast** (success confirmations, non-critical info):
- Enters from top: translates Y from -48 px to 0 over 220 ms (`Mo.base`, `Mo.curve`)
- Holds for 3 seconds
- Exits: translates Y from 0 to -48 px AND fades to opacity 0 over 200 ms

**DaySnackbar** (undo-able actions):
- Enters from bottom: translates Y from +48 px to 0 over 220 ms (`Mo.base`, `Mo.curve`)
- Auto-dismisses after 5 seconds: slides back down over 140 ms (`Mo.fast`)
- Only one snackbar at a time. If a new snackbar is requested while one is visible, the old one exits immediately (100 ms), then the new one enters.

Both are shown via an `Overlay` managed by a global key, not via `ScaffoldMessenger` (which uses Material styling). Implementation:

```dart
class DayOverlayManager {
  static final overlayKey = GlobalKey<OverlayState>();

  static void showToast(BuildContext context, {required String message}) {
    final entry = OverlayEntry(builder: (ctx) => _DayToastOverlay(message: message));
    overlayKey.currentState?.insert(entry);
    Future.delayed(const Duration(milliseconds: 3220), () => entry.remove());
  }

  static OverlayEntry? _activeSnackbar;
  static void showSnackbar(BuildContext context, {
    required String message, String? action, VoidCallback? onAction,
  }) {
    _activeSnackbar?.remove();
    final entry = OverlayEntry(builder: (ctx) =>
        _DaySnackbarOverlay(message: message, action: action, onAction: onAction));
    _activeSnackbar = entry;
    overlayKey.currentState?.insert(entry);
    Future.delayed(const Duration(milliseconds: 5220), () {
      if (_activeSnackbar == entry) { entry.remove(); _activeSnackbar = null; }
    });
  }
}
```

Place the `Overlay` at the root of the widget tree, above `MaterialApp` but below `LifecycleCover`.

---

### 5K. Reduced motion

When `MediaQuery.of(context).disableAnimations` is `true`:

| Normal behaviour | Reduced-motion behaviour |
|---|---|
| All `Mo.dur()` durations | `Duration.zero` (instant) |
| All `Mo.durSoft()` durations | 50 ms (gentle crossfade) |
| Translate and scale animations | Skipped entirely (widget appears at final position) |
| `AnimatedTheme` 300 ms crossfade | 150 ms crossfade (colours only, acceptable) |
| Page transitions | 50 ms fade, no slide/zoom |
| List stagger | All items appear at once |
| Pull-to-refresh dots wave | Static dots, no scale animation |
| Wrong-password shake | No shake; the DayFormError text alone indicates failure |

Enforce this by NEVER using a raw `Duration(milliseconds: xxx)` in any animation property. Always use `Mo.dur(context, Mo.xxx)` or `Mo.durSoft(context, Mo.xxx)`. The only exception is `AnimationController` durations set in `initState` where context is not yet available — for those, check `WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations` directly and set `Duration.zero`.

---

### 5L. Implementation checklist

Before moving to Phase 6, verify each of these animations works:

| # | Animation | Where | Duration | Verified? |
|---|---|---|---|---|
| 1 | Page fade+slide (Win/Linux) | every route | 400 ms | |
| 2 | Cupertino slide (iOS/macOS) | every route | platform | |
| 3 | Zoom (Android) | every route | platform | |
| 4 | Lock instant appear | /lock | 0 ms | |
| 5 | Sidebar collapse | sidebar sections | 220 ms | |
| 6 | Chevron rotation | sidebar sections | 220 ms | |
| 7 | Sidebar hover | sidebar items, buttons | 140 ms | |
| 8 | Sidebar new item | new entry in list | 200 ms | |
| 9 | Drawer slide | phone drawer | ~260 ms | |
| 10 | Button press scale | all buttons | 80/140 ms | |
| 11 | Button focus ring | all buttons (keyboard) | 100 ms | |
| 12 | Card tap shadow | all cards | 100 ms | |
| 13 | Swipe to delete | entries, returns | 200 ms | |
| 14 | List stagger | journal, issues, returns | 200 + 30n ms | |
| 15 | Theme crossfade | entire app | 300 ms | |
| 16 | Editor saved fade | entry editor | 140/300 ms | |
| 17 | Saving pulse dot | entry editor | 600 ms loop | |
| 18 | Password shake | lock screen | 300 ms | |
| 19 | App-switcher cover | whole app | instant | |
| 20 | Pull-to-refresh dots | synced list (phone) | 600 ms wave | |
| 21 | Toast enter/exit | overlay | 220/200 ms | |
| 22 | Snackbar enter/exit | overlay | 220/140 ms | |

Write the table into REDESIGN_PROGRESS.md and mark each as verified after testing.

### PHASE 5 ACCEPTANCE

1. Run `flutter run --profile` on a mid-range Android device (or emulator) with the performance overlay enabled. Every animation must hold 60 fps. If any animation drops below 50 fps, simplify it (reduce shadow complexity or remove the translate).
2. No animation exceeds 400 ms (the page transition). Most are 220 ms or less.
3. The lock screen appears with zero visual delay — test by minimising and re-opening the app; the lock must be the first thing visible.
4. Theme switching cross-fades all colours smoothly with no white flash or flicker between old and new values.
5. Enable reduced-motion in the device's accessibility settings. Confirm all movement is eliminated and the app remains fully usable.
6. Commit: `add motion system and micro-interactions`

## PHASE 6 — PLATFORM-SPECIFIC POLISH (20 min)

Each platform has conventions that users feel even if they cannot name them. This phase adds them. Do not skip items to save time.

### 6A. Android

1. **Edge-to-edge display.** In `MainActivity.kt` (or `.java`), call:
   ```kotlin
   WindowCompat.setDecorFitsSystemWindows(window, false)
   ```
   In Flutter, wrap the top-level Scaffold body in `SafeArea(bottom: true, top: true)`. The status bar and navigation bar should be transparent, showing `palette.ground` behind them. Set:
   ```dart
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
     statusBarColor: Colors.transparent,
     statusBarIconBrightness: isNight ? Brightness.light : Brightness.dark,
     systemNavigationBarColor: Colors.transparent,
     systemNavigationBarIconBrightness: isNight ? Brightness.light : Brightness.dark,
   ));
   ```

2. **Material You dynamic color: DISABLED.** Do not use `DynamicColorBuilder` or `dynamic_color` package. Day Before has its own palette and must not inherit the device wallpaper colours. Explicitly: no `colorSchemeSeed`, no `DynamicColorPlugin`.

3. **Predictive back gesture.** In `AndroidManifest.xml` set `android:enableOnBackInvokedCallback="true"`. In Flutter, use `PopScope` (not the deprecated `WillPopScope`) on every screen that should intercept back:
   ```dart
   PopScope(
     canPop: true,   // or false if there is unsaved work
     onPopInvokedWithResult: (didPop, result) {
       if (!didPop) { /* show save dialog */ }
     },
     child: screenContent,
   )
   ```

4. **Splash screen.** Use `flutter_native_splash` with this pubspec config:
   ```yaml
   flutter_native_splash:
     color: "#131211"
     color_dark: "#131211"
     image: assets/icon/splash_symbol.png
     android_12:
       color: "#131211"
       color_dark: "#131211"
       image: assets/icon/splash_symbol.png
   ```
   `splash_symbol.png`: the half-disc + horizon line on transparent background, 288x288 px. Generate from the symbol SVG using `sharp`.

5. **Permissions.** In `android/app/src/main/AndroidManifest.xml`, directly above `<application`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   ```
   Nothing else. No camera, no storage (use app-scoped storage), no location.

6. **Min SDK and target.** In `android/app/build.gradle`: `minSdkVersion 23`, `targetSdkVersion 34`, `compileSdkVersion 34`.

### 6B. iOS

1. **Safe areas.** Every screen must respect the notch, Dynamic Island, and home indicator. Use `SafeArea` or `MediaQuery.of(context).padding`. The sidebar extends behind the status bar with a solid `palette.sidebar` colour behind the system bar content.

2. **Large title pattern: NOT used.** Day Before does not use the iOS large-title collapsing navigation bar. It has its own top bar and sidebar. However, the scroll physics must be `BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())` on iOS for the expected rubber-band feel.

3. **Haptic feedback.** Import `package:flutter/services.dart`. Add light haptic feedback on:
   - Bottom navigation item tap: `HapticFeedback.lightImpact()`
   - Toggle change: `HapticFeedback.lightImpact()`
   - Swipe-to-delete threshold reached: `HapticFeedback.mediumImpact()`
   - Lock screen wrong password: `HapticFeedback.heavyImpact()`
   Only on iOS and Android. On desktop platforms, these calls are no-ops.

4. **Status bar style.** On iOS the status bar icon colour follows the theme:
   ```dart
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
     statusBarBrightness: isNight ? Brightness.dark : Brightness.light,   // iOS uses inverted naming
   ));
   ```

5. **App transport security.** In `ios/Runner/Info.plist`, ensure there is NO `NSAllowsArbitraryLoads` entry. All traffic goes to daybefore.app over HTTPS.

### 6C. Windows

1. **Native title bar.** Use the default Windows title bar (no custom title bar, no `window_manager` hidden title bar, no `DragToMoveArea`). Set the window title to `"Day Before"` in `windows/runner/main.cpp`:
   ```cpp
   Win32Window::Point origin(10, 10);
   Win32Window::Size size(1200, 800);
   if (!window.Create(L"Day Before", origin, size)) { ... }
   ```

2. **Window icon.** Set the `.ico` file in `windows/runner/resources/app_icon.ico`. Generate from the 1024x1024 PNG using ImageMagick or `sharp`:
   ```bash
   magick icon.png -resize 256x256 -define icon:auto-resize=256,128,64,48,32,16 app_icon.ico
   ```
   Or if using sharp: convert to multiple PNGs and use `png-to-ico`.

3. **Minimum window size: 800x500.** In `windows/runner/main.cpp` or using `window_manager` (ONLY for setting min size, NOT for hiding the title bar):
   ```dart
   // in main() after runApp:
   if (Platform.isWindows) {
     windowManager.setMinimumSize(const Size(800, 500));
   }
   ```

4. **Hover states on all interactive elements.** Every button, list row, sidebar item, card, and link must have a hover state. Use `MouseRegion` with `SystemMouseCursors.click` for tappable items. This is already in the component specs but verify nothing was missed.

5. **Scroll wheel.** `ListView` handles this by default. Ensure horizontal scrolling (if any, e.g. tabs) responds to shift+scroll.

6. **Keyboard navigation with visible focus rings.** Every interactive element must be focusable via Tab key. Focus order must match visual order (left-to-right, top-to-bottom). Use `FocusTraversalGroup` on the sidebar and on the main content area separately so Tab moves through the sidebar first, then into the content. The focus ring (2px, `palette.focusRing`) must be visible.

7. **Keyboard shortcuts.** Using the `Shortcuts` and `Actions` widgets at the app level:
   - `Ctrl+N`: New entry (navigate /entry/new)
   - `Ctrl+E`: Export (navigate /export)
   - `Ctrl+L`: Lock (navigate /lock, clear keys)
   - `Ctrl+,`: Account/Settings (navigate /account)
   - `Ctrl+1`: Switch to Journal section
   - `Ctrl+2`: Switch to Issues section
   - `Ctrl+3`: Switch to Core Points section
   - `Escape`: Close current full-screen route (go back)
   - `Ctrl+S`: Force save (in editor, bypass debounce)

8. **ProductName and FileDescription.** In `windows/runner/Runner.rc`:
   ```
   VALUE "FileDescription", "Day Before"
   VALUE "ProductName", "Day Before"
   ```

### 6D. macOS

1. **Native title bar and traffic lights.** Keep the standard macOS title bar with the red/yellow/green buttons. Do NOT hide or reposition them. The sidebar background colour should extend behind the title bar area using `SystemChrome.setSystemUIOverlayStyle` or by letting the window background match `palette.sidebar`.

2. **Trackpad gestures.** Two-finger swipe back is handled by `CupertinoPageTransitionsBuilder`. Two-finger scroll works by default on `ListView`. Pinch-to-zoom: NOT enabled (it would break the layout).

3. **Keyboard shortcuts.** Same as Windows but use `Cmd` instead of `Ctrl`:
   - `Cmd+N`: New entry
   - `Cmd+E`: Export
   - `Cmd+L`: Lock
   - `Cmd+,`: Account/Settings (macOS convention for preferences)
   - `Cmd+1/2/3`: Section switching
   - `Cmd+S`: Force save
   - `Escape`: Close/back

4. **Entitlements.** In both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
   ```xml
   <key>com.apple.security.network.client</key>
   <true/>
   ```
   This is REQUIRED for the app to make network requests on macOS. Without it, every API call fails silently.

5. **App name.** In `macos/Runner/Configs/AppInfo.xcconfig`:
   ```
   PRODUCT_NAME = Day Before
   ```

6. **Minimum window size.** Using `window_manager`:
   ```dart
   if (Platform.isMacOS) {
     windowManager.setMinimumSize(const Size(800, 500));
   }
   ```

### PHASE 6 ACCEPTANCE

1. Android: the app runs edge-to-edge with transparent bars, splash screen shows the symbol on dark ground, back gesture works, no dynamic colour contamination.
2. iOS: safe areas respected on all screens, rubber-band scroll physics, haptic feedback fires on toggle/delete/wrong-password.
3. Windows: native title bar shows "Day Before" and the correct icon, minimum window size enforced, all keyboard shortcuts work, Tab-key focus traversal works with visible rings.
4. macOS: traffic lights visible, Cmd shortcuts work, network entitlements present, minimum window size enforced.
5. Commit: `platform-specific polish for Android, iOS, Windows, macOS`

---

## PHASE 7 — ACCESSIBILITY (20 min)

Accessibility is not a layer added on top. These checks verify that the component library and screen specs produce an accessible app. Fix failures in the components themselves, not with accessibility-only patches.

### 7A. Colour contrast

Every text/background pair must meet WCAG 2.1 AA:
- Body text (under 18px or under 14px bold): 4.5:1 minimum
- Large text (18px+ or 14px+ bold): 3:1 minimum
- UI components and graphical objects: 3:1 minimum against adjacent colours

Verify these specific pairs (use a contrast checker or compute in code):

| Pair | Night | Day |
|---|---|---|
| text on ground | #F2EEE6 on #131211 → ~15.5:1 | #1E1A15 on #F6F1E8 → ~14.8:1 |
| muted on ground | #A39D92 on #131211 → ~7.2:1 | #6A6358 on #F6F1E8 → ~5.2:1 |
| faint on ground | #6E6960 on #131211 → ~4.0:1 | #9A9283 on #F6F1E8 → ~3.5:1 |
| accent on ground | #D4A25A on #131211 → ~7.5:1 | #A8691F on #F6F1E8 → ~4.8:1 |
| buttonInk on buttonBg | #131211 on #F2EEE6 → ~15.5:1 | #F6F1E8 on #1E1A15 → ~14.8:1 |
| danger on ground | #E07A6B on #131211 → ~5.5:1 | #B5483A on #F6F1E8 → ~5.0:1 |

`faint` is used only for non-essential decorative text (the "Saved" indicator, version numbers). It is NEVER used for actionable text or required information. If it is, change the colour to `muted`.

Write a Dart test `test/accessibility/contrast_test.dart` that computes the relative luminance and contrast ratio for every pair and asserts the minimum. Run it in CI.

### 7B. Semantic labels

Every interactive element needs a `Semantics` widget or a `semanticLabel` property:

- `DayButton`: `Semantics(button: true, label: buttonLabel, child: ...)`
- `DayIconButton`: `Semantics(button: true, label: tooltipText, child: ...)` — icon buttons MUST have a tooltip/label describing the action ("New entry", "Close", "Back", "Menu", "Export", "Lock", "Delete")
- `DayTextField`: the `decoration.labelText` serves as the semantic label. If there is no label (e.g. the editor body), add `Semantics(label: "Entry body text", child: ...)`
- `DayToggle`: `Semantics(toggled: value, label: toggleLabel, child: ...)`
- `DayCard` (tappable): `Semantics(button: true, label: "Open entry: $title, dated $date", child: ...)`
- Sidebar sections: `Semantics(header: true, label: sectionName, child: ...)`
- Illustrations: `Semantics(image: true, label: illustrationDescription, child: ...)` — e.g. "An open book with blank pages"

### 7C. Screen reader announcements

Use `SemanticsService.announce()` for dynamic state changes:
- After saving: announce "Entry saved"
- After delete: announce "Entry deleted"
- After export: announce "Entries exported as $format"
- After locking: announce "Journal locked"
- After unlocking: announce "Journal unlocked"
- After theme change: announce "Switched to $theme theme"
- Network error: announce the error message

### 7D. Reduce motion

Already implemented in Phase 5. Verify: enable "Remove animations" (Android) or "Reduce motion" (iOS/macOS) in device settings, then navigate every screen. No element should fly, bounce, scale, or slide. Crossfades of 50 ms are acceptable.

### 7E. Dynamic type / text scaling

Layouts must not break when the system text scale factor is set to 2.0 (double the normal size).
- Test by wrapping the app in `MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2.0)), child: ...)`
- Common breakage points: the sidebar (items overflow), the top bar (title clips), button text (overflows the button). Fix by:
  - Sidebar: use `FittedBox` or `Flexible` for text, let rows grow in height (`constraints` instead of fixed height)
  - Top bar: use `Flexible` + `Text(overflow: ellipsis)` for the title
  - Buttons: use `IntrinsicHeight` or flexible padding, never a fixed `height` that cannot grow
  - Date chips and status pills: allow wrapping

### 7F. Focus traversal order

On desktop (keyboard users), pressing Tab should move through the UI in this order:
1. Sidebar: New entry button → Journal items → Issues items → Core Points items → Take a minute → Export → Account
2. Content area: back button (if present) → title field → body field → action buttons

Use `FocusTraversalGroup(policy: OrderedTraversalPolicy(...))` on the sidebar and on the content area. Within each group, use `FocusTraversalOrder` with `NumericFocusOrder` for explicit ordering only where the default (reading order) gets it wrong.

### 7G. Minimum touch targets

- Every tappable element on phone: minimum 44x44 logical pixels. If the visual element is smaller (e.g. a 28x28 icon button), use `SizedBox(width: 44, height: 44)` as the hit target with the visual element centred inside.
- Every tappable element on desktop: minimum 40x40.
- Verify with a test that finds every `GestureDetector`, `InkWell`, and `DayPressable` in the widget tree and asserts its render box is at least 44x44 (phone) or 40x40 (desktop).

### PHASE 7 ACCEPTANCE

1. `flutter test test/accessibility/contrast_test.dart` passes — all contrast ratios meet AA.
2. Run the app with TalkBack (Android) or VoiceOver (iOS/macOS) and navigate every screen. Every element is announced with a meaningful label.
3. Dynamic type at 2.0x: no overflow, no clipping, no broken layouts.
4. Reduced motion: no movement on any screen.
5. Keyboard-only navigation (desktop): every screen reachable, every action performable, focus ring visible throughout.
6. Commit: `accessibility pass — contrast, semantics, scaling, focus`

---

## PHASE 8 — BUILD, VERIFY, AND RELEASE (30 min)

### 8A. Code quality

1. `flutter analyze` — zero errors, zero warnings. Fix every warning, do not suppress with `// ignore:`.
2. `flutter test` — all tests pass. This includes:
   - Component gallery rendering tests (every component in both themes, at phone and desktop sizes)
   - Contrast ratio tests
   - Touch target size tests
   - Crypto round-trip tests (existing, must not be broken)
   - API smoke test (existing, must not be broken)
   - Export format tests
3. `dart format .` — all files formatted.

### 8B. Build

Edit `.github/workflows/native.yml`:
- Default platforms: android + windows (fast CI)
- Optional: macOS + iOS jobs (triggered by workflow_dispatch or `native-v*` tags)
- Ensure `flutter analyze` and `flutter test` run BEFORE any build step. If they fail, the workflow fails.
- Android: `flutter build apk --release` with the existing keystore
- Windows: `flutter build windows --release`, then zip the Release folder
- macOS: `flutter build macos --release`, then zip with `ditto`
- iOS: `flutter build ios --release --no-codesign`, then package as .ipa

Push, trigger the workflow, watch it. Fix build failures and re-trigger. Repeat until android and windows pass. Give macOS and iOS the same effort within the time box.

### 8C. Manual verification

After building, download and run the Windows zip and Android APK. Walk through this test plan (write it to `docs/TEST_PLAN.md`):

| # | Test | Expected | Pass? |
|---|---|---|---|
| 1 | Launch the app cold | Splash screen with symbol, then empty state with "Write the day down." | |
| 2 | Tap "New entry" | Editor opens, cursor in title field, date shown as overline | |
| 3 | Type a title and body, wait 1 second | "Saved" appears and fades | |
| 4 | Press back, check sidebar | Entry appears in Journal section with the title | |
| 5 | Tap the entry in the sidebar | Editor opens with the saved content | |
| 6 | Create an issue, write theory, add a return | Issue appears in sidebar; Theory and Returns tabs work | |
| 7 | Open "Read it back" tab | Timeline shows revision and return in chronological order | |
| 8 | Add a Core Point | Point appears in list, editable inline | |
| 9 | Swipe left on drawer (phone) | Drawer opens smoothly tracking the finger | |
| 10 | Tap every sidebar row | Each navigates to the correct screen | |
| 11 | Open Account screen | Profile, plan status, all setting rows visible | |
| 12 | Tap "Export your entries" | Export screen with Markdown/PDF/JSON options | |
| 13 | Export as Markdown | Zip downloads, contains README.md and journal/*.md files | |
| 14 | Tap "Take a minute" | Game screen opens, close button works | |
| 15 | Tap "Plan and sync" | Plan screen shows pricing, yearly pre-selected | |
| 16 | Open Appearance, switch to Day theme | All colours cross-fade to light theme | |
| 17 | Switch back to Night | All colours return to dark theme | |
| 18 | Minimise and reopen the app | Lock screen appears IMMEDIATELY, no content flash | |
| 19 | Enter wrong password | Shake animation, error message | |
| 20 | Enter correct password | Journal unlocked, content visible | |
| 21 | Sign in with an account | Login succeeds (or shows clear error if credentials wrong) | |
| 22 | Check that NO Flutter logo appears anywhere | Title bar, splash, icon — all show Day Before branding | |
| 23 | Check that NO "Subscribe on website" appears in sidebar | Not present | |
| 24 | Resize window (desktop) below 800x500 | Window stops shrinking at minimum size | |
| 25 | Press Ctrl+N (desktop) | New entry opens | |

### 8D. Screenshots

Take screenshots of every screen in both themes at both sizes and save to `docs/screens/`:
- `journal-list-night-desktop.png`, `journal-list-night-phone.png`
- `journal-list-day-desktop.png`, `journal-list-day-phone.png`
- `entry-editor-night-desktop.png`, `entry-editor-night-phone.png`
- `entry-editor-day-desktop.png`, `entry-editor-day-phone.png`
- `issues-list-night-desktop.png`, etc.
- `issue-detail-night-desktop.png`, etc.
- `core-points-night-desktop.png`, etc.
- `account-night-desktop.png`, etc.
- `plan-night-desktop.png`, etc.
- `export-night-desktop.png`, etc.
- `lock-night-desktop.png`, etc.
- `empty-state-night-desktop.png`, etc.
- `sign-in-night-desktop.png`, etc.
- `minute-night-desktop.png`, etc.
- `design-gallery-night-desktop.png`, `design-gallery-day-desktop.png`

Use Playwright or Flutter's screenshot testing to automate this.

### 8E. Release

1. Tag the commit: `native-v0.3.0-bespoke`
2. Push the tag to trigger the GitHub Actions workflow
3. When the workflow passes, create a GitHub Release with the tag
4. Attach: `DayBefore-android.apk`, `DayBefore-windows.zip` (and macOS/iOS if they built)
5. Mirror to the public download host if one exists
6. Update the website's /download page with new version, SHA256 sums, and date
7. Write docs/CHANGELOG.md entry:
   ```
   ## v0.3.0-bespoke — [date]
   Complete UI redesign of all native apps.
   - Bespoke design system with custom components, illustrations, and iconography
   - Night and Day themes with WCAG AA contrast
   - Privacy lock: app locks when you leave, covers content in app switcher
   - Export: Markdown zip, PDF, or JSON
   - "Take a minute" game ported from website
   - Custom animations with reduced-motion support
   - Platform polish: edge-to-edge Android, haptics on iOS, keyboard shortcuts on desktop
   - Accessibility: semantic labels, dynamic type support, focus traversal
   ```

### 8F. Final report

Write to REDESIGN_PROGRESS.md, then also print as your final message. Maximum 20 lines:

- Per platform: **runs-verified** (you tested it) / **builds-only** (CI passed but untested) / **not done** (and why)
- Component count and which ones required deviations from the spec
- Illustration count
- Animation count (from the Phase 5 checklist)
- Any Lucide icon substitutions made
- Known issues
- The single most likely thing that still breaks
- The GitHub Release URL

### OVERALL ACCEPTANCE CRITERIA

Before calling this prompt done, verify ALL of these. A single failure means the phase that owns it must be revisited.

- [ ] Zero stock Flutter widgets visible anywhere (no default AppBar, FloatingActionButton, BottomNavigationBar, Drawer, Switch, Dialog, TextField decoration, Card, Chip, SnackBar, ListTile)
- [ ] Every component matches the Phase 2 specification within 2 px
- [ ] Fonts render as Gelasio and Inter everywhere, NEVER the default Roboto
- [ ] The app feels warm, calm, and hand-made — not generated, not stock
- [ ] All 8 custom icons render correctly
- [ ] All 6 spot illustrations render in both themes
- [ ] Both Night and Day themes work completely on all screens
- [ ] All 22 animations from the Phase 5 checklist work at 60 fps
- [ ] Reduced motion eliminates all movement
- [ ] Lock screen appears instantly with no content leak
- [ ] Export produces valid Markdown zip, PDF, and JSON
- [ ] The game ("Take a minute") works
- [ ] No "Subscribe on website" or "Sign In / Sync" in the sidebar
- [ ] Subscription UI appears ONLY on /plan
- [ ] No Flutter logo anywhere (splash, title bar, icon, about)
- [ ] WCAG AA contrast ratios pass on all text/background pairs
- [ ] All touch targets meet minimum size (44x44 phone, 40x40 desktop)
- [ ] Tab-key focus traversal works on desktop with visible focus rings
- [ ] Dynamic type at 2.0x does not break layouts
- [ ] `flutter analyze` zero warnings
- [ ] `flutter test` all pass
- [ ] Android APK and Windows zip build successfully in CI
