import 'package:flutter/widgets.dart';
import 'dart:async';
import '../theme_provider.dart';
import '../tokens.dart';
import 'utils.dart';

class DayTextArea extends StatefulWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool showBottomBorder;

  const DayTextArea({
    super.key,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.showBottomBorder = false,
  });

  @override
  State<DayTextArea> createState() => _DayTextAreaState();
}

class _DayTextAreaState extends State<DayTextArea> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  void _onChanged(String value) {
    if (widget.onChanged == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      widget.onChanged!(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final textStyle = isDesktop(context) || isTablet(context) 
        ? Ty.writingLg(palette.text) 
        : Ty.writingSm(palette.text);
    
    Widget innerField = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      style: textStyle,
      cursorColor: palette.accent,
      backgroundCursorColor: palette.ground,
      selectionColor: palette.accent.withOpacity(0.25),
      maxLines: null,
      expands: false,
      onChanged: _onChanged,
    );

    if (widget.placeholder != null) {
      innerField = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              if (_controller.text.isEmpty)
                Text(
                  widget.placeholder!, 
                  style: isDesktop(context) || isTablet(context) 
                      ? Ty.writingLg(palette.faint) 
                      : Ty.writingSm(palette.faint)
                ),
              child!,
            ],
          );
        },
        child: innerField,
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        border: widget.showBottomBorder && _isFocused
            ? Border(bottom: BorderSide(color: palette.hairline, width: 1))
            : null,
      ),
      child: innerField,
    );
  }
}
