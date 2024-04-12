import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:one_dollar_unistroke_recognizer/src/default_unistrokes.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';
import 'package:vector_math/vector_math.dart';

/// A recognized unistroke.
///
/// This is the output of [recognizeUnistroke].
///
/// See also [RecognizedCustomUnistroke], which is the same as this class
/// but with a custom key type.
typedef RecognizedUnistroke = RecognizedCustomUnistroke<DefaultUnistrokeNames>;

/// A recognized unistroke, with a custom key type.
///
/// This is the output of [recognizeCustomUnistroke].
class RecognizedCustomUnistroke<K> {
  /// Creates a [RecognizedCustomUnistroke].
  const RecognizedCustomUnistroke(
    this.name,
    this.score, {
    required this.originalPoints,
    required this.referenceUnistrokes,
  });

  /// The recognized unistroke name.
  final K? name;

  /// The score of the recognized unistroke.
  ///
  /// The score is a value between 0.0 and 1.0, where 1.0 is a perfect match.
  final double score;

  /// The original [inputPoints] parameter that was provided to
  /// [recognizeUnistroke].
  final List<Offset> originalPoints;

  /// The list of reference unistrokes
  /// that were used in [recognizeUnistroke].
  final List<Unistroke<K>> referenceUnistrokes;

  /// Gets the canonical polygon of the recognized unistroke,
  /// and transforms it to the size and position of the original unistroke.
  ///
  /// This function assumes that the recognized unistroke is a polygon.
  /// If it's a circle, use [convertToCircle] instead.
  List<Offset> convertToCanonicalPolygon() {
    final unscaledCanonicalPolygon = findUnscaledCanonicalPolygon();

    if (unscaledCanonicalPolygon.isALineExactly) {
      final (start, end) = convertToLine();
      return [start, end];
    }

    final originalBoundingBox = boundingBox(originalPoints);
    final canonicalBoundingBox = boundingBox(unscaledCanonicalPolygon.points);

    final originalCenter = originalBoundingBox.center;
    final originalWidth = originalBoundingBox.width;
    final originalHeight = originalBoundingBox.height;

    final canonicalCenter = canonicalBoundingBox.center;
    final canonicalWidth = canonicalBoundingBox.width;
    final canonicalHeight = canonicalBoundingBox.height;

    /// The transform that transforms the canonical polygon
    /// to the original polygon.
    final transform = Matrix4.identity()
      ..translate(originalCenter.dx, originalCenter.dy)
      ..scale(originalWidth / canonicalWidth, originalHeight / canonicalHeight)
      ..rotateZ(indicativeAngle(originalPoints))
      ..translate(-canonicalCenter.dx, -canonicalCenter.dy);

    return unscaledCanonicalPolygon.points
        .map((point) => transform.transform3(Vector3(point.dx, point.dy, 0)))
        .map((point) => Offset(point.x, point.y))
        .toList();
  }

  /// Gets the canonical line of the recognized unistroke.
  ///
  /// This function just returns the first and last input points.
  (Offset start, Offset end) convertToLine() {
    return (originalPoints.first, originalPoints.last);
  }

  /// Gets the canonical circle of the recognized unistroke.
  ///
  /// This function assumes that the recognized unistroke is a circle.
  /// If it isn't, it will return the closest approximation.
  ///
  /// Also see [convertToOval]
  (Offset center, double radius) convertToCircle() {
    final rect = boundingBox(originalPoints);
    final radius = (rect.width + rect.height) / 4;
    return (rect.center, radius);
  }

  /// Gets the canonical oval of the recognized unistroke.
  ///
  /// Unlike [convertToCircle], this function does not take the
  /// average of the width and height of the bounding box.
  (Offset center, double radiusX, double radiusY) convertToOval() {
    final rect = boundingBox(originalPoints);
    return (rect.center, rect.width / 2, rect.height / 2);
  }

  /// Gets the bounding box of the recognized unistroke.
  ///
  /// This function is useful for recognized squares/rectangles.
  Rect convertToRect() => boundingBox(originalPoints);

  /// Gets the canonical form of this unistroke.
  @visibleForTesting
  Unistroke findUnscaledCanonicalPolygon() {
    final choices =
        referenceUnistrokes.where((ref) => ref.name == name).toList();
    assert(choices.isNotEmpty, 'No reference unistrokes with name "$name"');
    return choices.firstWhere(
      (ref) => ref.isCanonical,
      orElse: () => choices.first,
    );
  }
}
