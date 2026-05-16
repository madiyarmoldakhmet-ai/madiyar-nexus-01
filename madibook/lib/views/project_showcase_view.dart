import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../models/project_model.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Showcase View
// ──────────────────────────────────────────────────────────────────────────────

class ProjectShowcaseView extends StatefulWidget {
  const ProjectShowcaseView({super.key});

  @override
  State<ProjectShowcaseView> createState() => _ProjectShowcaseViewState();
}

class _ProjectShowcaseViewState extends State<ProjectShowcaseView> {
  final CollectionReference _projects =
      FirebaseFirestore.instance.collection('projects');

  // ── Upload bytes → Firebase Storage → return download URL ──────────────────
  Future<String> _uploadToStorage(
    Uint8List bytes,
    String mediaType, {
    void Function(double)? onProgress,
  }) async {
    final ext = mediaType == 'video' ? 'mp4' : 'jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = FirebaseStorage.instance.ref().child('projects/$fileName');

    final contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
    final task = ref.putData(bytes, SettableMetadata(contentType: contentType));

    task.snapshotEvents.listen((snap) {
      if (snap.totalBytes > 0 && onProgress != null) {
        onProgress(snap.bytesTransferred / snap.totalBytes);
      }
    });

    await task;
    return await ref.getDownloadURL();
  }

  // ── Save project document to Firestore ─────────────────────────────────────
  Future<void> _saveToFirestore({
    required String title,
    required String description,
    required String mediaUrl,
    required String mediaType,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Talent';
    await _projects.add({
      'title': title,
      'description': description,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'imageUrl': mediaUrl, // backwards-compat field
      'timestamp': FieldValue.serverTimestamp(),
      'authorId': uid,
      'owner_name': name,
      'support_count': 0,
      'category': 'Showcase',
    });
  }

  // ── Create-project dialog ──────────────────────────────────────────────────
  void _createNewProject() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // Dialog-local state
    Uint8List? dialogBytes;
    String dialogMediaType = 'image';
    bool dialogUploading = false;
    double dialogProgress = 0.0;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          // ── pick media ──────────────────────────────────────────────────
          Future<void> pickMedia(String type) async {
            final picker = ImagePicker();
            XFile? file;
            if (type == 'image') {
              file = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 85);
            } else {
              file = await picker.pickVideo(source: ImageSource.gallery);
            }
            if (file == null) return;
            final bytes = await file.readAsBytes();
            setDialog(() {
              dialogBytes = bytes;
              dialogMediaType = type;
            });
          }

