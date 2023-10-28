/// A recognized unistroke.
/// 
/// This is the output of [recognizeUnistroke].
class RecognizedUnistroke {
  /// Creates a [RecognizedUnistroke].
  const RecognizedUnistroke(this.name, this.score);

  /// The recognized unistroke name.
  final String name;

  /// The score of the recognized unistroke.
  ///
  /// The score is a value between 0.0 and 1.0, where 1.0 is a perfect match.
  /// 
  /// In some cases, the score can be less than 0.0.
  final double score;
}
