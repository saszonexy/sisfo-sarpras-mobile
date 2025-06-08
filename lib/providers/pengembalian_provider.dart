import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PengembalianProvider with ChangeNotifier {
  final String _baseUrl = 'http://127.0.0.1:8000/api/mobile';
  String? token;

  // Update the token when login happens
  void updateToken(String? newToken) {
    token = newToken;
  }

  // Submit pengembalian data to the server
  Future<bool> submitPengembalian(Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/pengembalian');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
