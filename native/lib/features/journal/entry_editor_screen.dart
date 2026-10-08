import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_icon_button.dart';
import '../../ui/components/utils.dart';
import '../../ui/icons/day_icons.dart';

class EntryEditorScreen extends StatefulWidget {
  final String id;
  const EntryEditorScreen({super.key, required this.id});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _justSaved = false;

  void _scheduleAutosave() {
    setState(() {
      _justSaved = true;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _justSaved = false;
        });
      }
    });
  }

  void _confirmDelete() {
    // Show modal to delete
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    final phone = isPhone(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: phone ? 20.0 : 32.0,
            ).copyWith(
              top: phone ? 20.0 : 56.0,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (phone) ...[
                  Row(
                    children: [
                      // DayIconButton(icon: DayIconName.lock, onTap: () => context.pop()), // Assuming back icon exists
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back, color: palette.text),
                      ),
                      const Spacer(),
                      _SavedIndicator(visible: _justSaved),
                      const SizedBox(width: 8),
                      GestureDetector(onTap: _confirmDelete, child: Icon(Icons.more_vert, color: palette.text)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _SavedIndicator(visible: _justSaved),
                      const SizedBox(width: 8),
                      GestureDetector(onTap: _confirmDelete, child: Icon(Icons.more_vert, color: palette.text)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  "TUESDAY 6 OCTOBER 2026",
                  style: Ty.overline(palette.muted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  style: Ty.titleLg(palette.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Untitled',
                    hintStyle: Ty.titleLg(palette.faint),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  cursorColor: palette.accent,
                  onChanged: (_) => _scheduleAutosave(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bodyController,
                  style: phone ? Ty.writingSm(palette.text) : Ty.writingLg(palette.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                    hintStyle: phone ? Ty.writingSm(palette.faint) : Ty.writingLg(palette.faint),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  cursorColor: palette.accent,
                  onChanged: (_) => _scheduleAutosave(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedIndicator extends StatelessWidget {
  final bool visible;
  const _SavedIndicator({required this.visible});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: visible ? 140 : 300),
      child: Text('Saved', style: Ty.caption(palette.faint)),
    );
  }
}
