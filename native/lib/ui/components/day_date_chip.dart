import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../theme_provider.dart';
import '../tokens.dart';

class DayDateChip extends StatelessWidget {
  final DateTime date;

  const DayDateChip({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final isCurrentYear = date.year == DateTime.now().year;
    
    // "Mon 6 Oct" or "6 Oct 2025"
    final format = isCurrentYear ? DateFormat('EEE d MMM') : DateFormat('d MMM yyyy');
    final formatted = format.format(date);

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: palette.sunken,
        borderRadius: Rad.bSm,
      ),
      alignment: Alignment.center,
      child: Text(
        formatted,
        style: Ty.captionMedium(palette.faint),
      ),
    );
  }
}
