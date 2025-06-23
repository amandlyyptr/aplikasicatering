import 'package:flutter/material.dart';
import 'menu_list_page.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final List<Map<String, String>> categories = [
    {'name': 'Nikahan', 'image': 'assets/nikahan.jpg'},
    {'name': 'Harian', 'image': 'assets/harian.jpg'},
    {'name': 'Ulang Tahun', 'image': 'assets/ulangtahun.jpg'},
    {'name': 'Aqiqah', 'image': 'assets/aqiqah.jpg'},
    {'name': 'Kantoran', 'image': 'assets/kantoran.jpg'},
    {'name': 'Tasyakuran', 'image': 'assets/tasyakuran.jpg'},
    {'name': 'Buka Bersama', 'image': 'assets/bukabersama.jpg'},
    {'name': 'Paket Nasi Kotak', 'image': 'assets/nasikotak.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        244,
        229,
        229,
      ), // 🎨 Background peach pastel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1, // kotak persegi
          ),

          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MenuListPage(categoryName: category['name']!),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(category['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  category['name']!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
