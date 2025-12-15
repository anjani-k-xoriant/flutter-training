import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/profile/profile_tab.dart';

class UserService {
  static const String baseUrl = "https://example.com/api"; // change this

  Future<User> fetchUser() async {
    final res = await http.get(Uri.parse("$baseUrl/user"));

    if (res.statusCode != 200) {
      throw Exception("Failed to load user");
    }

    final data = jsonDecode(res.body);
    return User(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
    );
  }

  Future<User> updateUser(User user) async {
    final body = jsonEncode({
      "name": user.name,
      "email": user.email,
      "phone": user.phone,
      "location": user.location,
    });

    final res = await http.put(
      Uri.parse("$baseUrl/user/update"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update user");
    }

    final data = jsonDecode(res.body);
    return User(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      location: data['location'],
    );
  }
}
