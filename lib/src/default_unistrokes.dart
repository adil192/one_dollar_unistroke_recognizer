import 'dart:math';
import 'dart:ui' show Offset, Rect;

import 'package:one_dollar_unistroke_recognizer/src/line_detection.dart';
import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';

const _circlePoints = 32;
const _square = Rect.fromLTWH(0, 0, 50, 50);
const _rectangle = Rect.fromLTWH(0, 0, 100, 50);

/// The default unistroke templates provided by this package.
final default$1Unistrokes =
    List<Unistroke<DefaultUnistrokeNames>>.unmodifiable([
  Unistroke(DefaultUnistrokeNames.line, [
    _square.centerLeft,
    _square.centerRight,
  ]),
  Unistroke(DefaultUnistrokeNames.circle, [
    for (var i = 0; i <= _circlePoints; i++)
      Offset(
        50 + 50 * cos(2 * pi * i / _circlePoints),
        50 + 50 * sin(2 * pi * i / _circlePoints),
      ),
  ]),
  Unistroke(DefaultUnistrokeNames.rectangle, isCanonical: true, [
    _square.topLeft,
    _square.topRight,
    _square.bottomRight,
    _square.bottomLeft,
    _square.topLeft,
  ]),
  Unistroke(DefaultUnistrokeNames.rectangle, [
    _rectangle.topLeft,
    _rectangle.topRight,
    _rectangle.bottomRight,
    _rectangle.bottomLeft,
    _rectangle.topLeft,
  ]),
  Unistroke(DefaultUnistrokeNames.triangle, [
    _square.topCenter,
    _square.bottomRight,
    _square.bottomLeft,
    _square.topCenter,
  ]),
]);

/// The enum of the names of the default unistrokes.
// If you add a new unistroke name, you should also add it to the README.
enum DefaultUnistrokeNames {
  /// A line.
  ///
  /// Note that the line unistroke in default$1Unistrokes is just for
  /// completeness,
  /// but we use a different algorithm to recognize straight lines:
  /// see [meanAbsoluteError].
  line,

  /// A circle
  circle,

  /// A rectangle
  rectangle,

  /// A triangle
  triangle,
}
