import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class LocalStorageService {
  static const String userKey = 'user_data';
  static const String tokenKey = 'auth_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastLoginKey = 'last_login';

  /// Save user and token after login
  static Future<void> saveLoginData({
    required User user,
    required String token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save user data
      await prefs.setString(userKey, jsonEncode(user.toJson()));
      
      // Save token
      await prefs.setString(tokenKey, token);
      
      // Mark as logged in
      await prefs.setBool(isLoggedInKey, true);
      
      // Save login timestamp
      await prefs.setString(lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving login data: $e');
    }
  }

  /// Get saved authentication token
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  /// Get saved user data
  static Future<User?> getSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(userKey);
      
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting saved user: $e');
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Clear all login data (logout)
  static Future<void> clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userKey);
      await prefs.remove(tokenKey);
      await prefs.setBool(isLoggedInKey, false);
      await prefs.remove(lastLoginKey);
    } catch (e) {
      print('Error clearing login data: $e');
    }
  }

  /// Get last login timestamp
  static Future<DateTime?> getLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLogin = prefs.getString(lastLoginKey);
      
      if (lastLogin != null) {
        return DateTime.parse(lastLogin);
      }
      return null;
    } catch (e) {
      print('Error getting last login: $e');
      return null;
    }
  }

  /// Update user data
  static Future<void> updateUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
}
