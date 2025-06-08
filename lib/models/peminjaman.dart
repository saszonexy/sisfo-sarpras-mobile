class Peminjaman {
  final int idPeminjaman;
  final int idUser;
  final int idBarang;
  final int jumlah;
  final DateTime tanggalPinjam;
  final DateTime? tanggalKembali;
  final String? keterangan;
  final String status;
  final String? labelStatus;
  final String? namaBarang;

  Peminjaman({
    required this.idPeminjaman,
    required this.idUser,
    required this.idBarang,
    required this.jumlah,
    required this.tanggalPinjam,
    this.tanggalKembali,
    this.keterangan,
    required this.status,
    this.labelStatus,
    this.namaBarang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      idPeminjaman: json['id_peminjaman'] ?? 0,
      idUser: json['id_user'] ?? 0,
      idBarang: json['id_barang'] ?? 0,
      jumlah: json['jumlah'] ?? 0,
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: json['tanggal_kembali'] != null ? DateTime.tryParse(json['tanggal_kembali']) : null,
      keterangan: json['keterangan'],
      status: json['status'] ?? '',
      labelStatus: json['label_status'],
      namaBarang: json['barang'] != null && json['barang']['nama_barang'] != null
          ? json['barang']['nama_barang']
          : null,
    );
  }
}