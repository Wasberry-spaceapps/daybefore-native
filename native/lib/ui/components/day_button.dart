import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

enum _DayButtonVariant { primary, quiet, danger }

class DayButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final _DayButtonVariant _variant;

  const DayButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
  }) : _variant = _DayButtonVariant.primary;

  const DayButton.quiet({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
  }) : _variant = _DayButtonVariant.quiet;

  const DayButton.danger({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isLoading = false,
  }) : _variant = _DayButtonVariant.danger;

  @override
  State<DayButton> createState() => _DayButtonState();
}

class _DayButtonState extends State<DayButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus && HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
    });
  }

  bool get _disabled => widget.onTap == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Color bg;
    Color border = const Color(0x00000000);
    Color text;
    Color iconColor;

    switch (widget._variant) {
      case _DayButtonVariant.primary:
        bg = _isPressed ? palette.buttonPressed : (_isHovered ? palette.buttonHover : palette.buttonBg);
        text = palette.buttonInk;
        iconColor = palette.buttonInk;
        break;
      case _DayButtonVariant.quiet:
        bg = _isPressed ? palette.quietButtonPressed : (_isHovered ? palette.quietButtonHover : const Color(0x00000000));
        border = _isHovered ? palette.hairlineBold : palette.hairline;
        text = palette.text;
        iconColor = palette.muted;
        break;
      case _DayButtonVariant.danger:
        bg = _isPressed ? palette.danger.withOpacity(0.25) : (_isHovered ? palette.dangerMuted : const Color(0x00000000));
        border = palette.danger.withOpacity(0.4);
        text = palette.danger;
        iconColor = palette.danger;
        break;
    }

    Widget content;
    if (widget.isLoading) {
      // Need a custom spinner instead of this in full implementation
      content = const SizedBox(width: 16, height: 16); 
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
          ],
          Text(widget.label, style: Ty.label(text)),
        ],
      );
    }

    Widget button = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : Mo.fast,
      curve: Mo.ease,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.bMd,
        border: border.alpha > 0 ? Border.all(color: border, width: 1) : null,
      ),
      child: Center(
        widthFactor: 1.0,
        child: content,
      ),
    );

    if (_isFocused) {
      button = Container(
        decoration: BoxDecoration(
          borderRadius: Rad.bMd,
          border: Border.all(color: palette.focusRing, width: 2),
        ),
        padding: const EdgeInsets.all(2),
        child: button,
      );
    }

    button = MouseRegion(
      onEnter: (_) { if (!_disabled) setState(() => _isHovered = true); },
      onExit: (_) { if (!_disabled) setState(() => _isHovered = false); },
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) { if (!_disabled) setState(() => _isPressed = true); },
        onTapUp: (_) { if (!_disabled) setState(() => _isPressed = false); },
        onTapCancel: () { if (!_disabled) setState(() => _isPressed = false); },
        onTap: () {
          if (!_disabled) {
            _focusNode.requestFocus();
            widget.onTap?.call();
          }
        },
        child: Focus(
          focusNode: _focusNode,
          child: Opacity(
            opacity: _disabled ? 0.35 : 1.0,
            child: IgnorePointer(
              ignoring: _disabled,
              child: button,
            ),
          ),
        ),
      ),
    );

    return Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      alignment: Alignment.center,
      child: button,
    );
  }
}
