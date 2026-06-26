// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  // Mock users database
  final Map<String, Map<String, String>> _users = {
    'admin@edgesafe.ai': {'password': 'Admin@123', 'name': 'Admin User'},
    'demo@edgesafe.ai': {'password': 'Demo@123', 'name': 'Demo Operator'},
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulate network delay

    final user = _users[email.toLowerCase()];
    if (user == null) {
      return {'success': false, 'message': 'No account found with this email.'};
    }
    if (user['password'] != password) {
      return {
        'success': false,
        'message': 'Incorrect password. Please try again.',
      };
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, user['name']!);

    return {'success': true, 'name': user['name'], 'email': email};
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_users.containsKey(email.toLowerCase())) {
      return {
        'success': false,
        'message': 'An account with this email already exists.',
      };
    }

    _users[email.toLowerCase()] = {'password': password, 'name': name};

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);

    return {'success': true, 'name': name, 'email': email};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Operator';
  }
}
