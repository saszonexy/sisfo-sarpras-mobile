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

class _ListBarangPageState extends State<ListBarangPage>
    with TickerProviderStateMixin {
  late ApiService apiService;
  List<Barang> barangList = [];
  List<Barang> filteredBarangList = [];
  bool isLoadingBarang = true;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedCategory = 'semua';

  // Modern Color Palette
  static const primaryCyan = Color(0xFF06B6D4);
  static const secondaryTeal = Color(0xFF14B8A6);
  static const accentEmerald = Color(0xFF10B981);
  static const warningAmber = Color(0xFFF59E0B);
  static const errorRose = Color(0xFFF43F5E);
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
    _fetchBarang();
    _searchController.addListener(_filterBarang);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBarang() async {
    setState(() => isLoadingBarang = true);
    try {
      final data = await apiService.fetchBarang();
      setState(() {
        barangList = data;
        filteredBarangList = data;
        isLoadingBarang = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoadingBarang = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Gagal mengambil data barang: $e')),
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

  void _filterBarang() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBarangList = barangList.where((barang) {
        final matchesSearch = barang.namaBarang.toLowerCase().contains(query) ||
            barang.kategori.toLowerCase().contains(query);
        final matchesCategory = selectedCategory == 'semua' ||
            barang.kategori.toLowerCase() == selectedCategory.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Color _getStatusColor(int tersedia) {
    if (tersedia == 0) return errorRose;
    if (tersedia <= 5) return warningAmber;
    return accentEmerald;
  }

  String _getStatusText(int tersedia) {
    if (tersedia == 0) return 'Habis';
    if (tersedia <= 5) return 'Sedikit';
    return 'Tersedia';
  }

  IconData _getStatusIcon(int tersedia) {
    if (tersedia == 0) return Icons.remove_circle_rounded;
    if (tersedia <= 5) return Icons.warning_rounded;
    return Icons.check_circle_rounded;
  }

  List<String> _getUniqueCategories() {
    final categories = barangList.map((b) => b.kategori).toSet().toList();
    categories.sort();
    return ['semua', ...categories];
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
                  colors: [primaryCyan, secondaryTeal, accentEmerald],
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
                  'Inventaris Barang',
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
                      colors: [primaryCyan, secondaryTeal, accentEmerald],
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 40,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 70,
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
                  onPressed: _fetchBarang,
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

                // Category Filter
                if (!isLoadingBarang && barangList.isNotEmpty)
                  _buildCategoryFilter(),

                const SizedBox(height: 20),

                // Beautiful Stats Cards
                if (!isLoadingBarang && barangList.isNotEmpty)
                  _buildBeautifulStatsCards(),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // List Content
          isLoadingBarang
              ? SliverToBoxAdapter(child: _buildModernLoadingState())
              : filteredBarangList.isEmpty
                  ? SliverToBoxAdapter(child: _buildModernEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final barang = filteredBarangList[index];
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
                                child: _buildModernBarangCard(barang),
                              ),
                            ),
                          );
                        },
                        childCount: filteredBarangList.length,
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
            color: primaryCyan.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari barang atau kategori...',
          hintStyle: TextStyle(color: textLight, fontSize: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryCyan, secondaryTeal],
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
                    _filterBarang();
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

  Widget _buildCategoryFilter() {
    final categories = _getUniqueCategories();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category == 'semua' ? 'Semua' : category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                  _filterBarang();
                });
              },
              backgroundColor: cardWhite,
              selectedColor: primaryCyan,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : textMedium,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: isSelected ? primaryCyan : primaryCyan.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: isSelected ? 4 : 0,
              shadowColor: primaryCyan.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeautifulStatsCards() {
    final totalBarang = barangList.length;
    final tersedia = barangList.where((b) => b.tersedia > 0).length;
    final habis = barangList.where((b) => b.tersedia == 0).length;
    final sedikit =
        barangList.where((b) => b.tersedia > 0 && b.tersedia <= 5).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
              child: _buildGlassStatCard('Total', totalBarang.toString(),
                  primaryCyan, Icons.inventory_2_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildGlassStatCard('Tersedia', tersedia.toString(),
                  accentEmerald, Icons.check_circle_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildGlassStatCard('Sedikit', sedikit.toString(),
                  warningAmber, Icons.warning_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildGlassStatCard('Habis', habis.toString(), errorRose,
                  Icons.remove_circle_rounded)),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
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
                    color: primaryCyan.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryCyan),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat data barang...',
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
            child: Icon(Icons.inventory_2_outlined, size: 64, color: textLight),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada barang ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba kata kunci lain atau ubah kategori'
                : 'Belum ada data barang tersedia',
            style: TextStyle(color: textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernBarangCard(Barang barang) {
    final statusColor = _getStatusColor(barang.tersedia);
    final statusText = _getStatusText(barang.tersedia);
    final statusIcon = _getStatusIcon(barang.tersedia);

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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Modern Image Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryCyan.withOpacity(0.1),
                    secondaryTeal.withOpacity(0.1)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryCyan.withOpacity(0.2)),
              ),
              child: barang.gambar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        barang.gambar!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryCyan, secondaryTeal],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.inventory_2_rounded,
                                color: Colors.white, size: 32),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryCyan, secondaryTeal],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.inventory_2_rounded,
                          color: Colors.white, size: 32),
                    ),
            ),
            const SizedBox(width: 20),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.namaBarang,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: purpleAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: purpleAccent.withOpacity(0.2)),
                    ),
                    child: Text(
                      barang.kategori,
                      style: TextStyle(
                        fontSize: 12,
                        color: purpleAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.inventory_rounded,
                          size: 16, color: textMedium),
                      const SizedBox(width: 6),
                      Text(
                        'Stok: ${barang.tersedia}',
                        style: TextStyle(
                          fontSize: 14,
                          color: textMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 20, color: statusColor),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
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
      ),
    );
  }
}
