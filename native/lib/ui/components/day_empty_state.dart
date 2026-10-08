import 'package:flutter/widgets.dart';
import '../illustrations/day_illustrations.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayEmptyState extends StatefulWidget {
  final DayIllustrationName illustration;
  final String headline;
  final String body;

  const DayEmptyState({
    super.key,
    required this.illustration,
    required this.headline,
    required this.body,
  });

  @override
  State<DayEmptyState> createState() => _DayEmptyStateState();
}

class _DayEmptyStateState extends State<DayEmptyState> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim1;
  late final Animation<double> _anim2;
  late final Animation<double> _anim3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim1 = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Mo.easeOut));
    _anim2 = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Mo.easeOut));
    _anim3 = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Mo.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget buildItem(Animation<double> anim, Widget child) {
      if (reduceMotion) return child;
      return AnimatedBuilder(
        animation: anim,
        builder: (context, child) {
          return Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - anim.value)),
              child: child,
            ),
          );
        },
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildItem(
              _anim1,
              DayIllustration(name: widget.illustration, size: 120),
            ),
            const SizedBox(height: 16),
            buildItem(
              _anim2,
              Text(
                widget.headline,
                style: Ty.heading(palette.text),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            buildItem(
              _anim3,
              Text(
                widget.body,
                style: Ty.body(palette.muted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
