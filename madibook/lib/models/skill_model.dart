import 'package:uuid/uuid.dart';

/// Whether a user is offering to teach or seeking to learn a skill.
enum SkillType { offering, seeking }

/// Represents a single skill entry on a user's profile.
///
/// Each skill belongs to a [category] (e.g. "Programming", "Music")
/// and has a [type] indicating whether the user teaches or wants to learn it.
///
/// Designed for easy serialization to/from a backend (Firebase, FastAPI).
class Skill {
  final String id;
  final String name;
  final String category;
  final SkillType type;

  Skill({
    String? id,
    required this.name,
    required this.category,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  /// Create a Skill from a JSON map (backend deserialization).
  factory Skill.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return Skill(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      type: data['type'] == 'offering' ? SkillType.offering : SkillType.seeking,
    );
  }

  /// Serialize to JSON map for backend persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type == SkillType.offering ? 'offering' : 'seeking',
    };
  }

  /// Two skills "match" if they share the same name (case-insensitive).
  bool matchesWith(Skill other) {
    return name.toLowerCase().trim() == other.name.toLowerCase().trim();
  }

  @override
  String toString() => 'Skill($name, $category, ${type.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
