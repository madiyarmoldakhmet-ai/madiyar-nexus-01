import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'skill_model.dart';

/// Roles in the Nexus ecosystem.
enum UserRole { talent, mentor, expert }

/// Represents a Nexus user profile.
class NexusUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String bio;
  final String location;
  final String? avatarUrl;
  final UserRole role;
  final String specialty;
  final String? fcmToken;
  double nexusCredits;
  final List<Skill> offerings;
  final List<Skill> seekings;
  final bool isVerified;
  final DateTime joinedAt;

  NexusUser({
    String? id,
    required this.name,
    this.username = '',
    this.email = '',
    this.bio = '',
    this.location = '',
    this.avatarUrl,
    this.role = UserRole.talent,
    this.specialty = '',
    this.fcmToken,
    this.nexusCredits = 3.0,
    this.isVerified = false,
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

  /// Create a NexusUser from a JSON map (backend deserialization).
  factory NexusUser.fromJson(Map<String, dynamic> json, [String? docId]) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? docId ?? '';
    return NexusUser(
      id: id,
      name: json['name'] as String? ?? 'User',
      username: json['username'] as String? ?? json['name'] as String? ?? 'user',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String?),
        orElse: () => UserRole.talent,
      ),
      specialty: json['specialty'] as String? ?? '',
      fcmToken: json['fcm_token'] as String?,
      nexusCredits: (json['nexus_credits'] as num?)?.toDouble() ?? 
                    (json['nexus_credits'] as num?)?.toDouble() ?? 3.0,
      offerings: (json['offerings'] as List<dynamic>?)
              ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      seekings: (json['seekings'] as List<dynamic>?)
              ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      isVerified: json['is_verified'] as bool? ?? false,
      joinedAt: _parseDateTime(json['joined_at'] ?? json['createdAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }

  /// Serialize to JSON map for backend persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'location': location,
      'avatar_url': avatarUrl,
      'role': role.name,
      'specialty': specialty,
      'fcm_token': fcmToken,
      'nexus_credits': nexusCredits,
      'offerings': offerings.map((s) => s.toJson()).toList(),
      'seekings': seekings.map((s) => s.toJson()).toList(),
      'is_verified': isVerified,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  /// Returns a copy with modified fields — useful for immutable state updates.
  NexusUser copyWith({
    String? name,
    String? username,
    String? email,
    String? bio,
    String? location,
    String? avatarUrl,
    UserRole? role,
    String? specialty,
    String? fcmToken,
    double? nexusCredits,
    List<Skill>? offerings,
    List<Skill>? seekings,
    bool? isVerified,
  }) {
    return NexusUser(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      fcmToken: fcmToken ?? this.fcmToken,
      nexusCredits: nexusCredits ?? this.nexusCredits,
      offerings: offerings ?? this.offerings,
      seekings: seekings ?? this.seekings,
      isVerified: isVerified ?? this.isVerified,
      joinedAt: joinedAt,
    );
  }

  @override
  String toString() => 'NexusUser($name, role: ${role.name}, specialty: $specialty)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NexusUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
