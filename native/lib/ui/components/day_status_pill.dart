import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

enum DayStatusPillVariant { neutral, accent, success, danger }

class DayStatusPill extends StatelessWidget {
  final String label;
  final DayStatusPillVariant variant;
  final bool showDot;

  const DayStatusPill({
    super.key,
    required this.label,
    this.variant = DayStatusPillVariant.neutral,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    Color bg;
    Color text;
    
    switch (variant) {
      case DayStatusPillVariant.neutral:
        bg = palette.ghost;
        text = palette.faint;
        break;
      case DayStatusPillVariant.accent:
        bg = palette.accentMuted;
        text = palette.accent;
        break;
      case DayStatusPillVariant.success:
        bg = palette.successMuted;
        text = palette.success;
        break;
      case DayStatusPillVariant.danger:
        bg = palette.dangerMuted;
        text = palette.danger;
        break;
    }

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.bPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: text,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Ty.captionMedium(text),
          ),
        ],
      ),
    );
  }
}
