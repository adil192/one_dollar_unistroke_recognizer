import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

class Unistroke {
  Unistroke(this.name, Iterable<Offset> inputPoints) {
    points = processInputPoints(inputPoints);
  }

  final String name;
  late final List<Offset> points;
  late final List<double> vector = vectorize(points);

  /// Input points are resampled into this many points.
  static const numPoints = 64;

  /// Input points are scaled to this size.
  static const squareSize = 250.0;

  /// The diagonal length of [squareSize].
  static const squareDiagonal = 250 * math.sqrt2;

  /// The half diagonal length of [squareSize].
  static const halfSquareDiagonal = squareDiagonal / 2;

  static List<Offset> processInputPoints(Iterable<Offset> inputPoints) {
    var points = inputPoints.toList(); // copy to new list since [resample] mutates
    points = resample(points, numPoints);
    final radians = indicativeAngle(points);
    points = rotateBy(points, -radians);
    points = scaleTo(points, squareSize);
    points = translateTo(points, Offset.zero);
    return points;
  }
}
