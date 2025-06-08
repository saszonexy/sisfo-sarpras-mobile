import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  String? token;
  Map<String, dynamic>? userData;
  bool isLoading = false;
  String? lastErrorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    lastErrorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.login(email, password);
      if (response['success'] == true) {
        token = response['data']['token'];
        userData = response['data']['user'];
        apiService.updateToken(token);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token!);

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        lastErrorMessage = response['message'] ?? 'Login gagal';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      lastErrorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    token = null;
    userData = null;
    apiService.updateToken(null);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token != null) {
      apiService.updateToken(token);
      // Anda bisa menambahkan logika untuk mengambil data pengguna dari API jika diperlukan
      // Misalnya:
      // userData = await apiService.getUserProfile();
    }
    notifyListeners();
  }
}