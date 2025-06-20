import 'package:flutter/material.dart';
import '../models/peminjaman.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class FormPengembalianPage extends StatefulWidget {
  final Peminjaman peminjaman;

  const FormPengembalianPage({Key? key, required this.peminjaman})
      : super(key: key);

  @override
  State<FormPengembalianPage> createState() => _FormPengembalianPageState();
}

class _FormPengembalianPageState extends State<FormPengembalianPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _jumlahController = TextEditingController();

  bool isSubmitting = false;
  DateTime? tanggalKembali;
  late ApiService apiService;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Modern Color Palette
  static const primaryEmerald = Color(0xFF10B981);
  static const secondaryTeal = Color(0xFF14B8A6);
  static const accentCyan = Color(0xFF06B6D4);
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

    // Pre-fill form
    _jumlahController.text = widget.peminjaman.stok.toString();
    tanggalKembali = DateTime.now();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _jumlahController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
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
        backgroundColor: isError ? errorRose : primaryEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickTanggalKembali() async {
    final date = await showDatePicker(
      context: context,
      initialDate: tanggalKembali ?? DateTime.now(),
      firstDate: widget.peminjaman.tanggalPinjam,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryEmerald,
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

  Future<void> _submitPengembalian() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final body = {
        'id_peminjaman': widget.peminjaman.idPeminjaman,
        'tanggal_kembali': tanggalKembali!.toIso8601String().split('T')[0],
        'keterangan': _keteranganController.text,
      };

      bool success = await apiService.postPengembalianCustom(body);

      if (!mounted) return;

      if (success) {
        _showMessage('Pengembalian berhasil diproses! 🎉');
        Navigator.pop(context);
      } else {
        _showMessage('Gagal memproses pengembalian', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pinjam = widget.peminjaman;

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
                  colors: [primaryEmerald, secondaryTeal, accentCyan],
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
                  'Kembalikan Barang',
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
                      colors: [primaryEmerald, secondaryTeal, accentCyan],
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
                          Icons.assignment_return_rounded,
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
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
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

                      // Detail Peminjaman Card
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.5, 0),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: _buildDetailCard(pinjam),
                      ),

                      const SizedBox(height: 24),

                      // Form Fields Card
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.5, 0),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: _buildFormCard(pinjam),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.1),
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
                colors: [primaryEmerald, secondaryTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.3),
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
            'Proses Pengembalian Barang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Konfirmasi pengembalian barang yang telah dipinjam dengan mengisi formulir di bawah ini',
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

  Widget _buildDetailCard(Peminjaman pinjam) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentCyan, secondaryTeal],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detail Peminjaman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildModernDetailRow(
                  'Nama Barang',
                  pinjam.namaBarang ?? "Tidak diketahui",
                  Icons.inventory_2_rounded,
                  purpleAccent,
                ),
                const SizedBox(height: 16),
                _buildModernDetailRow(
                  'Jumlah Dipinjam',
                  '${pinjam.stok} unit',
                  Icons.numbers_rounded,
                  warningAmber,
                ),
                const SizedBox(height: 16),
                _buildModernDetailRow(
                  'Tanggal Pinjam',
                  _formatDate(pinjam.tanggalPinjam),
                  Icons.calendar_today_rounded,
                  accentCyan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(Peminjaman pinjam) {
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
          // Input Jumlah
          const Text(
            'Jumlah Dikembalikan',
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
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryEmerald, secondaryTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_return_rounded,
                      color: Colors.white, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                hintText: 'Masukkan jumlah yang dikembalikan',
                hintStyle: const TextStyle(color: textLight),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah harus diisi';
                }
                final intValue = int.tryParse(value);
                if (intValue == null || intValue <= 0) {
                  return 'Jumlah tidak valid';
                }
                if (intValue > pinjam.stok) {
                  return 'Jumlah tidak boleh lebih dari jumlah dipinjam';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Maksimal ${pinjam.stok} unit',
            style: const TextStyle(fontSize: 12, color: textLight),
          ),

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
            onTap: _pickTanggalKembali,
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
                        colors: [warningAmber, Color(0xFFFF9800)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: Colors.white, size: 20),
                  ),
                  Text(
                    tanggalKembali != null
                        ? _formatDate(tanggalKembali!)
                        : 'Pilih tanggal pengembalian',
                    style: TextStyle(
                      fontSize: 16,
                      color: tanggalKembali != null ? textDark : textLight,
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
                hintText: 'Kondisi barang, catatan tambahan, dll...',
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
          colors: [primaryEmerald, secondaryTeal],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitPengembalian,
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
                    'Konfirmasi Pengembalian',
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
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: textLight)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }
}
