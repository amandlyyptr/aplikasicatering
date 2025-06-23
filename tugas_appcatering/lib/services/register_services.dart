import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  final String baseUrl =
      'https://api-catering-default-rtdb.firebaseio.com/catering.json';

  Future<bool> registerUser({
    required String nama,
    required String username,
    required String password,
  }) async {
    try {
      // Cek apakah username sudah ada
      final getResponse = await http.get(Uri.parse(baseUrl));
      if (getResponse.statusCode == 200) {
        final Map<String, dynamic>? users =
            json.decode(getResponse.body) as Map<String, dynamic>?;

        if (users != null) {
          for (var user in users.values) {
            if (user['username'] == username) {
              return false; // Username sudah ada
            }
          }
        }
      }

      // Jika username belum ada, simpan data baru
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'nama': nama,
          'username': username,
          'password': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error during register: $e");
      return false;
    }
  }
}
