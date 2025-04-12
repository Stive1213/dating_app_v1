import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  Future<Map<String, dynamic>> getHome() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load API');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to signup');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to login');
    }
  }

  Future<Map<String, dynamic>> saveProfile({
    required String token,
    required String name,
    required int age,
    required String gender,
    required String bio,
    required String location,
    File? photo,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['age'] = age.toString();
    request.fields['gender'] = gender;
    request.fields['bio'] = bio;
    request.fields['location'] = location;

    if (photo != null && !kIsWeb) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      return jsonDecode(responseBody.body);
    } else {
      throw Exception(jsonDecode(responseBody.body)['error'] ?? 'Failed to save profile');
    }
  }
}