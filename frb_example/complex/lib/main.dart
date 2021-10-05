import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_example/generated_api.dart';
import 'package:flutter_rust_bridge_example/generated_wire.dart';
import 'package:flutter_rust_bridge_example/utils.dart';

// Simple Flutter code. If you are not familiar with Flutter, this may sounds a bit long. But indeed
// it is quite trivial and Flutter is just like that. Please refer to Flutter's tutorial to learn Flutter.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Rust Bridge Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final dylib =
      Platform.isAndroid ? DynamicLibrary.open('libflutter_rust_bridge_example.so') : DynamicLibrary.process();
  late final api = ExampleApi(ExampleWire(dylib));

  double scale = 1.0;
  Uint8List? exampleImage;
  String? exampleText;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (timer) => _callExampleFfi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Rust Bridge Example'),
      ),
      body: ListView(
        children: [
          buildCardUi(
            'Example 1',
            'Image generated by Rust and displayed by Flutter/Dart',
            exampleImage != null
                ? SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: AnimatedReplaceableImage(image: MemoryImage(exampleImage!))))
                : Container(),
          ),
          buildCardUi(
            'Example 2',
            'Complex struct/class is passed smoothly through FFI',
            Text(exampleText ?? ''),
          ),
        ],
      ),
    );
  }

  Future<void> _callExampleFfi() async {
    final receivedImage = await api.drawMandelbrot(
        imageSize: Size(width: 50, height: 50), zoomPoint: examplePoint, scale: scale *= 0.5, numThreads: 4);
    setState(() => exampleImage = receivedImage);

    final receivedText = await api.passingComplexStructs(root: createExampleTree());
    setState(() => exampleText = receivedText);
  }
}
