import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/utils.dart';
import '../../ui/components/day_tab.dart';

class IssueDetailScreen extends StatefulWidget {
  final String id;
  const IssueDetailScreen({super.key, required this.id});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _nameController    = TextEditingController();
  final _theoryController  = TextEditingController();
  int   _tab = 0; // 0 = Theory, 1 = Returns, 2 = Read it back

  static const _tabLabels = ['Theory', 'Returns', 'Read it back'];

  @override
  void dispose() {
    _nameController.dispose();
    _theoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final phone   = isPhone(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: phone ? 20.0 : 32.0,
            ).copyWith(
              top:    phone ? 20.0 : 56.0,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Breadcrumb ───────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text('Issues', style: Ty.label(palette.muted)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.chevron_right, size: 14, color: palette.faint),
                    ),
                    Expanded(
                      child: Text(
                        _nameController.text.isEmpty ? 'New issue' : _nameController.text,
                        style: Ty.label(palette.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Name row ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: Ty.titleLg(palette.text),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name this issue',
                          hintStyle: Ty.titleLg(palette.faint),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        cursorColor: palette.accent,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
                      onPressed: () => context.go('/'),
                      tooltip: 'Delete Issue',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Tabs ─────────────────────────────────────────────────
                DayTab(
                  labels: _tabLabels,
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 24),

                // ── Tab body ─────────────────────────────────────────────
                if (_tab == 0)
                  TextField(
                    controller: _theoryController,
                    maxLines: null,
                    style: phone ? Ty.writingSm(palette.text) : Ty.writingLg(palette.text),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'What do you think is behind this?',
                      hintStyle: phone
                          ? Ty.writingSm(palette.faint)
                          : Ty.writingLg(palette.faint),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: palette.accent,
                  ),

                if (_tab == 1)
                  Text(
                    'Each time it returns, note what happened.',
                    style: Ty.body(palette.faint),
                  ),

                if (_tab == 2)
                  Text(
                    'Your earlier entries will appear here.',
                    style: Ty.body(palette.faint),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
