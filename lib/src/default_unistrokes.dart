import 'dart:math';
import 'dart:ui' show Offset, Rect;

import 'package:one_dollar_unistroke_recognizer/src/unistroke.dart';

const _circlePoints = 32;
const _rectangle = Rect.fromLTWH(0, 0, 50, 50);

/// The default unistroke templates provided by this package.
final default$1Unistrokes =
    List<Unistroke<DefaultUnistrokeNames>>.unmodifiable([
  Unistroke(DefaultUnistrokeNames.line, [
    _rectangle.centerLeft,
    _rectangle.centerRight,
  ]),
  Unistroke(DefaultUnistrokeNames.circle, [
    for (var i = 0; i <= _circlePoints; i++)
      Offset(
        50 + 50 * cos(2 * pi * i / _circlePoints),
        50 + 50 * sin(2 * pi * i / _circlePoints),
      ),
  ]),
  Unistroke(DefaultUnistrokeNames.rectangle, [
    _rectangle.topLeft,
    _rectangle.topRight,
    _rectangle.bottomRight,
    _rectangle.bottomLeft,
    _rectangle.topLeft,
  ]),
  Unistroke(DefaultUnistrokeNames.triangle, [
    _rectangle.topCenter,
    _rectangle.bottomRight,
    _rectangle.bottomLeft,
    _rectangle.topCenter,
  ]),
]);

/// The enum of the names of the default unistrokes.
enum DefaultUnistrokeNames {
  /// A line
  line,

  /// A circle
  circle,

  /// A rectangle
  rectangle,

  /// A triangle
  triangle,
}
