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
List<Offset> resample(List<Offset> points,
    [int numPoints = Unistroke.numPoints]) {
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
    // sometimes we fall a rounding-error short of adding the last point, so add it if so
    newPoints.add(points.last);
  }

  assert(newPoints.length == numPoints);
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
List<Offset> scaleTo(List<Offset> points,
    [double squareSize = Unistroke.squareSize]) {
  final b = boundingBox(points);
  return points
      .map((p) => Offset(
            p.dx * (squareSize / b.width),
            p.dy * (squareSize / b.height),
          ))
      .toList();
}

/// Translates [points]' centroid to [newCenter].
List<Offset> translateTo(List<Offset> points, Offset newCenter) {
  final c = centroid(points);
  return points.map((p) => p - c + newCenter).toList();
}

List<double> vectorize(List<Offset> points) {
  // for Protractor
  var sum = 0.0;
  var vector = <double>[];
  for (final point in points) {
    vector.add(point.dx);
    vector.add(point.dy);
    sum += point.distance;
  }
  final magnitude = math.sqrt(sum);
  for (var i = 0; i < vector.length; ++i) {
    vector[i] /= magnitude;
  }
  return vector;
}

/// Protractor algorithm (optimized $1 recognizer)
double optimalCosineDistance(List<double> vector1, List<double> vector2) {
  // for Protractor
  var a = 0.0;
  var b = 0.0;
  for (var i = 0; i < vector1.length; i += 2) {
    a += vector1[i] * vector2[i] + vector1[i + 1] * vector2[i + 1];
    b += vector1[i] * vector2[i + 1] - vector1[i + 1] * vector2[i];
  }
  final angle = math.atan2(b, a);
  return math.acos(a * math.cos(angle) + b * math.sin(angle));
}

/// Golden section search (original $1 recognizer)
double distanceAtBestAngle(List<Offset> points, Unistroke template, double a,
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

double distanceAtAngle(
    List<Offset> points, Unistroke template, double radians) {
  final newPoints = rotateBy(points, radians);
  return pathDistance(newPoints, template.points);
}

Offset centroid(List<Offset> points) {
  var x = 0.0;
  var y = 0.0;
  for (final point in points) {
    x += point.dx;
    y += point.dy;
  }
  return Offset(x / points.length, y / points.length);
}

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

double pathDistance(List<Offset> points1, List<Offset> points2) {
  assert(points1.length == points2.length);
  var d = 0.0;
  for (var i = 0; i < points1.length; ++i) {
    d += (points1[i] - points2[i]).distance;
  }
  return d / points1.length;
}

double pathLength(List<Offset> points) {
  var d = 0.0;
  for (var i = 1; i < points.length; ++i) {
    d += (points[i] - points[i - 1]).distance;
  }
  return d;
}
