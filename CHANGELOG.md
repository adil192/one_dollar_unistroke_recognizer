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
