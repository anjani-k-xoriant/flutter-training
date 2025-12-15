import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool loading = false;
  String? errorMessage;

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.changePassword(oldPassword, newPassword);
      loading = false;
      notifyListeners();
      return success;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
