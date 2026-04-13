import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../models/pet.dart';
import 'pet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await context.read<PetProvider>().fetchPets(
            userId: auth.currentUser!.id,
            token: auth.authToken ?? '',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final petProvider = context.watch<PetProvider>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header: OWNER PROFILE
              Text(
                'OWNER PROFILE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 30),

              // HOUSEHOLD Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: onSurface, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'HOUSEHOLD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Pet Grid
                    SizedBox(
                      height: 140,
                      child: petProvider.isLoading 
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            children: [
                              ...petProvider.pets.map((pet) => _PetAvatar(pet: pet)),
                              if (petProvider.pets.length < 3)
                                _AddPetButton(onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PetDetailScreen()),
                                )),
                            ],
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bottom Section: Something else idk
              Container(
                width: 250,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: onSurface, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'DAILY LOG / HEALTH',
                  style: TextStyle(color: onSurface.withOpacity(0.5)),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Logout Button
              TextButton(
                onPressed: () => auth.logout(),
                child: const Text('LOGOUT', style: TextStyle(color: Colors.red, letterSpacing: 1.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final Pet pet;
  const _PetAvatar({required this.pet});

  String _getPetEmoji(String species) {
    final s = species.toLowerCase().trim();
    if (s.contains('dog')) return '🐶';
    if (s.contains('cat')) return '🐱';
    return '🐾';
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
      ),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onSurface, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Text(
                _getPetEmoji(pet.species),
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pet.name.toUpperCase(),
              style: TextStyle(fontSize: 12, color: onSurface),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: onSurface, width: 1.0, style: BorderStyle.solid),
              ),
              child: Icon(Icons.add, size: 30, color: onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'ADD PET',
              style: TextStyle(fontSize: 10, color: onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