          // ── submit ──────────────────────────────────────────────────────
          Future<void> submit() async {
            if (titleCtrl.text.trim().isEmpty) return;
            setDialog(() => dialogUploading = true);

            try {
              String mediaUrl = '';
              if (dialogBytes != null) {
                mediaUrl = await _uploadToStorage(
                  dialogBytes!,
                  dialogMediaType,
                  onProgress: (p) => setDialog(() => dialogProgress = p),
                );
              }

              await _saveToFirestore(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                mediaUrl: mediaUrl,
                mediaType: dialogMediaType,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Project posted!',
                        style: GoogleFonts.oswald(fontSize: 16)),
                    backgroundColor: MadiColors.bloodRed,
                  ),
                );
              }
            } catch (e) {
              setDialog(() => dialogUploading = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upload failed: $e'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          }

          // ── Dialog UI ───────────────────────────────────────────────────
          return AlertDialog(
            backgroundColor: const Color(0xFF1A0A0A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: MadiColors.bloodRed, width: 2),
            ),
            title: Text(
              'New Showcase Project',
              style: GoogleFonts.oswald(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Title ────────────────────────────────────────────
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Project Title *',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: MadiColors.bloodRed),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Description ──────────────────────────────────────
                    TextField(
                      controller: descCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: MadiColors.bloodRed),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Media preview ─────────────────────────────────────
                    if (dialogBytes != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: dialogMediaType == 'image'
                            ? Image.memory(
                                dialogBytes!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 100,
                                color: Colors.black54,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.videocam_rounded,
                                          color: Colors.white70, size: 40),
                                      SizedBox(height: 6),
                                      Text('Video selected',
                                          style:
                                              TextStyle(color: Colors.white60)),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Media pick buttons ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: dialogUploading
                                ? null
                                : () => pickMedia('image'),
                            icon: const Icon(Icons.image_rounded, size: 18),
                            label: const Text('Photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: dialogUploading
                                ? null
                                : () => pickMedia('video'),
                            icon: const Icon(Icons.videocam_rounded, size: 18),
                            label: const Text('Video'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Upload progress bar ───────────────────────────────
                    if (dialogUploading) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: dialogProgress > 0 ? dialogProgress : null,
                          backgroundColor: Colors.white12,
                          color: MadiColors.bloodRed,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          dialogProgress > 0
                              ? 'Uploading ${(dialogProgress * 100).toStringAsFixed(0)}%...'
                              : 'Preparing upload...',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: dialogUploading
                    ? null
                    : () {
                        Navigator.pop(ctx);
                      },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: dialogUploading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MadiColors.bloodRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      MadiColors.bloodRed.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: dialogUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Post',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('The world is empty...',
              style: GoogleFonts.coveredByYourGrace(
                  color: Colors.white, fontSize: 24)),
          const SizedBox(height: 8),
          Text('Post something to be noticed.',
              style: GoogleFonts.coveredByYourGrace(
                  color: MadiColors.textMuted, fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewProject,
            style:
                ElevatedButton.styleFrom(backgroundColor: MadiColors.bloodRed),
            child: const Text('Be the First',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProject,
        backgroundColor: MadiColors.bloodRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _projects.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: MadiColors.bloodRed));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return _buildEmptyState(context);

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final project = NexusProject(
                id: docs[index].id,
                ownerId: data['authorId'] ?? 'anon',
                ownerName: data['owner_name'] ?? 'Showcase User',
                title: data['title'] ?? 'Untitled',
                description: data['description'] ?? '',
                imageUrl: data['mediaUrl'] ?? data['imageUrl'],
                category: data['category'] ?? 'Showcase',
                supportCount: data['support_count'] ?? 0,
              );
              final mediaType = (data['mediaType'] as String?) ?? 'image';
              return _ProjectCard(project: project, mediaType: mediaType);
            },
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Support transfer (Nexus-Credits)
// ──────────────────────────────────────────────────────────────────────────────

Future<void> _supportAuthor(BuildContext context, String authorId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.uid == authorId) return;

  try {
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final supporterRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final authorRef =
          FirebaseFirestore.instance.collection('users').doc(authorId);

      final supporterSnap = await tx.get(supporterRef);
      if (!supporterSnap.exists) throw Exception('User not found');

      final credits =
          (supporterSnap.data()?['nexus_credits'] as num?)?.toDouble() ?? 0.0;
      if (credits < 10.0) throw Exception('Insufficient credits');

      tx.update(supporterRef, {'nexus_credits': FieldValue.increment(-10)});
      tx.update(authorRef, {'nexus_credits': FieldValue.increment(10)});
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('10 Credits transferred!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Project Card
// ──────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final NexusProject project;
  final String mediaType;

  const _ProjectCard({required this.project, this.mediaType = 'image'});

  @override
  Widget build(BuildContext context) {
    final hasMedia = project.imageUrl != null && project.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: MadiColors.ghoulDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: MadiColors.bloodRed.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: MadiColors.bloodRed.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Media thumbnail ─────────────────────────────────────────────
          if (hasMedia)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: mediaType == 'video'
                  ? _VideoPlaceholder(url: project.imageUrl!)
                  : AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        project.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black45,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded,
                                color: MadiColors.bloodRed, size: 48),
                          ),
                        ),
                      ),
                    ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Author row ─────────────────────────────────────────
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: MadiColors.bloodRed,
                      child: Text(
                        project.ownerName.isNotEmpty
                            ? project.ownerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        project.ownerName,
                        style: GoogleFonts.oswald(
                            color: MadiColors.textSecondary, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MadiColors.bloodRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: MadiColors.bloodRed.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        project.category,
                        style: const TextStyle(
                            color: MadiColors.bloodRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Title ─────────────────────────────────────────────
                Text(
                  project.title,
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    project.description,
                    style: GoogleFonts.coveredByYourGrace(
                        color: MadiColors.textMuted, fontSize: 16, height: 1.3),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24),

                // ── Support button ────────────────────────────────────
                _ActionButton(
                  icon: Icons.favorite_rounded,
                  label: 'SUPPORT (${project.supportCount})',
                  color: MadiColors.bloodRed,
                  onPressed: () => _supportAuthor(context, project.ownerId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Video placeholder widget
// ──────────────────────────────────────────────────────────────────────────────

class _VideoPlaceholder extends StatelessWidget {
  final String url;
  const _VideoPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.black87),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MadiColors.bloodRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: MadiColors.bloodRed, width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: MadiColors.bloodRed, size: 48),
              ),
              const SizedBox(height: 8),
              const Text('Video Project',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Action button
// ──────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
