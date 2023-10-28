library one_dollar_unistroke_recognizer;

import 'dart:ui' show Offset;

import 'package:one_dollar_unistroke_recognizer/src/known_unistrokes.dart';
import 'package:one_dollar_unistroke_recognizer/src/recognized_unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';
import 'package:one_dollar_unistroke_recognizer/src/utils.dart';

RecognizedUnistroke? recognizeUnistroke(List<Offset> inputPoints, {bool useProtractor = true}) {
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
