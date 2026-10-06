import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'day_icon_button.dart';

// Assuming lucide_icons_flutter is used per spec for error icon
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DayTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const DayTextField({
    super.key,
    this.label,
    this.placeholder,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<DayTextField> createState() => _DayTextFieldState();
}

class _DayTextFieldState extends State<DayTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText || widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final hasError = widget.errorText != null;
    
    Color borderColor;
    if (hasError) {
      borderColor = palette.danger;
    } else if (_isFocused) {
      borderColor = palette.accent;
    } else if (_isHovered) {
      borderColor = palette.hairlineBold;
    } else {
      borderColor = palette.hairline;
    }

    Widget innerField = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      style: Ty.body(palette.text),
      cursorColor: palette.accent,
      backgroundCursorColor: palette.ground,
      selectionColor: palette.accent.withOpacity(0.25),
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
    
    if (widget.placeholder != null) {
      innerField = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              if (_controller.text.isEmpty)
                Text(widget.placeholder!, style: Ty.body(palette.faint)),
              child!,
            ],
          );
        },
        child: innerField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Ty.labelSm(palette.muted)),
          const SizedBox(height: 6),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : Mo.fast,
            curve: Mo.ease,
            height: 44,
            decoration: BoxDecoration(
              color: palette.raised,
              borderRadius: Rad.bMd,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Expanded(
                  child: Semantics(
                    textField: true,
                    child: innerField,
                  ),
                ),
                if (widget.isPassword) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: DayIconButton(
                        icon: _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 14),
                ]
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.alertCircle, size: 12, color: palette.danger),
              const SizedBox(width: 4),
              Expanded(child: Text(widget.errorText!, style: Ty.caption(palette.danger))),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(widget.helperText!, style: Ty.caption(palette.faint)),
        ],
      ],
    );
  }
}
