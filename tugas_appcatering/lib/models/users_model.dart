class User {
  int? id;
  String nama;
  String email;
  String? telepon;
  String? alamat;
  String? tanggalLahir;

  User({
    this.id,
    required this.nama,
    required this.email,
    this.telepon,
    this.alamat,
    this.tanggalLahir,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
        nama: json['nama'] ?? '',
        email: json['email'] ?? '',
        telepon: json['telepon'],
        alamat: json['alamat'],
        tanggalLahir: json['tanggal_lahir'],
      );

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'email': email,
        'telepon': telepon,
        'alamat': alamat,
        'tanggal_lahir': tanggalLahir,
      };
}
