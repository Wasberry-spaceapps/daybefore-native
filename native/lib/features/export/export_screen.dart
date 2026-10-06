import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_button.dart';
import '../../ui/components/day_status_pill.dart';
import '../../ui/components/day_icon_button.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _format = 0; // 0=markdown, 1=pdf, 2=json

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      appBar: AppBar(
        backgroundColor: palette.ground,
        elevation: 0,
        leading: DayIconButton(icon: 'back', size: 44, onTap: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Export your entries', style: Ty.titleLg(palette.text)),
                  const SizedBox(height: 12),
                  Text(
                    'Everything is decrypted on this device and saved as files. Nothing is uploaded.',
                    style: Ty.body(palette.muted),
                  ),
                  const SizedBox(height: 24),
                  _ExportFormatCard(
                    selected: _format == 0,
                    onTap: () => setState(() => _format = 0),
                    title: 'Markdown',
                    pill: DayStatusPill(label: 'recommended', color: palette.accentMuted),
                    description: 'One file per entry, in a zip. Opens in Obsidian, Notion and any text editor.',
                  ),
                  const SizedBox(height: 12),
                  _ExportFormatCard(
                    selected: _format == 1,
                    onTap: () => setState(() => _format = 1),
                    title: 'PDF',
                    description: 'One readable document of all your entries.',
                  ),
                  const SizedBox(height: 12),
                  _ExportFormatCard(
                    selected: _format == 2,
                    onTap: () => setState(() => _format = 2),
                    title: 'JSON',
                    description: 'A complete backup, including every revision of every issue.',
                  ),
                  const SizedBox(height: 24),
                  DayButton(
                    label: 'Export',
                    variant: DayButtonVariant.primary,
                    fullWidth: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportFormatCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;
  final Widget? pill;
  final String description;

  const _ExportFormatCard({
    required this.selected,
    required this.onTap,
    required this.title,
    this.pill,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.raised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? palette.accent : palette.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Ty.heading(palette.text)),
                if (pill != null) ...[const SizedBox(width: 8), pill!],
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: Ty.caption(palette.muted)),
          ],
        ),
      ),
    );
  }
}
