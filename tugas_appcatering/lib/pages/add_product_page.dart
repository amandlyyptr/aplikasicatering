import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;
  final String? docId;

  AddProductPage({this.existingData, this.docId});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String? selectedJenis;
  String alamat = "";

  File? _image;
  Uint8List? _webImage;
  String? _gambarBase64;
  double? latitude;
  double? longitude;

  final List<String> jenisMakanan = [
    'Nikahan',
    'Harian',
    'Ulang Tahun',
    'Aqiqah',
    'Kantoran',
    'Tasyakuran',
    'Buka Bersama',
    'Paket Nasi Kotak',
  ];

  final TextEditingController namaCateringController = TextEditingController();
  final TextEditingController namaMenuController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController noWaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData!;
      print("Data yang diterima: $data"); // Debugging
      namaCateringController.text = data['namaCatering'] ?? '';
      namaMenuController.text = data['namaMenu'] ?? '';
      hargaController.text = data['harga']?.toString() ?? '';
      keteranganController.text = data['keterangan'] ?? '';

      noWaController.text = data['noWa'] ?? '';
      lokasiController.text = data['lokasi'] ?? '';
      selectedJenis = data['jenis'];
      _gambarBase64 = data['gambarBase64'];
      latitude = data['latitude'];
      longitude = data['longitude'];
      alamat = data['alamat'] ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        _getCurrentLocation(); // panggil di sini
      });
    });
  }

  void _showSnack(String message) {
    debugPrint("Menampilkan SnackBar: $message");
    Future.delayed(Duration(milliseconds: 100), () {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _showImageSourcePicker() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("Ambil dari Kamera"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Ambil dari Galeri"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();

    if (kIsWeb) {
      // 🌐 Web: cukup ambil gambar dari galeri dan baca bytes
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      ); // hanya gallery di web
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _gambarBase64 = base64Encode(bytes); // simpan sebagai base64
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar berhasil dipilih (Web)')),
        );
      } else {
        print('Tidak ada gambar yang dipilih (Web)');
      }
    } else {
      // 📱 Mobile
      if (source == ImageSource.gallery) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Izin galeri ditolak')));
          return;
        }
      } else if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Izin kamera ditolak')));
          return;
        }
      }

      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        print('Gambar dipilih: ${image.path}');
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          quality: 70,
        );

        if (compressedBytes == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal kompres gambar')));
          return;
        }

        setState(() {
          _image = File(image.path);
          _gambarBase64 = base64Encode(
            compressedBytes,
          ); // simpan sebagai base64
        });

        final result = await ImageGallerySaverPlus.saveImage(
          compressedBytes,
          quality: 100,
          name: "gambar_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result != null &&
            (result is Map && result['isSuccess'] == true ||
                result['filePath'] != null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gambar berhasil disimpan ke galeri')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan gambar ke galeri')),
          );
        }
      } else {
        print('Tidak ada gambar yang dipilih (Mobile)');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("Layanan lokasi tidak aktif. Aktifkan terlebih dahulu.");
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Izin lokasi ditolak");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack("Izin lokasi ditolak secara permanen. Buka pengaturan.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        alamat =
            "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}";

        setState(() {
          lokasiController.text = alamat; // <-- Set lokasi otomatis
        });
      }
    } catch (e) {
      _showSnack("Gagal mendapatkan lokasi: $e");
      setState(() {
        alamat = "Gagal mendapatkan lokasi";
        lokasiController.text = alamat;
      });
    }
  }

  void simpanProduk() async {
    final namaCatering = namaCateringController.text.trim();
    final namaMenu = namaMenuController.text.trim();
    final hargaText = hargaController.text.trim();
    final noWaText = noWaController.text.trim();
    final lokasi = lokasiController.text.trim();
    final keterangan = keteranganController.text.trim();

    final waRegex = RegExp(r'^0[0-9]{11}$');
    final angkaRegex = RegExp(r'^[0-9]+$');

    if (namaCatering.isEmpty ||
        namaMenu.isEmpty ||
        hargaText.isEmpty ||
        !angkaRegex.hasMatch(hargaText) ||
        int.tryParse(hargaText) == null ||
        int.parse(hargaText) < 0 ||
        selectedJenis == null ||
        selectedJenis!.isEmpty ||
        noWaText.isEmpty ||
        !waRegex.hasMatch(noWaText) ||
        lokasi.isEmpty ||
        keterangan.isEmpty ||
        _gambarBase64 == null ||
        _gambarBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pastikan semua field telah diisi dengan benar.\nNo WA harus 12 digit, angka, dan dimulai dari 0.",
          ),
        ),
      );
      return;
    }

    try {
      final uid =
          FirebaseAuth.instance.currentUser!.uid; // Ambil UID user yang login

      Map<String, dynamic> dataProduk = {
        'namaCatering': namaCatering,
        'namaMenu': namaMenu,
        'harga': int.parse(hargaText),
        'jenis': selectedJenis,
        'noWa': noWaText,
        'lokasi': lokasi,
        'keterangan': keterangan,
        'gambarBase64': _gambarBase64,
        'latitude': latitude,
        'longitude': longitude,
        'alamat': alamat,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': uid, // 🔥 TAMBAHKAN INI
      };

      if (widget.docId != null) {
        // Update produk yang sudah ada
        await FirebaseFirestore.instance
            .collection('produk')
            .doc(widget.docId)
            .update(dataProduk);

        final updateUrl = Uri.parse(
          'https://tugas-appcatering-default-rtdb.firebaseio.com/catering/${widget.docId}.json',
        );

        final response = await http.put(
          updateUrl,
          body: jsonEncode(dataProduk),
        );
        print("Realtime DB update response: ${response.statusCode}");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Produk berhasil diperbarui")));
        try {
          final controller = DefaultTabController.of(context);
          if (controller != null) {
            controller.animateTo(0);
          } else {
            Navigator.pop(context);
          }
        } catch (e) {
          Navigator.pop(context);
        }
      } else {
        // Simpan produk baru
        final firestoreRef =
            FirebaseFirestore.instance.collection('produk').doc();
        final firestoreId = firestoreRef.id;

        await firestoreRef.set({...dataProduk, 'idRealtimeDb': firestoreId});

        final realtimeUrl = Uri.parse(
          'https://tugas-appcatering-default-rtdb.firebaseio.com/catering/$firestoreId.json',
        );
        final realtimeResponse = await http.put(
          realtimeUrl,
          body: jsonEncode(dataProduk),
        );

        if (realtimeResponse.statusCode == 200) {
          await firestoreRef.update({'idRealtimeDb': firestoreId});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Produk berhasil disimpan")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal simpan ke Realtime Database")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan produk: $e")));
    }
  }

  void hapusProduk(BuildContext context, String docId) async {
    try {
      final firestoreDoc =
          await FirebaseFirestore.instance
              .collection('produk')
              .doc(docId)
              .get();
      final data = firestoreDoc.data();

      if (data == null) {
        print("❌ Dokumen Firestore tidak ditemukan");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Data tidak ditemukan di Firestore")),
        );
        return;
      }

      final encodedId = Uri.encodeComponent(docId);
      final deleteUrl = Uri.parse(
        'https://tugas-appcatering-default-rtdb.firebaseio.com/catering/$encodedId.json',
      );
      final response = await http.delete(deleteUrl);

      print("Status Kode Respon: ${response.statusCode}");
      print("Body Respon: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Realtime DB berhasil dihapus");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Produk berhasil dihapus")));
      } else {
        print("❌ Gagal hapus Realtime DB");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal hapus dari Realtime Database")),
        );
      }
    } catch (e) {
      print("❌ ERROR saat menghapus produk: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    namaCateringController.clear();
    namaMenuController.clear();
    hargaController.clear();
    keteranganController.clear();
    noWaController.clear();
    lokasiController.clear();
    setState(() {
      selectedJenis = null;
      _image = null;
      _webImage = null;
      _gambarBase64 = null;
      latitude = null;
      longitude = null;
      alamat = "";
    });
  }

  @override
  void dispose() {
    namaCateringController.dispose();
    namaMenuController.dispose();
    hargaController.dispose();
    keteranganController.dispose();
    noWaController.dispose();
    lokasiController.dispose();
    super.dispose();
  }

  void _showMapPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return MapPicker(
          initialLatitude: latitude ?? -6.200000, // Koordinat default
          initialLongitude: longitude ?? 106.816666, // Koordinat default
          onLocationSelected: (LatLng point) {
            setState(() {
              latitude = point.latitude;
              longitude = point.longitude;
              _getAddressFromLatLng();
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _getAddressFromLatLng() async {
    if (latitude != null && longitude != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          alamat =
              "${placemark.street}, ${placemark.locality}, ${placemark.country}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        186,
                        13,
                        13,
                      ), // Warna latar belakang gambar
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        _gambarBase64 == null
                            ? Center(
                              child: Text(
                                "Silahkan Pilih Gambar",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  fontSize: 18,
                                ),
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(_gambarBase64!),
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_album),
                  label: Text(
                    "Pilih Upload/ Ambil Gambar",
                    style: TextStyle(
                      color: Colors.white,
                    ), // Ubah warna teks di sini
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      216,
                      32,
                      32,
                    ), // Gantikan `primary`
                  ),
                  onPressed: _showImageSourcePicker,
                ),
                const SizedBox(height: 16),
                buildTextField(namaCateringController, "Nama Catering"),
                buildTextField(namaMenuController, "Nama Makanan/Minuman"),
                buildTextField(
                  hargaController,
                  "Harga",
                  keyboardType: TextInputType.number,
                ),
                buildTextField(keteranganController, "Keterangan"),
                buildDropdownJenis(),
                buildTextField(
                  noWaController,
                  "Nomor WhatsApp",
                  keyboardType: TextInputType.phone,
                ),
                buildTextField(lokasiController, "Lokasi"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("Simpan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          230,
                          54,
                          54,
                        ), // Gantikan `primary`
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          simpanProduk();
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.refresh),
                      label: Text("Reset"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Gantikan `primary`
                      ),
                      onPressed: _resetForm,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.cancel),
                      label: Text("Batal"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          214,
                          214,
                          214,
                        ), // Gantikan `primary`
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            (value) =>
                value == null || value.isEmpty ? "Field ini wajib diisi" : null,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: const Color.fromARGB(255, 9, 9, 9)),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget buildDropdownJenis() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Jenis Makanan",
          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 3, 3)),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        value: selectedJenis,
        items:
            jenisMakanan.map((String jenis) {
              return DropdownMenuItem<String>(value: jenis, child: Text(jenis));
            }).toList(),
        onChanged: (value) {
          setState(() {
            selectedJenis = value;
          });
        },
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Silakan pilih jenis makanan'
                    : null,
      ),
    );
  }
}

class MapPicker extends StatelessWidget {
  final double initialLatitude;
  final double initialLongitude;
  final Function(LatLng) onLocationSelected;

  MapPicker({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(initialLatitude, initialLongitude),
          zoom: 13.0,
          onTap: (tapPosition, point) {
            onLocationSelected(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
