import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

void main() {
  group('known unistrokes should be recognized (golden section search)', () {
    for (var unistroke in default$1Unistrokes) {
      test(unistroke.name, () {
        final result =
            recognizeUnistroke(unistroke.points, useProtractor: false);
        expect(result, isNotNull);
        expect(result!.name, unistroke.name);
      });
    }
  });
  group('known unistrokes should be recognized (protractor)', () {
    for (var unistroke in default$1Unistrokes) {
      test(unistroke.name, () {
        final result =
            recognizeUnistroke(unistroke.points, useProtractor: true);
        expect(result, isNotNull);
        expect(result!.name, unistroke.name);
      });
    }
  });
}
