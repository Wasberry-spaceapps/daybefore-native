import 'package:flutter/widgets.dart';
import '../theme_provider.dart';
import '../tokens.dart';
import 'day_button.dart';
import 'day_divider.dart';
import 'day_avatar.dart';
import 'day_date_chip.dart';
import 'day_status_pill.dart';
import 'day_section_header.dart';
import 'day_empty_state.dart';
import 'day_skeleton.dart';
import '../illustrations/day_illustrations.dart';

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  bool _isDay = false;

  @override
  Widget build(BuildContext context) {
    final palette = _isDay ? Palette.day : Palette.night;

    return PaletteProvider(
      palette: palette,
      child: Builder(
        builder: (context) {
          return Container(
            color: palette.ground,
            child: DefaultTextStyle(
              style: Ty.body(palette.text),
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: palette.hairline)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Component Gallery', style: Ty.heading(palette.text))),
                          // We'll use a placeholder for DayToggle if it's not ready
                          GestureDetector(
                            onTap: () => setState(() => _isDay = !_isDay),
                            child: Text(_isDay ? 'Switch to Night' : 'Switch to Day', style: Ty.label(palette.accent)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const DaySectionHeader(title: 'Buttons', topMargin: 0),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              DayButton.primary(label: 'Primary', onTap: () {}),
                              DayButton.quiet(label: 'Quiet', onTap: () {}),
                              DayButton.danger(label: 'Danger', onTap: () {}),
                              DayButton.primary(label: 'Disabled', onTap: null),
                              DayButton.primary(label: 'Loading', onTap: () {}, isLoading: true),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const DaySectionHeader(title: 'Status & Data'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              const DayStatusPill(label: 'Neutral', variant: DayStatusPillVariant.neutral, showDot: true),
                              const DayStatusPill(label: 'Success', variant: DayStatusPillVariant.success, showDot: true),
                              const DayStatusPill(label: 'Danger', variant: DayStatusPillVariant.danger, showDot: true),
                              const DayStatusPill(label: 'Accent', variant: DayStatusPillVariant.accent, showDot: true),
                              DayDateChip(date: DateTime.now()),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const DaySectionHeader(title: 'Skeletons'),
                          const SizedBox(height: 16),
                          DaySkeletonGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const DaySkeleton.circle(size: 40),
                                const SizedBox(height: 8),
                                const DaySkeleton.text(width: 200),
                                const SizedBox(height: 4),
                                const DaySkeleton.text(width: 150),
                                const SizedBox(height: 16),
                                const DaySkeleton.rect(width: double.infinity, height: 60),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const DaySectionHeader(title: 'Avatars & Dividers'),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              DayAvatar(size: 40, email: 'test@example.com'),
                              SizedBox(width: 16),
                              DayAvatar(size: 40, email: null),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const DayDivider(),
                          const SizedBox(height: 32),
                          const DaySectionHeader(title: 'Empty State'),
                          const SizedBox(height: 16),
                          const DayEmptyState(
                            illustration: DayIllustrationName.emptyJournal,
                            headline: 'Write the day down.',
                            body: 'Or return to something that keeps coming back.',
                          ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
