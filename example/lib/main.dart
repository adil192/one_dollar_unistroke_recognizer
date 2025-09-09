import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:one_dollar_unistroke_recognizer_example/canvas_draw.dart';
import 'package:one_dollar_unistroke_recognizer_example/unistroke_preview.dart';

final recognized = ValueNotifier<RecognizedUnistroke?>(null);
Timer? pointDebounce;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '\$1 Unistroke Recognizer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.highContrastLight(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.highContrastDark(),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: recognized,
            builder: (context, recognized, child) {
              return Text(
                recognized == null
                    ? 'Draw below to detect a shape'
                    : 'Detected "${recognized.name?.name}" with score '
                        '${recognized.score.toStringAsFixed(2)}',
              );
            },
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                for (final shape in DefaultUnistrokeNames.values) ...[
                  Expanded(
                    child: UnistrokePreview(
                      unistroke: referenceUnistrokes.firstWhere(
                        (unistroke) => unistroke.name == shape,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: CanvasDraw(
                  recognized: recognized,
                  onDraw: (points) {
                    if (pointDebounce == null || !pointDebounce!.isActive) {
                      pointDebounce =
                          Timer(const Duration(milliseconds: 100), () {
                        recognized.value = recognizeUnistroke(points);
                      });
                    }
                  },
                  onDrawEnd: (points) {
                    pointDebounce?.cancel();
                    pointDebounce = null;
                    recognized.value = recognizeUnistroke(points);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
