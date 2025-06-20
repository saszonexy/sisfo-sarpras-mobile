class Barang {
  final int idBarang;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final int stok;
  final int tersedia;
  final String kondisi;
  final String lokasi;
  final String? gambar;

  Barang({
    required this.idBarang,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.stok,
    required this.tersedia,
    required this.kondisi,
    required this.lokasi,
    this.gambar,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      idBarang: json['id_barang'] ?? 0,
      kodeBarang: json['kode_barang'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? '',
      stok: json['stok'] ?? 0,
      tersedia: json['tersedia'] ?? 0,
      kondisi: json['kondisi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      gambar: json['gambar'], // sudah berupa URL lengkap dari backend
    );
  }
}
