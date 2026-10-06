import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayAvatar extends StatelessWidget {
  final double size;
  final String? email;

  const DayAvatar({
    super.key,
    this.size = 32.0,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final hasEmail = email != null && email!.trim().isNotEmpty;
    final initial = hasEmail ? email!.trim()[0].toUpperCase() : '';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.ghost,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: hasEmail
          ? Text(
              initial,
              style: Ty.captionMedium(palette.muted).copyWith(
                fontSize: size * 0.375, // Scales proportionally (12 for 32)
                height: 1.0,
              ),
            )
          : Icon(
              LucideIcons.user,
              size: size * 0.6,
              color: palette.muted,
            ),
    );
  }
}
