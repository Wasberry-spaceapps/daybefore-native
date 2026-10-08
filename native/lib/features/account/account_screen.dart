import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/backup_manager.dart';
import '../../core/registry.dart';
import '../../ui/app_shell.dart' show AppState;
import '../../features/auth/auth_provider.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_icon_button.dart';
import '../../ui/components/day_avatar.dart';
import '../../ui/components/day_status_pill.dart';
import '../../ui/components/day_button.dart';
import '../../ui/components/day_toast.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _timeAgo(int ms) {
    if (ms == 0) return 'never';
    final diff = DateTime.now().millisecondsSinceEpoch - ms;
    final mins = diff ~/ 60000;
    if (mins < 2) return 'just now';
    if (mins < 60) return '$mins minutes ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return '$hrs hours ago';
    final days = hrs ~/ 24;
    return '$days days ago';
  }

  Future<void> _backUpNow() async {
    final bm = context.read<BackupManager>();
    bm.markDirty();
    await bm.writeBackup();
    if (mounted) DayToast.show(context, 'Backup saved');
  }

  Future<void> _deleteAccount() async {
    final auth = context.read<AuthProvider>();
    final state = context.read<AppState>();
    final bm = context.read<BackupManager>();
    final entryCount = await state.db.entryCount();

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteAccountDialog(entryCount: entryCount),
    );

    if (confirmed != true || !mounted) return;

    // Execute deletion
    await state.db.deleteAccount();
    await registry.removeAccount(
      (await registry.getActiveAccountId()) ?? '',
    );
    await auth.logout();
    final backups = await bm.listBackups();
    for (final b in backups) {
      await bm.deleteBackup(b.name);
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final auth = context.watch<AuthProvider>();
    final bm = context.watch<BackupManager>();

    return Scaffold(
      backgroundColor: palette.ground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  DayIconButton(icon: LucideIcons.arrowLeft, onTap: () => context.pop()),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Profile ──────────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                DayAvatar(size: 56, email: auth.email),
                                const SizedBox(height: 12),
                                Text(
                                  auth.email ?? 'Local journal',
                                  style: Ty.body(palette.text),
                                ),
                                const SizedBox(height: 6),
                                DayStatusPill(
                                  label: auth.isLoggedIn ? 'Syncing' : 'Free',
                                  variant: auth.isLoggedIn
                                      ? DayStatusPillVariant.accent
                                      : DayStatusPillVariant.neutral,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ─── Backup ───────────────────────────────────
                          Text('Backup', style: Ty.caption(palette.muted)),
                          const SizedBox(height: 8),
                          _SettingRow(
                            label: 'Auto-backup',
                            value: 'On',
                            onTap: () {},
                          ),
                          _SettingRow(
                            label: 'Last backup',
                            value: _timeAgo(bm.lastBackupTime),
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          DayButton.quiet(
                            label: bm.isBackingUp ? 'Backing up…' : 'Back up now',
                            onTap: bm.isBackingUp ? null : _backUpNow,
                            isLoading: bm.isBackingUp,
                          ),
                          const SizedBox(height: 32),

                          // ─── General ──────────────────────────────────
                          Text('General', style: Ty.caption(palette.muted)),
                          const SizedBox(height: 8),
                          _SettingRow(
                            label: 'Plan and sync',
                            onTap: () => context.push('/plan'),
                          ),
                          _SettingRow(
                            label: 'Export entries',
                            onTap: () => context.push('/export'),
                          ),
                          _SettingRow(
                            label: 'Switch journal',
                            onTap: () => context.push('/switch-account'),
                          ),
                          if (auth.isLoggedIn)
                            _SettingRow(
                              label: 'Sign out',
                              onTap: _signOut,
                            )
                          else
                            _SettingRow(
                              label: 'Sign in / sync',
                              onTap: () => context.push('/sign-in'),
                            ),
                          const SizedBox(height: 32),

                          // ─── Danger ───────────────────────────────────
                          _SettingRow(
                            label: 'Delete account',
                            danger: true,
                            onTap: _deleteAccount,
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: Text('Day Before v1.0.0', style: Ty.caption(palette.faint)),
                          ),
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

  Future<void> _signOut() async {
    final palette = PaletteProvider.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.raised,
        title: Text('Sign out?', style: Ty.titleSm(palette.text)),
        content: Text(
          'Our entries remain on this device. We can sign back in any time.',
          style: Ty.body(palette.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/');
    }
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool danger;
  final VoidCallback onTap;

  const _SettingRow({
    required this.label,
    this.value,
    this.danger = false,
    required this.onTap,
  });

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
                  Text(
                    label,
                    style: Ty.body(danger ? palette.danger : palette.text),
                  ),
                  const Spacer(),
                  if (value != null) ...[
                    Text(value!, style: Ty.body(palette.muted)),
                    const SizedBox(width: 8),
                  ],
                  if (!danger)
                    Icon(Icons.chevron_right, size: 16, color: palette.faint),
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

// ─── Delete Account Dialog ────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatefulWidget {
  final int entryCount;
  const _DeleteAccountDialog({required this.entryCount});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  int _countdown = 30;
  Timer? _timer;
  bool _started = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdown = 0;
          t.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final canDelete = _started && _countdown == 0;

    return AlertDialog(
      backgroundColor: palette.raised,
      title: Text('Delete account?', style: Ty.titleSm(palette.danger)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We have ${widget.entryCount} ${widget.entryCount == 1 ? "entry" : "entries"}.',
            style: Ty.body(palette.text),
          ),
          const SizedBox(height: 8),
          Text(
            'This will permanently delete all our data from this device. This cannot be undone.',
            style: Ty.body(palette.muted),
          ),
          if (_started && _countdown > 0) ...[
            const SizedBox(height: 16),
            Text(
              'Deleting in $_countdown seconds…',
              style: Ty.body(palette.danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: Ty.body(palette.muted)),
        ),
        if (!_started)
          TextButton(
            onPressed: () => context.push('/export'),
            child: Text('Export first', style: Ty.body(palette.accent)),
          ),
        if (!_started)
          TextButton(
            onPressed: _startCountdown,
            child: Text('Delete everything', style: Ty.body(palette.danger)),
          ),
        if (_started && canDelete)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm delete', style: Ty.body(palette.danger)),
          ),
        if (_started && !canDelete)
          TextButton(
            onPressed: null,
            child: Text('Delete in $_countdown…', style: Ty.body(palette.faint)),
          ),
      ],
    );
  }
}
