import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme_provider.dart';
import '../icons/day_icons.dart';

class DayTopBar extends StatelessWidget {
  const DayTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final sectionName = "Journal"; // Placeholder, derive from route context
    return Container(
      height: 56,
      color: palette.ground,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          // Menu button
          SizedBox(
            width: 44, height: 44,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                customBorder: const CircleBorder(),
                hoverColor: palette.hover,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Center(child: Icon(Icons.menu, size: 22, color: palette.text)), // Fallback to Icons.menu
              ),
            ),
          ),
          // Centered title
          Expanded(
            child: Center(
              child: Text(sectionName,
                style: TextStyle(fontFamily: 'Newsreader', fontSize: 18, height: 24 / 18,
                  fontWeight: FontWeight.w500, color: palette.text)),
            ),
          ),
          // New entry button
          SizedBox(
            width: 44, height: 44,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
                customBorder: const CircleBorder(),
                hoverColor: palette.hover,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Center(child: DayIcon(name: DayIconName.newEntry, size: 22, color: palette.text)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
