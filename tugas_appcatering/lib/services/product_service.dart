import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductService {
  final String baseUrl =
      'http://192.168.1.20/RESTAPI_catering'; // Ganti sesuai kebutuhan

  Future<bool> tambahProduk(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/post.php'),
      body: data,
    );
    return jsonDecode(response.body)['success'] ?? false;
  }

  Future<List<dynamic>> ambilSemuaProduk() async {
    final response = await http.get(Uri.parse('$baseUrl/get.php'));
    return jsonDecode(response.body);
  }

  Future<bool> updateProduk(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/put.php'), body: data);
    return jsonDecode(response.body)['success'] ?? false;
  }

  Future<bool> hapusProduk(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete.php'),
      body: {'id': id},
    );
    return jsonDecode(response.body)['success'] ?? false;
  }
}
