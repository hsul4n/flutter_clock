import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const int MINUTES_PER_HOUR = 64;
const int HOURS_PER_DAY = 24;
const int SCISMAS_PER_DAY = 2;
const int HOURS_PER_SCISMA = HOURS_PER_DAY ~/ SCISMAS_PER_DAY;

class Clockwise extends StatefulWidget {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const Clockwise({
    @required this.color,
    @required this.size,
    @required this.angleRadians,
    @required this.thickness,
  })  : assert(color != null),
        assert(thickness != null),
        assert(size != null),
        assert(angleRadians != null);

  /// Hand color.
  final Color color;

  /// Hand length, as a percentage of the smaller side of the clock's parent
  /// container.
  final double size;

  /// The angle, in radians, at which the hand is drawn.
  ///
  /// This angle is measured from the 12 o'clock position.
  final double angleRadians;

  /// Hand thickness or weight.
  final double thickness;

  @override
  _ClockwiseState createState() => _ClockwiseState();
}

class _ClockwiseState extends State<Clockwise>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _ClockwisePainter(
            handSize: widget.size,
            lineWidth: widget.thickness,
            angleRadians: widget.angleRadians,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _ClockwisePainter extends CustomPainter {
  _ClockwisePainter({
    @required this.handSize,
    @required this.lineWidth,
    @required this.angleRadians,
    @required this.color,
  })  : assert(handSize != null),
        assert(lineWidth != null),
        assert(angleRadians != null),
        assert(color != null),
        assert(handSize >= 0.0),
        assert(handSize <= 1.0);

  final double handSize;
  final double lineWidth;
  final double angleRadians;
  final Color color;

  @override
  bool shouldRepaint(_ClockwisePainter oldDelegate) {
    return oldDelegate.handSize != handSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.angleRadians != angleRadians ||
        oldDelegate.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    // We want to start at the top, not at the x-axis, so add pi/2.
    final angle = angleRadians - math.pi / 2.0;
    final length = size.shortestSide * 0.5 * handSize;
    final position = center + Offset(math.cos(angle), math.sin(angle)) * length;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(center, position, linePaint);

    // Center dot
    canvas.drawCircle(center, 4.0, Paint()..color = Colors.red);
  }
}
