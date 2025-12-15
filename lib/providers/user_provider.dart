import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../screens/profile/profile_tab.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service = UserService();

  User? user;
  bool loading = false;
  String? error;

  Future<void> loadUser() async {
    loading = true;
    notifyListeners();

    try {
      user = await _service.fetchUser();
      error = null;
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> updateUser(User updated) async {
    loading = true;
    notifyListeners();

    try {
      user = await _service.updateUser(updated);
      error = null;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
