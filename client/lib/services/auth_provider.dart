import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  Future<void> signup(String email, String password, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await ApiService().signup(email, password, name);
    _user = User.fromJson(response['user']);
    _token = response['token'];
    await prefs.setString('token', _token!);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await ApiService().login(email, password);
    _user = User.fromJson(response['user']);
    _token = response['token'];
    await prefs.setString('token', _token!);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _user = null;
    _token = null;
    await prefs.remove('token');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;
    _token = prefs.getString('token');
    notifyListeners();
    return true;
  }
}