import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _notesController;

  DateTime? _nextWalk;
  DateTime? _nextFeeding;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _speciesController = TextEditingController(text: widget.pet?.species ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _ageController = TextEditingController(text: widget.pet?.age?.toString() ?? '');
    _notesController = TextEditingController(text: widget.pet?.notes ?? '');
    _nextWalk = widget.pet?.nextWalk;
    _nextFeeding = widget.pet?.nextFeeding;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context, bool isWalk) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isWalk ? _nextWalk : _nextFeeding) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime((isWalk ? _nextWalk : _nextFeeding) ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isWalk) {
        _nextWalk = combined;
      } else {
        _nextFeeding = combined;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<PetProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final pet = (widget.pet ?? Pet(
      id: '',
      name: '',
      species: '',
      ownerId: auth.currentUser!.id,
    )).copyWith(
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      age: int.tryParse(_ageController.text),
      notes: _notesController.text.trim(),
      nextWalk: _nextWalk,
      nextFeeding: _nextFeeding,
    );

    final success = widget.pet == null
        ? await provider.addPet(pet: pet, token: auth.authToken!)
        : await provider.updatePet(petId: widget.pet!.id, pet: pet, token: auth.authToken!);

    if (mounted) {
      if (success) {
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to save pet')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Add New Pet' : 'Edit Pet'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(labelText: 'Species', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Breed (Optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            Text('Reminders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_walk_rounded, color: Colors.blue),
              title: const Text('Next Walk'),
              subtitle: Text(_nextWalk != null ? dateFormat.format(_nextWalk!) : 'Not set'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: () => _pickDateTime(context, true),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_rounded, color: Colors.orange),
              title: const Text('Next Feeding'),
              subtitle: Text(_nextFeeding != null ? dateFormat.format(_nextFeeding!) : 'Not set'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: () => _pickDateTime(context, false),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            if (widget.pet != null)
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Pet'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    final auth = context.read<AuthProvider>();
                    final petProvider = context.read<PetProvider>();
                    final navigator = Navigator.of(context);
                    
                    await petProvider.deletePet(petId: widget.pet!.id, token: auth.authToken!);
                    
                    if (mounted) {
                      navigator.pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                label: const Text('Delete Pet', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
