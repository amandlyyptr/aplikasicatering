import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'add_product_page.dart';
import 'account_page.dart';
import '../pages/home_tab.dart';
import '../pages/search_tab.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  late Stream<ConnectivityResult> _connectivityStream;

  late final List<Widget> _pages;

  final List<String> _titles = [
    "Beranda",
    "Cari Menu",
    "Tambah Produk",
    "Akun Saya",
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.add_box,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(),
      SearchTab(),
      AddProductPage(),
      AccountPage(username: widget.username),
    ];
    _checkConnection();

    // Initialize the connectivity stream
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      if (!_isOnline) {
        _showConnectionAlert();
      }
    });
  }

  Future<void> _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
    if (!_isOnline) {
      _showConnectionAlert();
    }
  }

  void _showConnectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Koneksi Internet"),
          content: Text(
            "Tidak ada koneksi internet. Silakan periksa pengaturan Wi-Fi atau data seluler Anda.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _checkConnection(); // Cek koneksi saat tab diubah
  }

  @override
  void dispose() {
    // Clean up the connectivity listener if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          !_isOnline
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Tidak ada koneksi internet",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkConnection,
                      child: Text("Coba Lagi"),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      color: Color(0xFF800000), // Mengubah warna latar belakang
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _icons[_selectedIndex],
                            size: 30,
                            color: Colors.white, // Warna ikon
                          ),
                          SizedBox(width: 8),
                          Text(
                            _titles[_selectedIndex],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Warna teks
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: _pages[_selectedIndex]),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 255, 80, 80),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Tambah"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
