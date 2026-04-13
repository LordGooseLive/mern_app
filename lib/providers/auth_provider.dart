import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Initialize auth state (check if already logged in)
  Future<void> initializeAuth() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final loggedIn = await LocalStorageService.isLoggedIn();
      
      if (loggedIn) {
        // Restore user and token from local storage
        _currentUser = await LocalStorageService.getSavedUser();
        _authToken = await LocalStorageService.getAuthToken();
        _isLoggedIn = _currentUser != null && _authToken != null;
        _errorMessage = null;
      } else {
        _isLoggedIn = false;
        _currentUser = null;
        _authToken = null;
      }
    } catch (e) {
      _errorMessage = 'Error initializing auth: ${e.toString()}';
      _isLoggedIn = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _isLoggedIn = true;
        
        // Save to local storage
        await LocalStorageService.saveLoginData(
          user: _currentUser!,
          token: _authToken!,
        );
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during login: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register user
  Future<bool> register(String fName, String lName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        fName: fName,
        lName: lName,
        email: email,
        password: password,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _authToken = result['token'];
        _isLoggedIn = true;
        
        // Save to local storage
        await LocalStorageService.saveLoginData(
          user: _currentUser!,
          token: _authToken!,
        );
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during registration: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await LocalStorageService.clearLoginData();
      _currentUser = null;
      _authToken = null;
      _isLoggedIn = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error during logout: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
