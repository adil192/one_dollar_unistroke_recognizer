import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

class CanvasDraw extends StatefulWidget {
  const CanvasDraw({
    super.key,
    required this.recognized,
    required this.onDraw,
    required this.onDrawEnd,
  });

  final ValueNotifier<RecognizedUnistroke?> recognized;
  final void Function(List<Offset>) onDraw;
  final void Function(List<Offset>) onDrawEnd;

  @override
  State<CanvasDraw> createState() => _CanvasDrawState();
}

class _CanvasDrawState extends State<CanvasDraw> with ChangeNotifier {
  List<Offset> points = [];
  bool finishedStroke = true;
  Color onSurface = const Color(0x88888888);

  @override
  void initState() {
    super.initState();
    addListener(() {
      widget.onDraw(points);
    });
  }

  @override
  void dispose() {
    removeListener(() {
      widget.onDraw(points);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onSurface = ColorScheme.of(context).onSurface;
    return GestureDetector(
      onPanStart: (details) {
        finishedStroke = false;
        points = [details.localPosition];
      },
      onPanUpdate: (details) {
        points.add(details.localPosition);
        notifyListeners();
      },
      onPanEnd: (details) {
        finishedStroke = true;
        widget.onDrawEnd(points);
        notifyListeners();
      },
      child: CustomPaint(
        painter: _CanvasDrawPainter(this),
      ),
    );
  }
}

class _CanvasDrawPainter extends CustomPainter {
  _CanvasDrawPainter(this.state) : super(repaint: state);

  final _CanvasDrawState state;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = state.onSurface.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPoints(PointMode.polygon, state.points, paint);

    paint.color = Colors.blue.withValues(alpha: state.finishedStroke ? 1 : 0.5);

    final recognized = state.widget.recognized.value;
    switch (recognized?.name) {
      case null:
        break;
      case DefaultUnistrokeNames.line:
        final (start, end) = recognized!.convertToLine();
        canvas.drawLine(start, end, paint);
      case DefaultUnistrokeNames.circle:
        final (center, radius) = recognized!.convertToCircle();
        canvas.drawCircle(center, radius, paint);
      case DefaultUnistrokeNames.rectangle:
        final rect = recognized!.convertToRect();
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(10)),
          paint,
        );
      case DefaultUnistrokeNames.triangle:
      case DefaultUnistrokeNames.star:
        final polygon = recognized!.convertToCanonicalPolygon();
        canvas.drawPoints(PointMode.polygon, polygon, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasDrawPainter oldDelegate) {
    return oldDelegate.state.points != state.points ||
        oldDelegate.state.points.length != state.points.length ||
        oldDelegate.state.widget.recognized.value?.name !=
            state.widget.recognized.value?.name;
  }
}
