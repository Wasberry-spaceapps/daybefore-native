import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const DayToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  State<DayToggle> createState() => _DayToggleState();
}

class _DayToggleState extends State<DayToggle> {
  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget track = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : Mo.base,
      curve: Mo.ease,
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: widget.value ? palette.accent : palette.ghost,
        borderRadius: Rad.bPill,
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: reduceMotion ? Duration.zero : Mo.base,
            curve: Mo.ease,
            top: 3,
            bottom: 3,
            left: widget.value ? 23 : 3,
            right: widget.value ? 3 : 23,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: Depth.sm(palette),
              ),
            ),
          ),
        ],
      ),
    );

    Widget content = track;
    if (widget.label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label!, style: Ty.body(palette.text)),
          const SizedBox(width: 12),
          track,
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(!widget.value),
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          alignment: Alignment.centerLeft,
          child: content,
        ),
      ),
    );
  }
}
