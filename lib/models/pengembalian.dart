class Pengembalian {
  final int idPengembalian;
  final int idPeminjaman;
  final DateTime tanggalKembali;
  final String keterangan;
  final String labelStatus;

  Pengembalian({
    required this.idPengembalian,
    required this.idPeminjaman,
    required this.tanggalKembali,
    required this.keterangan,
    required this.labelStatus,
  });

  // Convert a JSON object into a Pengembalian instance
  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      idPengembalian: json['id_pengembalian'],
      idPeminjaman: json['id_peminjaman'],
      tanggalKembali: DateTime.parse(json['tanggal_kembali']),
      keterangan: json['keterangan'] ?? '',
      labelStatus: json['label_status'],
    );
  }

  // Convert a Pengembalian instance into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id_pengembalian': idPengembalian,
      'id_peminjaman': idPeminjaman,
      'tanggal_kembali': tanggalKembali.toIso8601String(),
      'keterangan': keterangan,
      'label_status': labelStatus,
    };
  }
}
