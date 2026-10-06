import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayFormError extends StatelessWidget {
  final String? errorText;

  const DayFormError({
    super.key,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return AnimatedCrossFade(
      duration: Mo.fast,
      firstCurve: Mo.ease,
      secondCurve: Mo.ease,
      crossFadeState: hasError ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: hasError
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      LucideIcons.alertCircle,
                      size: 14,
                      color: palette.danger,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorText!,
                      style: Ty.caption(palette.danger),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
