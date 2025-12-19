import 'package:flutter/material.dart';
import 'package:hello_world/providers/expense_provider.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final Box<Category> _box = Hive.box<Category>('categories');

  List<Category> get categories => _box.values.toList();

  void addCategory(String name) {
    _box.add(Category(name: name));
    notifyListeners();
  }

  void updateCategory(int index, String name) {
    _box.putAt(index, Category(name: name));
    notifyListeners();
  }

  void deleteCategory(int index) {
    _box.deleteAt(index);
    notifyListeners();
  }

  /// Initial default categories
  void addDefaultsIfEmpty() {
    if (_box.isEmpty) {
      for (final name in [
        'Food',
        'Travel',
        'Shopping',
        'Bills',
        'Cashback',
        'Other',
      ]) {
        _box.add(Category(name: name));
      }
      notifyListeners();
    }
  }

  bool canDeleteCategory(String categoryName, ExpenseProvider expenseProvider) {
    return !expenseProvider.isCategoryInUse(categoryName);
  }
}
