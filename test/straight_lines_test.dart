import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

/// These should be recognized as straight lines
final lines = {
  'perfect_horizontal': [
    for (var i = 0.0; i < 100; i++) Offset(i, 50),
  ],
  'perfect_vertical': [
    for (var i = 0.0; i < 100; i++) Offset(50, i),
  ],
  'line_with_small_lip': [
    for (var i = 0.0; i < 99; i++) Offset(i, 50),
    const Offset(100, 55),
  ],
  'line_with_medium_lip': [
    for (var i = 0.0; i < 100; i++) Offset(i, 50),
    const Offset(100, 70),
  ],
  'polynomial_2': [
    for (var i = 0.0; i < 100; i++)
      Offset(
        i,
        100 - i * i / 100,
      ),
  ],
};

/// These should not be recognized as straight lines
final curves = {
  'line_with_large_lip': [
    for (var i = 0.0; i < 100; i++) Offset(i, 50),
    const Offset(100, 80),
  ],
  for (var p = 3; p <= 10; p++)
    'polynomial_$p': [
      for (var i = 0.0; i < 100; i++)
        Offset(
          i,
          100 - i * pow(i / 100, p - 1),
        ),
    ],
};

void main() {
  group('Straight lines:', () {
    for (final key in lines.keys) {
      test('Recognize $key as a line', () {
        final result = recognizeUnistroke(
          lines[key]!,
          overrideReferenceUnistrokes: default$1Unistrokes
              .where((stroke) => stroke.name == DefaultUnistrokeNames.line)
              .toList(),
        );
        printOnFailure(
            'Detected as ${result?.name} with score ${result?.score}');
        expect(result?.name, DefaultUnistrokeNames.line,
            reason: '$key should be recognized as line');
      });
    }

    for (final key in curves.keys) {
      test('Don\'t recognize $key as a line', () {
        final result = recognizeUnistroke(
          curves[key]!,
          overrideReferenceUnistrokes: default$1Unistrokes
              .where((stroke) => stroke.name == DefaultUnistrokeNames.line)
              .toList(),
        );
        printOnFailure(
            'Detected as ${result?.name} with score ${result?.score}');
        expect(result?.name, isNull,
            reason: '$key should not be recognized as line');
      });
    }
  });
}
