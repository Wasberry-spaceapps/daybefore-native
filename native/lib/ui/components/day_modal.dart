import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'day_icon_button.dart';
import 'package:flutter/material.dart' show Material;

class DayModal extends StatefulWidget {
  final String title;
  final String body;
  final List<Widget> actions;

  const DayModal({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierDismissible: true,
        transitionDuration: Mo.base,
        reverseTransitionDuration: Mo.fast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final palette = PaletteProvider.of(context);
          final reduceMotion = MediaQuery.of(context).disableAnimations;

          if (reduceMotion) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: ColoredBox(color: palette.overlay),
                  ),
                ),
                Center(child: child),
              ],
            );
          }

          final opacity = CurveTween(curve: Mo.ease).animate(animation);
          final scale = Tween<double>(begin: 0.97, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Mo.ease));

          return Stack(
            children: [
              Positioned.fill(
                child: FadeTransition(
                  opacity: opacity,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: ColoredBox(color: palette.overlay),
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: opacity,
                  child: ScaleTransition(
                    scale: scale,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  State<DayModal> createState() => _DayModalState();
}

class _DayModalState extends State<DayModal> {
  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final h = MediaQuery.of(context).size.height;

    return FocusScope(
      autofocus: true,
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape): const Intent(LocalKey.key("escape")),
        },
        child: Actions(
          actions: {
            Intent: CallbackAction(
              onInvoke: (_) {
                Navigator.of(context).pop();
                return null;
              },
            ),
          },
          child: Material(
            color: const Color(0x00000000),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: h * 0.85,
              ),
              decoration: BoxDecoration(
                color: palette.raised,
                borderRadius: Rad.bModal,
                boxShadow: Depth.overlay(palette),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: Ty.titleSm(palette.text)),
                        const SizedBox(height: 8),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(widget.body, style: Ty.body(palette.muted)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (int i = 0; i < widget.actions.length; i++) ...[
                              if (i > 0) const SizedBox(width: 12),
                              widget.actions[i],
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DayIconButton(
                      icon: LucideIcons.x,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
