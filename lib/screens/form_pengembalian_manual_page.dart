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

class _FormPengembalianManualPageState extends State<FormPengembalianManualPage> {
  final _formKey = GlobalKey<FormState>();

  List<Barang> barangList = [];
  Barang? selectedBarang;
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? tanggalKembali;

  late ApiService apiService;
  bool isLoadingBarang = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchBarangDipinjam();
    tanggalKembali = DateTime.now();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetchBarangDipinjam() async {
    setState(() => isLoadingBarang = true);
    try {
      final data = await apiService.fetchBarangDipinjam();
      setState(() {
        barangList = data;
        isLoadingBarang = false;
      });
    } catch (e) {
      setState(() => isLoadingBarang = false);
      _showMessage('Gagal mengambil data barang: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickTanggalKembali() async {
    final date = await showDatePicker(
      context: context,
      initialDate: tanggalKembali ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange[600]!,
              onPrimary: Colors.white,
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

    if (selectedBarang == null) {
      _showMessage('Barang harus dipilih', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    final body = {
      'id_barang': selectedBarang!.idBarang,
      'jumlah': int.parse(_jumlahController.text),
      'tanggal_kembali': tanggalKembali!.toIso8601String().split('T')[0],
      'keterangan': _keteranganController.text,
    };

    bool success = await apiService.postPengembalianCustom(body);

    setState(() => isSubmitting = false);

    if (success) {
      if (!mounted) return;
      _showMessage('Pengembalian berhasil diproses!');
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      _showMessage('Gagal memproses pengembalian', isError: true);
    }
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pengembalian Barang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoadingBarang
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data barang dipinjam...'),
                ],
              ),
            )
          : barangList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada barang yang dipinjam',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pinjam barang terlebih dahulu',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Info banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            border: Border.all(color: Colors.orange[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[600]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pilih barang yang ingin dikembalikan dari daftar barang yang sedang Anda pinjam',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card untuk pilih barang
                        _buildCard(
                          title: 'Pilih Barang yang Dikembalikan',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<Barang>(
                                decoration: const InputDecoration(border: InputBorder.none),
                                hint: const Text('Pilih barang yang akan dikembalikan'),
                                value: selectedBarang,
                                items: barangList.map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Row(
                                    children: [
                                      Icon(Icons.assignment_return, 
                                           color: Colors.orange[600], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('${b.namaBarang}'),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Dipinjam: ${b.jumlah}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                                onChanged: (b) => setState(() => selectedBarang = b),
                                validator: (value) =>
                                    value == null ? 'Barang harus dipilih' : null,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card untuk jumlah dan tanggal
                        _buildCard(
                          title: 'Detail Pengembalian',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _jumlahController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Jumlah Dikembalikan',
                                  prefixIcon: Icon(Icons.numbers, color: Colors.orange[600]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jumlah harus diisi';
                                  }
                                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                    return 'Jumlah tidak valid';
                                  }
                                  if (selectedBarang != null &&
                                      int.parse(value) > selectedBarang!.jumlah) {
                                    return 'Jumlah melebihi jumlah pinjam';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _pickTanggalKembali,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.orange[600]),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tanggal Kembali',
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          Text(
                                            tanggalKembali != null
                                                ? tanggalKembali!.toLocal().toString().split(' ')[0]
                                                : 'Pilih tanggal',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Icon(Icons.arrow_forward_ios, 
                                           size: 16, color: Colors.grey[600]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card untuk keterangan
                        _buildCard(
                          title: 'Keterangan (Opsional)',
                          child: TextFormField(
                            controller: _keteranganController,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan keterangan kondisi barang atau catatan lainnya...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 3,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tombol submit
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submitPengembalian,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Kembalikan Barang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}