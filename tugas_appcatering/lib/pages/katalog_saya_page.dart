import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_appcatering/pages/add_product_page.dart';
import 'package:tugas_appcatering/pages/ProductDetailPage.dart';

class KatalogSayaPage extends StatefulWidget {
  @override
  _KatalogSayaPageState createState() => _KatalogSayaPageState();
}

class _KatalogSayaPageState extends State<KatalogSayaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Katalog Saya')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('produk').snapshots(),
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

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;
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

              final namaCatering = data['namaCatering'] ?? 'Tidak ada';
              final namaMenu = data['namaMenu'] ?? 'Tidak ada';
              final harga = data['harga']?.toString() ?? '0';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                color: const Color(0xFFFFF5E0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageBytes != null
                        ? Image.memory(imageBytes, width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                  title: Text(
                    namaMenu,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Catering: $namaCatering\nRp $harga"),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProduct(context, docId, data);
                      } else if (value == 'delete') {
                        _confirmDeleteProduct(context, docId);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                  onTap: () => _openDetailPage(context, docId, data),
                ),
              );
            },
          );
        },
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
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil dihapus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus produk: $e")),
      );
    }
  }
}
