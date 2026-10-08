import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/registry.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_icon_button.dart';
import '../../ui/components/day_avatar.dart';
import '../../ui/components/day_status_pill.dart';

class SwitchAccountScreen extends StatefulWidget {
  const SwitchAccountScreen({super.key});

  @override
  State<SwitchAccountScreen> createState() => _SwitchAccountScreenState();
}

class _SwitchAccountScreenState extends State<SwitchAccountScreen> {
  List<Map<String, dynamic>> _accounts = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await registry.getAllAccounts();
    final active = await registry.getActiveAccountId();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _activeId = active;
        _loading = false;
      });
    }
  }

  Future<void> _switchTo(String accountId) async {
    await registry.setActiveAccountId(accountId);
    await registry.updateLastAccessed(accountId);
    if (mounted) context.go('/');
  }

  Future<void> _addLocal() async {
    // Create fresh local account (bypass the "get existing" logic)
    final id = await registry.getOrCreateLocalAccount();
    await registry.setActiveAccountId(id);
    if (mounted) context.go('/');
  }

  String _timeAgo(int ms) {
    final diff = DateTime.now().millisecondsSinceEpoch - ms;
    final mins = diff ~/ 60000;
    if (mins < 2) return 'just now';
    if (mins < 60) return '$mins minutes ago';
    final hrs = mins ~/ 60;
    if (hrs < 24) return '$hrs hours ago';
    final days = hrs ~/ 24;
    return '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);

    return Scaffold(
      backgroundColor: palette.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text('Your journals on this device', style: Ty.titleSm(palette.text)),
            ),
            Expanded(
              child: _loading
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _accounts.length,
                      separatorBuilder: (_, __) => Container(height: 1, color: palette.hairline),
                      itemBuilder: (context, i) {
                        final acc = _accounts[i];
                        final id = acc['account_id'] as String;
                        final email = acc['email'] as String?;
                        final count = (acc['entry_count'] as int?) ?? 0;
                        final lastMs = (acc['last_accessed_at'] as int?) ?? 0;
                        final isActive = id == _activeId;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          leading: DayAvatar(size: 40, email: email),
                          title: Text(
                            email ?? 'Local journal',
                            style: Ty.body(palette.text),
                          ),
                          subtitle: Text(
                            '$count ${count == 1 ? "entry" : "entries"} · last opened ${_timeAgo(lastMs)}',
                            style: Ty.caption(palette.muted),
                          ),
                          trailing: isActive
                              ? const DayStatusPill(
                                  label: 'Active',
                                  variant: DayStatusPillVariant.accent,
                                )
                              : null,
                          onTap: isActive ? null : () => _switchTo(id),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: palette.hairline),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/sign-in'),
                    child: Text('Add another account', style: Ty.body(palette.accent)),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _addLocal,
                    child: Text('Start a new local journal', style: Ty.body(palette.muted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
