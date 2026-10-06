import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DaySnackbar {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    final palette = PaletteProvider.of(context);

    final entry = OverlayEntry(
      builder: (context) => _DaySnackbarWidget(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
        palette: palette,
        onDismissed: () {
          if (_currentOverlay != null) {
            _currentOverlay!.remove();
            _currentOverlay = null;
          }
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }
}

class _DaySnackbarWidget extends StatefulWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Palette palette;
  final VoidCallback onDismissed;

  const _DaySnackbarWidget({
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.palette,
    required this.onDismissed,
  });

  @override
  State<_DaySnackbarWidget> createState() => _DaySnackbarWidgetState();
}

class _DaySnackbarWidgetState extends State<_DaySnackbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Mo.base);
    _translate = Tween<double>(begin: 48.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Mo.easeOut));
    
    _controller.forward();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.duration = Mo.fast;
        _controller.reverse().then((_) => widget.onDismissed());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAction() {
    widget.onAction?.call();
    _controller.duration = Mo.fast;
    _controller.reverse().then((_) => widget.onDismissed());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translate.value),
              child: child,
            );
          },
          child: Container(
            height: 48,
            width: double.infinity,
            color: widget.palette.buttonBg,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.message,
                    style: Ty.label(widget.palette.buttonInk),
                  ),
                ),
                if (widget.actionLabel != null)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _handleAction,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          widget.actionLabel!,
                          style: Ty.label(widget.palette.accent),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
