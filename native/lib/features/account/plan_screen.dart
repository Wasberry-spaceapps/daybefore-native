import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_button.dart';
import '../../ui/components/day_card.dart';
import '../../ui/components/day_tab.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      appBar: AppBar(
        backgroundColor: palette.ground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Sync across devices', style: Ty.titleLg(palette.text)),
              const SizedBox(height: 16),
              Text(
                'Writing is free and stays on this device. Sync keeps your encrypted entries on every device you use.',
                style: Ty.body(palette.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DayTab(
                labels: const ['Yearly', 'Monthly'],
                selected: _yearly ? 0 : 1,
                onChanged: (i) => setState(() => _yearly = i == 0),
              ),
              const SizedBox(height: 16),
              DayCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _yearly ? '\$20 a year' : '\$2 a month',
                        style: Ty.heading(palette.text),
                      ),
                      if (_yearly) ...[
                        const SizedBox(height: 4),
                        Text('about \$1.67 a month', style: Ty.caption(palette.muted)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/student'),
                child: Text('I am a student', style: Ty.body(palette.accent)),
              ),
              const SizedBox(height: 24),
              DayButton.primary(
                label: 'Continue',
                onTap: () {
                  // Launch URL logic
                },
              ),
              const SizedBox(height: 12),
              Text(
                'You will finish on the website. If sync ever ends, your entries stay on this device and you can export them anytime.',
                style: Ty.caption(palette.faint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
