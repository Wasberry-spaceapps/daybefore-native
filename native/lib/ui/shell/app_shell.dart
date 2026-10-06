import 'package:flutter/material.dart';
import '../theme_provider.dart';
import 'day_sidebar.dart';
import 'day_top_bar.dart';
import 'day_bottom_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final w = MediaQuery.of(context).size.width;

    if (w >= 600) {
      // Desktop (>=900) or Tablet (600–899)
      final sideW = w >= 900 ? 288.0 : 256.0;
      return ColoredBox(
        color: palette.ground,
        child: Row(
          children: [
            SizedBox(width: sideW, child: DaySidebar(width: sideW)),
            Container(width: 1, color: palette.hairline),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone (<600)
    return Scaffold(
      backgroundColor: palette.ground,
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 40,
      drawerScrimColor: Colors.black54,
      drawer: SizedBox(
        width: (w * 0.86).clamp(0.0, 340.0),
        child: ColoredBox(
          color: palette.sidebar,
          child: SafeArea(child: DaySidebar(width: (w * 0.86).clamp(0.0, 340.0))),
        ),
      ),
      body: Column(
        children: [
          const DayTopBar(),
          Expanded(child: child),
          const DayBottomNav(),
        ],
      ),
    );
  }
}
