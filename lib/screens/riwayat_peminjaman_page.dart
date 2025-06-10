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

class _RiwayatPeminjamanPageState extends State<RiwayatPeminjamanPage>
    with TickerProviderStateMixin {
  late ApiService apiService;
  List<Peminjaman> riwayatPeminjamanList = [];
  List<Peminjaman> filteredRiwayatList = [];
  bool isLoadingRiwayat = true;
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'semua';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fetchRiwayatPeminjaman();
    _searchController.addListener(_filterRiwayat);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRiwayatPeminjaman() async {
    setState(() => isLoadingRiwayat = true);
    try {
      final data = await apiService.fetchRiwayatPeminjaman();
      setState(() {
        riwayatPeminjamanList = data;
        filteredRiwayatList = data;
        isLoadingRiwayat = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoadingRiwayat = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil riwayat peminjaman: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _filterRiwayat() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRiwayatList = riwayatPeminjamanList.where((peminjaman) {
        final matchesSearch =
            peminjaman.namaBarang?.toLowerCase().contains(query) ?? false;
        final matchesFilter = selectedFilter == 'semua' ||
            peminjaman.status.toLowerCase() == selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return const Color(0xFFffa726);
      case 'dikembalikan':
        return const Color(0xFF43e97b);
      case 'terlambat':
        return const Color(0xFFf5576c);
      default:
        return const Color(0xFF9e9e9e);
    }
  }

  Gradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return const LinearGradient(
          colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
        );
      case 'dikembalikan':
        return const LinearGradient(
          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
        );
      case 'terlambat':
        return const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFe0e0e0), Color(0xFFbdbdbd)],
        );
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Riwayat Peminjaman',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchRiwayatPeminjaman,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari riwayat peminjaman...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('semua', 'Semua'),
                    _buildFilterChip('dipinjam', 'Dipinjam'),
                    _buildFilterChip('dikembalikan', 'Dikembalikan'),
                    _buildFilterChip('terlambat', 'Terlambat'),
                  ],
                ),
              ),

              // Stats Row
              if (!isLoadingRiwayat && riwayatPeminjamanList.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total',
                        riwayatPeminjamanList.length.toString(),
                        Icons.history,
                        const Color(0xFF4facfe),
                      ),
                      _buildStatItem(
                        'Selesai',
                        riwayatPeminjamanList
                            .where(
                                (p) => p.status.toLowerCase() == 'dikembalikan')
                            .length
                            .toString(),
                        Icons.check_circle,
                        const Color(0xFF43e97b),
                      ),
                      _buildStatItem(
                        'Aktif',
                        riwayatPeminjamanList
                            .where((p) => p.status.toLowerCase() == 'dipinjam')
                            .length
                            .toString(),
                        Icons.schedule,
                        const Color(0xFFffa726),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: isLoadingRiwayat
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat riwayat peminjaman...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchRiwayatPeminjaman,
                        color: Colors.white,
                        backgroundColor: const Color(0xFF4facfe),
                        child: filteredRiwayatList.isEmpty
                            ? _buildEmptyState()
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: filteredRiwayatList.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final peminjaman =
                                        filteredRiwayatList[index];
                                    return _buildRiwayatCard(peminjaman, index);
                                  },
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
            _filterRiwayat();
          });
        },
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: const Color(0xFF4facfe),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada riwayat peminjaman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Mulai pinjam barang untuk melihat riwayat',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Peminjaman peminjaman, int index) {
    final statusColor = _getStatusColor(peminjaman.status);
    final statusGradient = _getStatusGradient(peminjaman.status);
    final statusIcon = _getStatusIcon(peminjaman.status);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            statusIcon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            peminjaman.namaBarang ?? 'Barang tidak diketahui',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: statusGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            peminjaman.status,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Details
                    _buildDetailRow(
                      Icons.numbers,
                      'Jumlah',
                      peminjaman.jumlah.toString(),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Tanggal Pinjam',
                      peminjaman.tanggalPinjam
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.event_available,
                      'Tanggal Kembali',
                      peminjaman.tanggalKembali
                              ?.toLocal()
                              .toString()
                              .split(' ')[0] ??
                          'Belum dikembalikan',
                    ),

                    // Notes
                    if (peminjaman.keterangan != null &&
                        peminjaman.keterangan!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keterangan:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              peminjaman.keterangan!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
