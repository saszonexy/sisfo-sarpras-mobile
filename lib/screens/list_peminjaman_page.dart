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
  late Animation<double> _slideAnimation;

  // Modern Color Palette
  static const primaryPurple = Color(0xFF8B5CF6);
  static const secondaryIndigo = Color(0xFF6366F1);
  static const accentTeal = Color(0xFF14B8A6);
  static const successEmerald = Color(0xFF10B981);
  static const warningAmber = Color(0xFFF59E0B);
  static const errorRose = Color(0xFFF43F5E);
  static const backgroundSlate = Color(0xFFF8FAFC);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textSlate900 = Color(0xFF0F172A);
  static const textSlate600 = Color(0xFF475569);
  static const textSlate400 = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchPeminjaman();
    _searchController.addListener(_filterPeminjaman);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
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
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal mengambil data peminjaman: $e')),
              ],
            ),
            backgroundColor: errorRose,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return warningAmber;
      case 'dikembalikan':
        return successEmerald;
      case 'terlambat':
        return errorRose;
      default:
        return textSlate400;
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
      backgroundColor: backgroundSlate,
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
                  colors: [primaryPurple, secondaryIndigo, accentTeal],
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
                  'Daftar Peminjaman',
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
                      colors: [primaryPurple, secondaryIndigo, accentTeal],
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
                        top: 40,
                        right: 20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
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
                          Icons.assignment_rounded,
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
                  onPressed: _fetchPeminjaman,
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
                if (!isLoadingPeminjaman && peminjamanList.isNotEmpty)
                  _buildBeautifulStatsCards(),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // List Content
          isLoadingPeminjaman
              ? SliverToBoxAdapter(child: _buildModernLoadingState())
              : filteredPeminjamanList.isEmpty
                  ? SliverToBoxAdapter(child: _buildModernEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final peminjaman = filteredPeminjamanList[index];
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
                              opacity: _slideAnimation,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: _buildModernPeminjamanCard(peminjaman),
                              ),
                            ),
                          );
                        },
                        childCount: filteredPeminjamanList.length,
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
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari peminjaman atau barang...',
          hintStyle: TextStyle(color: textSlate400, fontSize: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, secondaryIndigo],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.search_rounded, color: Colors.white, size: 20),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: textSlate400),
                  onPressed: () {
                    _searchController.clear();
                    _filterPeminjaman();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(color: textSlate900, fontSize: 16),
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
              'semua', 'Semua', Icons.list_rounded, primaryPurple),
          _buildModernFilterChip(
              'dipinjam', 'Dipinjam', Icons.access_time_rounded, warningAmber),
          _buildModernFilterChip('dikembalikan', 'Dikembalikan',
              Icons.check_circle_rounded, successEmerald),
          _buildModernFilterChip(
              'terlambat', 'Terlambat', Icons.warning_rounded, errorRose),
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
            _filterPeminjaman();
          });
        },
        backgroundColor: cardWhite,
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : textSlate600,
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
    final totalPeminjaman = peminjamanList.length;
    final dipinjam = peminjamanList
        .where((p) => p.status.toLowerCase() == 'dipinjam')
        .length;
    final dikembalikan = peminjamanList
        .where((p) => p.status.toLowerCase() == 'dikembalikan')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _buildGlassStatCard('Total', totalPeminjaman.toString(),
                  primaryPurple, Icons.assignment_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildGlassStatCard('Dipinjam', dipinjam.toString(),
                  warningAmber, Icons.access_time_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildGlassStatCard('Selesai', dikembalikan.toString(),
                  successEmerald, Icons.check_circle_rounded)),
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
              color: textSlate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textSlate600,
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
                    color: primaryPurple.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat data peminjaman...',
              style: TextStyle(
                fontSize: 16,
                color: textSlate600,
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
              color: textSlate400.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                Icon(Icons.assignment_outlined, size: 64, color: textSlate400),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada peminjaman ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textSlate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba kata kunci lain atau ubah filter'
                : 'Belum ada data peminjaman tersedia',
            style: TextStyle(color: textSlate600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernPeminjamanCard(Peminjaman peminjaman) {
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
            // Modern Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPurple, secondaryIndigo],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peminjaman.namaBarang ?? 'Barang tidak diketahui',
                        style: const TextStyle(
                          // tambahkan const biar warning hilang
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textSlate900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${peminjaman.idPeminjaman}', // <-- cukup begini
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSlate400,
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
                color: backgroundSlate,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildModernDetailRow('stok', '${peminjaman.stok} unit',
                      Icons.numbers_rounded, accentTeal),
                  const SizedBox(height: 12),
                  _buildModernDetailRow(
                      'Tanggal Pinjam',
                      peminjaman.tanggalPinjam
                          .toLocal()
                          .toString()
                          .split(' ')[0],
                      Icons.calendar_today_rounded,
                      warningAmber),
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
                          ? successEmerald
                          : textSlate400),
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
                  color: secondaryIndigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: secondaryIndigo.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 16, color: secondaryIndigo),
                        const SizedBox(width: 8),
                        Text(
                          'Keterangan:',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryIndigo,
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
                        color: textSlate900,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Modern Return Button
            if (peminjaman.status.toLowerCase() == 'dipinjam') ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [successEmerald, successEmerald.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: successEmerald.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FormPengembalianPage(peminjaman: peminjaman),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_return_rounded,
                      color: Colors.white),
                  label: const Text(
                    'Kembalikan Barang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
            color: textSlate600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textSlate900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
