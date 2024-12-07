import 'package:get/get.dart';

class ResCategoriesController extends GetxController {
  var activeChip = 100.obs;

  void setActiveChip(int index) {
    activeChip.value = index;
  }
}
