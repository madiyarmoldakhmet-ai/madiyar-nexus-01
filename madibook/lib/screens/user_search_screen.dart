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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: query.trim())
          .get();

      setState(() {
        _searchResults = snapshot.docs
            .map((doc) => doc.data())
            .toList();
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
            hintText: 'Search by nickname...',
            hintStyle: TextStyle(color: MadiColors.textMuted),
            border: InputBorder.none,
          ),
          onChanged: _searchUsers,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Enter a nickname to find friends'
                        : 'No users found',
                    style: const TextStyle(color: MadiColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    final nickname = user['nickname'] ?? 'Unknown';
                    final uid = user['uid'] ?? '';

                    // Don't show current user in search results
                    if (uid == currentUserId) return const SizedBox.shrink();

                    return Card(
                      color: MadiColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MadiRadius.md),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: MadiColors.indigo,
                          child: Text(
                            nickname[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          nickname,
                          style: const TextStyle(color: MadiColors.textPrimary),
                        ),
                        trailing: const Icon(Icons.chat_outlined,
                            color: MadiColors.gold),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivateChatScreen(
                                otherUserId: uid,
                                otherUserNickname: nickname,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
