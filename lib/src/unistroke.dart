import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

/// A unistroke containing the list of [points]
/// and optionally a [name].
class Unistroke<K> {
  /// Creates a [Unistroke] with the given [name].
  ///
  /// The [inputPoints] are manipulated by [processInputPoints]
  /// before being stored in [points] and [vector].
  Unistroke(this.name, this.inputPoints, {this.isCanonical = false});

  /// The name describing the unistroke.
  ///
  /// The name is only relevant for the [knownUnistrokes] list,
  /// and it can otherwise just be empty.
  final K? name;

  /// The raw input points.
  final List<Offset> inputPoints;

  /// Whether [inputPoints] has exactly 2 distinct points.
  late final isALineExactly =
      inputPoints.length == 2 && inputPoints.first != inputPoints.last;

  /// The manipulated input points.
  late final points = processInputPoints(inputPoints);

  /// The manipulated input points with aspect ratio preserved.
  ///
  /// This is best suited for detecting straight lines.
  late final pointsWithAspectRatioPreserved = processInputPoints(
    inputPoints,
    preserveAspectRatio: true,
  );

  /// The manipulated input points, before being [resample]d.
  late final pointsBeforeResampling = processInputPoints(
    inputPoints,
    shouldResample: false,
  );

  /// The vectorized version of [points],
  /// used for the Protractor algorithm.
  late final List<double> vector = vectorize(points);

  /// [points] but in reverse order.
  late final List<Offset> reversedPoints = points.reversed.toList();

  /// [vector] but in reverse order.
  late final List<double> reversedVector = vectorize(reversedPoints);

  /// Whether this unistroke's [points] should be considered as the ideal
  /// shape of a unistroke with name [name].
  ///
  /// This is used in [RecognizedUnistroke.getCanonicalPolygon].
  ///
  /// If no unistroke is canonical, the first unistroke in the list of
  /// [RecognizedUnistroke.referenceUnistrokes] is chosen.
  final bool isCanonical;

  /// Input points are resampled into this many points.
  static const numPoints = 64;

  /// Input points are scaled to this size.
  static const squareSize = 250.0;

  /// The diagonal length of [squareSize].
  static const squareDiagonal = 250 * math.sqrt2;

  /// The half diagonal length of [squareSize].
  static const halfSquareDiagonal = squareDiagonal / 2;

  /// The [points] are resampled, rotated, scaled and translated
  /// to match the [Unistroke.numPoints] and [Unistroke.squareSize] constants.
  @visibleForTesting
  static List<Offset> processInputPoints(
    List<Offset> points, {
    bool preserveAspectRatio = false,
    bool shouldResample = true,
  }) {
    if (shouldResample) {
      // copy to new list since [resample] mutates
      points = resample(points.toList(), numPoints);
      assert(
        points.length == numPoints,
        'resampled to ${points.length} but expected $numPoints',
      );
    }
    final radians = indicativeAngle(points);
    points = rotateBy(points, -radians);
    points = scaleTo(
      points,
      squareSize: squareSize,
      preserveAspectRatio: preserveAspectRatio,
    );
    points = translateTo(points, Offset.zero);
    return points;
  }
}
