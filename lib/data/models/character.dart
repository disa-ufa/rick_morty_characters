class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String image;
  final String locationName;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.locationName,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Character(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      species: (json['species'] as String?) ?? '',
      image: (json['image'] as String?) ?? '',
      locationName: (location['name'] as String?) ?? '',
    );
  }
}
