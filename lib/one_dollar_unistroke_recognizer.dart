library one_dollar_unistroke_recognizer;

import 'dart:ui' show Offset;

import 'package:one_dollar_unistroke_recognizer/src/default_unistrokes.dart';
import 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

export 'package:one_dollar_unistroke_recognizer/src/default_unistrokes.dart'
    show default$1Unistrokes;
export 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart'
    show RecognizedUnistroke;

/// The unistroke templates that can be recognized by [recognizeUnistroke].
///
/// Multiple unistrokes can have the same name. This is useful if you want to
/// improve the recognition of a unistroke by adding multiple templates.
///
/// The default value is [default$1Unistrokes].
var referenceUnistrokes = default$1Unistrokes;

/// Recognizes a unistroke from [inputPoints].
///
/// If [useProtractor] is true, the Protractor algorithm is used.
/// Otherwise, the Golden Section Search algorithm is used.
///
/// The Protractor algorithm is the newer algorithm and is faster.
///
/// Returns null if no unistroke could be recognized, otherwise returns a
/// [RecognizedUnistroke] with the recognized unistroke name and the score.
/// The name will be one of the names of the templates in [referenceUnistrokes].
///
/// You can set [referenceUnistrokes] to a list of your own unistroke templates
/// if you want to recognize a different set of unistrokes.
///
/// Alternatively, you can set [overrideReferenceUnistrokes] to override
/// [referenceUnistrokes] for this call only.
RecognizedUnistroke? recognizeUnistroke(
  List<Offset> inputPoints, {
  bool useProtractor = true,
  List<Unistroke>? overrideReferenceUnistrokes,
}) {
  // Not enough points to recognize
  if (inputPoints.length < Unistroke.numPoints) return null;

  final candidate = Unistroke('', inputPoints);

  Unistroke? closestUnistroke;
  var closestUnistrokeDist = double.infinity;

  assert((overrideReferenceUnistrokes ?? referenceUnistrokes).isNotEmpty);
  for (final unistrokeTemplate
      in (overrideReferenceUnistrokes ?? referenceUnistrokes)) {
    final distance = useProtractor
        ? optimalCosineDistance(unistrokeTemplate.vector, candidate.vector)
        : distanceAtBestAngle(candidate.points, unistrokeTemplate, -angleRange,
            angleRange, anglePrecision);

    if (distance < closestUnistrokeDist) {
      closestUnistrokeDist = distance;
      closestUnistroke = unistrokeTemplate;
    }
  }

  if (closestUnistroke == null) {
    return null;
  } else {
    return RecognizedUnistroke(
      closestUnistroke.name,
      useProtractor
          ? (1.0 - closestUnistrokeDist)
          : (1.0 - closestUnistrokeDist / Unistroke.squareDiagonal),
    );
  }
}
