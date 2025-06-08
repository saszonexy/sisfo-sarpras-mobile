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

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<List<Barang>> fetchBarang() async {
    final url = Uri.parse('$baseUrl/barang');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

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

  Future<List<Peminjaman>> fetchPeminjaman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/peminjaman/mobile-list'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Cetak respons lengkap

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> userPeminjaman = data['data']['user'] ?? [];
        final List<dynamic> lainnyaPeminjaman = data['data']['lainnya'] ?? [];

        final List<Peminjaman> userPeminjamanList = userPeminjaman.map((json) => Peminjaman.fromJson(json)).toList();
        final List<Peminjaman> lainnyaPeminjamanList = lainnyaPeminjaman.map((json) => Peminjaman.fromJson(json)).toList();

        return [...userPeminjamanList, ...lainnyaPeminjamanList];
      } else {
        throw Exception('Failed to fetch peminjaman');
      }
    } catch (e) {
      print('Error fetching peminjaman: $e');
      throw Exception('Failed to fetch peminjaman');
    }
  }

  Future<List<Peminjaman>> fetchRiwayatPeminjaman() async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman/riwayat'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Peminjaman.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch riwayat peminjaman');
    }
  }

  Future<bool> postPeminjamanCustom(Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/peminjaman');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // Ambil barang yang sedang dipinjam user (status dipinjam)
  Future<List<Barang>> fetchBarangDipinjam() async {
    final url = Uri.parse('$baseUrl/barang-dipinjam');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => Barang.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data barang yang dipinjam');
      }
    } else {
      throw Exception(
          'Gagal mengambil data barang yang dipinjam, status: ${response.statusCode}');
    }
  }

// Kirim data pengembalian manual
Future<bool> postPengembalianCustom(Map<String, dynamic> body) async {
  try {
    final url = Uri.parse('$baseUrl/pengembalian');
    print('URL: $url'); // Debugging
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('Status Code: ${response.statusCode}'); // Debugging
    print('Response Body: ${response.body}'); // Debugging

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in postPengembalianCustom: $e'); // Debugging
    return false;
  }
}

}
