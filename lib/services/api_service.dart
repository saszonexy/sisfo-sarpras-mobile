import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import '../models/peminjaman.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api/mobile';
  String? token;

  void updateToken(String? newToken) {
    token = newToken;
  }

  // ✅ Login API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tokenFromResponse = data['data']['token'];
      updateToken(tokenFromResponse);
      return data;
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  // ✅ Fetch Data Barang
  Future<List<Barang>> fetchBarang() async {
    _checkToken();
    final url = Uri.parse('$baseUrl/barang');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> barangListJson = jsonResponse['data'];
        return barangListJson.map((json) => Barang.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data barang');
      }
    } else {
      throw Exception('Failed to load barang, status: ${response.statusCode}');
    }
  }

  // ✅ Fetch Data Peminjaman
  Future<List<Peminjaman>> fetchPeminjaman() async {
    _checkToken();
    final url = Uri.parse('$baseUrl/peminjaman/mobile-list');
    print('Token: $token');

    final response = await http.get(url, headers: _headers());
    print('Fetch Peminjaman: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> dataContent = data['data'] ?? {};

      final List<dynamic> userData =
          dataContent['user'] is List ? dataContent['user'] : [];
      final List<dynamic> lainnyaData =
          dataContent['lainnya'] is List ? dataContent['lainnya'] : [];

      final List<Peminjaman> userList =
          userData.map((json) => Peminjaman.fromJson(json)).toList();
      final List<Peminjaman> lainnyaList =
          lainnyaData.map((json) => Peminjaman.fromJson(json)).toList();

      return [...userList, ...lainnyaList];
    } else {
      throw Exception(
          'Failed to fetch peminjaman, status: ${response.statusCode}');
    }
  }

  // ✅ Fetch Riwayat Peminjaman
  Future<List<Peminjaman>> fetchRiwayatPeminjaman() async {
    _checkToken();
    final url = Uri.parse('$baseUrl/peminjaman/riwayat');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Peminjaman.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch riwayat peminjaman, status: ${response.statusCode}');
    }
  }

  // ✅ Custom Post Peminjaman
  Future<bool> postPeminjamanCustom(Map<String, dynamic> body) async {
    _checkToken();
    final url = Uri.parse('$baseUrl/peminjaman');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(body),
    );

    print('Post Peminjaman: ${response.statusCode} - ${response.body}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ✅ Fetch Barang Dipinjam
  Future<List<Barang>> fetchBarangDipinjam() async {
    _checkToken();
    final url = Uri.parse('$baseUrl/barang-dipinjam');
    final response = await http.get(url, headers: _headers());

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => Barang.fromJson(item)).toList();
      } else {
        throw Exception('Gagal ambil barang dipinjam');
      }
    } else {
      throw Exception(
          'Gagal ambil barang dipinjam, status: ${response.statusCode}');
    }
  }

  // ✅ Custom Post Pengembalian
  Future<bool> postPengembalianCustom(Map<String, dynamic> body) async {
    _checkToken();
    try {
      final url = Uri.parse('$baseUrl/pengembalian');
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );

      print('Pengembalian: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error pengembalian: $e');
      return false;
    }
  }

  // ✅ Utility Headers
  Map<String, String> _headers() {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ✅ Utility Token Check
  void _checkToken() {
    if (token == null || token!.isEmpty) {
      throw Exception('Token belum tersedia. Silakan login terlebih dahulu.');
    }
  }
}
