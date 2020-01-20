import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'clockwise.dart';

class Clockface extends StatelessWidget {
  const Clockface({
    this.hoursStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16.0,
    ),
    this.showHours = true,
    this.showSeconds = true,
    this.secondsColor,
  })  : assert((hoursStyle != null)),
        assert(showHours != null),
        assert(showSeconds != null),
        assert(secondsColor != null);

  final bool showHours;
  final bool showSeconds;
  final TextStyle hoursStyle;
  final Color secondsColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _ClockfacePainter(
            hoursStyle: hoursStyle,
            showHours: showHours,
            showSeconds: showSeconds,
            secondsColor: secondsColor,
          ),
        ),
      ),
    );
  }
}

class _ClockfacePainter extends CustomPainter {
  const _ClockfacePainter({
    this.hoursStyle,
    this.showHours,
    this.showSeconds,
    this.secondsColor,
  })  : assert(hoursStyle != null),
        assert(showHours != null),
        assert(showSeconds != null),
        assert(secondsColor != null);

  final bool showHours;
  final bool showSeconds;
  final TextStyle hoursStyle;
  final Color secondsColor;

  @override
  bool shouldRepaint(_ClockfacePainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = secondsColor;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxLen = math.min(center.dx, center.dy);

    if (showHours) {
      final TextPainter painter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      for (int i = 1; i <= HOURS_PER_SCISMA; i++) {
        final Offset paintOffset = _getPosition(
          i.toDouble(),
          HOURS_PER_SCISMA.toDouble(),
          maxLen * .82,
        );

        painter.text = TextSpan(
          text: i.toString(),
          style: hoursStyle,
        );

        painter.layout();

        // The text is painted with the offset being the top right corner of the render box
        // We need to adjust the box to properly center our text
        final Offset textOffset = Offset(painter.width, painter.height) / 2;

        painter.paint(canvas, paintOffset + center - textOffset);
      }
    }

    if (showSeconds) {
      // The rest of the decorations
      paint
        ..style = PaintingStyle.fill
        ..strokeWidth = 2.0;

      for (int i = 0; i < MINUTES_PER_HOUR; i++) {
        double insideFactor = .97;

        final Offset outsideOffset = _getPosition(
          i.toDouble(),
          MINUTES_PER_HOUR.toDouble(),
          maxLen - 1,
        );
        final Offset insideOffset = _getPosition(
          i.toDouble(),
          MINUTES_PER_HOUR.toDouble(),
          maxLen * insideFactor,
        );

        canvas.drawLine(center + insideOffset, center + outsideOffset, paint);
      }
    }
  }

  Offset _getPosition(double timePart, double timeTotal, double length) {
    // What percentage of the whole have we covered
    final percentage = timePart / timeTotal;
    // -2PI*percentage is how many radians we have moved clockwise
    // then we rotate backwards 180 degrees to correct for quandrant
    final radians = -2 * math.pi * percentage - math.pi;

    return new Offset(length * math.sin(radians), length * math.cos(radians));
  }
}
