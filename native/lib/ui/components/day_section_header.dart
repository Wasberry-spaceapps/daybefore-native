import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DaySectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final double topMargin;

  const DaySectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.topMargin = Sp.x32,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Container(
      height: 32,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.hairline, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: Ty.overline(palette.muted),
          ),
          if (actionLabel != null)
            MouseRegion(
              cursor: onActionTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: onActionTap,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  actionLabel!,
                  style: Ty.captionMedium(palette.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
