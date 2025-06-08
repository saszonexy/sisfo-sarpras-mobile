import 'package:flutter/material.dart';
import '../models/peminjaman.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

class FormPengembalianPage extends StatefulWidget {
  final Peminjaman peminjaman;

  const FormPengembalianPage({Key? key, required this.peminjaman}) : super(key: key);

  @override
  State<FormPengembalianPage> createState() => _FormPengembalianPageState();
}

class _FormPengembalianPageState extends State<FormPengembalianPage> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _jumlahController = TextEditingController();

  bool isSubmitting = false;
  DateTime? tanggalKembali;

  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    apiService = authProvider.apiService;

    // Isi otomatis jumlah dan tanggal kembali default hari ini
    _jumlahController.text = widget.peminjaman.jumlah.toString();
    tanggalKembali = DateTime.now();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _jumlahController.dispose();
    super.dispose();
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
      firstDate: widget.peminjaman.tanggalPinjam,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal[600]!,
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

    setState(() => isSubmitting = true);

    try {
      final body = {
        'id_peminjaman': widget.peminjaman.idPeminjaman,
        'tanggal_kembali': tanggalKembali!.toIso8601String().split('T')[0],
        'keterangan': _keteranganController.text,
      };

      print('Request Body: $body'); // Debugging

      bool success = await apiService.postPengembalianCustom(body);

      if (success) {
        if (!mounted) return;
        _showMessage('Pengembalian berhasil diproses!');
        Navigator.pop(context);
      } else {
        if (!mounted) return;
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

  Widget _buildCard({required String title, required Widget child, Color? headerColor}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor ?? Colors.teal[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: headerColor != null ? Colors.white : Colors.teal[700],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pinjam = widget.peminjaman;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kembalikan Barang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Info Card - Detail Peminjaman
              _buildCard(
                title: 'Detail Peminjaman',
                headerColor: Colors.teal[600],
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.inventory_2,
                      label: 'Nama Barang',
                      value: pinjam.namaBarang ?? "Tidak diketahui",
                      valueStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.numbers,
                      label: 'Jumlah Dipinjam',
                      value: '${pinjam.jumlah} unit',
                      valueColor: Colors.blue[700],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal Pinjam',
                      value: _formatDate(pinjam.tanggalPinjam),
                      valueColor: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pastikan jumlah yang dikembalikan sesuai dengan kondisi barang',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Input Card
              _buildCard(
                title: 'Form Pengembalian',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Dikembalikan',
                        prefixIcon: Icon(Icons.assignment_return, color: Colors.teal[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        helperText: 'Maksimal ${pinjam.jumlah} unit',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah harus diisi';
                        }
                        final intValue = int.tryParse(value);
                        if (intValue == null || intValue <= 0) {
                          return 'Jumlah tidak valid';
                        }
                        if (intValue > pinjam.jumlah) {
                          return 'Jumlah tidak boleh lebih dari jumlah dipinjam';
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
                            Icon(Icons.calendar_today, color: Colors.teal[600]),
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
                                      ? _formatDate(tanggalKembali!)
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

              // Keterangan Card
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitPengembalian,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: valueStyle ?? TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}