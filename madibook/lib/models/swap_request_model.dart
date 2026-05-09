import 'package:uuid/uuid.dart';

/// The lifecycle of a swap request.
enum SwapStatus {
  pending,   // Sent, waiting for response
  accepted,  // Both sides agreed
  declined,  // Receiver declined
  completed, // Session happened, credits transferred
  cancelled, // Sender withdrew the request
}

/// Represents a swap request between two users.
///
/// User A (requester) wants to learn [skillRequested] from User B (receiver).
/// In return, User A offers to teach [skillOffered].
/// When the session completes, 1 Madi-Credit is transferred from learner to teacher.
class SwapRequest {
  final String id;
  final String requesterId;
  final String receiverId;
  final String skillRequested;  // What the requester wants to learn
  final String skillOffered;    // What the requester offers in return
  final String? message;        // Optional intro message
  SwapStatus status;
  final DateTime createdAt;
  DateTime? respondedAt;
  DateTime? completedAt;

  SwapRequest({
    String? id,
    required this.requesterId,
    required this.receiverId,
    required this.skillRequested,
    required this.skillOffered,
    this.message,
    this.status = SwapStatus.pending,
    DateTime? createdAt,
    this.respondedAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isPending => status == SwapStatus.pending;
  bool get isAccepted => status == SwapStatus.accepted;
  bool get isCompleted => status == SwapStatus.completed;

  /// Create from JSON (backend deserialization).
  factory SwapRequest.fromJson(Map<String, dynamic> json) {
    return SwapRequest(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId: json['receiver_id'] as String,
      skillRequested: json['skill_requested'] as String,
      skillOffered: json['skill_offered'] as String,
      message: json['message'] as String?,
      status: SwapStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SwapStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Serialize to JSON for backend persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'receiver_id': receiverId,
      'skill_requested': skillRequested,
      'skill_offered': skillOffered,
      'message': message,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'SwapRequest($skillOffered ⇄ $skillRequested, ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwapRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
