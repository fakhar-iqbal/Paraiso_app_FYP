import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourcePicker {
  static Future<File?> pickFile(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: imageSource, imageQuality: 50);
    if (image == null) return null;

    return File(image.path);
  }

  static Future<XFile?> pickFileforWeb(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: imageSource, imageQuality: 50);
    if (image == null) return null;

    return image;
  }

  static Future<ImageSource?> showImageSource(BuildContext context) async {
    if (Platform.isIOS) {
      return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (_) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            )
          ],
        ),
      );
    } else {
      return showModalBottomSheet(
        context: context,
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              tileColor: Colors.white,
              title: const Text("Camera"),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              tileColor: Colors.white,
              title: const Text("Gallery"),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            )
          ],
        ),
      );
    }
  }
}
