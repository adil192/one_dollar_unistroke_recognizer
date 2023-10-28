import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:one_dollar_unistroke_recognizer/src/known_unistrokes.dart';

void main() {
  group('known unistrokes should be recognized (golden section search)', () {
    for (var unistroke in knownUnistrokes) {
      test(unistroke.name, () {
        final result = recognizeUnistroke(unistroke.points, useProtractor: false);
        expect(result, isNotNull);
        expect(result!.unistrokeName, unistroke.name);
        expect(result.score, greaterThan(0.9)); // 90% accuracy
      });
    }
  });
  group('known unistrokes should be recognized (protractor)', () {
    for (var unistroke in knownUnistrokes) {
      test(unistroke.name, () {
        final result = recognizeUnistroke(unistroke.points, useProtractor: true);
        expect(result, isNotNull);
        expect(result!.unistrokeName, unistroke.name);
        expect(result.score, greaterThan(0.9)); // 90% accuracy
      });
    }
  });
}
