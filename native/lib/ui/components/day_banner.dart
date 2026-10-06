import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'day_icon_button.dart';

enum DayBannerType { info, error, success }

class DayBanner extends StatefulWidget {
  final String text;
  final DayBannerType type;
  final IconData? icon;
  final VoidCallback? onClose;

  const DayBanner({
    super.key,
    required this.text,
    this.type = DayBannerType.info,
    this.icon,
    this.onClose,
  });

  @override
  State<DayBanner> createState() => _DayBannerState();
}

class _DayBannerState extends State<DayBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Mo.base);
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Mo.ease));
    if (!MediaQueryData.fromView(WidgetsBinding.instance.window).disableAnimations) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    if (MediaQuery.of(context).disableAnimations) {
      widget.onClose?.call();
    } else {
      _controller.duration = Mo.fast;
      _controller.reverse().then((_) {
        widget.onClose?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Color bg;
    switch (widget.type) {
      case DayBannerType.info:
        bg = palette.accentMuted;
        break;
      case DayBannerType.error:
        bg = palette.dangerMuted;
        break;
      case DayBannerType.success:
        bg = palette.successMuted;
        break;
    }

    Widget content = Container(
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: palette.hairline, width: 1)),
      ),
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: palette.text),
                  const SizedBox(width: 8),
                ],
                Text(widget.text, style: Ty.labelSm(palette.text)),
              ],
            ),
          ),
          if (widget.onClose != null)
            Positioned(
              right: 6,
              top: 6,
              bottom: 6,
              child: SizedBox(
                width: 28,
                height: 28,
                child: DayIconButton(
                  icon: LucideIcons.x,
                  onTap: dismiss,
                ),
              ),
            ),
        ],
      ),
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (reduceMotion) return child!;
          return Align(
            alignment: Alignment.topCenter,
            heightFactor: _heightFactor.value,
            child: child,
          );
        },
        child: content,
      ),
    );
  }
}
