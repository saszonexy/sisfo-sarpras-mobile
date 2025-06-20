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
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Modern Color Palette
  static const primaryTeal = Color(0xFF14B8A6);
  static const secondaryCyan = Color(0xFF06B6D4);
  static const accentEmerald = Color(0xFF10B981);
  static const warningOrange = Color(0xFFF97316);
  static const errorRed = Color(0xFFEF4444);
  static const purpleAccent = Color(0xFF8B5CF6);
  static const backgroundGray = Color(0xFFF8FAFC);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMedium = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchRiwayatPeminjaman();
    _searchController.addListener(_filterRiwayat);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal mengambil riwayat peminjaman: $e')),
              ],
            ),
            backgroundColor: errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
        return warningOrange;
      case 'dikembalikan':
        return accentEmerald;
      case 'terlambat':
        return errorRed;
      default:
        return textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return Icons.access_time_rounded;
      case 'dikembalikan':
        return Icons.check_circle_rounded;
      case 'terlambat':
        return Icons.warning_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryTeal, secondaryCyan, purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Riwayat Peminjaman',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryTeal, secondaryCyan, purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 30,
                        right: 20,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(45),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.history_rounded,
                          size: 80,
                          color: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _fetchRiwayatPeminjaman,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Modern Search Bar
                _buildModernSearchBar(),

                const SizedBox(height: 20),

                // Enhanced Filter Chips
                _buildEnhancedFilterChips(),

                const SizedBox(height: 20),

                // Beautiful Stats Cards
                if (!isLoadingRiwayat && riwayatPeminjamanList.isNotEmpty)
                  _buildBeautifulStatsCards(),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // List Content
          isLoadingRiwayat
              ? SliverToBoxAdapter(child: _buildModernLoadingState())
              : filteredRiwayatList.isEmpty
                  ? SliverToBoxAdapter(child: _buildModernEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final peminjaman = filteredRiwayatList[index];
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                                curve: Curves.easeOutCubic,
                              ),
                            )),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: _buildModernRiwayatCard(peminjaman),
                              ),
                            ),
                          );
                        },
                        childCount: filteredRiwayatList.length,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari riwayat peminjaman...',
          hintStyle: TextStyle(color: textLight, fontSize: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryTeal, secondaryCyan],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.search_rounded, color: Colors.white, size: 20),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: textLight),
                  onPressed: () {
                    _searchController.clear();
                    _filterRiwayat();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(color: textDark, fontSize: 16),
      ),
    );
  }

  Widget _buildEnhancedFilterChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildModernFilterChip(
              'semua', 'Semua', Icons.list_rounded, primaryTeal),
          _buildModernFilterChip(
              'dipinjam', 'Dipinjam', Icons.access_time_rounded, warningOrange),
          _buildModernFilterChip('dikembalikan', 'Dikembalikan',
              Icons.check_circle_rounded, accentEmerald),
          _buildModernFilterChip(
              'terlambat', 'Terlambat', Icons.warning_rounded, errorRed),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(
      String value, String label, IconData icon, Color color) {
    final isSelected = selectedFilter == value;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        avatar: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
            _filterRiwayat();
          });
        },
        backgroundColor: cardWhite,
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : textMedium,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: isSelected ? color : color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 4 : 0,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBeautifulStatsCards() {
    final totalRiwayat = riwayatPeminjamanList.length;
    final selesai = riwayatPeminjamanList
        .where((p) => p.status.toLowerCase() == 'dikembalikan')
        .length;
    final aktif = riwayatPeminjamanList
        .where((p) => p.status.toLowerCase() == 'dipinjam')
        .length;
    final terlambat = riwayatPeminjamanList
        .where((p) => p.status.toLowerCase() == 'terlambat')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildGlassStatCard('Total', totalRiwayat.toString(),
                      primaryTeal, Icons.history_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildGlassStatCard('Selesai', selesai.toString(),
                      accentEmerald, Icons.check_circle_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildGlassStatCard('Aktif', aktif.toString(),
                      warningOrange, Icons.access_time_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildGlassStatCard('Terlambat', terlambat.toString(),
                      errorRed, Icons.warning_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryTeal.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat riwayat peminjaman...',
              style: TextStyle(
                fontSize: 16,
                color: textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: textLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.history_outlined, size: 64, color: textLight),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada riwayat peminjaman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba kata kunci lain atau ubah filter'
                : 'Mulai pinjam barang untuk melihat riwayat',
            style: TextStyle(color: textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernRiwayatCard(Peminjaman peminjaman) {
    final statusColor = _getStatusColor(peminjaman.status);
    final statusIcon = _getStatusIcon(peminjaman.status);

    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header with Timeline Design
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryTeal, secondaryCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.history_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peminjaman.namaBarang ?? 'Barang tidak diketahui',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${peminjaman.idPeminjaman ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        peminjaman.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Modern Details Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildModernDetailRow('Jumlah', '${peminjaman.stok} unit',
                      Icons.numbers_rounded, purpleAccent),
                  const SizedBox(height: 12),
                  _buildModernDetailRow(
                      'Tanggal Pinjam',
                      peminjaman.tanggalPinjam
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      Icons.calendar_today_rounded,
                      warningOrange),
                  const SizedBox(height: 12),
                  _buildModernDetailRow(
                      'Tanggal Kembali',
                      peminjaman.tanggalKembali
                              ?.toLocal()
                              .toString()
                              .split(' ')[0] ??
                          'Belum dikembalikan',
                      Icons.event_available_rounded,
                      peminjaman.tanggalKembali != null
                          ? accentEmerald
                          : textLight),
                ],
              ),
            ),

            // Modern Notes
            if (peminjaman.keterangan != null &&
                peminjaman.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: secondaryCyan.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 16, color: secondaryCyan),
                        const SizedBox(width: 8),
                        Text(
                          'Keterangan:',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      peminjaman.keterangan!,
                      style: TextStyle(
                        fontSize: 14,
                        color: textDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
