import 'package:flutter/material.dart';
import 'dart:math' show pi;

import '../models/expense_data.dart';

class AnimatedPieChart extends StatefulWidget {
  final List<ExpenseData> data;
  final double size;
  final Duration duration;

  const AnimatedPieChart({
    super.key,
    required this.data,
    this.size = 200,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AnimatedPieChartPainter(
            data: widget.data,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _AnimatedPieChartPainter extends CustomPainter {
  final List<ExpenseData> data;
  final double progress;

  _AnimatedPieChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    double total = data.fold(0, (sum, item) => sum + item.amount);
    double startAngle = -pi / 2;

    // Vẽ đường viền ngoài
    final outlinePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.grey.withOpacity(0.1);

    canvas.drawCircle(center, radius, outlinePaint);

    for (var item in data) {
      final sweepAngle = (item.amount / total) * 2 * pi * progress;

      // Vẽ phần chính của chart
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 25
            ..strokeCap = StrokeCap.round;

      // Gradient cho mỗi phần
      paint.shader = SweepGradient(
        colors: [item.color.withOpacity(0.7), item.color],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Vẽ hiệu ứng glass effect ở giữa
    final innerCirclePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 30, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
