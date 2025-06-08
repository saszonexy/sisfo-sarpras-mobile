import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ListBarangPage extends StatefulWidget {
  const ListBarangPage({super.key});

  @override
  State<ListBarangPage> createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> {
  late ApiService apiService;
  List<Barang> barangList = [];
  bool isLoadingBarang = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchBarang();
  }

  Future<void> _fetchBarang() async {
    setState(() => isLoadingBarang = true);
    try {
      final data = await apiService.fetchBarang();
      setState(() {
        barangList = data;
        isLoadingBarang = false;
      });
    } catch (e) {
      setState(() => isLoadingBarang = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data barang: $e')),
        );
      }
    }
  }

  Color _getAvailabilityColor(int tersedia) {
    if (tersedia == 0) return Colors.red;
    if (tersedia <= 5) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoadingBarang
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBarang,
              child: barangList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data barang',
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
                      itemCount: barangList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final barang = barangList[index];
                        final availabilityColor = _getAvailabilityColor(barang.tersedia);

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
                            child: Row(
                              children: [
                                // Image or Icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: barang.gambar != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            barang.gambar!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.inventory_2_outlined,
                                                size: 30,
                                                color: Colors.grey[600],
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.inventory_2_outlined,
                                          size: 30,
                                          color: Colors.grey[600],
                                        ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        barang.namaBarang,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            barang.kategori,
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
                                            Icons.inventory_outlined,
                                            size: 16,
                                            color: availabilityColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tersedia: ${barang.tersedia}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: availabilityColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Availability Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: availabilityColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    barang.tersedia == 0
                                        ? 'Habis'
                                        : barang.tersedia <= 5
                                            ? 'Sedikit'
                                            : 'Tersedia',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: availabilityColor,
                                    ),
                                  ),
                                ),
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