import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayBottomSheet extends StatelessWidget {
  final Widget child;

  const DayBottomSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: palette.raised,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Rad.modal),
          topRight: Radius.circular(Rad.modal),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.ghost,
              borderRadius: Rad.bPill,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
