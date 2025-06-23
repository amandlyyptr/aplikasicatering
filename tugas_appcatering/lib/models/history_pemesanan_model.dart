class HistoryPemesanan {
  final String id;
  final String namaMakanan;
  final String waktuPesan;

  HistoryPemesanan({
    required this.id,
    required this.namaMakanan,
    required this.waktuPesan,
  });

  factory HistoryPemesanan.fromJson(Map<String, dynamic> json) {
    return HistoryPemesanan(
      id: json['id'].toString(),
      namaMakanan: json['nama_makanan'] ?? '',
      waktuPesan: json['waktu_pesan'] ?? '',
    );
  }
}
