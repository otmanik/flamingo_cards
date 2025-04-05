import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomProgressIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const CustomProgressIndicator({
    Key? key,
    this.color = const Color(0xFFFF4081),
    this.size = 60.0,
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: EdgeInsets.all(widget.size * 0.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinningProgressPainter(
              progress: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _SpinningProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _SpinningProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 0.8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Spinning arc
    final spinningPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * 0.75 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + 2 * math.pi * progress * 2,
      sweepAngle,
      false,
      spinningPaint,
    );

    // Add small dot at the end of the arc
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final endPointAngle = startAngle + 2 * math.pi * progress * 2 + sweepAngle;
    final endPointX = center.dx + radius * math.cos(endPointAngle);
    final endPointY = center.dy + radius * math.sin(endPointAngle);

    canvas.drawCircle(
      Offset(endPointX, endPointY),
      strokeWidth * 0.8,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinningProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
