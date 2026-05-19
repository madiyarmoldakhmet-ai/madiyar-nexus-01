import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  StreamSubscription<QuerySnapshot>? _subscription;
  
  // Track the exact initialization time to avoid showing older unread messages on start
  DateTime? _appStartTime;

  /// Compatibility initialize method
  Future<void> initialize() async {
    debugPrint('[NotificationService] Initialized.');
  }

  /// Compatibility FCM Token method
  Future<void> updateFcmToken(String userId) async {
    debugPrint('[NotificationService] FCM Token update skipped on Web.');
  }

  /// Starts listening to real-time incoming messages across all chat collections.
  void startListening() {
    // 1. Cancel previous subscription if active
    stopListening();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[NotificationService] No authenticated user found. Skipping listener.');
        return;
      }

      _appStartTime = DateTime.now();
      debugPrint('[NotificationService] Started listening at $_appStartTime for user: ${user.uid}');

      // 2. Setup the real-time query using collectionGroup
      _subscription = FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('receiverId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                _handleNewMessage(change.doc);
              }
            }
          }, onError: (error) {
            debugPrint('[NotificationService] Error listening to messages: $error');
          });
    } catch (e) {
      debugPrint('[NotificationService] Failed to start listening (Firebase might not be initialized): $e');
    }
  }

  /// Stop listening to notifications (e.g., on logout)
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _appStartTime = null;
    debugPrint('[NotificationService] Listener stopped.');
  }

  /// Inspect and trigger notification if it passes checks
  void _handleNewMessage(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    // Extract timestamp
    final dynamic rawTimestamp = data['timestamp'];
    DateTime messageTime;

    if (rawTimestamp is Timestamp) {
      messageTime = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      messageTime = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      messageTime = DateTime.now();
    }

    // 3. Protection check: Only notify for messages sent strictly AFTER service initialization
    if (_appStartTime != null && messageTime.isBefore(_appStartTime!)) {
      debugPrint('[NotificationService] Message ignored (sent before start: $messageTime)');
      return;
    }

    // Extract payload with safe fallbacks
    final senderName = data['senderName'] as String? ?? 'New Message';
    final text = data['text'] as String? ?? 'Sent a file/image';
    final senderAvatar = data['senderAvatar'] as String? ?? '';

    // 4. Trigger premium UI notification overlay
    _showPremiumNotification(
      senderName: senderName,
      text: text,
      avatarUrl: senderAvatar,
    );
  }

  /// Renders a beautiful premium dark overlay notification
  void _showPremiumNotification({
    required String senderName,
    required String text,
    required String avatarUrl,
  }) {
    showSimpleNotification(
      // Title: Sender name styled in blood red
      Text(
        senderName,
        style: GoogleFonts.oswald(
          color: const Color(0xFFD32F2F), // Blood Red
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      // Subtitle: Message body styled with Oswald, maximum 1 line
      subtitle: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.oswald(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w300,
        ),
      ),
      // Leading widget: circular avatar with fallback placholder
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF2C2C2C),
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person_rounded, color: Color(0xFFD32F2F))
              : null,
        ),
      ),
      // Premium aesthetics: Dark background and subtle borders
      background: const Color(0xFF121212), // Deep Dark
      duration: const Duration(seconds: 4),
      position: NotificationPosition.top,
      slideDismissDirection: DismissDirection.horizontal, // Swipe sideways to dismiss
    );
  }
}
