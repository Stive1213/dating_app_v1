import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class User {
  final int id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  final ApiService _apiService = ApiService(); // Add instance of ApiService

  User? get user => _user;
  String? get token => _token;

  Future<void> signup(String email, String password, String name) async {
    final response = await _apiService.signup(email, password, name);
    _user = User.fromJson(response['user']);
    _token = response['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userId', _user!.id.toString());
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    _user = User.fromJson(response['user']);
    _token = response['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userId', _user!.id.toString());
    notifyListeners();
  }

  Future<bool> checkProfileExists() async {
    if (_token == null) {
      throw Exception('No token available');
    }
    return await _apiService.checkProfileExists(_token!);
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    _token = prefs.getString('token');
    final userId = prefs.getString('userId');
    // In a real app, you'd fetch user data from the server using the token
    _user = User(id: int.parse(userId!), email: '', name: '');
    notifyListeners();
    return true;
  }
}