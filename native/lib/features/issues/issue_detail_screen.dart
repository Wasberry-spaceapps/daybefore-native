import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/utils.dart';

class IssueDetailScreen extends StatefulWidget {
  final String id;
  const IssueDetailScreen({super.key, required this.id});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _nameController = TextEditingController();
  
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
                    Text('A short temper', style: Ty.label(palette.text)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
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
                ),
                const SizedBox(height: 32),
                Text("Tabs here: Theory, Returns, Read it back", style: Ty.body(palette.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
