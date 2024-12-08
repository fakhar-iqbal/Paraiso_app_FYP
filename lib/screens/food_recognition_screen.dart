// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/database_helper.dart';
// import '../widgets/item_details_widget.dart';

// class FoodRecognitionScreen extends StatefulWidget {
//   final Function(String, String?) onFoodRecognized;

//   const FoodRecognitionScreen({
//     Key? key, 
//     required this.onFoodRecognized
//   }) : super(key: key);

//   @override
//   _FoodRecognitionScreenState createState() => _FoodRecognitionScreenState();
// }

// class _FoodRecognitionScreenState extends State<FoodRecognitionScreen> {
//   final ImagePicker _picker = ImagePicker();
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
  
//   File? _imageFile;
//   String? _recognizedDish;
//   List<Map<String, dynamic>> _itemResults = [];
//   bool _isLoading = false;

//   final GenerativeModel _visionModel = GenerativeModel(
//     model: 'gemini-pro-vision',
//     apiKey: 'YOUR_GEMINI_API_KEY'
//   );

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
    
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _recognizedDish = null;
//         _itemResults = [];
//       });
      
//       await _recognizeFoodImage();
//     }
//   }

//   Future<void> _recognizeFoodImage() async {
//     if (_imageFile == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final image = await _imageFile!.readAsBytes();

//       final prompt = 'Identify the specific food item in this image. Only respond with the exact name of the dish.';
      
//       final response = await _visionModel.generateContent([
//         Content.multi([
//           TextPart(prompt),
//           DataPart('image/jpeg', image),
//         ])
//       ]);

//       String? dishName = response.text?.trim();

//       if (dishName != null && dishName.isNotEmpty) {
//         // Search for dish in restaurants
//         var results = await _databaseHelper.searchItemsByName(dishName);

//         setState(() {
//           _recognizedDish = dishName;
//           _itemResults = results;
//         });

//         // Callback to parent widget with image and dish name
//         widget.onFoodRecognized(dishName, _imageFile!.path);
//       }
//     } catch (e) {
//       print("Error recognizing image: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to recognize food item'))
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Food Recognition'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.camera_alt),
//             onPressed: () => _pickImage(ImageSource.camera),
//           ),
//           IconButton(
//             icon: Icon(Icons.image),
//             onPressed: () => _pickImage(ImageSource.gallery),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_imageFile != null)
//             Image.file(
//               _imageFile!, 
//               height: 250, 
//               width: double.infinity, 
//               fit: BoxFit.cover
//             ),
          
//           if (_isLoading)
//             CircularProgressIndicator(),
          
//           if (_recognizedDish != null)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 'Recognized Dish: $_recognizedDish',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
          
//           if (_itemResults.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _itemResults.length,
//                 itemBuilder: (context, index) {
//                   return ItemDetailsWidget(
//                     itemDetails: _itemResults[index]
//                   );
//                 },
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }