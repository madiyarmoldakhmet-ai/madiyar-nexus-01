import 'package:uuid/uuid.dart';

/// Represents a talent showcase project in Nexus.
class NexusProject {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final String category; // e.g., "Football", "Robotics", "FPV"
  final DateTime createdAt;
  int supportCount;
  final List<String> supportedBy; // List of User IDs
  final bool quietMode; // If true, only verified users can comment/interact

  NexusProject({
    String? id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    required this.category,
    DateTime? createdAt,
    this.supportCount = 0,
    List<String>? supportedBy,
    this.quietMode = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        supportedBy = supportedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'support_count': supportCount,
      'supported_by': supportedBy,
      'quiet_mode': quietMode,
    };
  }

  factory NexusProject.fromJson(Map<String, dynamic> json) {
    return NexusProject(
      id: json['id'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      supportCount: json['support_count'] ?? 0,
      supportedBy: List<String>.from(json['supported_by'] ?? []),
      quietMode: json['quiet_mode'] ?? false,
    );
  }
}
