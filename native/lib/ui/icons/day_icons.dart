import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DayIconName {
  journal,
  issues,
  corePoints,
  newEntry,
  export_,
  lock,
  takeAMinute,
  horizon,
}

class DayIcon extends StatelessWidget {
  final DayIconName name;
  final double size;
  final Color color;

  const DayIcon({
    super.key,
    required this.name,
    this.size = 24,
    required this.color,
  });

  String get _assetPath {
    const map = {
      DayIconName.journal: 'assets/icons/journal.svg',
      DayIconName.issues: 'assets/icons/issues.svg',
      DayIconName.corePoints: 'assets/icons/core-points.svg',
      DayIconName.newEntry: 'assets/icons/new-entry.svg',
      DayIconName.export_: 'assets/icons/export.svg',
      DayIconName.lock: 'assets/icons/lock.svg',
      DayIconName.takeAMinute: 'assets/icons/take-a-minute.svg',
      DayIconName.horizon: 'assets/icons/horizon.svg',
    };
    return map[name]!;
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      package: null, // assets are in the app itself
    );
  }
}