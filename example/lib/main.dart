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
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: recognized,
            builder: (context, recognized, child) {
              return Text(
                recognized == null
                    ? 'Draw below to detect a shape'
                    : 'Detected "${recognized.name}" with score '
                        '${recognized.score.toStringAsFixed(2)}',
              );
            },
          ),
        ),
        body: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final shape in DefaultUnistrokeNames.values)
                  UnistrokePreview(
                    unistroke: referenceUnistrokes.firstWhere(
                      (unistroke) => unistroke.name == shape,
                    ),
                  ),
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
