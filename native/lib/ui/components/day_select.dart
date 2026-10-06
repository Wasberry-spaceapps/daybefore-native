import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DaySelect<T> extends StatefulWidget {
  final T? value;
  final String? placeholder;
  final List<DaySelectOption<T>> options;
  final ValueChanged<T> onChanged;

  const DaySelect({
    super.key,
    this.value,
    this.placeholder,
    required this.options,
    required this.onChanged,
  });

  @override
  State<DaySelect<T>> createState() => _DaySelectState<T>();
}

class DaySelectOption<T> {
  final T value;
  final String label;

  const DaySelectOption({
    required this.value,
    required this.label,
  });
}

class _DaySelectState<T> extends State<DaySelect<T>> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  bool _isHovered = false;
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Mo.fast);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Mo.ease));
    _offset = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Mo.ease));
  }

  @override
  void dispose() {
    _close();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    if (_isOpen) return;
    
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0x00000000),
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: FadeTransition(
                  opacity: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _opacity,
                  child: SlideTransition(
                    position: reduceMotion ? const AlwaysStoppedAnimation(Offset.zero) : _offset,
                    child: Material(
                      color: const Color(0x00000000),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        decoration: BoxDecoration(
                          color: palette.raised,
                          border: Border.all(color: palette.hairline, width: 1),
                          borderRadius: Rad.bMd,
                          boxShadow: Depth.md(palette),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: widget.options.length,
                          itemBuilder: (context, index) {
                            final option = widget.options[index];
                            final isSelected = option.value == widget.value;
                            return _SelectOptionItem(
                              option: option,
                              isSelected: isSelected,
                              onTap: () {
                                widget.onChanged(option.value);
                                _close();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    if (reduceMotion) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    if (MediaQuery.of(context).disableAnimations) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    
    final selectedOption = widget.options.where((o) => o.value == widget.value).firstOrNull;
    final text = selectedOption?.label ?? widget.placeholder ?? '';
    final textStyle = selectedOption != null ? Ty.body(palette.text) : Ty.body(palette.faint);
    
    Color borderColor = _isOpen ? palette.accent : (_isHovered ? palette.hairlineBold : palette.hairline);

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : Mo.fast,
            curve: Mo.ease,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: palette.raised,
              borderRadius: Rad.bMd,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(text, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: reduceMotion ? Duration.zero : Mo.fast,
                  curve: Mo.ease,
                  child: Icon(LucideIcons.chevronDown, size: 16, color: palette.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectOptionItem<T> extends StatefulWidget {
  final DaySelectOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectOptionItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SelectOptionItem<T>> createState() => _SelectOptionItemState<T>();
}

class _SelectOptionItemState<T> extends State<_SelectOptionItem<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: _isHovered ? palette.hover : const Color(0x00000000),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.option.label,
                  style: Ty.body(palette.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Icon(LucideIcons.check, size: 16, color: palette.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
