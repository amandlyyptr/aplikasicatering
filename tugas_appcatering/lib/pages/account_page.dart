import 'package:flutter/material.dart';
import 'package:tugas_appcatering/pages/histori_pesanan_page.dart';
import 'kelola_akun_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  final String username;

  AccountPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 224, 224),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Mengurangi padding
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10), // Mengurangi jarak
                      CircleAvatar(
                        radius: 40, // Mengurangi ukuran avatar
                        backgroundColor: const Color.fromARGB(255, 166, 0, 0),
                        child: Icon(
                          Icons.person,
                          size: 40, // Mengurangi ukuran ikon
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hai, $username!",
                        style: TextStyle(
                          fontSize: 20, // Mengurangi ukuran font
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Hello, Welcome!",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  icon: Icons.settings,
                  title: 'Kelola Akun',
                  color: const Color.fromARGB(255, 245, 240, 240),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KelolaAkunPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.history,
                  title: 'Histori Pesanan',
                  color: const Color.fromARGB(255, 245, 243, 243),
                  onTap: () async {
                    String? uid = FirebaseAuth.instance.currentUser?.uid;

                    if (uid != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPesananPage(uid: uid),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User  belum login')),
                      );
                    }
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  color: const Color.fromARGB(255, 239, 238, 238),
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "Tentang Usaha Kamu",
                  style: TextStyle(
                    fontSize: 14, // Mengurangi ukuran font
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12), // Mengurangi padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🍱 Info Tentang Kami 🍱",
                        style: TextStyle(
                          fontSize: 14, // Mengurangi ukuran font
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 187, 21, 21),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Melayani dengan cinta dan rasa. Kami hadir untuk menyempurnakan setiap momen spesialmu dengan hidangan terbaik buatan rumah.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Terima kasih sudah mempercayakan kepada kami",
                        style: TextStyle(
                          fontSize: 11, // Mengurangi ukuran font
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16), // Mengurangi margin
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, // Mengurangi padding horizontal
          vertical: 12, // Mengurangi padding vertikal
        ),
        leading: Icon(
          icon,
          size: 24,
          color: Colors.black87,
        ), // Mengurangi ukuran ikon
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ), // Mengurangi ukuran font
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
        ), // Mengurangi ukuran ikon
        onTap: onTap,
      ),
    );
  }
}
