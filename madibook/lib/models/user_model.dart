import 'package:uuid/uuid.dart';
import 'skill_model.dart';

/// Represents a Madibook user profile.
///
/// Each user has:
/// - A [name] and optional [bio] and [avatarUrl]
/// - A [location] string (city-level, for proximity features later)
/// - A [madiCredits] balance (the platform's exchange currency)
/// - Two skill lists: [offerings] (what they teach) and [seekings] (what they want to learn)
class MadiUser {
  final String id;
  final String name;
  final String bio;
  final String location;
  final String? avatarUrl;
  double madiCredits;
  final List<Skill> offerings;
  final List<Skill> seekings;
  final DateTime joinedAt;

  MadiUser({
    String? id,
    required this.name,
    this.bio = '',
    this.location = '',
    this.avatarUrl,
    this.madiCredits = 3.0, // New users get 3 starter credits
    List<Skill>? offerings,
    List<Skill>? seekings,
    DateTime? joinedAt,
  })  : id = id ?? const Uuid().v4(),
        offerings = offerings ?? [],
        seekings = seekings ?? [],
        joinedAt = joinedAt ?? DateTime.now();

  /// Convenience: all skills combined.
  List<Skill> get allSkills => [...offerings, ...seekings];

  /// The initials for the default avatar.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Create a MadiUser from a JSON map (backend deserialization).
  factory MadiUser.fromJson(Map<String, dynamic> json) {
    return MadiUser(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      madiCredits: (json['madi_credits'] as num?)?.toDouble() ?? 3.0,
      offerings: (json['offerings'] as List<dynamic>?)
              ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      seekings: (json['seekings'] as List<dynamic>?)
              ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  /// Serialize to JSON map for backend persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'location': location,
      'avatar_url': avatarUrl,
      'madi_credits': madiCredits,
      'offerings': offerings.map((s) => s.toJson()).toList(),
      'seekings': seekings.map((s) => s.toJson()).toList(),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  /// Returns a copy with modified fields — useful for immutable state updates.
  MadiUser copyWith({
    String? name,
    String? bio,
    String? location,
    String? avatarUrl,
    double? madiCredits,
    List<Skill>? offerings,
    List<Skill>? seekings,
  }) {
    return MadiUser(
      id: id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      madiCredits: madiCredits ?? this.madiCredits,
      offerings: offerings ?? this.offerings,
      seekings: seekings ?? this.seekings,
      joinedAt: joinedAt,
    );
  }

  @override
  String toString() => 'MadiUser($name, credits: $madiCredits)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MadiUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
