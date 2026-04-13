class Pet {
  final String id;
  final String name;
  final String species; // Dog, Cat, etc.
  final int? age;
  final String? breed;
  final String ownerId; // Reference to the owner 
  DateTime? lastWalk;
  DateTime? nextWalk;
  DateTime? lastFeeding;
  DateTime? nextFeeding;
  String? notes;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.age,
    this.breed,
    required this.ownerId,
    this.lastWalk,
    this.nextWalk,
    this.lastFeeding,
    this.nextFeeding,
    this.notes,

  });

  // Convert JSON to Pet object
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      age: json['age'] != null ? (json['age'] as num).toInt() : null,
      breed: json['breed'],
      ownerId: json['userId'] ?? '',
      lastWalk: json['lastWalk'] != null ? DateTime.tryParse(json['lastWalk'].toString()) : null,
      nextWalk: json['nextWalk'] != null ? DateTime.tryParse(json['nextWalk'].toString()) : null,
      lastFeeding: json['lastFeeding'] != null ? DateTime.tryParse(json['lastFeeding'].toString()) : null,
      nextFeeding: json['nextFeeding'] != null ? DateTime.tryParse(json['nextFeeding'].toString()) : null,
      notes: json['notes'],
    );
  }

  // Create a copy with modifications
  Pet copyWith({
    String? id,
    String? name,
    String? species,
    int? age,
    String? breed,
    String? ownerId,
    DateTime? lastWalk,
    DateTime? nextWalk,
    DateTime? lastFeeding,
    DateTime? nextFeeding,
    String? notes,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      ownerId: ownerId ?? this.ownerId,
      lastWalk: lastWalk ?? this.lastWalk,
      nextWalk: nextWalk ?? this.nextWalk,
      lastFeeding: lastFeeding ?? this.lastFeeding,
      nextFeeding: nextFeeding ?? this.nextFeeding,
      notes: notes ?? this.notes,
    );
  }

  // Convert Pet object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'lastWalk': lastWalk?.toIso8601String(),
      'nextWalk': nextWalk?.toIso8601String(),
      'lastFeeding': lastFeeding?.toIso8601String(),
      'nextFeeding': nextFeeding?.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  String toString() => 'Pet(id: $id, name: $name, species: $species)';
}
