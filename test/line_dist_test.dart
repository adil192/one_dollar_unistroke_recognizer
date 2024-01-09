import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/src/line_detection.dart';

void main() {
  group('Line.distanceToPoint', () {
    test('(0,0) from flat line', () {
      final line = Line(Offset.zero, const Offset(1, 0));
      expect(line.distanceToPoint(Offset.zero), 0);
    });
    test('(0,1) from flat line', () {
      final line = Line(Offset.zero, const Offset(1, 0));
      expect(line.distanceToPoint(const Offset(0, 1)), 1);
    });
    test('(3,4) from diagonal line', () {
      final line = Line(const Offset(3, 3), const Offset(10, 10));
      final expected = sqrt(2 * 0.5 * 0.5);
      expect(
        line.distanceToPoint(const Offset(3, 4)),
        closeTo(expected, expected / 1000000),
      );
    });
    test('(0,0) from line at x=1', () {
      final line = Line(const Offset(1, -999), const Offset(1, 999));
      expect(line.distanceToPoint(Offset.zero), 1);
    });
  });
}
