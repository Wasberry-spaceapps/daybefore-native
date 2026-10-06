import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

enum DayListRowType { compact, settings }

class DayListRow extends StatefulWidget {
  final String text;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final DayListRowType type;

  const DayListRow.compact({
    super.key,
    required this.text,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.selected = false,
  }) : type = DayListRowType.compact;

  const DayListRow.settings({
    super.key,
    required this.text,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.selected = false,
  }) : type = DayListRowType.settings;

  @override
  State<DayListRow> createState() => _DayListRowState();
}

class _DayListRowState extends State<DayListRow> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _disabled => widget.onTap == null;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final isCompact = widget.type == DayListRowType.compact;
    final height = isCompact ? 40.0 : 52.0;
    final paddingHorizontal = isCompact ? 12.0 : 16.0;
    final radius = isCompact ? Rad.bSm : Rad.bMd;
    final textStyle = isCompact ? Ty.label(palette.text) : Ty.body(palette.text);

    Color bg = const Color(0x00000000);
    if (widget.selected) {
      bg = palette.hover;
    } else if (_isPressed) {
      bg = palette.pressed;
    } else if (_isHovered) {
      bg = palette.hover;
    }

    final iconColor = widget.selected ? palette.text : palette.muted;

    Widget content = Row(
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: 18, color: iconColor),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            widget.text,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 10),
          widget.trailing!,
        ],
      ],
    );

    Widget row = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : Mo.fast,
      curve: Mo.ease,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          content,
          if (widget.selected)
            AnimatedOpacity(
              duration: reduceMotion ? Duration.zero : Mo.fast,
              curve: Mo.ease,
              opacity: 1.0,
              child: Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: Rad.bPill,
                ),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) { if (!_disabled) setState(() => _isHovered = true); },
      onExit: (_) { if (!_disabled) setState(() => _isHovered = false); },
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) { if (!_disabled) setState(() => _isPressed = true); },
        onTapUp: (_) { if (!_disabled) setState(() => _isPressed = false); },
        onTapCancel: () { if (!_disabled) setState(() => _isPressed = false); },
        onTap: widget.onTap,
        child: row,
      ),
    );
  }
}
