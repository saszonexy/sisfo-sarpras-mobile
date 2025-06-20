import 'package:flutter/material.dart';
import '../models/barang.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class FormPengembalianManualPage extends StatefulWidget {
  const FormPengembalianManualPage({Key? key}) : super(key: key);

  @override
  State<FormPengembalianManualPage> createState() =>
      _FormPengembalianManualPageState();
}

class _FormPengembalianManualPageState extends State<FormPengembalianManualPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<Barang> barangList = [];
  Barang? selectedBarang;
  final _stokController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime tanggalKembali = DateTime.now();

  late ApiService apiService;
  bool isLoading = true;
  bool isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Modern Color Palette
  static const primaryViolet = Color(0xFF7C3AED);
  static const secondaryPurple = Color(0xFF8B5CF6);
  static const accentIndigo = Color(0xFF6366F1);
  static const successGreen = Color(0xFF10B981);
  static const warningOrange = Color(0xFFF59E0B);
  static const errorRed = Color(0xFFF43F5E);
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

    _loadData();
  }

  @override
  void dispose() {
    _stokController.dispose();
    _keteranganController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final data = await apiService.fetchBarangDipinjam();
      setState(() {
        barangList = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorRed : successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: tanggalKembali,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryViolet,
              onPrimary: Colors.white,
              surface: cardWhite,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => tanggalKembali = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || selectedBarang == null) {
      _showSnackBar('Lengkapi semua field yang diperlukan', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    final body = {
      'id_barang': selectedBarang!.idBarang,
      'stok': int.parse(_stokController.text),
      'tanggal_kembali': tanggalKembali.toIso8601String().split('T')[0],
      'keterangan': _keteranganController.text,
    };

    final success = await apiService.postPengembalianCustom(body);
    setState(() => isSubmitting = false);

    if (success) {
      _showSnackBar('Pengembalian berhasil diproses! 🎉');
      Navigator.pop(context);
    } else {
      _showSnackBar('Gagal memproses pengembalian', isError: true);
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
                  colors: [primaryViolet, secondaryPurple, accentIndigo],
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
                  'Pengembalian Manual',
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
                      colors: [primaryViolet, secondaryPurple, accentIndigo],
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
                          Icons.assignment_return_rounded,
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
                  onPressed: _loadData,
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: isLoading
                ? _buildModernLoadingState()
                : barangList.isEmpty
                    ? _buildModernEmptyState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                // Header Card with Animation
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -0.5),
                                    end: Offset.zero,
                                  ).animate(_slideAnimation),
                                  child: _buildHeaderCard(),
                                ),

                                const SizedBox(height: 24),

                                // Form Fields Card
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.5),
                                    end: Offset.zero,
                                  ).animate(_slideAnimation),
                                  child: _buildFormCard(),
                                ),

                                const SizedBox(height: 24),

                                // Submit Button
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(_slideAnimation),
                                  child: _buildSubmitButton(),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
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
                    color: primaryViolet.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryViolet),
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
            'Tidak ada barang dipinjam',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pinjam barang terlebih dahulu untuk dapat mengembalikannya melalui form ini',
            style: TextStyle(color: textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryViolet, secondaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryViolet.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_return_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pengembalian Barang Manual',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih barang yang ingin dikembalikan dan lengkapi informasi pengembalian',
            style: TextStyle(
              color: textMedium,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Barang
          const Text(
            'Pilih Barang yang Dikembalikan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              color: backgroundGray,
            ),
            child: DropdownButtonFormField<Barang>(
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryViolet, secondaryPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: Colors.white, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Pilih barang yang akan dikembalikan',
                hintStyle: const TextStyle(color: textLight),
              ),
              value: selectedBarang,
              items: barangList.map((barang) {
                return DropdownMenuItem(
                  value: barang,
                  child: Text(
                    '${barang.namaBarang} (${barang.stok} unit)',
                    style: const TextStyle(color: textDark),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedBarang = value),
              validator: (value) =>
                  value == null ? 'Pilih barang yang akan dikembalikan' : null,
            ),
          ),

          const SizedBox(height: 24),

          // Input Jumlah
          const Text(
            'Jumlah yang Dikembalikan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              color: backgroundGray,
            ),
            child: TextFormField(
              controller: _stokController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [warningOrange, Color(0xFFFF9800)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.numbers_rounded,
                      color: Colors.white, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Masukkan jumlah yang dikembalikan',
                hintStyle: const TextStyle(color: textLight),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Masukkan jumlah yang dikembalikan';
                final num = int.tryParse(value!);
                if (num == null || num <= 0) return 'Jumlah tidak valid';
                if (selectedBarang != null && num > selectedBarang!.stok) {
                  return 'Melebihi jumlah yang dipinjam (${selectedBarang!.stok} unit)';
                }
                return null;
              },
            ),
          ),
          if (selectedBarang != null) ...[
            const SizedBox(height: 8),
            Text(
              'Maksimal ${selectedBarang!.stok} unit',
              style: const TextStyle(fontSize: 12, color: textLight),
            ),
          ],

          const SizedBox(height: 24),

          // Tanggal Kembali
          const Text(
            'Tanggal Pengembalian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                color: backgroundGray,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentIndigo, Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 20),
                  ),
                  Text(
                    tanggalKembali.toLocal().toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 16,
                      color: textDark,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down_rounded, color: textLight),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Keterangan
          const Text(
            'Keterangan (Opsional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              color: backgroundGray,
            ),
            child: TextFormField(
              controller: _keteranganController,
              maxLines: 4,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [textMedium, Color(0xFF4A5568)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notes_rounded,
                      color: Colors.white, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Kondisi barang, catatan pengembalian, dll...',
                hintStyle: const TextStyle(color: textLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryViolet, secondaryPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Memproses Pengembalian...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Kembalikan Barang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
