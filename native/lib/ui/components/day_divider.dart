import 'package:flutter/widgets.dart';
import '../theme_provider.dart';

class DayDivider extends StatelessWidget {
  final double horizontalMargin;
  
  const DayDivider({
    super.key,
    this.horizontalMargin = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: ColoredBox(color: palette.hairline),
      ),
    );
  }
}
