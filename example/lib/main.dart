import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:one_dollar_unistroke_recognizer_example/canvas_draw.dart';

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
                    : 'Detected "${recognized.name}" with score ${recognized.score.toStringAsFixed(2)}',
              );
            },
          ),
        ),
        body: Column(
          children: [
            Center(
              child: Card(
                color: Colors.blue.withOpacity(0.1),
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      for (final name in knownUnistrokesNames)
                        Chip(
                          label: Text(name),
                        ),
                    ],
                  ),
                ),
              ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
