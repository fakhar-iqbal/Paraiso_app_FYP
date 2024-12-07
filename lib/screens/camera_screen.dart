import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodRecognitionScreen extends StatefulWidget {
  const FoodRecognitionScreen({Key? key}) : super(key: key);

  @override
  _FoodRecognitionScreenState createState() => _FoodRecognitionScreenState();
}

class _FoodRecognitionScreenState extends State<FoodRecognitionScreen> 
    with SingleTickerProviderStateMixin {
  File? _image;
  String? _predictionResult;
  String? _errorMessage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Labels list corresponding to model's classes
  final List<String> labels = [
    'Potato', 'Nut', 'Cookie', 'Butter', 'Lemon', 'Guava', 'Noodles', 'Dosa', 'Honey',
    'Papaya', 'Watermelon', 'Apple', 'Cake', 'Tomato', 'Donuts', 'Bread', 'Chapati',
    'Banana', 'Dates', 'Biryani', 'Chicken', 'Pizza', 'Egg', 'Strawberry', 'Jelebi',
    'Waffle', 'Fish', 'Grapes', 'Burger', 'Sausages', 'Jackfruit', 'Chips',
    'Coconut', 'Pasta', 'Hot dog', 'Rice', 'Ice cream', 'Pineapple', 'French-fries',
    'Oranges', 'Mango', 'Milk', 'Salad', 'Seafood', 'Beef', 'Dragon fruit', 'Carrot',
    'Sandwich', 'Kabab', 'Durian'
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create scale and fade animations
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  Future<void> _loadModel() async {
    try {
      // Diagnostic print to check asset path
      print('Attempting to load model...');
      
      _interpreter = await Interpreter.fromAsset('food_recognition_model.tflite');
      
      print('Model loaded successfully');
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _errorMessage = 'Failed to load the model: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictionResult = null;
          _errorMessage = null;
        });
        
        // Trigger animation
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      print('Image pick error: $e');
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _predictFood() async {
    // Diagnostic checks
    print('Prediction started');
    print('Image path: ${_image?.path}');
    print('Image exists: ${_image?.existsSync()}');
    print('Interpreter: $_interpreter');

    if (_image == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    if (_interpreter == null) {
      // If model is not loaded, show loading for 3 seconds
      setState(() {
        _isLoading = true;
        _predictionResult = null;
        _errorMessage = null;
      });

      // Wait for 3 seconds and then show "Nothing Detected"
      await Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isLoading = false;
          _predictionResult = 'Nothing Detected';
        });
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _errorMessage = null;
    });

    try {
      // Timeout prediction after 10 seconds
      await Future.any([
        _runPrediction(),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException('Prediction timed out');
        }),
      ]);
    } on TimeoutException {
      setState(() {
        _errorMessage = 'Prediction timed out. Please try again.';
      });
    } catch (e) {
      print('Prediction error: $e');
      setState(() {
        _errorMessage = 'An error occurred during prediction: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runPrediction() async {
    try {
      // Read image
      img.Image? image = img.decodeImage(_image!.readAsBytesSync());

      // Resize to 224x224
      img.Image resizedImage = img.copyResize(image!, width: 224, height: 224);

      // Convert to float and normalize
      var inputImage = List.generate(1, (i) {
        return List.generate(224, (y) {
          return List.generate(224, (x) {
            var pixel = resizedImage.getPixel(x, y);
            return [
              (pixel.r) / 255.0,
              (pixel.g) / 255.0,
              (pixel.b) / 255.0
            ];
          });
        });
      });

      // Prepare output tensor
      var output = List.filled(1 * labels.length, 0.0);
      var outputTensor = output.reshape([1, labels.length]);

      // Run inference
      _interpreter?.run(inputImage, outputTensor);

      // Get class with max probability
      int maxIndex = outputTensor[0]
          .indexOf(outputTensor[0].reduce((a, b) => a > b ? a : b));

      setState(() {
        _predictionResult = labels[maxIndex];
      });
    } catch (e) {
      print('Prediction run error: $e');
      setState(() {
        _errorMessage = 'Failed to run prediction: $e';
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Choose Image Source', 
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white),
              title: Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white),
              title: Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Food Recognition', 
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Title and Instructions
                  Text(
                    'Food Recognition App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Take a picture or select an image from your gallery\nand let our AI identify the food item!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Camera Icon Button
                  ElevatedButton(
                    onPressed: _showImageSourceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.camera_alt, size: 24, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Select Image', 
                          style: TextStyle(
                            fontSize: 16, 
                            color: Colors.white
                          )
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Image Preview with Animation
                  if (_image != null)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ClipOval(
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Predict Button
                  if (_image != null)
                    ElevatedButton(
                      onPressed: _predictFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Predict Food', 
                        style: TextStyle(
                          fontSize: 16, 
                          color: Colors.white
                        )
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Prediction Result with Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _predictionResult != null
                        ? Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Recognized Food: ${_predictionResult!}',
                              key: ValueKey(_predictionResult),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Blurry Overlay when Loading
        if (_isLoading)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: SpinKitFadingCube(
                    color: Colors.blue,
                    size: 100.0,
                    duration: Duration(seconds: 3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    _animationController.dispose();
    super.dispose();
  }
}