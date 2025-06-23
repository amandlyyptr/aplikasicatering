class Menu {
  final String id;
  final String namaMenu;
  final String deskripsi;
  final String harga;
  final String imageUrl;
  final String namaCatering;

  Menu({
    required this.id,
    required this.namaMenu,
    required this.deskripsi,
    required this.harga,
    required this.imageUrl,
    required this.namaCatering,
  });

  factory Menu.fromMap(String id, Map data) {
    return Menu(
      id: id,
      namaMenu: data['namaMenu'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      harga: data['harga'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      namaCatering: data['namaCatering'] ?? '',
    );
  }
}
