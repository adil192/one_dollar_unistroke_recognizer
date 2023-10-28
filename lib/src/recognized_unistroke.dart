class RecognizedUnistroke {
  const RecognizedUnistroke(this.unistrokeName, this.score)
      : assert(score >= 0.0 && score <= 1.0);

  /// The recognized unistroke name.
  final String unistrokeName;

  /// The score of the recognized unistroke.
  ///
  /// The score is a value between 0.0 and 1.0, where 1.0 is a perfect match.
  final double score;
}
