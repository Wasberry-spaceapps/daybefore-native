import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme_provider.dart';

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