import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

void main() {
  group('known unistrokes should be recognized', () {
    for (final useProtractor in [false, true]) {
      for (final reversed in [false, true]) {
        for (final unistroke in default$1Unistrokes) {
          test(
            '${unistroke.name} (useProtractor: $useProtractor, '
            'reversed: $reversed)',
            () {
              final result = recognizeUnistroke(
                reversed ? unistroke.reversedPoints : unistroke.points,
                useProtractor: useProtractor,
              );
              expect(result, isNotNull);
              expect(result!.name, unistroke.name);
            },
          );
        }
      }
    }
  });
}
