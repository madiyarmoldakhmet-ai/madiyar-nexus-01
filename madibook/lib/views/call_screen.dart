import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  final String channelName;
  final String? channelId;
  final String? remoteUserName;
  final bool? isVideo;
  final bool? isBroadcaster;

  const CallScreen({
    super.key, 
    this.channelName = 'Unknown',
    this.channelId,
    this.remoteUserName,
    this.isVideo,
    this.isBroadcaster,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Call: $channelName')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Calls are disabled on Web to ensure stability.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('End Call'),
            ),
          ],
        ),
      ),
    );
  }
}
