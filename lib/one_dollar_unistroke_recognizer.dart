library one_dollar_unistroke_recognizer;

import 'dart:ui' show Offset;

import 'package:one_dollar_unistroke_recognizer/src/default_unistrokes.dart';
import 'package:one_dollar_unistroke_recognizer/src/line_detection.dart';
import 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

export 'package:one_dollar_unistroke_recognizer/src/default_unistrokes.dart'
    show default$1Unistrokes, DefaultUnistrokeNames;
export 'package:one_dollar_unistroke_recognizer/src/example_unistrokes.dart'
    show example$1Unistrokes;
export 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart'
    show RecognizedUnistroke, RecognizedCustomUnistroke;

/// The unistroke templates that can be recognized by [recognizeUnistroke].
///
/// Multiple unistrokes can have the same name. This is useful if you want to
/// improve the recognition of a unistroke by adding multiple templates.
///
/// The default value is [default$1Unistrokes].
/// See also [example$1Unistrokes],
/// or provide your own list of unistroke templates.
List<Unistroke> referenceUnistrokes = default$1Unistrokes;

/// Recognizes a unistroke from [inputPoints].
///
/// If [useProtractor] is true, the Protractor algorithm is used.
/// Otherwise, the Golden Section Search algorithm is used.
/// The Protractor algorithm is the newer algorithm and is faster.
///
/// Returns null if no unistroke could be recognized, otherwise returns a
/// [RecognizedUnistroke] with the recognized unistroke name and the score.
///
/// You can set [referenceUnistrokes] to a list of your own unistroke templates
/// if you want to recognize a different set of unistrokes.
/// Alternatively, you can set [overrideReferenceUnistrokes] to override
/// [referenceUnistrokes] for this call only.
/// If you change [referenceUnistrokes] or [overrideReferenceUnistrokes],
/// you should call [recognizeCustomUnistroke] instead of this function.
RecognizedUnistroke? recognizeUnistroke<K extends DefaultUnistrokeNames>(
  List<Offset> inputPoints, {
  bool useProtractor = true,
  List<Unistroke<K>>? overrideReferenceUnistrokes,
}) {
  return recognizeCustomUnistroke<K>(
    inputPoints,
    useProtractor: useProtractor,
    overrideReferenceUnistrokes: overrideReferenceUnistrokes,
  );
}

/// Recognizes a unistroke from [inputPoints].
///
/// This is deprecated. Use [recognizeCustomUnistroke] instead.
@Deprecated('Use recognizeCustomUnistroke instead')
RecognizedCustomUnistroke<K>? recognizeUnistrokeOfType<K>(
  List<Offset> inputPoints, {
  bool useProtractor = true,
  List<Unistroke<K>>? overrideReferenceUnistrokes,
}) {
  return recognizeCustomUnistroke<K>(
    inputPoints,
    useProtractor: useProtractor,
    overrideReferenceUnistrokes: overrideReferenceUnistrokes,
  );
}

/// Recognizes a unistroke from [inputPoints].
///
/// If [useProtractor] is true, the Protractor algorithm is used.
/// Otherwise, the Golden Section Search algorithm is used.
/// The Protractor algorithm is the newer algorithm and is faster.
///
/// Returns null if no unistroke could be recognized,
/// otherwise returns a [RecognizedCustomUnistroke]
/// with the recognized unistroke name and the score.
/// The name will be one of the names of the templates in [referenceUnistrokes],
/// and of type [K].
///
/// You can set [referenceUnistrokes] to a list of your own unistroke templates
/// if you want to recognize a different set of unistrokes.
/// Alternatively, you can set [overrideReferenceUnistrokes] to override
/// [referenceUnistrokes] for this call only.
/// If you haven't changed [referenceUnistrokes] or
/// [overrideReferenceUnistrokes], you can call [recognizeUnistroke] instead
/// so you don't have to specify the type parameter.
///
/// If you're using custom unistroke templates,
/// and you need straight line detection,
/// please set [straightLineName] to the name of the straight line template.
/// This is needed since straight lines are best recognized with
/// a different algorithm than the standard $1 algorithm.
RecognizedCustomUnistroke<K>? recognizeCustomUnistroke<K>(
  List<Offset> inputPoints, {
  bool useProtractor = true,
  List<Unistroke<K>>? overrideReferenceUnistrokes,
  K? straightLineName,
}) {
  // Not enough points to recognize
  if (inputPoints.length < Unistroke.numPoints) return null;

  final candidate = Unistroke('', inputPoints);

  Unistroke? closestUnistroke;
  var closestUnistrokeDist = double.infinity;

  assert((overrideReferenceUnistrokes ?? referenceUnistrokes).isNotEmpty);
  for (final unistrokeTemplate
      in (overrideReferenceUnistrokes ?? referenceUnistrokes)) {
    final double distance;
    if (unistrokeTemplate.name ==
        (straightLineName ?? DefaultUnistrokeNames.line)) {
      distance = meanAbsoluteError(
        inputPoints,
        useProtractor: useProtractor,
      );
    } else if (useProtractor) {
      distance = optimalCosineDistance(
        unistrokeTemplate.vector,
        candidate.vector,
      );
    } else {
      distance = distanceAtBestAngle(
        candidate.points,
        unistrokeTemplate.points,
        -angleRange,
        angleRange,
        anglePrecision,
      );
    }

    if (distance < closestUnistrokeDist) {
      closestUnistrokeDist = distance;
      closestUnistroke = unistrokeTemplate;
    }

    final reverseDistance = useProtractor
        ? optimalCosineDistance(
            unistrokeTemplate.reversedVector,
            candidate.vector,
          )
        : distanceAtBestAngle(
            candidate.points,
            unistrokeTemplate.reversedPoints,
            -angleRange,
            angleRange,
            anglePrecision,
          );
    if (reverseDistance < closestUnistrokeDist) {
      closestUnistrokeDist = reverseDistance;
      closestUnistroke = unistrokeTemplate;
    }
  }

  if (closestUnistroke == null) return null;

  final score = useProtractor
      ? (1.0 - closestUnistrokeDist)
      : (1.0 - closestUnistrokeDist / Unistroke.squareDiagonal);
  if (score < 0) return null;

  return RecognizedCustomUnistroke<K>(
    closestUnistroke.name,
    score,
    originalPoints: inputPoints,
    referenceUnistrokes: (overrideReferenceUnistrokes ?? referenceUnistrokes)
        as List<Unistroke<K>>,
  );
}
