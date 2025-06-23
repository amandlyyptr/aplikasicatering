import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tugas_appcatering/pages/ProductDetailPage.dart';
import 'package:tugas_appcatering/pages/add_product_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';

  // Daftar makanan favorit dan gambar terkait
  final List<Map<String, String>> makananFavorit = [
    {'name': 'Nasi Goreng', 'image': 'assets/nasi_goreng.jpg'},
    {'name': 'Sate Ayam', 'image': 'assets/sateayam.jpg'},
    {'name': 'Rendang', 'image': 'assets/rendang.jpg'},
    {'name': 'Gulai', 'image': 'assets/gulai.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser!.uid; // Ambil UID user yang login

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 253, 240, 240),
          child: Column(
            children: [
              // Widget pencarian
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama menu atau catering...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),
              // Judul "Menu Best Seller"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Menu Best Seller',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000), // Maroon
                  ),
                ),
              ),
              // List horizontal untuk makanan favorit dengan gambar
              Container(
                height: 100, // Tinggi dari list horizontal
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: makananFavorit.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 100, // Lebar kotak
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              makananFavorit[index]['image']!,
                              fit: BoxFit.cover,
                              height: 70, // Tinggi gambar
                              width: 80, // Lebar gambar
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            makananFavorit[index]['name']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // StreamBuilder untuk menampilkan produk
              Container(
                height:
                    MediaQuery.of(context).size.height -
                    250, // Batasi tinggi untuk menghindari overflow
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('produk')
                          .where('userId', isEqualTo: uid) // 🔥 FILTER PER USER
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Data produk kosong'));
                    }

                    final docs =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final namaMenu =
                              (data['namaMenu'] ?? '').toString().toLowerCase();
                          final namaCatering =
                              (data['namaCatering'] ?? '')
                                  .toString()
                                  .toLowerCase();
                          return namaMenu.contains(_searchQuery) ||
                              namaCatering.contains(_searchQuery);
                        }).toList();

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Produk tidak ditemukan'),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;

                        Uint8List? imageBytes;
                        try {
                          final base64String = data['gambarBase64'] ?? '';
                          if (base64String.isNotEmpty) {
                            imageBytes = base64Decode(base64String);
                          }
                        } catch (_) {
                          imageBytes = null;
                        }

                        final namaCatering =
                            data['namaCatering'] ?? 'Tidak ada';
                        final namaMenu = data['namaMenu'] ?? 'Tidak ada';
                        final harga = data['harga']?.toString() ?? '0';

                        return GestureDetector(
                          onTap: () => _openDetailPage(context, docId, data),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color.fromARGB(255, 199, 71, 71),
                            elevation: 3,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child:
                                            imageBytes != null
                                                ? Image.memory(
                                                  imageBytes,
                                                  fit: BoxFit.cover,
                                                )
                                                : const Icon(
                                                  Icons.broken_image,
                                                  size: 70,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            namaMenu,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Catering: $namaCatering",
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Rp $harga",
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    elevation: 4,
                                    shape: const CircleBorder(),
                                    color: Colors.orangeAccent,
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _editProduct(context, docId, data);
                                        } else if (value == 'delete') {
                                          _confirmDeleteProduct(context, docId);
                                        }
                                      },
                                      itemBuilder:
                                          (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Hapus'),
                                            ),
                                          ],
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  void _openDetailPage(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(docId: docId, productData: data),
      ),
    );
  }

  void _editProduct(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductPage(docId: docId, existingData: data),
      ),
    );
  }

  Future<void> _confirmDeleteProduct(BuildContext context, String docId) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus produk ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya'),
              ),
            ],
          ),
    );

    if (result == true) {
      _deleteProduct(context, docId);
    }
  }

  void _deleteProduct(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('produk').doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus produk: $e")));
    }
  }
}
