import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

void main() {
  group('Canonical', () {
    testWidgets('Circle', (tester) async {
      final recognized = recognizeUnistroke(_approximateCircle.toList());
      expect(recognized, isNotNull);
      expect(recognized!.name, 'circle');

      await tester.pumpWidget(Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _Painter(recognized),
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/circle.png'),
      );
    });
  });
}

class _Painter extends CustomPainter {
  const _Painter(this.recognizedStroke);

  final RecognizedUnistroke recognizedStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final circle = recognizedStroke.convertToCircle();

    canvas
      ..drawPoints(
        PointMode.polygon,
        recognizedStroke.originalPoints,
        paint..color = Colors.black,
      )
      ..drawPoints(
        PointMode.polygon,
        recognizedStroke.convertToCanonicalPolygon(),
        paint..color = Colors.red.withOpacity(0.5),
      )
      ..drawCircle(
        circle.$1,
        circle.$2,
        paint..color = Colors.blue.withOpacity(0.5),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The points of an approximate circle.
Iterable<Offset> get _approximateCircle sync* {
  const radius = 100.0;
  const maxVariance = 50.0;
  const center = Offset(200, 200);
  const numPoints = 64;
  const t = 10 / numPoints;

  final random = math.Random(100);
  double variance = 0;

  for (var i = 0; i < numPoints; i++) {
    final angle = 2 * math.pi * i / numPoints;
    variance = variance * (1 - t) + random.nextDouble() * maxVariance * t;

    final x = center.dx + radius * math.cos(angle) + variance;
    final y = center.dy + radius * math.sin(angle) + variance;
    yield Offset(x, y);
  }
}
