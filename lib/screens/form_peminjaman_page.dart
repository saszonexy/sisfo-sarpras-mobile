import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  List<Barang> barangList = [];
  Barang? selectedBarang;
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  DateTime? tanggalPinjam;

  late ApiService apiService;
  bool isLoadingBarang = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;
    _fetchBarang();
    tanggalPinjam = DateTime.now();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data barang: $e')));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedBarang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang harus dipilih')));
      return;
    }

    setState(() => isSubmitting = true);

    final body = {
      'id_barang': selectedBarang!.idBarang,
      'jumlah': int.parse(_jumlahController.text),
      'tanggal_pinjam': tanggalPinjam!.toIso8601String().split('T')[0],
      'keterangan': _keteranganController.text,
      'status': 'dipinjam',
      'label_status': 'menunggu'
    };

    final success = await apiService.postPeminjamanCustom(body);
    setState(() => isSubmitting = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil diajukan!'),
            backgroundColor: Colors.green,
          ));
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengajukan peminjaman'),
            backgroundColor: Colors.red,
          ));
    }
  }

  Future<void> _pickTanggalPinjam() async {
    final date = await showDatePicker(
      context: context,
      initialDate: tanggalPinjam ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => tanggalPinjam = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Peminjaman Barang'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoadingBarang
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.inventory_2, 
                                     color: Colors.blue[600], size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Form Peminjaman',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lengkapi form di bawah untuk mengajukan peminjaman barang',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Form Fields
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Dropdown Barang
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonFormField<Barang>(
                                decoration: const InputDecoration(
                                  labelText: 'Pilih Barang',
                                  prefixIcon: Icon(Icons.inventory),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                items: barangList
                                    .map((b) => DropdownMenuItem(
                                          value: b,
                                          child: Text('${b.namaBarang} (${b.tersedia} tersedia)'),
                                        ))
                                    .toList(),
                                onChanged: (b) => setState(() => selectedBarang = b),
                                validator: (value) =>
                                    value == null ? 'Pilih barang terlebih dahulu' : null,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Input Jumlah
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                controller: _jumlahController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Jumlah',
                                  prefixIcon: Icon(Icons.pin),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
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

                            const SizedBox(height: 16),

                            // Tanggal Pinjam
                            GestureDetector(
                              onTap: _pickTanggalPinjam,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, 
                                         color: Colors.grey[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tanggal Pinjam',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            tanggalPinjam != null
                                                ? tanggalPinjam!.toLocal()
                                                    .toString().split(' ')[0]
                                                : 'Pilih tanggal',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Keterangan
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                controller: _keteranganController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Keterangan (Opsional)',
                                  prefixIcon: Icon(Icons.notes),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: isSubmitting
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ajukan Peminjaman',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}