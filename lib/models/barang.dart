class Barang {
  final int idBarang;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final int jumlah;
  final int tersedia;
  final String kondisi;
  final String lokasi;
  final String? gambar;

  Barang({
    required this.idBarang,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    required this.jumlah,
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
      jumlah: json['jumlah'] ?? 0,
      tersedia: json['tersedia'] ?? 0,
      kondisi: json['kondisi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      gambar: json['gambar'], // sudah berupa URL lengkap dari backend
    );
  }
}
