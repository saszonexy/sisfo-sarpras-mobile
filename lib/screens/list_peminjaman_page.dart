import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/peminjaman.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'form_pengembalian_page.dart';

class ListPeminjamanPage extends StatefulWidget {
  const ListPeminjamanPage({super.key});

  @override
  State<ListPeminjamanPage> createState() => _ListPeminjamanPageState();
}

class _ListPeminjamanPageState extends State<ListPeminjamanPage> {
  late ApiService apiService;
  List<Peminjaman> peminjamanList = [];
  bool isLoadingPeminjaman = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchPeminjaman();
  }

  Future<void> _fetchPeminjaman() async {
    setState(() => isLoadingPeminjaman = true);
    try {
      final data = await apiService.fetchPeminjaman();
      setState(() {
        peminjamanList = data;
        isLoadingPeminjaman = false;
      });
    } catch (e) {
      setState(() => isLoadingPeminjaman = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data peminjaman: $e')),
        );
      }
    }
  }

  void _navigateToPengembalian(Peminjaman peminjaman) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPengembalianPage(peminjaman: peminjaman),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return Colors.orange;
      case 'dikembalikan':
        return Colors.green;
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoadingPeminjaman
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPeminjaman,
              child: peminjamanList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data peminjaman',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: peminjamanList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final pinjam = peminjamanList[index];
                        final statusColor = _getStatusColor(pinjam.status);

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pinjam.namaBarang ?? 'Barang tidak diketahui',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        pinjam.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                Row(
                                  children: [
                                    Icon(
                                      Icons.numbers,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Jumlah: ${pinjam.jumlah}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pinjam: ${pinjam.tanggalPinjam.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_return,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Kembali: ${pinjam.tanggalKembali != null ? pinjam.tanggalKembali!.toLocal().toString().split(' ')[0] : '-'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),

                                if (pinjam.keterangan != null && pinjam.keterangan!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      pinjam.keterangan!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],

                                if (pinjam.status == 'dipinjam') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _navigateToPengembalian(pinjam),
                                      icon: const Icon(Icons.assignment_return),
                                      label: const Text('Kembalikan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}