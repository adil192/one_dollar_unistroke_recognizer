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
