import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayScrollIndicator extends StatefulWidget {
  final ScrollController controller;
  final Widget child;

  const DayScrollIndicator({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<DayScrollIndicator> createState() => _DayScrollIndicatorState();
}

class _DayScrollIndicatorState extends State<DayScrollIndicator> {
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void didUpdateWidget(DayScrollIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleScroll);
      widget.controller.addListener(_handleScroll);
      _handleScroll();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.controller.hasClients) return;
    
    final position = widget.controller.position;
    final up = position.pixels > position.minScrollExtent;
    final down = position.pixels < position.maxScrollExtent;
    
    if (up != _canScrollUp || down != _canScrollDown) {
      setState(() {
        _canScrollUp = up;
        _canScrollDown = down;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final dur = reduceMotion ? Duration.zero : Mo.fast;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 24,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: dur,
              opacity: _canScrollUp ? 1.0 : 0.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.ground,
                      palette.ground.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 24,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: dur,
              opacity: _canScrollDown ? 1.0 : 0.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      palette.ground,
                      palette.ground.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
