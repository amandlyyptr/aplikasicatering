import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_pemesanan_model.dart';

class HistoryService {
  static Future<List<HistoryPemesanan>> fetchHistory(String uid) async {
    if (uid.isEmpty) {
      throw Exception('UID tidak boleh kosong');
    }

    final url = Uri.parse(
      'http://192.168.1.20/catering_restapi/api/get_history.php?uid=$uid',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => HistoryPemesanan.fromJson(item)).toList();
    } else if (response.statusCode == 400) {
      throw Exception('Bad request: Pastikan parameter uid sudah benar');
    } else {
      throw Exception('Gagal mengambil data: Status ${response.statusCode}');
    }
  }

  // ✅ Tambahan: Hapus histori berdasarkan ID
  static Future<void> deleteHistory(String id) async {
    final url = Uri.parse(
      'http://192.168.1.36/catering_restapi/api/hapus_history.php',
    );

    final response = await http.post(url, body: {'id': id});

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] != true) {
        throw Exception('Gagal menghapus: ${result['message']}');
      }
    } else {
      throw Exception('Gagal koneksi ke server saat menghapus');
    }
  }
}
