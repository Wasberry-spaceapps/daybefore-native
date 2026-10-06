import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayTab extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const DayTab({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      decoration: BoxDecoration(
        color: palette.sunken,
        borderRadius: Rad.bMd,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(labels.length, (index) {
          final isSelected = index == selected;
          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: reduceMotion ? Duration.zero : Mo.fast,
                  curve: Mo.ease,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? palette.raised : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected ? Depth.sm(palette) : null,
                  ),
                  child: Text(
                    labels[index],
                    style: Ty.label(isSelected ? palette.text : palette.muted),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
