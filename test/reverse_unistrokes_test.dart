import 'package:flutter_test/flutter_test.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';

void main() {
  final circle = default$1Unistrokes.firstWhere(
    (element) => element.name == 'circle',
  );

  test('Unistrokes drawn in reverse (golden section search)', () {
    final result = recognizeUnistroke(
      circle.reversedPoints,
      useProtractor: false,
    );
    expect(result, isNotNull);
    expect(result!.name, circle.name);
  });

  test('Unistrokes drawn in reverse (protractor)', () {
    final result = recognizeUnistroke(
      circle.reversedPoints,
      useProtractor: true,
    );
    expect(result, isNotNull);
    expect(result!.name, circle.name);
  });
}
