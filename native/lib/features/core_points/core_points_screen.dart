import 'package:flutter/material.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/utils.dart';
import '../../ui/illustrations/day_illustrations.dart';
import '../../ui/components/day_empty_state.dart';
import '../../ui/components/day_button.dart';

class CorePointScreen extends StatelessWidget {
  final String id;
  const CorePointScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isPhone(context)) ...[
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 48),
            child: Text('Core Points', style: Ty.titleLg(palette.text)),
          ),
          const SizedBox(height: 24),
        ],
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone(context) ? 20.0 : 32.0,
                  ).copyWith(
                    top: isPhone(context) ? 20.0 : 56.0,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: Ty.titleLg(palette.text),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name this core point',
                                hintStyle: Ty.titleLg(palette.faint),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: palette.accent,
                            ),
                          ),
                          IconButton(
                            icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
                            onPressed: () {
                              // TODO: Implement actual delete
                            },
                            tooltip: 'Delete Core Point',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: null,
                        style: Ty.writing(palette.text, phone: isPhone(context)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'What are the few standards you would like to be held to?',
                          hintStyle: Ty.writing(palette.faint, phone: isPhone(context)),
                        ),
                        cursorColor: palette.accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
