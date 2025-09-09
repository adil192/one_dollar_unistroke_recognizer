import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

class UnistrokePreview extends StatelessWidget {
  const UnistrokePreview({
    super.key,
    required this.unistroke,
  });

  final Unistroke unistroke;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              (unistroke.name as DefaultUnistrokeNames).name,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: CustomPaint(
                painter: _UnistrokePreviewPainter(
                  unistroke,
                  color: ColorScheme.of(context).onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnistrokePreviewPainter extends CustomPainter {
  _UnistrokePreviewPainter(this.unistroke, {required this.color});

  final Unistroke unistroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = _normalizePoints(unistroke.inputPoints, size);

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant _UnistrokePreviewPainter oldDelegate) =>
      unistroke != oldDelegate.unistroke;

  /// Transforms points to the origin and
  /// scales them to [newSize].
  static List<Offset> _normalizePoints(List<Offset> points, Size newSize) {
    if (points.length <= 2) {
      // For a line, return a diagonal line
      return [
        Offset.zero,
        Offset(newSize.width, newSize.height),
      ];
    }

    final minX = points.map((e) => e.dx).reduce(min);
    final minY = points.map((e) => e.dy).reduce(min);
    final maxX = points.map((e) => e.dx).reduce(max);
    final maxY = points.map((e) => e.dy).reduce(max);
    final oldSize = Size(maxX - minX, maxY - minY);

    return points
        .map((point) => Offset(
              (point.dx - minX) / oldSize.width * newSize.width,
              (point.dy - minY) / oldSize.height * newSize.height,
            ))
        .toList();
  }
}
