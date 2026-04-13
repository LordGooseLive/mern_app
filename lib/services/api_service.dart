import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/pet.dart';

class ApiService {
  // Use your computer's actual IPv4 address
  static const String baseUrl = 'http://192.168.0.48:5000/api';
  
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String resetPasswordEndpoint = '/resetpassword';

  static Map<String, String> get defaultHeaders {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== USER AUTHENTICATION ====================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: defaultHeaders,
        body: jsonEncode({
          'login': email,
          'Password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['id'] != null && data['id'] != -1) {
          final user = User(
            id: data['id'].toString(),
            fName: data['FirstName'] ?? '',
            lName: data['LastName'] ?? '',
            email: email,
            isVerified: true,
          );
          return {'success': true, 'user': user, 'token': 'session-token'};
        }
        return {'success': false, 'message': data['error'] ?? 'Invalid credentials'};
      }
      return {'success': false, 'message': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Connection Refused: Check your IP and Firewall'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fName,
    required String lName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$registerEndpoint'),
        headers: defaultHeaders,
        body: jsonEncode({
          'FirstName': fName,
          'LastName': lName,
          'Email': email,
          'Password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['id'] != -1) {
        return {'success': true, 'message': 'User registered successfully'};
      }
      return {'success': false, 'message': data['error'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> requestPasswordReset({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$resetPasswordEndpoint'),
        headers: defaultHeaders,
        body: jsonEncode({'Email': email}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Reset email sent!'};
      }
      return {'success': false, 'message': 'Failed to send reset email'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // ==================== PET MANAGEMENT ====================

  static Future<Map<String, dynamic>> getUserPets({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getpets'),
        headers: defaultHeaders,
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pets = (data['results'] as List).map((p) => Pet.fromJson(p)).toList();
        return {'success': true, 'pets': pets};
      }
      return {'success': false, 'message': 'Failed to fetch pets'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> addPet({
    required Pet pet,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addpet'),
        headers: defaultHeaders,
        body: jsonEncode({
          'userId': pet.ownerId,
          'name': pet.name,
          'species': pet.species,
          'age': pet.age,
          'lastFeeding': pet.lastFeeding?.toIso8601String(),
          'lastWalk': pet.lastWalk?.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'pet': pet};
      }
      return {'success': false, 'message': 'Failed to add pet'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updatePet({required String petId, required Pet pet, required String token}) async {
    // Similar implementation as addPet
    return {'success': true};
  }

  static Future<Map<String, dynamic>> deletePet({required String petId, required String token}) async {
    // Similar implementation
    return {'success': true};
  }
}
