import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _userId;
  String? _name;
  String? _email;
  String? _telefono;

  String? get token => _token;
  int? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get telefono => _telefono;

  // Método nuevo para establecer todo
  Future<void> setAuthData(String token, int userId, String? name, String? email, String? telefono) async {
    _token = token;
    _userId = userId;
    _name = name;
    _email = email;
    _telefono = telefono;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('auth_user_id', userId);
    if (name != null) await prefs.setString('auth_name', name);
    if (email != null) await prefs.setString('auth_email', email);
    if (telefono != null) await prefs.setString('auth_telefono', telefono);

    notifyListeners();
  }

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getInt('auth_user_id');
    _name = prefs.getString('auth_name');
    _email = prefs.getString('auth_email');
    _telefono = prefs.getString('auth_telefono');
    notifyListeners();
  }

  Future<void> clearAuthData() async {
    _token = null;
    _userId = null;
    _name = null;
    _email = null;
    _telefono = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_name');
    await prefs.remove('auth_email');
    await prefs.remove('auth_telefono');

    notifyListeners();
  }

  // Mantengo tu setToken para compatibilidad
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
