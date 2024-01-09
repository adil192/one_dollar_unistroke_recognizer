import 'dart:math';

import 'package:flutter/material.dart' show visibleForTesting, Offset;

/// A line between two points.
@visibleForTesting
class Line {
  // ignore: public_member_api_docs
  Line(this.start, this.end);

  /// The start point of the line.
  final Offset start;

  /// The end point of the line.
  final Offset end;

  /// The [a] in the equation [ax + by + c = 0].
  late final a = end.dy - start.dy;

  /// The [b] in the equation [ax + by + c = 0].
  late final b = start.dx - end.dx;

  /// The [c] in the equation [ax + by + c = 0].
  late final c = (-a * start.dx) + (-b * start.dy);

  /// The denominator in the equation for the distance from a point to a line.
  /// See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line.
  late final denominator = sqrt(a * a + b * b);

  /// Returns the min distance from a point to this line.
  /// See https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line.
  double distanceToPoint(Offset point) {
    return (a * point.dx + b * point.dy + c).abs() / denominator;
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
  final line = Line(inputPoints.first, inputPoints.last);
  final sumAbsoluteError = inputPoints
      .map((point) => line.distanceToPoint(point))
      .reduce((a, b) => a + b);
  return useProtractor
      ? sumAbsoluteError / inputPoints.length
      : sumAbsoluteError;
}
