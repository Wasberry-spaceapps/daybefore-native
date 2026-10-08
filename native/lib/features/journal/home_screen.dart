import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/components/day_button.dart';
import '../../ui/components/utils.dart';
import '../../ui/illustrations/day_illustrations.dart';
import '../../ui/tokens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final phone = isPhone(context);

    // Empty state for now
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DayIllustration(name: DayIllustrationName.welcome, size: 80),
                const SizedBox(height: 24),
                Text('Write the day down.',
                  textAlign: TextAlign.center,
                  style: Ty.displaySm(palette.text)),
                const SizedBox(height: 12),
                Text('Or open up something in us that keeps coming back.',
                  textAlign: TextAlign.center,
                  style: Ty.body(palette.muted)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DayButton(
                      label: 'New entry',
                      variant: DayButtonVariant.primary,
                      onTap: () => context.goNamed('entry', pathParameters: {'id': 'new'}),
                    ),
                    const SizedBox(width: 12),
                    DayButton(
                      label: 'Open an issue',
                      variant: DayButtonVariant.quiet,
                      onTap: () => context.goNamed('issue', pathParameters: {'id': 'new'}),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
