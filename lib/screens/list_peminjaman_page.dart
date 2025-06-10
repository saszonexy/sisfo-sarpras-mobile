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

class _ListPeminjamanPageState extends State<ListPeminjamanPage>
    with TickerProviderStateMixin {
  late ApiService apiService;
  List<Peminjaman> peminjamanList = [];
  List<Peminjaman> filteredPeminjamanList = [];
  bool isLoadingPeminjaman = true;
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

    _fetchPeminjaman();
    _searchController.addListener(_filterPeminjaman);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPeminjaman() async {
    setState(() => isLoadingPeminjaman = true);
    try {
      final data = await apiService.fetchPeminjaman();
      setState(() {
        peminjamanList = data;
        filteredPeminjamanList = data;
        isLoadingPeminjaman = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoadingPeminjaman = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data peminjaman: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _filterPeminjaman() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPeminjamanList = peminjamanList.where((peminjaman) {
        final matchesSearch =
            peminjaman.namaBarang?.toLowerCase().contains(query) ?? false;
        final matchesFilter = selectedFilter == 'semua' ||
            peminjaman.status.toLowerCase() == selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _navigateToPengembalian(Peminjaman peminjaman) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FormPengembalianPage(peminjaman: peminjaman),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
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
        return Icons.help_outline;
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
                        'Daftar Peminjaman',
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
                        onPressed: _fetchPeminjaman,
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
                    hintText: 'Cari peminjaman...',
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
              if (!isLoadingPeminjaman && peminjamanList.isNotEmpty)
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
                        peminjamanList.length.toString(),
                        Icons.assignment,
                        const Color(0xFF4facfe),
                      ),
                      _buildStatItem(
                        'Dipinjam',
                        peminjamanList
                            .where((p) => p.status.toLowerCase() == 'dipinjam')
                            .length
                            .toString(),
                        Icons.schedule,
                        const Color(0xFFffa726),
                      ),
                      _buildStatItem(
                        'Selesai',
                        peminjamanList
                            .where(
                                (p) => p.status.toLowerCase() == 'dikembalikan')
                            .length
                            .toString(),
                        Icons.check_circle,
                        const Color(0xFF43e97b),
                      ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: isLoadingPeminjaman
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
                                'Memuat data peminjaman...',
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
                        onRefresh: _fetchPeminjaman,
                        color: Colors.white,
                        backgroundColor: const Color(0xFF4facfe),
                        child: filteredPeminjamanList.isEmpty
                            ? _buildEmptyState()
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  itemCount: filteredPeminjamanList.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final peminjaman =
                                        filteredPeminjamanList[index];
                                    return _buildPeminjamanCard(
                                        peminjaman, index);
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
            _filterPeminjaman();
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
                Icons.assignment_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tidak ada peminjaman ditemukan',
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
                  : 'Belum ada data peminjaman tersedia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeminjamanCard(Peminjaman peminjaman, int index) {
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
                      Icons.date_range,
                      'Tanggal Pinjam',
                      peminjaman.tanggalPinjam
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.assignment_return,
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

                    // Return Button
                    if (peminjaman.status.toLowerCase() == 'dipinjam') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43e97b).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _navigateToPengembalian(peminjaman),
                            icon: const Icon(Icons.assignment_return,
                                color: Colors.white),
                            label: const Text(
                              'Kembalikan Barang',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
