import 'dart:ui' show Offset;

class _Line {
  _Line(this.start, this.end);

  final Offset start;
  final Offset end;

  late final dx = end.dx - start.dx;
  late final dy = end.dy - start.dy;
  late final sqrLength = dx * dx + dy * dy;
  late final crossProduct = end.dx * start.dy - end.dy * start.dx;

  /// Returns the min distance from a point to this line.
  double distanceToPoint(Offset point) {
    return (dy * point.dx - dx * point.dy + crossProduct).abs() / sqrLength;
  }
}

/// Returns the mean absolute error between the inputPoints
/// and the line between the first and last point.
///
/// See https://en.m.wikipedia.org/wiki/Mean_absolute_error.
///
/// If [useProtractor] is false,
/// the mean isn't taken, and the sum of the absolute errors is returned.
/// This is to match the expected output of a Golden Section Search.
double meanAbsoluteError(
  List<Offset> inputPoints, {
  bool useProtractor = true,
}) {
  final line = _Line(inputPoints.first, inputPoints.last);
  final sumAbsoluteError = inputPoints
      .map((point) => line.distanceToPoint(point))
      .reduce((a, b) => a + b);
  return useProtractor
      ? sumAbsoluteError / inputPoints.length
      : sumAbsoluteError;
}
