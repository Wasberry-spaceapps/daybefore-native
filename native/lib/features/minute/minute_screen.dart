import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../ui/tokens.dart';
import '../../ui/theme.dart';

class MinuteScreen extends StatefulWidget {
  const MinuteScreen({super.key});

  @override
  State<MinuteScreen> createState() => _MinuteScreenState();
}

class Obstacle {
  double x;
  double y;
  double width;
  double height;
  String type; // 'rock' or 'branch'
  
  Obstacle({required this.x, required this.y, required this.width, required this.height, required this.type});
}

class _MinuteScreenState extends State<MinuteScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  
  int _frames = 0;
  double _score = 0;
  
  final double _groundHeight = 40;
  
  double _carX = 50;
  double _carY = 140; // 200 - 40 - 20
  final double _carWidth = 40;
  final double _carHeight = 20;
  double _carDy = 0;
  final double _jumpForce = -10;
  final double _originalY = 140;
  bool _grounded = true;
  
  final double _gravity = 0.6;
  double _speed = 4;
  
  List<Obstacle> _obstacles = [];
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (_isGameOver) return;

    setState(() {
      _carY += _carDy;
      if (_carY + _carHeight < 200 - _groundHeight) {
        _carDy += _gravity;
        _grounded = false;
      } else {
        _carDy = 0;
        _grounded = true;
        _carY = 200 - _groundHeight - _carHeight;
      }

      int spawnRate = max(80, 150 - (_score ~/ 50));
      if (_frames % spawnRate == 0) {
        String type = Random().nextBool() ? 'rock' : 'branch';
        _obstacles.add(Obstacle(
          x: 600,
          y: 200 - _groundHeight - (type == 'rock' ? 15 : 5),
          width: type == 'rock' ? 20 : 30,
          height: type == 'rock' ? 15 : 5,
          type: type,
        ));
      }

      for (var obs in _obstacles) {
        obs.x -= _speed;
        
        if (_carX < obs.x + obs.width &&
            _carX + _carWidth > obs.x &&
            _carY < obs.y + obs.height &&
            _carY + _carHeight > obs.y) {
          _isGameOver = true;
        }
      }

      _obstacles.removeWhere((obs) => obs.x + obs.width < 0);

      _score += 0.1;
      if (_frames > 0 && _frames % 600 == 0 && _speed < 8) {
        _speed += 0.5;
      }

      _frames++;
    });
  }

  void _handleInput() {
    if (_isGameOver) {
      setState(() {
        _isGameOver = false;
        _frames = 0;
        _score = 0;
        _speed = 4;
        _obstacles.clear();
        _carY = _originalY;
        _carDy = 0;
        _grounded = true;
      });
      return;
    }
    
    if (_grounded && !_isGameOver) {
      setState(() {
        _carDy = _jumpForce;
        _grounded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).brightness == Brightness.dark ? Palette.night : Palette.day;
    
    return Scaffold(
      backgroundColor: palette.ground, // or web bg #111111
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTapDown: (_) => _handleInput(),
              child: Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent && event.logicalKey.keyLabel == 'Space') {
                    _handleInput();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 600,
                    height: 200,
                    color: palette.ground, // Explicit canvas bg
                    child: CustomPaint(
                      painter: _GamePainter(
                        carX: _carX, carY: _carY, carWidth: _carWidth, carHeight: _carHeight,
                        obstacles: _obstacles, groundHeight: _groundHeight,
                        score: _score, isGameOver: _isGameOver,
                        textCol: palette.text, dividerCol: palette.hairline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('close', style: Ty.label(palette.text)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final double carX, carY, carWidth, carHeight;
  final List<Obstacle> obstacles;
  final double groundHeight;
  final double score;
  final bool isGameOver;
  final Color textCol, dividerCol;

  _GamePainter({
    required this.carX, required this.carY, required this.carWidth, required this.carHeight,
    required this.obstacles, required this.groundHeight,
    required this.score, required this.isGameOver,
    required this.textCol, required this.dividerCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPaint = Paint()..color = textCol;
    final dividerPaint = Paint()..color = dividerCol;

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, size.height - groundHeight, size.width, 1), dividerPaint);

    // Obstacles
    for (var obs in obstacles) {
      if (obs.type == 'rock') {
        final path = Path()
          ..moveTo(obs.x, obs.y + obs.height)
          ..lineTo(obs.x + obs.width / 2, obs.y)
          ..lineTo(obs.x + obs.width, obs.y + obs.height)
          ..close();
        canvas.drawPath(path, dividerPaint);
      } else {
        canvas.drawRect(Rect.fromLTWH(obs.x, obs.y, obs.width, obs.height), dividerPaint);
      }
    }

    // Car
    canvas.drawRect(Rect.fromLTWH(carX, carY, carWidth, carHeight), textPaint);
    canvas.drawRect(Rect.fromLTWH(carX + 8, carY - 12, 20, 12), textPaint);

    // Score
    final textPainter = TextPainter(
      text: TextSpan(text: 'Distance: ${score.floor()}', style: TextStyle(color: textCol, fontSize: 14, fontFamily: 'sans-serif')),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(20, 30));

    // Game Over
    if (isGameOver) {
      final goPainter = TextPainter(
        text: TextSpan(
          text: 'Finished. Tap or press Space to restart.',
          style: TextStyle(color: textCol, fontSize: 20, fontFamily: 'sans-serif')
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      goPainter.paint(canvas, Offset(size.width / 2 - goPainter.width / 2, size.height / 2 - goPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true; // Could optimize, but fine for tick-based
}
