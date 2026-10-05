
import 'package:flutter/material.dart';

final darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF12100E),
  cardColor: const Color(0xFF161412),
  dividerColor: const Color(0xFF333333),
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'serif'),
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Color(0xFFA0A0A0),
    surface: Color(0xFF12100E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF12100E),
    elevation: 0,
  ),
);
