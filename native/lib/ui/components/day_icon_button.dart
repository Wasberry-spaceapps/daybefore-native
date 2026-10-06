import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'utils.dart';

class DayIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const DayIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
  });

  @override
  State<DayIconButton> createState() => _DayIconButtonState();
}

class _DayIconButtonState extends State<DayIconButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  late final FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _tooltipEntry;
  late AnimationController _tooltipController;
  late Animation<double> _tooltipOpacity;
  bool _tooltipTimerActive = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    
    _tooltipController = AnimationController(vsync: this, duration: Mo.fast);
    _tooltipOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _tooltipController,
      curve: Mo.ease,
    ));
  }

  @override
  void dispose() {
    _removeTooltip();
    _tooltipController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus && HardwareKeyboard.instance.logicalKeysPressed.isNotEmpty;
    });
  }

  bool get _disabled => widget.onTap == null;

  void _onHover(bool isHovering) {
    if (_disabled) return;
    setState(() {
      _isHovered = isHovering;
    });
    
    if (isHovering && widget.tooltip != null) {
      _tooltipTimerActive = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || !_tooltipTimerActive) return;
        _showTooltip();
      });
    } else {
      _tooltipTimerActive = false;
      _removeTooltip();
    }
  }
  
  void _showTooltip() {
    if (_tooltipEntry != null) return;
    
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    _tooltipEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, 4),
            child: FadeTransition(
              opacity: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _tooltipOpacity,
              child: DefaultTextStyle(
                style: Ty.caption(palette.buttonInk),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.buttonBg,
                      borderRadius: Rad.bXs,
                    ),
                    child: Text(widget.tooltip!),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_tooltipEntry!);
    if (reduceMotion) {
      _tooltipController.value = 1.0;
    } else {
      _tooltipController.forward();
    }
  }

  void _removeTooltip() {
    _tooltipTimerActive = false;
    if (_tooltipEntry != null) {
      _tooltipController.reverse().then((_) {
        _tooltipEntry?.remove();
        _tooltipEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final size = isPhone(context) ? 44.0 : 40.0;

    Color bg = const Color(0x00000000);
    if (_isPressed) {
      bg = palette.pressed;
    } else if (_isHovered) {
      bg = palette.hover;
    }

    Color iconColor = _isHovered ? palette.text : palette.muted;

    Widget button = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : Mo.fast,
      curve: Mo.ease,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.bSm,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );

    if (_isFocused) {
      button = Container(
        decoration: BoxDecoration(
          borderRadius: Rad.bSm,
          border: Border.all(color: palette.focusRing, width: 2),
        ),
        padding: const EdgeInsets.all(2),
        child: button,
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) {
            if (!_disabled) setState(() => _isPressed = true);
            _removeTooltip();
          },
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
      ),
    );
  }
}
