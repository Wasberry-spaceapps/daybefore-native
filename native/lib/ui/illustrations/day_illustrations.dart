import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme_provider.dart';
import '../gen_colors.dart';

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
      DayIllustrationName.emptyJournal:   'assets/illustrations/empty_journal.svg',
      DayIllustrationName.emptyIssues:    'assets/illustrations/empty_issues.svg',
      DayIllustrationName.emptyCorePoints:'assets/illustrations/empty_core_points.svg',
      DayIllustrationName.welcome:        'assets/illustrations/welcome.svg',
      DayIllustrationName.exportDone:     'assets/illustrations/export_done.svg',
      DayIllustrationName.lockScreen:     'assets/illustrations/lock_screen.svg',
    };
    return map[name]!;
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    // Compare against the compile-time constant so this works without a context chain.
    final isNight = palette.ground == AppColors.darkGround;

    // The SVGs are authored with Night colours:
    //   currentColor = dark text lines
    //   #D4A25A      = gold accent
    // In Day mode we string-replace before parsing because flutter_svg
    // does not support per-colour substitution.
    if (isNight) {
      return SvgPicture.asset(
        _assetPath,
        width: size,
        height: size,
        theme: const SvgTheme(currentColor: AppColors.darkText),
      );
    }

    // Day mode: swap dark ground, dark accent → light equivalents.
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(_assetPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox(width: size, height: size);
        final svg = snapshot.data!
            .replaceAll('#D4A25A', '#A9772F') // dark accent → light accent
            .replaceAll('#131211', '#1E1A15'); // dark ground → light text
        return SvgPicture.string(
          svg,
          width: size,
          height: size,
          theme: const SvgTheme(currentColor: AppColors.lightText),
        );
      },
    );
  }
}
