A Dart port of the $1 Unistroke Recognizer, with some additional features planned.

[![Pub](https://img.shields.io/pub/v/one_dollar_unistroke_recognizer.svg)](https://pub.dev/packages/one_dollar_unistroke_recognizer)

## Usage

```dart
List<Offset> points = [...];
RecognizedUnistroke? recognized = recognizeUnistroke(points);
if (recognized == null) {
  print('No match found');
} else {
  print('Stroke recognized as ${recognized.name}');
}
```

## Planned features

- [ ] Allow adding custom unistrokes.
- [ ] Create a subpackage containing a collection of unistrokes for common symbols.
- [ ] Convert user's stroke into a perfect shape.

## About the $1 Unistroke Recognizer

The $1 Unistroke Recognizer is a 2-D single-stroke recognizer designed for rapid prototyping of gesture-based user interfaces. In machine learning terms, $1 is an instance-based nearest-neighbor classifier with a 2-D Euclidean distance function, i.e., a geometric template matcher. $1 is a significant extension of the proportional shape matching approach used in SHARK2, which itself is an adaptation of Tappert's elastic matching approach with zero look-ahead. Despite its simplicity, $1 requires very few templates to perform well and is only about 100 lines of code, making it easy to deploy. An optional enhancement called Protractor improves $1's speed. 

You can read more about the $1 Unistroke Recognizer at [depts.washington.edu/acelab/proj/dollar](http://depts.washington.edu/acelab/proj/dollar/index.html).

This Dart package is a port of the JavaScript version of the $1 Unistroke Recognizer, which you can find at [depts.washington.edu/acelab/proj/dollar/dollar.js](http://depts.washington.edu/acelab/proj/dollar/dollar.js).
