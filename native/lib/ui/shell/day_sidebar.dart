import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme_provider.dart';
import '../icons/day_icons.dart';
import '../components/day_button.dart';
import '../components/day_avatar.dart';

class DaySidebar extends StatelessWidget {
  final double width;
  const DaySidebar({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.only(left: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DayIcon(name: DayIconName.horizon, size: 22, color: palette.accent),
              const SizedBox(width: 10),
              Text('Day Before',
                style: TextStyle(fontFamily: 'Gelasio', fontSize: 20, height: 26 / 20,
                  fontWeight: FontWeight.w600, color: palette.text)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DayButton.primary(
            label: 'New entry',
            onTap: () {
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Scaffold.of(context).closeDrawer();
              }
              context.goNamed('entry', pathParameters: {'id': 'new'});
            },
          ),
        ),
        const SizedBox(height: 20),
        _SidebarSection(
          title: 'JOURNAL',
          items: [],
          onAdd: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
        ),
        _SidebarSection(
          title: 'ISSUES',
          items: [],
          onAdd: () => context.goNamed('issue', pathParameters: {'id': 'new'}),
        ),
        _SidebarSection(
          title: 'CORE POINTS',
          items: [],
          onAdd: () => context.goNamed('core', pathParameters: {'id': 'new'}),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(height: 1, color: palette.hairline),
        ),
        const SizedBox(height: 8),
        _FooterRow(icon: DayIconName.takeAMinute, label: 'Take a minute', onTap: () => context.go('/minute')),
        _FooterRow(icon: DayIconName.export_, label: 'Export', onTap: () => context.go('/export')),
        _FooterRow(
          leading: DayAvatar(size: 28, email: null),
          label: 'Account',
          onTap: () => context.go('/account'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SidebarSection extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final String? selectedId;
  final VoidCallback onAdd;

  const _SidebarSection({required this.title, required this.items, this.selectedId, required this.onAdd});

  @override
  State<_SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends State<_SidebarSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 28,
            child: Row(
              children: [
                Text(widget.title,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, height: 16 / 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.9,
                    color: palette.muted)),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onAdd,
                  child: Icon(Icons.add, size: 16, color: palette.muted),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _collapsed = !_collapsed),
                  child: AnimatedRotation(
                    turns: _collapsed ? 0.0 : 0.25,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.chevron_right, size: 16, color: palette.faint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  final DayIconName? icon;
  final Widget? leading;
  final String label;
  final VoidCallback onTap;

  const _FooterRow({this.icon, this.leading, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return SizedBox(
      height: 36,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          hoverColor: palette.hover,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (leading != null) leading!
                else if (icon != null) DayIcon(name: icon!, size: 18, color: palette.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 20 / 14,
                      color: palette.muted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
