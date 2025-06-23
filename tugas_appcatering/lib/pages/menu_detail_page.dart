import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

const maroon = Color(0xFF800000);
const softMaroon = Color(0xFFFBECEC);

class MenuDetailPage extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String namaMenu;
  final String harga;
  final String keterangan;
  final String jenis;
  final String namaCatering;
  final String lokasi;
  final String noWa;

  const MenuDetailPage({
    Key? key,
    this.imageBytes,
    this.imageUrl,
    required this.namaMenu,
    required this.harga,
    required this.keterangan,
    required this.jenis,
    required this.namaCatering,
    required this.lokasi,
    required this.noWa,
  }) : super(key: key);

  Future<void> tambahHistory(
    String uid,
    String namaMenu,
    String waktuPesan,
  ) async {
    final url = Uri.parse(
      'http://192.168.1.6/catering_restapi/api/tambah_history.php',
    );

    try {
      final response = await http.post(
        url,
        body: {'uid': uid, 'nama_makanan': namaMenu, 'waktu_pesan': waktuPesan},
      );

      if (response.statusCode != 200) {
        print('Gagal menyimpan histori: ${response.body}');
      }
    } catch (e) {
      print('Error saat menambahkan histori: $e');
    }
  }

  void _launchWhatsApp(BuildContext context) async {
    String cleanedNumber = noWa.trim().replaceAll(RegExp(r'\D'), '');
    if (cleanedNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nomor tidak valid')));
      return;
    }
    if (cleanedNumber.startsWith('0')) {
      cleanedNumber = '62${cleanedNumber.substring(1)}';
    }

    final message = Uri.encodeComponent(
      'Halo, saya tertarik dengan menu $namaMenu dari $namaCatering.',
    );
    final url = Uri.parse('https://wa.me/$cleanedNumber?text=$message');

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      final now = DateTime.now().toIso8601String();
      await tambahHistory(uid, namaMenu, now);

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak bisa membuka WhatsApp');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka WhatsApp')));
    }
  }

  Widget _buildImage() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Icon(Icons.broken_image, size: 80, color: maroon),
      );
    } else {
      return Icon(Icons.broken_image, size: 80, color: maroon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softMaroon,
      appBar: AppBar(
        title: Text(namaMenu, style: TextStyle(fontSize: 16)),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(),
            ),
            SizedBox(height: 10),
            Text(
              namaMenu,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: maroon,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  harga,
                  style: TextStyle(fontSize: 14, color: Colors.green.shade800),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.storefront, size: 18, color: maroon),
                SizedBox(width: 6),
                Expanded(
                  child: Text(namaCatering, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red),
                SizedBox(width: 6),
                Expanded(child: Text(lokasi, style: TextStyle(fontSize: 13))),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.category, size: 18, color: maroon),
                SizedBox(width: 6),
                Text('Jenis: $jenis', style: TextStyle(fontSize: 13)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Keterangan:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(keterangan, style: TextStyle(fontSize: 13, height: 1.4)),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(context),
                icon: Icon(Icons.chat, size: 18),
                label: Text('Pesan via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
