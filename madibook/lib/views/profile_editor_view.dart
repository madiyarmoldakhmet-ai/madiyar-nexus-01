import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../view_models/app_state.dart';

/// Profile Editor — edit name, bio, location, and achievements.
class ProfileEditorView extends StatefulWidget {
  const ProfileEditorView({super.key});

  @override
  State<ProfileEditorView> createState() => _ProfileEditorViewState();
}

class _ProfileEditorViewState extends State<ProfileEditorView> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  final _achievementController = TextEditingController();

  // Pre-populated achievements for Madi.
  final List<String> _achievements = [
    'WorldSkills Winner',
    'FPV Pilot — Freestyle',
    'Robotics Olympiad — 1st Place',
    'CTF Hacker',
    'Madibook Lead Developer',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _locationController = TextEditingController(text: user.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MadiColors.scaffoldDark,
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save',
                style: TextStyle(
                    color: MadiColors.gold, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [MadiColors.gold, MadiColors.goldDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MadiColors.gold.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 34,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: MadiColors.cardDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: MadiColors.gold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Fields
            _buildTextField('Name', _nameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildTextField('Location', _locationController, Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildTextField('Bio', _bioController, Icons.info_outline_rounded,
                maxLines: 3),

            const SizedBox(height: 32),

            // Achievements
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: MadiColors.gold, size: 20),
                const SizedBox(width: 8),
                Text('Achievements',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),

            // Achievement chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _achievements.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: MadiColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(MadiRadius.full),
                    border: Border.all(
                        color: MadiColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: MadiColors.gold),
                      const SizedBox(width: 6),
                      Text(a,
                          style: const TextStyle(
                              color: MadiColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () =>
                            setState(() => _achievements.remove(a)),
                        child: Icon(Icons.close_rounded,
                            size: 14,
                            color: MadiColors.gold.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Add achievement
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _achievementController,
                    style:
                        const TextStyle(color: MadiColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add achievement...',
                      hintStyle: TextStyle(color: MadiColors.textMuted),
                      filled: true,
                      fillColor: MadiColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(MadiRadius.md),
                        borderSide:
                            const BorderSide(color: MadiColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(MadiRadius.md),
                        borderSide:
                            const BorderSide(color: MadiColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(MadiRadius.md),
                        borderSide: const BorderSide(
                            color: MadiColors.gold, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: MadiColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.black, size: 20),
                    onPressed: () {
                      if (_achievementController.text.trim().isNotEmpty) {
                        setState(() {
                          _achievements
                              .add(_achievementController.text.trim());
                          _achievementController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: MadiColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: MadiColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: MadiColors.textMuted, size: 20),
            filled: true,
            fillColor: MadiColors.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MadiRadius.md),
              borderSide: const BorderSide(color: MadiColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MadiRadius.md),
              borderSide: const BorderSide(color: MadiColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MadiRadius.md),
              borderSide:
                  const BorderSide(color: MadiColors.gold, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    final appState = context.read<AppState>();
    appState.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: MadiColors.emerald, size: 20),
            SizedBox(width: 10),
            Text('Profile updated!'),
          ],
        ),
      ),
    );
  }
}
