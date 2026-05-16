import 'package:flutter/foundation.dart';

/// Dummy Service to handle Audio and Video calls.
/// Agora SDK has been commented out to ensure Web compatibility for deployment.
class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  Future<void> initialize() async {
    if (_isInitialized) return;
    debugPrint('⚠️ Agora RTC is disabled for Web deployment.');
    _isInitialized = true;
  }

  Future<void> startCall({required String channelId, bool isVideo = true}) async {
    debugPrint('📞 Call started (Mock Mode): $channelId');
    _isVideoEnabled = isVideo;
  }

  Future<void> toggleMute(bool muted) async {
    _isMuted = muted;
    debugPrint(muted ? '🔇 Microphone muted' : '🔊 Microphone unmuted');
  }

  Future<void> toggleVideo(bool enabled) async {
    _isVideoEnabled = enabled;
    debugPrint(enabled ? '📹 Video enabled' : '📵 Video disabled');
  }

  Future<void> switchCamera() async {
    debugPrint('🔄 Camera switched');
  }

  Future<void> endCall() async {
    _isMuted = false;
    _isVideoEnabled = true;
    debugPrint('📴 Call ended');
  }

  Future<void> dispose() async {
    _isInitialized = false;
    debugPrint('🗑️ Agora engine disposed');
  }

  // Getters
  dynamic get engine => null;
  bool get isInitialized => _isInitialized;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
}
