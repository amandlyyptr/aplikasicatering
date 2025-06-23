import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_detail_page.dart';

// Warna tema maroon
const maroon = Color(0xFF800000);
const maroonSoft = Color(0xFFFBECEC);

class MenuListPage extends StatefulWidget {
  final String categoryName;

  const MenuListPage({super.key, required this.categoryName});

  @override
  _MenuListPageState createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  String searchQuery = '';

  String toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayCategory = toTitleCase(widget.categoryName);
    final uid =
        FirebaseAuth.instance.currentUser!.uid; // Ambil UID user yang login

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              color: maroon,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Menu $displayCategory',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari menu...',
                  prefixIcon: const Icon(Icons.search, color: maroon),
                  filled: true,
                  fillColor: maroonSoft,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: maroon),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: maroon, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // List Firestore data
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('produk')
                        .where('jenis', isEqualTo: widget.categoryName)
                        .where('userId', isEqualTo: uid) // 🔥 filter per user
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: maroon),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada menu dalam kategori ini.'),
                    );
                  }

                  final allDocs = snapshot.data!.docs;
                  final filteredDocs =
                      allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final nama =
                            (data['namaMenu'] ?? '').toString().toLowerCase();
                        return nama.contains(searchQuery);
                      }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('Menu tidak ditemukan.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredDocs[index].data()! as Map<String, dynamic>;
                      final imageBase64 = data['gambarBase64'] as String?;
                      Uint8List? imageBytes;

                      if (imageBase64 != null && imageBase64.isNotEmpty) {
                        try {
                          imageBytes = base64Decode(imageBase64);
                        } catch (e) {
                          print('Error decoding base64 image: $e');
                        }
                      }

                      final namaMenu = data['namaMenu'] ?? 'Tanpa Nama';
                      final harga =
                          data['harga'] != null
                              ? 'Rp ${data['harga']}'
                              : 'Rp 0';
                      final deskripsi = data['keterangan'] ?? '-';
                      final jenis = data['jenis'] ?? '-';
                      final namaCatering =
                          data['namaCatering'] ?? 'Tanpa Catering';
                      final lokasi = data['lokasi'] ?? '-';
                      final noWa = data['noWa'] ?? '';

                      return Card(
                        color: maroonSoft,
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                imageBytes != null
                                    ? Image.memory(
                                      imageBytes,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: maroon,
                                      ),
                                    ),
                          ),
                          title: Text(
                            namaMenu,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: maroon,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Catering: $namaCatering'),
                              Text('Harga: $harga'),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: maroon,
                            size: 18,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MenuDetailPage(
                                      imageBytes: imageBytes,
                                      namaMenu: namaMenu,
                                      harga: harga,
                                      keterangan: deskripsi,
                                      jenis: jenis,
                                      namaCatering: namaCatering,
                                      lokasi: lokasi,
                                      noWa: noWa,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
