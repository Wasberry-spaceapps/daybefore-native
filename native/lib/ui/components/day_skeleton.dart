import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DaySkeletonGroup extends StatefulWidget {
  final Widget child;

  const DaySkeletonGroup({super.key, required this.child});

  static Animation<double>? of(BuildContext context) {
    final state = context.findAncestorStateOfType<_DaySkeletonGroupState>();
    return state?._controller;
  }

  @override
  State<DaySkeletonGroup> createState() => _DaySkeletonGroupState();
}

class _DaySkeletonGroupState extends State<DaySkeletonGroup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

enum SkeletonType { rect, circle, text }

class DaySkeleton extends StatefulWidget {
  final SkeletonType type;
  final double? width;
  final double? height;

  const DaySkeleton({
    super.key,
    this.type = SkeletonType.text,
    this.width,
    this.height,
  });

  const DaySkeleton.rect({
    super.key,
    required this.width,
    required this.height,
  }) : type = SkeletonType.rect;

  const DaySkeleton.circle({
    super.key,
    required double size,
  }) : type = SkeletonType.circle, width = size, height = size;

  const DaySkeleton.text({
    super.key,
    this.width = double.infinity,
  }) : type = SkeletonType.text, height = 16.0;

  @override
  State<DaySkeleton> createState() => _DaySkeletonState();
}

class _DaySkeletonState extends State<DaySkeleton> with SingleTickerProviderStateMixin {
  AnimationController? _fallbackController;

  @override
  void dispose() {
    _fallbackController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    double h = widget.height ?? 16.0;
    double w = widget.width ?? double.infinity;
    
    BoxShape shape = widget.type == SkeletonType.circle ? BoxShape.circle : BoxShape.rectangle;
    BorderRadius? radius = widget.type == SkeletonType.rect ? Rad.bMd : (widget.type == SkeletonType.text ? Rad.bSm : null);

    if (reduceMotion) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: palette.skeleton,
          shape: shape,
          borderRadius: radius,
        ),
      );
    }

    final groupAnim = DaySkeletonGroup.of(context);
    Animation<double> anim;
    if (groupAnim != null) {
      anim = groupAnim;
    } else {
      _fallbackController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
      anim = _fallbackController!;
    }

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final x = anim.value * 2 - 0.5; // Sweep from -0.5 to 1.5
            return LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [
                palette.skeleton,
                palette.skeletonShimmer,
                palette.skeleton,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: palette.skeleton,
              shape: shape,
              borderRadius: radius,
            ),
          ),
        );
      },
    );
  }
}
