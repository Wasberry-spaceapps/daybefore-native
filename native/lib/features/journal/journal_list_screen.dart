import 'package:flutter/material.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Scaffold(
      backgroundColor: palette.ground,
      body: Center(
        child: Text('Journal List', style: Ty.body(palette.text)),
      ),
    );
  }
}
