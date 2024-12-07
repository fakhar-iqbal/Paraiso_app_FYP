import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../repositories/res_post_repo.dart';
import '../repositories/customer_auth_repo.dart';

class ProfilePicController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  Future<void> uploadImageToFirebase(File? imgPath) async {
    try {
      if (imgPath != null) {
        String imageUrl = await _repo.uploadImageToFirebase(imgPath: imgPath);
        await CustomerAuthRep().updateUserProfile({"photo": imageUrl});

        _imageUrl = imageUrl;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error uploading image: $e');
    }
  }

  Future<void> setImageUrlNull() async {
    _imageUrl = null;
    notifyListeners();
  }

}
