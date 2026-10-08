import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_icon_button.dart';

class _Obstacle {
  double x;
  double y;
  double width;
  double height;
  final String type; // 'rock' or 'branch'

  _Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
  });
}

class MinuteScreen extends StatefulWidget {
  const MinuteScreen({super.key});
  @override
  State<MinuteScreen> createState() => _MinuteScreenState();
}

class _MinuteScreenState extends State<MinuteScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  
  // Game state
  double groundHeight = 40;
  
  double carX = 50;
  double carY = 0; // will be set in first frame
  double carWidth = 40;
  double carHeight = 20;
  double carDy = 0;
  double jumpForce = -10;
  bool carGrounded = false;
  
  double gravity = 0.6;
  double speed = 4;
  
  List<_Obstacle> obstacles = [];
  bool isGameOver = false;
  double score = 0;
  int frames = 0;

  bool _initialized = false;
  double canvasWidth = 600;
  double canvasHeight = 200;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_update);
    _ticker.start();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initGame(Size size) {
    canvasWidth = size.width;
    canvasHeight = size.height;
    carY = canvasHeight - groundHeight - carHeight;
    _initialized = true;
  }

  void _jump() {
    if (carGrounded && !isGameOver) {
      carDy = jumpForce;
      carGrounded = false;
    }
  }

  void _update(Duration elapsed) {
    if (!mounted || !_initialized) return;

    if (isGameOver) {
      setState(() {});
      return;
    }

    setState(() {
      // Physics
      carY += carDy;
      if (carY + carHeight < canvasHeight - groundHeight) {
        carDy += gravity;
        carGrounded = false;
      } else {
        carDy = 0;
        carGrounded = true;
        carY = canvasHeight - groundHeight - carHeight;
      }

      // Obstacles spawn
      int spawnRate = max(80, 150 - (score ~/ 50)).toInt();
      if (frames % spawnRate == 0) {
        final type = Random().nextDouble() > 0.5 ? 'rock' : 'branch';
        obstacles.add(_Obstacle(
          x: canvasWidth,
          y: canvasHeight - groundHeight - (type == 'rock' ? 15 : 5),
          width: type == 'rock' ? 20 : 30,
          height: type == 'rock' ? 15 : 5,
          type: type,
        ));
      }

      // Obstacles update & collision
      for (final obs in obstacles) {
        obs.x -= speed;
        // Collision
        if (carX < obs.x + obs.width &&
            carX + carWidth > obs.x &&
            carY < obs.y + obs.height &&
            carY + carHeight > obs.y) {
          isGameOver = true;
        }
      }

      obstacles.removeWhere((obs) => obs.x + obs.width < 0);

      // Score and speed
      score += 0.1;
      if (frames % 600 == 0 && speed < 8) speed += 0.5;

      frames++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      body: Stack(
        children: [
          // The game canvas
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_initialized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _initGame(Size(constraints.maxWidth, constraints.maxHeight));
                  });
                }
                
                return RawKeyboardListener(
                  focusNode: _focusNode,
                  autofocus: true,
                  onKey: (event) {
                    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
                      _jump();
                    }
                  },
                  child: GestureDetector(
                    onPanUpdate: (_) => _jump(),
                    onTapDown: (_) => _jump(),
                    behavior: HitTestBehavior.opaque,
                    child: CustomPaint(
                      painter: _MinutePainter(
                        palette: palette,
                        carX: carX,
                        carY: carY,
                        carWidth: carWidth,
                        carHeight: carHeight,
                        obstacles: obstacles,
                        score: score,
                        isGameOver: isGameOver,
                        groundHeight: groundHeight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Close button top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: DayIconButton(
              icon: Icons.close,
              onTap: () => GoRouter.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinutePainter extends CustomPainter {
  final Palette palette;
  final double carX;
  final double carY;
  final double carWidth;
  final double carHeight;
  final List<_Obstacle> obstacles;
  final double score;
  final bool isGameOver;
  final double groundHeight;

  _MinutePainter({
    required this.palette,
    required this.carX,
    required this.carY,
    required this.carWidth,
    required this.carHeight,
    required this.obstacles,
    required this.score,
    required this.isGameOver,
    required this.groundHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPaint = Paint()..color = palette.muted;
    final dividerPaint = Paint()..color = palette.hairline;

    // Draw Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - groundHeight, size.width, 1),
      dividerPaint,
    );

    // Draw Obstacles
    for (final obs in obstacles) {
      if (obs.type == 'rock') {
        final path = Path()
          ..moveTo(obs.x, obs.y + obs.height)
          ..lineTo(obs.x + obs.width / 2, obs.y)
          ..lineTo(obs.x + obs.width, obs.y + obs.height)
          ..close();
        canvas.drawPath(path, dividerPaint);
      } else {
        canvas.drawRect(
          Rect.fromLTWH(obs.x, obs.y, obs.width, obs.height),
          dividerPaint,
        );
      }
    }

    // Draw Car
    canvas.drawRect(Rect.fromLTWH(carX, carY, carWidth, carHeight), textPaint);
    canvas.drawRect(Rect.fromLTWH(carX + 8, carY - 12, 20, 12), textPaint);

    // Draw Score
    final textStyle = TextStyle(
      color: palette.muted,
      fontSize: 14,
      fontFamily: 'Inter',
    );
    final textSpan = TextSpan(
      text: 'Distance: ${score.floor()}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 30));

    // Game Over
    if (isGameOver) {
      final goStyle = TextStyle(
        color: palette.muted,
        fontSize: 20,
        fontFamily: 'Inter',
      );
      final goSpan = TextSpan(text: 'Finished.', style: goStyle);
      final goPainter = TextPainter(text: goSpan, textDirection: TextDirection.ltr);
      goPainter.layout();
      goPainter.paint(
        canvas,
        Offset(size.width / 2 - goPainter.width / 2, size.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinutePainter old) => true;
}
