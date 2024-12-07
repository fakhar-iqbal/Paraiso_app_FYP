import 'package:flutter/material.dart';

class CategoriesProvider extends ChangeNotifier {
  int activeChip = 100;
  String selectedCategory = '';

  void setActiveChip(int index) {
    activeChip = index;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}
