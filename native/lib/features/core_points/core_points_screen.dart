import 'package:flutter/material.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/utils.dart';
import '../../ui/illustrations/day_illustrations.dart';
import '../../ui/components/day_empty_state.dart';
import '../../ui/components/day_button.dart';

class CorePointScreen extends StatelessWidget {
  final String id;
  const CorePointScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isPhone(context)) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 48),
            child: Text('Core Points', style: Ty.titleLg(palette.text)),
          ),
          const SizedBox(height: 24),
        ],
        Expanded(
          child: DayEmptyState(
            illustration: DayIllustrationName.emptyCorePoints,
            text: 'What are the few standards you would like to be held to?',
          ),
        ),
      ],
    );
  }
}
