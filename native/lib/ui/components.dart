import 'package:flutter/material.dart';
import 'tokens.dart'; // From generated tokens

class DBButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isQuiet;
  final bool isDanger;

  const DBButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isQuiet = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bgColor = Colors.transparent;
    Color fgColor = isDark ? AppColors.darkText : AppColors.lightText;
    
    if (isPrimary) {
      bgColor = isDark ? AppColors.darkText : AppColors.lightText;
      fgColor = isDark ? AppColors.darkGround : AppColors.lightGround;
    } else if (isDanger) {
      fgColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
      if (!isQuiet) bgColor = fgColor.withOpacity(0.1);
    }
    
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isQuiet ? Colors.transparent : bgColor,
        foregroundColor: fgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: isPrimary || isQuiet ? BorderSide.none : BorderSide(color: isDark ? AppColors.darkHairline : AppColors.lightHairline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.sansFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class DBInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final int maxLines;

  const DBInput({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: maxLines > 1 ? AppTypography.displayFont : AppTypography.sansFont,
        fontSize: maxLines > 1 ? 18 : 16,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkRaised : AppColors.lightRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class DBCard extends StatelessWidget {
  final Widget child;

  const DBCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkRaised : AppColors.lightRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkHairline : AppColors.lightHairline,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
