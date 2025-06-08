import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/peminjaman.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RiwayatPeminjamanPage extends StatefulWidget {
  const RiwayatPeminjamanPage({super.key});

  @override
  State<RiwayatPeminjamanPage> createState() => _RiwayatPeminjamanPageState();
}

class _RiwayatPeminjamanPageState extends State<RiwayatPeminjamanPage> {
  late ApiService apiService;
  List<Peminjaman> riwayatPeminjamanList = [];
  bool isLoadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchRiwayatPeminjaman();
  }

  Future<void> _fetchRiwayatPeminjaman() async {
    setState(() => isLoadingRiwayat = true);
    try {
      final data = await apiService.fetchRiwayatPeminjaman();
      setState(() {
        riwayatPeminjamanList = data;
        isLoadingRiwayat = false;
      });
    } catch (e) {
      setState(() => isLoadingRiwayat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil riwayat peminjaman: $e'))
      );
    }
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return Icons.schedule;
      case 'dikembalikan':
        return Icons.check_circle;
      case 'terlambat':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoadingRiwayat
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRiwayatPeminjaman,
              child: riwayatPeminjamanList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat peminjaman',
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
                      itemCount: riwayatPeminjamanList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pinjam = riwayatPeminjamanList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with item name and status
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pinjam.namaBarang ?? 'Barang tidak diketahui',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                                        color: _getStatusColor(pinjam.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(pinjam.status),
                                            size: 14,
                                            color: _getStatusColor(pinjam.status),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            pinjam.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _getStatusColor(pinjam.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Details in simple rows
                                _buildDetailRow(
                                  Icons.inventory,
                                  'Jumlah',
                                  '${pinjam.jumlah}',
                                ),
                                _buildDetailRow(
                                  Icons.calendar_today,
                                  'Tgl Pinjam',
                                  pinjam.tanggalPinjam.toLocal().toString().split(' ')[0],
                                ),
                                _buildDetailRow(
                                  Icons.event_available,
                                  'Tgl Kembali',
                                  pinjam.tanggalKembali != null 
                                    ? pinjam.tanggalKembali!.toLocal().toString().split(' ')[0] 
                                    : '-',
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
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontStyle: FontStyle.italic,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}