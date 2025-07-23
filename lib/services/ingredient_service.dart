//import 'package:tflite/tflite.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// class IngredientClassifier {
//   late Interpreter _interpreter;
//   static const int numClasses =
//       15; // Define number of classes your model can classify
//   bool _isModelLoaded = false;

//   // Map to convert class indices to readable ingredient names
//   final Map<int, String> ingredientNames = {
//     0: "Banana",
//     1: "Broccoli",
//     2: "Carrot",
//     3: "Cauliflower",
//     4: "Cucumber",
//     5: "Grape",
//     6: "Kiwi",
//     7: "Mango",
//     8: "Onion",
//     9: "Orange",
//     10: "Pineapple",
//     11: "Red Apple",
//     12: "Spinach",
//     13: "Strawberry",
//     14: "Tomato",
//     // Add all your ingredient classes here
//   };

//   bool get isModelLoaded => _isModelLoaded;

//   // Load the TFLite model
//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset(
//         'assets/models/custom_ingredient_classification_model.tflite',
//       );
//       _isModelLoaded = true;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Run inference
//   List<dynamic> classify(Float32List inputImage) {
//     if (!_isModelLoaded) {
//       throw Exception('Model not loaded yet');
//     }

//     // Define input & output tensor shapes
//     var input = [inputImage];
//     var output = List<double>.filled(numClasses, 0.0);
//     var outputBuffer = [output];

//     _interpreter.run(input, outputBuffer);
//     return outputBuffer;
//   }

//   // Preprocess image for TFLite model
//   Future<Float32List> preprocessImage(File imageFile) async {
//     // Read and decode the image
//     final bytes = await imageFile.readAsBytes();
//     final image = img.decodeImage(bytes);
//     if (image == null) throw Exception('Failed to decode image');

//     // Resize to match your model's input size (assume 224x224)
//     final resizedImage = img.copyResize(image, width: 224, height: 224);

//     // Convert to normalized float tensor
//     final Float32List buffer = Float32List(1 * 224 * 224 * 3);
//     int pixelIndex = 0;

//     for (int y = 0; y < 224; y++) {
//       for (int x = 0; x < 224; x++) {
//         final pixel = resizedImage.getPixel(x, y);
//         // Scale RGB values to 0-1
//         buffer[pixelIndex++] = img.getRed(pixel) / 255.0;
//         buffer[pixelIndex++] = img.getGreen(pixel) / 255.0;
//         buffer[pixelIndex++] = img.getBlue(pixel) / 255.0;
//       }
//     }

//     return buffer;
//   }

//   // Classify image and return the detected ingredient name
//   Future<String> classifyImageAndGetIngredientName(File imageFile) async {
//     try {
//       // Preprocess the image
//       final inputImage = await preprocessImage(imageFile);

//       // Run inference
//       final List<dynamic> output = classify(inputImage);

//       // Get the top class (highest probability)
//       List<double> probabilities = List<double>.from(output[0]);
//       int topClassIndex = probabilities.indexOf(
//         probabilities.reduce((a, b) => a > b ? a : b),
//       );

//       // Convert class index to ingredient name
//       return ingredientNames[topClassIndex] ?? "Unknown Item";
//     } catch (e) {
//       throw Exception('Failed to classify image: $e');
//     }
//   }
// }
