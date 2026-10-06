import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool elevated;

  const DayCard({
    super.key,
    required this.child,
    this.elevated = false,
  }) : onTap = null;

  const DayCard.tappable({
    super.key,
    required this.child,
    this.onTap,
    this.elevated = false,
  });

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isTappable => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Color bg = palette.raised;
    if (_isTappable) {
      if (_isPressed) {
        bg = palette.pressed;
      } else if (_isHovered) {
        bg = palette.hover;
      }
    }

    Widget card = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : Mo.fast,
      curve: Mo.ease,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.bCard,
        border: Border.all(color: palette.hairline, width: 1),
        boxShadow: widget.elevated ? Depth.sm(palette) : null,
      ),
      child: widget.child,
    );

    if (_isTappable) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: card,
        ),
      );
    }

    return card;
  }
}
