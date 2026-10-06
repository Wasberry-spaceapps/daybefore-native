import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_avatar.dart';
import '../../ui/components/day_status_pill.dart';
import '../../ui/components/day_icon_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  DayIconButton(icon: 'back', size: 44, onTap: () => context.pop()),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          DayAvatar(size: 56, email: null),
                          const SizedBox(height: 16),
                          Text('Not signed in', style: Ty.body(palette.text)),
                          const SizedBox(height: 8),
                          DayStatusPill(
                            label: 'Free',
                            color: null,
                          ),
                          const SizedBox(height: 32),
                          _SettingRow(label: 'Plan and sync', onTap: () => context.go('/plan')),
                          _SettingRow(label: 'Export your entries', onTap: () => context.go('/export')),
                          _SettingRow(label: 'Sign in', onTap: () => context.go('/sign-in')),
                          const SizedBox(height: 32),
                          Text('Day Before v1.0.0', style: Ty.caption(palette.faint)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool danger;
  final VoidCallback onTap;

  const _SettingRow({required this.label, this.value, this.danger = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            hoverColor: palette.hover,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Text(label, style: Ty.body(danger ? palette.danger : palette.text)),
                  const Spacer(),
                  if (value != null) ...[
                    Text(value!, style: Ty.body(palette.muted)),
                    const SizedBox(width: 8),
                  ],
                  if (!danger) Icon(Icons.chevron_right, size: 16, color: palette.faint),
                ],
              ),
            ),
          ),
        ),
        Container(height: 1, color: palette.hairline),
      ],
    );
  }
}
