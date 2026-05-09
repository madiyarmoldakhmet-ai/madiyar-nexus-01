import 'package:flutter/material.dart';

// IMPORTANT: Requires adding `agora_rtc_engine: ^6.2.1` to pubspec.yaml
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final bool isBroadcaster;

  const CallScreen({
    super.key,
    required this.channelName,
    required this.isBroadcaster,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Agora Implementation:
    // 1. Initialize Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: 'YOUR_AGORA_APP_ID',
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // 2. Set Callbacks
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() => _remoteUid = null);
        },
      ),
    );

    // 3. Enable Video
    await _engine.enableVideo();
    await _engine.startPreview();

    // 4. Join Channel
    await _engine.joinChannel(
      token: 'YOUR_TOKEN', // Recommended to fetch this from a secure backend
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    
    // Mock setup
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _localUserJoined = true);
    });
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Video Call')),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Waiting for other user to join...',
        textAlign: TextAlign.center,
      );
    }
  }
}
