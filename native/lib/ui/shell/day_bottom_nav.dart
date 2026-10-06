import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme_provider.dart';
import '../icons/day_icons.dart';

class DayBottomNav extends StatelessWidget {
  const DayBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final currentRoute = GoRouterState.of(context).uri.path;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 64 + bottomPad,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: palette.ground,
        border: Border(top: BorderSide(color: palette.hairline, width: 1)),
      ),
      child: Row(
        children: [
          _NavItem(icon: DayIconName.journal, label: 'Journal', active: currentRoute == '/' || currentRoute.startsWith('/entry'), onTap: () => context.go('/')),
          _NavItem(icon: DayIconName.issues, label: 'Issues', active: currentRoute.startsWith('/issue'), onTap: () => context.goNamed('issue', pathParameters: {'id': 'new'})),
          _NavItem(icon: DayIconName.corePoints, label: 'Core Points', active: currentRoute.startsWith('/core'), onTap: () => context.goNamed('core', pathParameters: {'id': 'new'})),
          _NavItem(icon: DayIconName.journal, label: 'Account', active: currentRoute == '/account', onTap: () => context.go('/account')), // Re-using icon for account placeholder
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final DayIconName icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final color = active ? palette.accent : palette.muted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: active ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 140),
                  child: Container(
                    width: 48, height: 32,
                    decoration: BoxDecoration(
                      color: palette.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                DayIcon(name: icon, size: 22, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 16 / 11,
                fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
