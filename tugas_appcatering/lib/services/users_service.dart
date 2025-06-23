// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/users_model.dart';

class ApiService {
  final String baseUrl =
      'http://192.168.1.38/RESTAPI_catering'; // sesuaikan IPconfig wifi

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> register(User user, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': user.nama,
        'email': user.email,
        'password': password,
      }),
    );
    return response.statusCode == 200;
  }

  Future<User?> getUser(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$email'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.email}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 200;
  }

  // Fungsi DELETE user berdasarkan email
  Future<bool> deleteUser(String email) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$email'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}
