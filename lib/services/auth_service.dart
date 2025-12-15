import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://example.com/api"; // change this

  Future<bool> changePassword(String oldPass, String newPass) async {
    final response = await http.post(
      Uri.parse("$baseUrl/change-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"oldPassword": oldPass, "newPassword": newPass}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body["message"] ?? "Password change failed");
    }
  }
}
