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
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? 'NEW PET');
    _speciesController = TextEditingController(text: widget.pet?.species ?? '');
    _ageController = TextEditingController(text: widget.pet?.age?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () async {
              final pet = (widget.pet ?? Pet(
                id: '',
                name: '',
                species: '',
                ownerId: auth.currentUser!.id,
              )).copyWith(
                name: _nameController.text,
                species: _speciesController.text,
                age: int.tryParse(_ageController.text),
              );

              if (widget.pet == null) {
                await petProvider.addPet(pet: pet, token: auth.authToken ?? '');
              } else {
                await petProvider.updatePet(petId: widget.pet!.id, pet: pet, token: auth.authToken ?? '');
              }
              if (mounted) Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            // PET NAME Header
            TextField(
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
            ),
            
            const SizedBox(height: 10),
            
            // PHOTO Circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onSurface, width: 1.5),
              ),
              child: Center(
                child: Text('PHOTO', style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 12)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Species and Age Row
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Species',
                    child: TextField(
                      controller: _speciesController,
                      style: TextStyle(color: onSurface),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _InfoBox(
                    label: 'Age',
                    child: TextField(
                      controller: _ageController,
                      style: TextStyle(color: onSurface),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Health and Daily Log Columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'health',
                    height: 200,
                    child: const Text('', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _InfoBox(
                    label: 'daily log',
                    height: 200,
                    child: const Text('', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            if (widget.pet != null)
              TextButton(
                onPressed: () async {
                  await petProvider.deletePet(petId: widget.pet!.id, token: auth.authToken ?? '');
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('DELETE PET', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
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
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: onSurface, width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }
}
