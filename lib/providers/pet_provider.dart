import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/api_service.dart';

class PetProvider extends ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch pets for a user
  Future<void> fetchPets({
    required String userId,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.getUserPets(
        userId: userId,
        token: token,
      );

      if (result['success']) {
        _pets = result['pets'] ?? [];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch pets';
      }
    } catch (e) {
      _errorMessage = 'Error fetching pets: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new pet
  Future<bool> addPet({
    required Pet pet,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.addPet(
        pet: pet,
        token: token,
      );

      if (result['success']) {
        _pets.add(result['pet']);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to add pet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding pet: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing pet
  Future<bool> updatePet({
    required String petId,
    required Pet pet,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.updatePet(
        petId: petId,
        pet: pet,
        token: token,
      );

      if (result['success']) {
        final index = _pets.indexWhere((p) => p.id == petId);
        if (index != -1) {
          _pets[index] = result['pet'];
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update pet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating pet: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a pet
  Future<bool> deletePet({
    required String petId,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.deletePet(
        petId: petId,
        token: token,
      );

      if (result['success']) {
        _pets.removeWhere((p) => p.id == petId);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete pet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting pet: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all pets (for logout)
  void clearPets() {
    _pets = [];
    notifyListeners();
  }
}
