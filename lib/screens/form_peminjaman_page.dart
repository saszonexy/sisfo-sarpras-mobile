import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/barang.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<Barang> barangList = [];
  Barang? selectedBarang;
  final _stokController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? tanggalPinjam;

  late ApiService apiService;
  bool isLoadingBarang = true;
  bool isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern Color Scheme
  static const primaryGradientStart = Color(0xFF667EEA);
  static const primaryGradientEnd = Color(0xFF764BA2);
  static const accentColor = Color(0xFF4FACFE);
  static const successColor = Color(0xFF00D4AA);
  static const warningColor = Color(0xFFFFB74D);
  static const errorColor = Color(0xFFFF5252);
  static const backgroundColor = Color(0xFFF8FAFF);
  static const cardColor = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchBarang();
    tanggalPinjam = DateTime.now();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _stokController.dispose();
    _keteranganController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBarang() async {
    setState(() => isLoadingBarang = true);
    try {
      final data = await apiService.fetchBarang();
      setState(() {
        barangList = data.where((barang) => barang.tersedia > 0).toList();
        isLoadingBarang = false;
      });
    } catch (e) {
      setState(() => isLoadingBarang = false);
      if (mounted) {
        _showCustomSnackBar('Gagal mengambil data barang: $e', isError: true);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedBarang == null) {
      _showCustomSnackBar('Barang harus dipilih', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Format data untuk Laravel backend
      final Map<String, dynamic> requestData = {
        'id_barang': selectedBarang!.idBarang.toString(),
        'stok': _stokController.text,
        'tanggal_pinjam': tanggalPinjam!.toIso8601String().split('T')[0],
        'keterangan': _keteranganController.text.isEmpty
            ? null
            : _keteranganController.text,
        'status': 'dipinjam',
        'label_status': 'menunggu'
      };

      // Kirim request ke Laravel dengan proper headers
      final response = await http.post(
        Uri.parse('${apiService.baseUrl}/peminjaman'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${apiService.token}',
          // Tambahkan CSRF token jika diperlukan
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(requestData),
      );

      setState(() => isSubmitting = false);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showCustomSnackBar(
          responseData['message'] ?? 'Peminjaman berhasil diajukan! 🎉',
          isError: false,
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        final errorData = json.decode(response.body);
        _showCustomSnackBar(
          errorData['message'] ?? 'Gagal mengajukan peminjaman',
          isError: true,
        );
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) {
        _showCustomSnackBar('Error: $e', isError: true);
      }
    }
  }

  void _showCustomSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickTanggalPinjam() async {
    final date = await showDatePicker(
      context: context,
      initialDate: tanggalPinjam ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGradientStart,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => tanggalPinjam = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGradientStart, primaryGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Form Peminjaman',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGradientStart, primaryGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.assignment_add,
                      size: 60,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: isLoadingBarang
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryGradientStart),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Memuat data barang...',
                            style: TextStyle(
                              fontSize: 16,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Header Card
                            _buildHeaderCard(),
                            const SizedBox(height: 24),

                            // Form Card
                            _buildFormCard(),
                            const SizedBox(height: 24),

                            // Submit Button
                            _buildSubmitButton(),
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
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGradientStart.withOpacity(0.1),
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
              gradient: const LinearGradient(
                colors: [primaryGradientStart, primaryGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ajukan Peminjaman Barang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lengkapi formulir di bawah ini untuk mengajukan peminjaman barang inventaris',
            style: TextStyle(
              color: textSecondary,
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField(),
          const SizedBox(height: 24),
          _buildStokField(),
          const SizedBox(height: 24),
          _buildDateField(),
          const SizedBox(height: 24),
          _buildKeteranganField(),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Barang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            color: backgroundColor,
          ),
          child: DropdownButtonFormField<Barang>(
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryGradientStart, primaryGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Pilih barang yang akan dipinjam',
              hintStyle: const TextStyle(color: textSecondary),
            ),
            items: barangList
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(
                        '${b.namaBarang} (${b.tersedia} tersedia)',
                        style: const TextStyle(color: textPrimary),
                      ),
                    ))
                .toList(),
            onChanged: (b) => setState(() => selectedBarang = b),
            validator: (value) =>
                value == null ? 'Pilih barang terlebih dahulu' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStokField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah Barang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            color: backgroundColor,
          ),
          child: TextFormField(
            controller: _stokController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentColor, primaryGradientStart],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.numbers_rounded,
                    color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Masukkan jumlah barang',
              hintStyle: const TextStyle(color: textSecondary),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Jumlah harus diisi';
              final num = int.tryParse(value!);
              if (num == null || num <= 0) return 'Jumlah tidak valid';
              if (selectedBarang != null && num > selectedBarang!.tersedia) {
                return 'Melebihi stok tersedia (${selectedBarang!.tersedia})';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Peminjaman',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickTanggalPinjam,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              color: backgroundColor,
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [warningColor, Color(0xFFFF9800)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 20),
                ),
                Text(
                  tanggalPinjam != null
                      ? tanggalPinjam!.toLocal().toString().split(' ')[0]
                      : 'Pilih tanggal peminjaman',
                  style: TextStyle(
                    fontSize: 16,
                    color: tanggalPinjam != null ? textPrimary : textSecondary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down_rounded, color: textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeteranganField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keterangan (Opsional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            color: backgroundColor,
          ),
          child: TextFormField(
            controller: _keteranganController,
            maxLines: 4,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [textSecondary, Color(0xFF4A5568)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notes_rounded,
                    color: Colors.white, size: 20),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Tambahkan keterangan jika diperlukan...',
              hintStyle: const TextStyle(color: textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGradientStart, primaryGradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGradientStart.withOpacity(0.3),
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
                    'Mengirim Peminjaman...',
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
                  Icon(Icons.send_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Ajukan Peminjaman',
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
