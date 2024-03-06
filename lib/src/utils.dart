// DollarRecognizer constants

import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';

/// The angle range for the indicative angle.
const angleRange = math.pi / 4;

/// The angle precision for the indicative angle.
const anglePrecision = math.pi / 90;

/// The golden ratio.
final phi = 0.5 * (-1.0 + math.sqrt(5.0));

/// Resamples [points] to have [numPoints] points.
///
/// Note that this mutates [points].
List<Offset> resample(List<Offset> points,
    [int numPoints = Unistroke.numPoints]) {
  // Special case for a line, just lerp between the two points.
  if (points.length == 2) {
    return List.generate(numPoints, (i) {
      final t = i / (numPoints - 1);
      return Offset.lerp(points.first, points.last, t)!;
    });
  }

  final intervalLength = pathLength(points) / (numPoints - 1);
  var currentIntervalD = 0.0;
  final newPoints = <Offset>[points.first];
  for (var i = 1; i < points.length; ++i) {
    final distance = (points[i] - points[i - 1]).distance;
    if (currentIntervalD + distance >= intervalLength) {
      final newPoint = points[i - 1] +
          (points[i] - points[i - 1]) *
              ((intervalLength - currentIntervalD) / distance);
      // append new point
      newPoints.add(newPoint);
      // insert newPoint at i into points, s.t. newPoint will be the next i
      points.insert(i, newPoint);
      currentIntervalD = 0.0;
    } else {
      currentIntervalD += distance;
    }
  }

  if (newPoints.length == numPoints - 1) {
    // sometimes we fall a rounding-error short of adding the last point
    newPoints.add(points.last);
  }

  return newPoints;
}

/// The indicative angle is the angle between the first point and the centroid.
double indicativeAngle(List<Offset> points) {
  final c = centroid(points);
  final firstPoint = points.first;
  return math.atan2(c.dy - firstPoint.dy, c.dx - firstPoint.dx);
}

/// Rotates [points] by [radians] around the centroid.
List<Offset> rotateBy(List<Offset> points, double radians) {
  final c = centroid(points);
  final cos = math.cos(radians);
  final sin = math.sin(radians);
  return points
      .map((p) => Offset(
            (p.dx - c.dx) * cos - (p.dy - c.dy) * sin + c.dx,
            (p.dx - c.dx) * sin + (p.dy - c.dy) * cos + c.dy,
          ))
      .toList();
}

/// Scales [points] to [squareSize].
///
/// Non-uniform scale; assumes 2D gestures (i.e., no lines).
List<Offset> scaleTo(
  List<Offset> points, {
  double squareSize = Unistroke.squareSize,
  bool preserveAspectRatio = false,
}) {
  final b = boundingBox(points);
  final longestSide = b.longestSide;

  final scaleX = preserveAspectRatio ? longestSide : b.width;
  final scaleY = preserveAspectRatio ? longestSide : b.height;

  return points
      .map((p) => Offset(
            p.dx * (squareSize / scaleX),
            p.dy * (squareSize / scaleY),
          ))
      .toList();
}

/// Translates [points]' centroid to [newCenter].
List<Offset> translateTo(List<Offset> points, Offset newCenter) {
  final c = centroid(points);
  return points.map((p) => p - c + newCenter).toList();
}

/// Vectorizes [points] into a 1D list of coordinates scaled down
/// by the square root of the sum of the squared distances.
List<double> vectorize(List<Offset> points) {
  var sum = 0.0;
  final vector = <double>[];
  for (final point in points) {
    vector
      ..add(point.dx)
      ..add(point.dy);
    sum += point.distanceSquared;
  }
  final magnitude = math.sqrt(sum);
  for (var i = 0; i < vector.length; ++i) {
    vector[i] /= magnitude;
  }
  return vector;
}

/// Protractor algorithm (optimized $1 recognizer)
double optimalCosineDistance(List<double> vector1, List<double> vector2) {
  final minLength = math.min(vector1.length, vector2.length);
  var a = 0.0;
  var b = 0.0;
  for (var i = 0; i < minLength - 1; i += 2) {
    a += vector1[i] * vector2[i] + vector1[i + 1] * vector2[i + 1];
    b += vector1[i] * vector2[i + 1] - vector1[i + 1] * vector2[i];
  }
  final angle = math.atan2(b, a);
  return math.acos(a * math.cos(angle) + b * math.sin(angle));
}

/// Golden section search (original $1 recognizer)
double distanceAtBestAngle(List<Offset> points, List<Offset> template, double a,
    double b, double threshold) {
  var x1 = phi * a + (1.0 - phi) * b;
  var f1 = distanceAtAngle(points, template, x1);
  var x2 = (1.0 - phi) * a + phi * b;
  var f2 = distanceAtAngle(points, template, x2);

  while ((b - a).abs() > threshold) {
    if (f1 < f2) {
      b = x2;
      x2 = x1;
      f2 = f1;
      x1 = phi * a + (1.0 - phi) * b;
      f1 = distanceAtAngle(points, template, x1);
    } else {
      a = x1;
      x1 = x2;
      f1 = f2;
      x2 = (1.0 - phi) * a + phi * b;
      f2 = distanceAtAngle(points, template, x2);
    }
  }

  return math.min(f1, f2);
}

/// Returns the [pathDistance] between [points] and [template]
/// when [points] are rotated by [radians].
double distanceAtAngle(
  List<Offset> points,
  List<Offset> template,
  double radians,
) {
  final newPoints = rotateBy(points, radians);
  return pathDistance(newPoints, template);
}

/// Returns the centroid of [points], i.e. the average of all points.
Offset centroid(List<Offset> points) {
  var x = 0.0;
  var y = 0.0;
  for (final point in points) {
    x += point.dx;
    y += point.dy;
  }
  return Offset(x / points.length, y / points.length);
}

/// Returns the smallest [Rect] that contains all [points].
Rect boundingBox(List<Offset> points) {
  var minX = double.infinity;
  var maxX = double.negativeInfinity;
  var minY = double.infinity;
  var maxY = double.negativeInfinity;
  for (final point in points) {
    minX = math.min(minX, point.dx);
    minY = math.min(minY, point.dy);
    maxX = math.max(maxX, point.dx);
    maxY = math.max(maxY, point.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Returns the path distance between [points1] and [points2], which is
/// the average distance between each point in [points1] and the corresponding
/// point in [points2].
double pathDistance(List<Offset> points1, List<Offset> points2) {
  assert(points1.length == points2.length);
  var d = 0.0;
  for (var i = 0; i < points1.length; ++i) {
    d += (points1[i] - points2[i]).distance;
  }
  return d / points1.length;
}

/// Returns the path length of [points], which is the sum of the distances
/// between each point.
double pathLength(List<Offset> points) {
  var d = 0.0;
  for (var i = 1; i < points.length; ++i) {
    d += (points[i] - points[i - 1]).distance;
  }
  return d;
}
