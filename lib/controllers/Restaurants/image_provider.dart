import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../repositories/res_post_repo.dart';

class ImageUploadProvider with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  // Future<void> uploadImageToFirebase(File? imgPath) async {
  //   try {
  //     if (imgPath != null) {
  //       String imageUrl = await _repo.uploadImageToFirebase(imgPath: imgPath);

  //       _imageUrl = imageUrl;
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('Error uploading image: $e');
  //   }
  // }
Future<String?> uploadImageToFirebase(File? imgPath) async {
  try {
    if (imgPath != null) {
      // Upload file to Firebase
      String imageUrl = await _repo.uploadImageToFirebase(imgPath: imgPath);

      _imageUrl = imageUrl; // Save to state
      notifyListeners();
      return imageUrl; // Return the URL
    }
    return null;
  } catch (e) {
    if (kDebugMode) print('Error uploading image: $e');
    return null;
  }
}

}
