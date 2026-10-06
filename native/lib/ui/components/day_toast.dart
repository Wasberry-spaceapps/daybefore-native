import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayToast {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    final palette = PaletteProvider.of(context);

    final entry = OverlayEntry(
      builder: (context) => _DayToastWidget(
        message: message,
        palette: palette,
        duration: duration,
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

class _DayToastWidget extends StatefulWidget {
  final String message;
  final Palette palette;
  final Duration duration;
  final VoidCallback onDismissed;

  const _DayToastWidget({
    required this.message,
    required this.palette,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_DayToastWidget> createState() => _DayToastWidgetState();
}

class _DayToastWidgetState extends State<_DayToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Mo.base);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Mo.easeOut));
    _translate = Tween<double>(begin: 20.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Mo.easeOut));
    
    _controller.forward();
    Future.delayed(widget.duration, () {
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 64,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, _translate.value),
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.palette.ghost.withOpacity(0.9),
                borderRadius: Rad.bPill,
                boxShadow: Depth.lg(widget.palette),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.message,
                style: Ty.captionMedium(widget.palette.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
