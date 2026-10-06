import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const DayPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<DayPullToRefresh> createState() => _DayPullToRefreshState();
}

class _DayPullToRefreshState extends State<DayPullToRefresh> with SingleTickerProviderStateMixin {
  double _overscroll = 0.0;
  bool _isRefreshing = false;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        setState(() {
          _overscroll = -notification.metrics.pixels;
        });
      } else if (_overscroll > 0) {
        setState(() {
          _overscroll = 0.0;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_overscroll > 80.0) {
        _startRefresh();
      } else {
        setState(() {
          _overscroll = 0.0;
        });
      }
    }
    return false;
  }

  void _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _overscroll = 80.0;
    });
    _waveController.repeat();
    
    await widget.onRefresh();
    
    if (mounted) {
      _waveController.stop();
      setState(() {
        _isRefreshing = false;
        _overscroll = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final indicatorY = _isRefreshing ? 40.0 : (_overscroll > 0 ? (_overscroll * 0.5).clamp(0.0, 40.0) : -40.0);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: widget.child,
        ),
        AnimatedPositioned(
          duration: _isRefreshing || _overscroll == 0 ? Mo.fast : Duration.zero,
          curve: Mo.easeOut,
          top: indicatorY,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              if (reduceMotion) {
                return Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                );
              }
              
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final t = (_waveController.value - (index * 0.166)) % 1.0;
                  final scale = t < 0 ? 0.5 : (t < 0.5 ? 0.5 + (t * 2) * 0.5 : 1.0 - ((t - 0.5) * 2) * 0.5);
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
