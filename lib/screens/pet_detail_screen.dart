import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet? pet;

  const PetDetailScreen({this.pet, super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _ageController;
  late TextEditingController _breedController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _speciesController = TextEditingController(text: widget.pet?.species ?? '');
    _ageController = TextEditingController(text: widget.pet?.age?.toString() ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _notesController = TextEditingController(text: widget.pet?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();

    final pet = (widget.pet ?? Pet(
      id: '',
      name: '',
      species: '',
      ownerId: auth.currentUser!.id,
    )).copyWith(
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      age: int.tryParse(_ageController.text),
      breed: _breedController.text.trim(),
      notes: _notesController.text.trim(),
    );

    bool success;
    if (widget.pet == null) {
      success = await petProvider.addPet(pet: pet, token: auth.authToken ?? '');
    } else {
      success = await petProvider.updatePet(petId: widget.pet!.id, pet: pet, token: auth.authToken ?? '');
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(petProvider.errorMessage ?? 'Failed to save pet')),
        );
      }
    }
  }

  Future<void> _deletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${_nameController.text}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = context.read<AuthProvider>();
      final petProvider = context.read<PetProvider>();
      
      final success = await petProvider.deletePet(petId: widget.pet!.id, token: auth.authToken ?? '');
      
      if (mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(petProvider.errorMessage ?? 'Failed to delete pet')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Add Pet' : 'Edit Pet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePet,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PET NAME Header
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: onSurface,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'PET NAME',
                ),
                validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
              ),
              
              const SizedBox(height: 20),
              
              // PHOTO Circle (Placeholder)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: onSurface.withOpacity(0.3), width: 1.5),
                ),
                child: Center(
                  child: Icon(Icons.pets, size: 60, color: onSurface.withOpacity(0.3)),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Species and Breed Row
              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      label: 'Species',
                      child: TextFormField(
                        controller: _speciesController,
                        style: TextStyle(color: onSurface),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Dog'),
                        textAlign: TextAlign.center,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoBox(
                      label: 'Breed',
                      child: TextFormField(
                        controller: _breedController,
                        style: TextStyle(color: onSurface),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Golden Retriever'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Age and Notes
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _InfoBox(
                      label: 'Age',
                      child: TextFormField(
                        controller: _ageController,
                        style: TextStyle(color: onSurface),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '3'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _InfoBox(
                      label: 'Notes',
                      child: TextFormField(
                        controller: _notesController,
                        style: TextStyle(color: onSurface),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Allergies, habits...'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              if (widget.pet != null)
                ElevatedButton.icon(
                  onPressed: _deletePet,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('DELETE PET'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final Widget child;
  final double? height;

  const _InfoBox({required this.label, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: onSurface.withOpacity(0.6), letterSpacing: 1.0)),
        ),
        Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: onSurface.withOpacity(0.2), width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }
}
