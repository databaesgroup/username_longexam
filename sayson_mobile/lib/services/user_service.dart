import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user_model.dart';

class UserService {
  static final UserService _i = UserService._();
  factory UserService() => _i;
  UserService._();

  static const _kToken = 'auth_token';
  AppUser? _current;

  Uri _u(String path) => Uri.parse('$kBaseUrl$path');

  Future<void> _saveToken(String t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, t);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    _current = null;
  }

  AppUser? get currentUser => _current;

  Future<AppUser?> login({
    String? email,
    String? username,
    required String password,
  }) async {
    final body = {
      if (email != null && email.isNotEmpty) 'email': email,
      if (username != null && username.isNotEmpty) 'username': username,
      'password': password,
    };
    final resp = await http.post(
      _u('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = json.decode(resp.body);
      final token = (map['token'] ?? '').toString();
      if (token.isNotEmpty) await _saveToken(token);
      final user = AppUser.fromJson(map);
      _current = user;
      return user;
    }
    throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
  }

  Future<AppUser?> registerUser(Map<String, dynamic> form) async {
    final resp = await http.post(
      _u('/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(form),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = json.decode(resp.body);
      final token = (map['token'] ?? '').toString();
      if (token.isNotEmpty) await _saveToken(token);
      final user = AppUser.fromJson(map);
      _current = user;
      return user;
    }
    throw Exception('Register failed: ${resp.statusCode} ${resp.body}');
  }

  Future<AppUser> getUserData() async {
    final t = await getToken();
    if (t == null) throw Exception('Not logged in');
    final resp = await http.get(
      _u('/api/users/me'),
      headers: {'Authorization': 'Bearer $t'},
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final map = json.decode(resp.body);
      final user = AppUser.fromJson(map);
      _current = user;
      return user;
    }
    throw Exception('Profile failed: ${resp.statusCode} ${resp.body}');
  }
}
