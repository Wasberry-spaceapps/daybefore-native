import 'package:flutter/material.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';

class IssuesListScreen extends StatelessWidget {
  const IssuesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return Scaffold(
      backgroundColor: palette.ground,
      body: Center(
        child: Text('Issues List', style: Ty.body(palette.text)),
      ),
    );
  }
}
