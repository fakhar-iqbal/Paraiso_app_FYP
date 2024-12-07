import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../repositories/res_post_repo.dart';

class ImageUploadProvider with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  Future<void> uploadImageToFirebase(File? imgPath) async {
    try {
      if (imgPath != null) {
        String imageUrl = await _repo.uploadImageToFirebase(imgPath: imgPath);

        _imageUrl = imageUrl;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error uploading image: $e');
    }
  }
}
