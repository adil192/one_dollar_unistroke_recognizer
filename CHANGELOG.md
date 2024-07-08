# 1.3.1

- Added the star to the README.

# 1.3.0

- Added a star to the default unistrokes.
- Fixed weird corners in the result of `convertToCanonicalPolygon`.
- The rotation of the recognized shape is now rounded to the nearest 5 degrees. You can change this by making your own rounding function and passing it to `convertToCanonicalPolygon`.

## 1.2.0

* Fixed the 'spikes' in `convertToCanonicalPolygon` for lines.
* If you're using custom unistrokes, you no longer need to specify `straightLineName` in `recognizeCustomUnistroke(..., straightLineName: ...)`. Just make sure your straight line unistroke template has exactly 2 distinct points and the recognizer will pick it up automatically.

## 1.1.2

* Better recognition of wide/tall rectangles, thanks to [@QubaB](https://github.com/QubaB)

## 1.1.1

* Fixes `RecognizedUnistroke.score` always being close to 1.0 when the stroke is recognized as a straight line.

## 1.1.0

* Separated the logic for straight lines and for other shapes to fix the issue where arbitrary strokes would often be incorrectly detected as a line.

## 1.0.0

* Used a better algorithm ([MAE](https://en.m.wikipedia.org/wiki/Mean_absolute_error))
  for detecting straight lines ([#3](https://github.com/adil192/one_dollar_unistroke_recognizer/pull/3)).
  This fixes the issue where lines would often be incorrectly detected as a circle
  ([saber-notes/saber#1039](https://github.com/saber-notes/saber/issues/1039)).

## 0.7.0

* Removed the type parameter from `RecognizedUnistroke`. Custom types will now use the `RecognizedCustomUnistroke<K>` type.
* `recognizeUnistrokeOfType` has been renamed to `recognizeCustomUnistroke`.

## 0.6.1

* Improved line detection.
* Improved the rotation of the recognized shape.

## 0.6.0

* Added a line template, and the corresponding `RecognizedUnistroke.convertToLine()` method.

## 0.5.0

* `RecognizedUnistroke.name` is now using an enum instead of a string, e.g. `DefaultUnistrokeNames.circle` instead of `'circle'`. If you're using custom unistrokes, see the README for how to use the `recognizeUnistrokeOfType` method.
* `convertToCanonicalPolygon()` now returns a correctly rotated shape (https://github.com/adil192/one_dollar_unistroke_recognizer/issues/2).

## 0.4.2

* Removed colored text from README since it doesn't work on pub.dev.

## 0.4.1

* Fixed images in the README on pub.dev.
* Added a `RecognizedUnistroke.convertToOval()` method.

## 0.4.0

* This release has changed the default set of templates to contain better shapes. The old templates are still available in `example$1Unistrokes`. The new templates are only a circle, rectangle, and triangle, where the old templates were more varied but were also sketched by hand and were not very pretty.
* Inputs are now recognized even if they are drawn in the opposite direction of the template. For example, a clockwise circle will be recognized as a circle, even if the template is a counter-clockwise circle. This wasn't the case in previous releases.
* Like previous releases, `convertToCanonicalPolygon()` is still returning incorrectly rotated shapes. See https://github.com/adil192/one_dollar_unistroke_recognizer/issues/2 to track progress on this issue.

## 0.3.1

* Scores can now only be between 0 and 1. Would-be negative scores are interpreted to mean that the stroke is not recognized, so `null` is returned.

## 0.3.0

* Added functions to `RecognizedUnistroke` to get a "perfect" shape from the user's stroke: see `RecognizedUnistroke.convertToCanonicalPolygon` and `RecognizedUnistroke.convertToCircle`.

## 0.2.0

* Recognize custom unistrokes by setting the `referenceUnistrokes` variable, or by passing the `overrideReferenceUnistrokes` parameter to `recognizeUnistroke`.

## 0.1.1

* feat: Added a web demo here: https://adil192.github.io/one_dollar_unistroke_recognizer.
* feat: You can see the list of possible outputs in `knownUnistrokesNames`.
* fix: Strokes that are too short are ignored.

## 0.1.0

* Initial release.
* TODO: Allow adding custom unistrokes.
