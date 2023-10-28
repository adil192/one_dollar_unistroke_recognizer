library one_dollar_unistroke_recognizer;

import 'dart:ui' show Offset;

import 'package:one_dollar_unistroke_recognizer/src/known_unistrokes.dart';
import 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

export 'package:one_dollar_unistroke_recognizer/src/known_unistrokes.dart' show knownUnistrokesNames;
export 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart' show RecognizedUnistroke;

/// Recognizes a unistroke from [inputPoints].
/// 
/// If [useProtractor] is true, the Protractor algorithm is used.
/// Otherwise, the Golden Section Search algorithm is used.
/// 
/// The Protractor algorithm is the newer algorithm and is faster.
/// 
/// Returns null if no unistroke could be recognized, otherwise returns a
/// [RecognizedUnistroke] with the recognized unistroke name and the score.
/// The name will be one of the names in [knownUnistrokesNames].
/// 
/// In the future, you will be able to add your own unistrokes to the recognizer
RecognizedUnistroke? recognizeUnistroke(
  List<Offset> inputPoints, {
  bool useProtractor = true,
}) {
  final candidate = Unistroke('', inputPoints);

  var unistrokeIndex = -1;
  var leastDistance = double.infinity;

  for (var i = 0; i < knownUnistrokes.length; ++i) {
    // for each unistroke template
    final distance = useProtractor
        ? optimalCosineDistance(knownUnistrokes[i].vector, candidate.vector)
        : distanceAtBestAngle(candidate.points, knownUnistrokes[i], -angleRange,
            angleRange, anglePrecision);

    if (distance < leastDistance) {
      leastDistance = distance;
      unistrokeIndex = i;
    }
  }

  if (unistrokeIndex == -1) {
    return null;
  } else {
    return RecognizedUnistroke(
      knownUnistrokes[unistrokeIndex].name,
      useProtractor
          ? (1.0 - leastDistance)
          : (1.0 - leastDistance / Unistroke.squareDiagonal),
    );
  }
}
