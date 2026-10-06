import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';

class MinuteScreen extends StatelessWidget {
  const MinuteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MinutePainter(palette: palette),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Text('close', style: TextStyle(fontSize: 16, color: palette.text)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinutePainter extends CustomPainter {
  final dynamic palette; // Dynamic to avoid specific type dependency for now

  _MinutePainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    // Basic ground line
    final paint = Paint()
      ..color = palette.hairline
      ..strokeWidth = 1.0;
    
    // Draw ground at bottom - 40px
    canvas.drawLine(
      Offset(0, size.height - 40),
      Offset(size.width, size.height - 40),
      paint,
    );

    // Draw car proxy
    final carPaint = Paint()..color = palette.text;
    canvas.drawRect(Rect.fromLTWH(50, size.height - 40 - 20, 40, 20), carPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
