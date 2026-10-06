import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'day_list_row.dart';

class DaySidebarSection extends StatefulWidget {
  final String title;
  final List<DayListRow> items;
  final VoidCallback? onAdd;

  const DaySidebarSection({
    super.key,
    required this.title,
    required this.items,
    this.onAdd,
  });

  @override
  State<DaySidebarSection> createState() => _DaySidebarSectionState();
}

class _DaySidebarSectionState extends State<DaySidebarSection> {
  bool _isExpanded = true;
  bool _addHovered = false;
  bool _chevronHovered = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 28,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Ty.overline(palette.muted),
                  ),
                ),
                if (widget.onAdd != null) ...[
                  MouseRegion(
                    onEnter: (_) => setState(() => _addHovered = true),
                    onExit: (_) => setState(() => _addHovered = false),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onAdd,
                      child: Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.plus,
                          size: 14,
                          color: _addHovered ? palette.muted : palette.faint,
                        ),
                      ),
                    ),
                  ),
                ],
                MouseRegion(
                  onEnter: (_) => setState(() => _chevronHovered = true),
                  onExit: (_) => setState(() => _chevronHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _toggleExpanded,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0 : -0.25,
                        duration: reduceMotion ? Duration.zero : Mo.base,
                        curve: Mo.ease,
                        child: Icon(
                          LucideIcons.chevronDown,
                          size: 14,
                          color: _chevronHovered ? palette.muted : palette.faint,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: _isExpanded ? 1.0 : 0.0,
            duration: reduceMotion ? Duration.zero : Mo.base,
            curve: Mo.ease,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: widget.items,
            ),
          ),
        ),
      ],
    );
  }
}
