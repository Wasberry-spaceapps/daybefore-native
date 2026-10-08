import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../icons/day_icons.dart';
import '../components/day_button.dart';
import '../components/day_avatar.dart';
import '../app_shell.dart' show AppState;

class _SidebarItemData {
  final String id;
  final String label;
  final String routeName;
  const _SidebarItemData({required this.id, required this.label, required this.routeName});
}

String _entryLabel(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

class DaySidebar extends StatelessWidget {
  final double width;
  const DaySidebar({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final state = context.watch<AppState>();

    final journalItems = state.journals.map((e) => _SidebarItemData(
      id: e.id,
      label: _entryLabel(DateTime.fromMillisecondsSinceEpoch(e.createdAt)),
      routeName: 'entry',
    )).toList();

    final issueItems = state.issues.map((e) => _SidebarItemData(
      id: e.id,
      label: e.name.isEmpty ? 'Untitled' : e.name,
      routeName: 'issue',
    )).toList();

    final coreItems = state.corePoints.map((e) => _SidebarItemData(
      id: e.id,
      label: e.name.isEmpty ? 'Untitled' : e.name,
      routeName: 'core',
    )).toList();

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
                style: TextStyle(fontFamily: 'Newsreader', fontSize: 20, height: 26 / 20,
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
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _SidebarSection(
                title: 'JOURNAL',
                items: journalItems,
                onAdd: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
              ),
              _SidebarSection(
                title: 'ISSUES',
                items: issueItems,
                onAdd: () => context.goNamed('issue', pathParameters: {'id': 'new'}),
              ),
              _SidebarSection(
                title: 'CORE POINTS',
                items: coreItems,
                onAdd: () => context.goNamed('core', pathParameters: {'id': 'new'}),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(height: 1, color: palette.hairline),
        ),
        const SizedBox(height: 8),
        _FooterRow(icon: DayIconName.takeAMinute, label: 'Take a minute', onTap: () => context.goNamed('minute')),
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
  final List<_SidebarItemData> items;
  final String? selectedId;
  final VoidCallback onAdd;

  const _SidebarSection({required this.title, required this.items, required this.onAdd});

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
        if (!_collapsed)
          ...widget.items.map((item) => _SidebarRow(
            item: item,
            isSelected: widget.selectedId == item.id,
          )),
      ],
    );
  }
}

class _SidebarRow extends StatelessWidget {
  final _SidebarItemData item;
  final bool isSelected;

  const _SidebarRow({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return SizedBox(
      height: 32,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.goNamed(item.routeName, pathParameters: {'id': item.id}),
          hoverColor: palette.hover,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: isSelected
                ? BoxDecoration(
                    color: palette.hover,
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            alignment: Alignment.centerLeft,
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 20 / 13,
                color: isSelected ? palette.text : palette.muted,
              ),
            ),
          ),
        ),
      ),
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
