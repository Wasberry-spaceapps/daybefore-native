import 'package:flutter/material.dart';

// Palette.night reference values (kept in sync with tokens.dart):
//   ground:   #131211
//   raised:   #1B1A18
//   hairline: #2A2724
//   muted:    #A39D92

final darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF131211),
  cardColor: const Color(0xFF1B1A18),
  dividerColor: const Color(0xFF2A2724),
  // Apply Newsreader to display/headline styles; Inter to the rest.
  textTheme: ThemeData.dark().textTheme.copyWith(
    displayLarge:  ThemeData.dark().textTheme.displayLarge?.copyWith(fontFamily: 'Newsreader'),
    displayMedium: ThemeData.dark().textTheme.displayMedium?.copyWith(fontFamily: 'Newsreader'),
    displaySmall:  ThemeData.dark().textTheme.displaySmall?.copyWith(fontFamily: 'Newsreader'),
    headlineLarge: ThemeData.dark().textTheme.headlineLarge?.copyWith(fontFamily: 'Newsreader'),
    headlineMedium:ThemeData.dark().textTheme.headlineMedium?.copyWith(fontFamily: 'Newsreader'),
    headlineSmall: ThemeData.dark().textTheme.headlineSmall?.copyWith(fontFamily: 'Newsreader'),
    titleLarge:    ThemeData.dark().textTheme.titleLarge?.copyWith(fontFamily: 'Newsreader'),
    titleMedium:   ThemeData.dark().textTheme.titleMedium?.copyWith(fontFamily: 'Inter'),
    titleSmall:    ThemeData.dark().textTheme.titleSmall?.copyWith(fontFamily: 'Inter'),
    bodyLarge:     ThemeData.dark().textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
    bodyMedium:    ThemeData.dark().textTheme.bodyMedium?.copyWith(fontFamily: 'Inter'),
    bodySmall:     ThemeData.dark().textTheme.bodySmall?.copyWith(fontFamily: 'Inter'),
    labelLarge:    ThemeData.dark().textTheme.labelLarge?.copyWith(fontFamily: 'Inter'),
    labelMedium:   ThemeData.dark().textTheme.labelMedium?.copyWith(fontFamily: 'Inter'),
    labelSmall:    ThemeData.dark().textTheme.labelSmall?.copyWith(fontFamily: 'Inter'),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFF2EEE6),   // Palette.night.text
    secondary: Color(0xFFA39D92), // Palette.night.muted
    surface: Color(0xFF131211),   // Palette.night.ground
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF131211),
    elevation: 0,
  ),
);
