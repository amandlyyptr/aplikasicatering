import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class KelolaAkunPage extends StatefulWidget {
  @override
  _KelolaAkunPageState createState() => _KelolaAkunPageState();
}

class _KelolaAkunPageState extends State<KelolaAkunPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndLoadUser();
  }

  Future<void> _initFirebaseAndLoadUser() async {
    // Pastikan Firebase sudah diinisialisasi
    await Firebase.initializeApp();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    _emailController.text = user.email ?? '';

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _namaController.text = data['nama'] ?? '';
        _teleponController.text = data['telepon'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _tanggalLahirController.text = data['tanggal_lahir'] ?? '';
      } else {
        // Jika data belum ada, bisa inisialisasi dari user Firebase Auth
        _namaController.text = user.displayName ?? '';
      }
    } catch (e) {
      // Jika error saat load, bisa ditangani di sini
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal load data user: $e')));
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _selectTanggalLahir() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_tanggalLahirController.text) ??
          DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User belum login')));
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'nama': _namaController.text,
        'email': _emailController.text,
        'telepon': _teleponController.text,
        'alamat': _alamatController.text,
        'tanggal_lahir': _tanggalLahirController.text,
      });

      // Update nama user di Firebase Auth (optional)
      await user.updateDisplayName(_namaController.text);
      if (_emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data berhasil disimpan')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan data: $e')));
    }
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User belum login')));
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'nama': _namaController.text,
        'email': _emailController.text,
        'telepon': _teleponController.text,
        'alamat': _alamatController.text,
        'tanggal_lahir': _tanggalLahirController.text,
      });

      await user.updateDisplayName(_namaController.text);
      if (_emailController.text != user.email) {
        await user.updateEmail(_emailController.text);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data berhasil diupdate')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update data: $e')));
    }
  }

  Future<void> _deleteData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User belum login')));
      return;
    }

    try {
      await _firestore.collection('users').doc(user.uid).delete();

      // Optional: hapus user dari Firebase Auth (berhati-hati)
      // await user.delete();

      _clearFields();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data berhasil dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus data: $e')));
    }
  }

  void _clearFields() {
    _namaController.clear();
    _emailController.clear();
    _teleponController.clear();
    _alamatController.clear();
    _tanggalLahirController.clear();
  }

  String _getInisial() {
    final email = _emailController.text;
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color.fromARGB(255, 192, 9, 9);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Akun'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar dengan inisial email
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color.fromARGB(255, 255, 63, 63),
                        child: Text(
                          _getInisial(),
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildInputField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        icon: Icons.person,
                      ),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildInputField(
                        controller: _tanggalLahirController,
                        label: 'Tanggal Lahir',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: _selectTanggalLahir,
                        hintText: 'yyyy-MM-dd',
                      ),
                      _buildInputField(
                        controller: _teleponController,
                        label: 'Nomor Telepon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildInputField(
                        controller: _alamatController,
                        label: 'Alamat',
                        icon: Icons.home,
                        maxLines: 2,
                      ),
                      // Ganti bagian tombol dengan yang berikut
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceEvenly, // Menyusun tombol secara horizontal
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveProfile,
                              icon: Icon(Icons.save),
                              label: Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  178,
                                  9,
                                  9,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // Jarak antar tombol
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _updateData,
                              icon: Icon(Icons.update),
                              label: Text('Update'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  65,
                                  96,
                                  255,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // Jarak antar tombol
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _deleteData,
                              icon: Icon(Icons.delete),
                              label: Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  238,
                                  57,
                                  57,
                                ),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          border: OutlineInputBorder(),
          hintText: hintText,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label wajib diisi';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Format email tidak valid';
          }
          return null;
        },
      ),
    );
  }
}
