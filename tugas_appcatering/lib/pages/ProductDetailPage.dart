import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> productData;

  ProductDetailPage({required this.docId, required this.productData});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Map<String, dynamic> product;
  List<Map<String, dynamic>> komentarList = [];
  final TextEditingController komentarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    product = widget.productData;
    fetchKomentar();
  }

  Future<void> fetchKomentar() async {
    try {
      var response = await http.get(
        Uri.parse(
          'http://192.168.1.20/catering_restapi/api/tampil_komentar.php?menu_id=${widget.docId}',
        ),
      );

      if (response.statusCode == 200) {
        var jsonRes = json.decode(response.body);

        if (jsonRes is List) {
          setState(() {
            komentarList = List<Map<String, dynamic>>.from(jsonRes);
          });
        } else if (jsonRes is Map && jsonRes.containsKey('status')) {
          // Kalau PHP mengembalikan error dalam bentuk objek (bukan array)
          print("Gagal ambil komentar: ${jsonRes['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonRes['message'] ?? 'Terjadi kesalahan')),
          );
        } else {
          print("Format JSON tidak dikenali: ${response.body}");
        }
      } else {
        print("Gagal ambil komentar. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Gagal mengambil komentar: $e");
    }
  }

  Future<void> tambahKomentar() async {
    print("TOMBOL DIKLIK"); // DEBUG LOG

    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? '';
    String namaUser = user?.email ?? 'Anonim';
    String isiKomentar = komentarController.text;

    if (isiKomentar.isEmpty) {
      print("Komentar kosong"); // DEBUG LOG
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(
          "http://192.168.1.20/catering_restapi/api/tambah_komentar.php",
        ),
        body: {
          "menu_id": widget.docId,
          "uid": uid,
          "nama_user": namaUser,
          "komentar": isiKomentar,
        },
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        komentarController.clear();
        fetchKomentar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Komentar ditambahkan')));
      } else {
        print("Gagal menambah komentar: ${response.body}");
      }
    } catch (e) {
      print("ERROR saat kirim komentar: $e");
    }
  }

  Future<void> editKomentar(String komentarId, String newText) async {
    print("DEBUG: Tombol edit diklik");
    print("DEBUG: ID Komentar: $komentarId");
    print("DEBUG: New Komentar: $newText");

    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.20/catering_restapi/api/edit_komentar.php'),
        body: {"id_komentar": komentarId, "komentar": newText},
      );

      print("DEBUG: Response status code: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          fetchKomentar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'] ?? 'Komentar diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json['message'] ?? 'Gagal memperbarui komentar'),
            ),
          );
        }
      } else {
        throw Exception('Gagal mengedit komentar');
      }
    } catch (e) {
      print("ERROR saat edit komentar: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  Future<void> hapusKomentar(String komentarId) async {
    print("DEBUG: Tombol hapus diklik");
    print("DEBUG: ID Komentar: $komentarId");

    try {
      var response = await http.post(
        Uri.parse(
          'http://192.168.1.20/catering_restapi/api/hapus_komentar.php',
        ),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded", // WAJIB
        },
        body: {"id": komentarId},
      );

      print("DEBUG: Response status code: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          fetchKomentar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'] ?? 'Komentar dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json['message'] ?? 'Gagal menghapus komentar'),
            ),
          );
        }
      } else {
        throw Exception('Gagal menghapus komentar');
      }
    } catch (e) {
      print("ERROR saat hapus komentar: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void showEditDialog(String komentarId, String oldKomentar) {
    final controller = TextEditingController(text: oldKomentar);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Edit Komentar"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Masukkan komentar baru"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  editKomentar(komentarId, controller.text);
                },
                child: Text("Simpan"),
              ),
            ],
          ),
    );
  }

  void _openWhatsApp(BuildContext context, Map<String, dynamic> product) async {
    String rawPhone = product['noWa'] ?? '';
    String phone = rawPhone
        .replaceAll(RegExp(r'^0'), '62') // Mengganti 0 di depan dengan 62
        .replaceAll(RegExp(r'[^0-9]'), ''); // Menghapus karakter non-numerik
    String menu = product['namaMenu'] ?? '';
    String catering = product['namaCatering'] ?? '';

    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? 'UNKNOWN_USER';

    try {
      var response = await http.post(
        Uri.parse(
          "http://192.168.1.20/catering_restapi/api/tambah_history.php",
        ),
        body: {"uid": uid, "nama_makanan": menu},
      );

      if (response.statusCode == 200) {
        String message = Uri.encodeComponent(
          "Halo, saya tertarik memesan *$menu* dari *$catering*. Apakah masih tersedia?",
        );
        final Uri url = Uri.parse("https://wa.me/$phone?text=$message");

        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal membuka WhatsApp')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan histori pemesanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final base64Image = product['gambarBase64'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Catering'),
        backgroundColor: const Color.fromARGB(255, 158, 13, 13),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            base64Image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(base64Image),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text('Tidak ada gambar')),
                ),
            SizedBox(height: 20),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                text: product['namaCatering'] ?? '',
              ),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Nama Catering',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    buildDetailRow('Nama Menu', product['namaMenu'] ?? ''),
                    buildDetailRow('Harga', product['harga']?.toString() ?? ''),
                    buildDetailRow('Keterangan', product['keterangan'] ?? ''),
                    buildDetailRow(
                      'Jenis',
                      product['jenis'] ?? 'Data jenis kosong',
                    ),
                    buildDetailRow('No WhatsApp', product['noWa'] ?? ''),
                    buildDetailRow('Lokasi', product['lokasi'] ?? ''),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openWhatsApp(context, product),
              icon: Icon(Icons.chat),
              label: Text('Pesan via WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 211, 89, 89),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Komentar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: komentarList.length,
              itemBuilder: (context, index) {
                final komentar = komentarList[index];
                final user = FirebaseAuth.instance.currentUser;
                final isUserComment = komentar['uid'] == user?.uid;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(komentar['nama_user']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(komentar['komentar']),
                        SizedBox(height: 4),
                        Text(
                          komentar['tanggal'].substring(0, 10),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing:
                        isUserComment
                            ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showEditDialog(
                                    komentar['id'],
                                    komentar['komentar'],
                                  );
                                } else if (value == 'delete') {
                                  hapusKomentar(komentar['id']);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus'),
                                    ),
                                  ],
                            )
                            : null,
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: komentarController,
              decoration: InputDecoration(
                labelText: 'Tulis komentar...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: tambahKomentar,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
