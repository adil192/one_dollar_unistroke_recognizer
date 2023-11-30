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
      expect(recognized!.name, DefaultUnistrokeNames.circle);

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

    testWidgets('Rectangle', (tester) async {
      final recognized = recognizeUnistroke(_approximateSquare.toList());
      expect(recognized, isNotNull);
      expect(recognized!.name, DefaultUnistrokeNames.rectangle);

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
        matchesGoldenFile('goldens/rectangle.png'),
      );
    });

    testWidgets('Triangle', (tester) async {
      final recognized = recognizeUnistroke(_approximateTriangle.toList());
      expect(recognized, isNotNull);
      expect(recognized!.name, DefaultUnistrokeNames.triangle);

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
        matchesGoldenFile('goldens/triangle.png'),
      );
    });
  });
}

class _Painter extends CustomPainter {
  const _Painter(this.recognizedStroke);

  final RecognizedUnistroke<DefaultUnistrokeNames> recognizedStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final circle = recognizedStroke.convertToCircle();
    final rect = recognizedStroke.convertToRect();

    canvas
      ..drawPoints(
        PointMode.polygon,
        recognizedStroke.originalPoints,
        paint
          ..strokeWidth = 4
          ..color = Colors.white.withOpacity(0.5),
      )
      ..drawPoints(
        PointMode.polygon,
        recognizedStroke.originalPoints,
        paint
          ..strokeWidth = 2
          ..color = Colors.black.withOpacity(0.5),
      )
      ..drawPoints(
        PointMode.polygon,
        recognizedStroke.convertToCanonicalPolygon(),
        paint..color = Colors.red,
      )
      ..drawCircle(
        circle.$1,
        circle.$2,
        paint..color = Colors.blue.withOpacity(0.5),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        paint..color = Colors.green.withOpacity(0.5),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The points of an approximate circle.
Iterable<Offset> get _approximateCircle sync* {
  const radius = 150.0;
  const maxVariance = 100.0;
  const center = Offset(200, 200);
  const numPoints = 64;
  const t = 5 / numPoints;

  final random = math.Random(100);
  Offset variance = Offset.zero;

  for (var i = 0; i < numPoints; i++) {
    final angle = 2 * math.pi * i / numPoints;
    variance = Offset(
      variance.dx * (1 - t) + random.nextVariance(maxVariance) * t,
      variance.dy * (1 - t) + random.nextVariance(maxVariance) * t,
    );

    final x = center.dx + radius * math.cos(angle) + variance.dx;
    final y = center.dy + radius * math.sin(angle) + variance.dy;
    yield Offset(x, y);
  }
}

Iterable<Offset> get _approximateSquare {
  final rect = Rect.fromCenter(
    center: const Offset(200, 200),
    width: 300,
    height: 300,
  );
  final corners = [
    rect.topLeft,
    rect.topRight,
    rect.bottomRight,
    rect.bottomLeft,
    rect.topLeft,
  ];
  return _approximatePolygon(corners);
}

Iterable<Offset> get _approximateTriangle {
  final rect = Rect.fromCenter(
    center: const Offset(200, 200),
    width: 300,
    height: 300,
  );
  final corners = [
    rect.topCenter,
    rect.bottomRight,
    rect.bottomLeft,
    rect.topCenter,
  ];
  return _approximatePolygon(corners);
}

Iterable<Offset> _approximatePolygon(List<Offset> corners) sync* {
  assert(corners.first == corners.last);

  const maxVariance = 100.0;
  final numPointsPerSide = 64 / (corners.length - 1);
  final t = 5 / numPointsPerSide / (corners.length - 1);

  final random = math.Random(100);
  Offset variance = Offset.zero;

  for (int corner = 0; corner < corners.length - 1; corner++) {
    final start = corners[corner];
    final end = corners[corner + 1];

    for (int i = 0; i < numPointsPerSide; i++) {
      variance = Offset(
        variance.dx * (1 - t) + random.nextVariance(maxVariance) * t,
        variance.dy * (1 - t) + random.nextVariance(maxVariance) * t,
      );

      yield Offset.lerp(
        start,
        end,
        i / numPointsPerSide,
      )!
          .translate(variance.dx, variance.dy);
    }
  }
}

extension on math.Random {
  /// Generates a random double between [-maxVariance, maxVariance].
  double nextVariance(double maxVariance) {
    return nextDouble() * 2 * maxVariance - maxVariance;
  }
}
