import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/auth_service.dart';
import 'private_chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthService>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MadiColors.scaffoldDark,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: MadiColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search by name, username or email...',
            hintStyle: TextStyle(color: MadiColors.textMuted),
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUsers = snapshot.data?.docs ?? [];
          debugPrint('DEBUG: [Search] Total users in Firestore: ${allUsers.length}');

          final results = allUsers.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = data['uid'] ?? data['id'] ?? doc.id;
            
            // Exclude self (robust check)
            if (id == currentUserId) return false;

            if (_searchQuery.isEmpty) return true; 

            final name = (data['name'] ?? '').toString().toLowerCase();
            final username = (data['username'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();

            return name.contains(query) || 
                   username.contains(query) || 
                   email.contains(query);
          }).toList();

          if (results.isEmpty) {
            return const Center(
              child: Text('No users found', 
                style: TextStyle(color: MadiColors.textMuted)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final doc = results[index];
              final user = doc.data() as Map<String, dynamic>;
              final name = user['name'] ?? 'Unknown';
              final id = user['uid'] ?? user['id'] ?? doc.id;

              return Card(
                color: MadiColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: MadiColors.indigo,
                    child: Text(name[0].toUpperCase(), 
                      style: const TextStyle(color: Colors.white)),
                  ),
                  title: Row(
                    children: [
                      Text(name, 
                        style: const TextStyle(color: MadiColors.textPrimary)),
                      if (user['role'] != null && user['role'] != 'talent') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: user['role'] == 'expert' ? Colors.purpleAccent.withValues(alpha: 0.1) : MadiColors.emerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: user['role'] == 'expert' ? Colors.purpleAccent : MadiColors.emerald, width: 0.5),
                          ),
                          child: Text(
                            user['role'].toString().toUpperCase(),
                            style: TextStyle(
                              color: user['role'] == 'expert' ? Colors.purpleAccent : MadiColors.emerald,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(user['username'] ?? user['email'] ?? '',
                    style: const TextStyle(color: MadiColors.textMuted, fontSize: 12)),
                  trailing: const Icon(Icons.chat_outlined, color: MadiColors.gold),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivateChatScreen(
                          otherUserId: id,
                          otherUserName: name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
