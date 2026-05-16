import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/anime_background.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditorView extends StatefulWidget {
  const ProfileEditorView({super.key});

  @override
  State<ProfileEditorView> createState() => _ProfileEditorViewState();
}

class _ProfileEditorViewState extends State<ProfileEditorView> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialtyController = TextEditingController();
  UserRole _selectedRole = UserRole.talent;
  String _selectedStatus = 'single';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _bioController.text = user.bio;
      _specialtyController.text = user.specialty;
      _selectedRole = user.role;
      _selectedStatus = user.relationshipStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'role': _selectedRole.name,
        'relationship_status': _selectedStatus,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update(updatedData);

      // Force a refresh of the user object in AuthService
      // In a real app, you might have a stream listener for the user doc
      debugPrint('DEBUG: Profile updated in Firestore');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: Failed to update profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimeBackground(
      assetPath: 'assets/images/backgrounds/bg_profile.png',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Edit Profile', style: GoogleFonts.oswald(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (!_isLoading)
              IconButton(
                icon: const Icon(Icons.check_rounded, color: MadiColors.bloodRed),
                onPressed: _saveProfile,
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MadiColors.bloodRed)),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.info_outline_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _specialtyController,
                label: 'Specialty (e.g., FPV, Football, Coding)',
                icon: Icons.star_outline_rounded,
              ),
              const SizedBox(height: 24),
              _buildRoleSelector(),
              const SizedBox(height: 24),
              _buildStatusSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am joining as a:',
          style: GoogleFonts.coveredByYourGrace(color: MadiColors.textMuted, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Row(
          children: UserRole.values.map((role) {
            final isSelected = _selectedRole == role;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(role.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedRole = role);
                  },
                  backgroundColor: MadiColors.cardDark,
                  selectedColor: MadiColors.bloodRed.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? MadiColors.bloodRed : MadiColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  side: BorderSide(
                    color: isSelected ? MadiColors.bloodRed : MadiColors.border,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    final statuses = [
      ('single', 'Single / Searching', MadiColors.gold),
      ('in_relationship', 'In Relationship', MadiColors.bloodRed),
      ('complicated', 'It\'s Complicated', MadiColors.indigo),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship Status:',
          style: GoogleFonts.coveredByYourGrace(color: MadiColors.textMuted, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Column(
          children: statuses.map((s) {
            final isSelected = _selectedStatus == s.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedStatus = s.$1),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? s.$3.withValues(alpha: 0.15) : MadiColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? s.$3 : MadiColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: s.$3.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isSelected ? s.$3 : MadiColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.$2,
                        style: TextStyle(
                          color: isSelected ? Colors.white : MadiColors.textMuted,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: s.$3, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: MadiColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.oswald(color: MadiColors.textMuted),
        prefixIcon: Icon(icon, color: MadiColors.bloodRed, size: 20),
        filled: true,
        fillColor: MadiColors.cardDark.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MadiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MadiColors.bloodRed),
        ),
      ),
    );
  }
}
