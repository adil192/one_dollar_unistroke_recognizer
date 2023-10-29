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
    return GestureDetector(
      onPanStart: (details) {
        points = [details.localPosition];
        notifyListeners();
      },
      onPanUpdate: (details) {
        points.add(details.localPosition);
        notifyListeners();
      },
      onPanEnd: (details) {
        widget.onDrawEnd(points);
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
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < state.points.length - 1; i++) {
      canvas.drawLine(state.points[i], state.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasDrawPainter oldDelegate) {
    return oldDelegate.state.points != state.points;
  }
}
