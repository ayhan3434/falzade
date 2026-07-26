import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/user_service.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/services/notification_service.dart';
import 'package:falcim/screens/chat_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserProfileScreen({super.key, required this.userData});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _userService = UserService();
  final _postService = PostService();
  final _notificationService = NotificationService();
  bool _isFollowing = false;
  bool _isBlocked = false;
  bool _loadingFollow = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final following = await _userService.isFollowing(widget.userData['uid']);
    final blocked = await _userService.isBlocked(widget.userData['uid']);
    setState(() {
      _isFollowing = following;
      _isBlocked = blocked;
    });
  }

  String _getSignEmoji(String sign) {
    final signs = {
      'Koç': '♈',
      'Boğa': '♉',
      'İkizler': '♊',
      'Yengeç': '♋',
      'Aslan': '♌',
      'Başak': '♍',
      'Terazi': '♎',
      'Akrep': '♏',
      'Yay': '♐',
      'Oğlak': '♑',
      'Kova': '♒',
      'Balık': '♓',
    };
    return signs[sign] ?? '⭐';
  }

  Future<void> _showBlockDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.purple1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isBlocked ? 'Engeli Kaldır' : 'Kullanıcıyı Engelle',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: _isBlocked ? AppTheme.gold : Colors.redAccent,
            fontSize: 15,
          ),
        ),
        content: Text(
          _isBlocked
              ? '${widget.userData['username']} adlı kullanıcının engelini kaldırmak istiyor musun?'
              : '${widget.userData['username']} adlı kullanıcıyı engellemek istiyor musun? Birbirinizin gönderilerini göremeyeceksiniz.',
          style: const TextStyle(
              color: AppTheme.muted,
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Vazgeç', style: TextStyle(color: AppTheme.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _isBlocked ? 'Engeli Kaldır' : 'Engelle',
              style: TextStyle(
                  color: _isBlocked ? AppTheme.gold : Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.toggleBlock(widget.userData['uid']);
      await _checkStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBlocked
                ? 'Engel kaldırıldı.'
                : '${widget.userData['username']} engellendi.'),
            backgroundColor: AppTheme.violet,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showPostDetail(
      BuildContext context, String postId, Map<String, dynamic> data) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.void_,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final likes = List<String>.from(data['likes'] ?? []);
          final isLiked = likes.contains(currentUid);

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.muted,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(data['fortuneEmoji'] ?? '🔮',
                                style: const TextStyle(fontSize: 60)),
                            const SizedBox(height: 12),
                            Text(data['fortuneType'] ?? '',
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 18,
                                    color: AppTheme.white,
                                    letterSpacing: 1)),
                            if ((data['caption'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(data['caption'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 13,
                                      color: AppTheme.muted)),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.purple3.withOpacity(0.4)),
                              ),
                              child: Text(data['fortuneResult'] ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.muted,
                                      height: 1.8)),
                            ),
                            const SizedBox(height: 16),
                            // Beğeni butonu
                            GestureDetector(
                              onTap: () async {
                                await _postService.toggleLike(postId);
                                if (!isLiked) {
                                  await _notificationService.sendNotification(
                                    toUid: widget.userData['uid'],
                                    type: 'like',
                                    postId: postId,
                                  );
                                }
                                setModalState(() {
                                  if (isLiked)
                                    likes.remove(currentUid);
                                  else
                                    likes.add(currentUid);
                                  data['likes'] = likes;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isLiked
                                      ? AppTheme.violet.withOpacity(0.3)
                                      : AppTheme.purple1.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isLiked
                                          ? AppTheme.violet
                                          : AppTheme.purple3.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(isLiked ? '❤️' : '🤍',
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text('${likes.length} Beğeni',
                                        style: const TextStyle(
                                            color: AppTheme.white,
                                            fontFamily: 'Nunito',
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Yorumlar',
                                  style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 13,
                                      color: AppTheme.gold,
                                      letterSpacing: 1)),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(postId)
                                  .collection('comments')
                                  .orderBy('createdAt', descending: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text('Henüz yorum yok 🔮',
                                        style: TextStyle(
                                            color: AppTheme.muted,
                                            fontFamily: 'Nunito',
                                            fontSize: 13)),
                                  );
                                }
                                return Column(
                                  children: snapshot.data!.docs.map((doc) {
                                    final comment =
                                        doc.data() as Map<String, dynamic>;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(comment['sign'] ?? '⭐',
                                              style: const TextStyle(
                                                  fontSize: 22)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(comment['username'] ?? '',
                                                    style: const TextStyle(
                                                        color: AppTheme.gold,
                                                        fontFamily: 'Nunito',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12)),
                                                Text(comment['comment'] ?? '',
                                                    style: const TextStyle(
                                                        color: AppTheme.white,
                                                        fontFamily: 'Nunito',
                                                        fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.purple2,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppTheme.purple3.withOpacity(0.4)),
                              ),
                              child: TextField(
                                controller: commentController,
                                style: const TextStyle(
                                    color: AppTheme.white,
                                    fontFamily: 'Nunito'),
                                decoration: const InputDecoration(
                                  hintText: 'Yorum yaz...',
                                  hintStyle: TextStyle(color: AppTheme.muted),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (commentController.text.isNotEmpty) {
                                final comment = commentController.text.trim();
                                await _postService.addComment(
                                    postId: postId, comment: comment);
                                await _notificationService.sendNotification(
                                  toUid: widget.userData['uid'],
                                  type: 'comment',
                                  postId: postId,
                                  comment: comment,
                                );
                                commentController.clear();
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  AppTheme.violet,
                                  AppTheme.purple3
                                ]),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userData['name'] ?? '';
    final surname = widget.userData['surname'] ?? '';
    final username = widget.userData['username'] ?? '';
    final sign = widget.userData['sign'] ?? '';
    final signEmoji = _getSignEmoji(sign);
    final uid = widget.userData['uid'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(context, username),
                  _buildProfileTop(signEmoji, uid),
                  _buildProfileInfo(name, surname, sign, signEmoji),
                  _buildFollowButton(uid),
                  _buildMessageButton(),
                  _buildBlockButton(),
                  const SizedBox(height: 8),
                  _buildDivider(),
                ],
              ),
            ),
          ],
          body: _isBlocked ? _buildBlockedView() : _buildPostsGrid(uid),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppTheme.purple1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppTheme.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Text(username,
              style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppTheme.white,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildProfileTop(String signEmoji, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [AppTheme.gold, AppTheme.violet, AppTheme.rose]),
            ),
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppTheme.purple2, AppTheme.violet])),
              child: Center(
                  child: Text(signEmoji, style: const TextStyle(fontSize: 36))),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final postCount = data?['postCount'] ?? 0;
                final followers = (data?['followers'] as List?)?.length ?? 0;
                final following = (data?['following'] as List?)?.length ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('$postCount', 'Gönderi'),
                    _buildStat('$followers', 'Takipçi'),
                    _buildStat('$following', 'Takip'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(number,
            style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.muted, fontFamily: 'Nunito')),
      ],
    );
  }

  Widget _buildProfileInfo(
      String name, String surname, String sign, String signEmoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name $surname ✦',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  fontFamily: 'Nunito')),
          const SizedBox(height: 3),
          Text('$signEmoji $sign Burcu',
              style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.gold)),
        ],
      ),
    );
  }

  Widget _buildFollowButton(String uid) {
    if (_isBlocked) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: _loadingFollow
            ? null
            : () async {
                setState(() => _loadingFollow = true);
                await _userService.toggleFollow(uid);
                await _checkStatus();
                setState(() => _loadingFollow = false);
              },
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
            gradient: _isFollowing
                ? null
                : const LinearGradient(
                    colors: [AppTheme.violet, AppTheme.purple3]),
            border: _isFollowing
                ? Border.all(color: AppTheme.purple3.withOpacity(0.6))
                : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: _loadingFollow
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(_isFollowing ? 'Takiptesin ✓' : '✦ Takip Et',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: _isFollowing ? AppTheme.muted : AppTheme.white,
                        letterSpacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageButton() {
    if (_isBlocked) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                      otherUid: widget.userData['uid'],
                      otherUserData: widget.userData)));
        },
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
              border: Border.all(color: AppTheme.purple3.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
              child: Text('💬 Mesaj Gönder',
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: AppTheme.white,
                      letterSpacing: 1))),
        ),
      ),
    );
  }

  Widget _buildBlockButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: _showBlockDialog,
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(
                color: _isBlocked
                    ? AppTheme.gold.withOpacity(0.5)
                    : Colors.redAccent.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              _isBlocked ? '🔓 Engeli Kaldır' : '🚫 Engelle',
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 13,
                  color: _isBlocked ? AppTheme.gold : Colors.redAccent,
                  letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🚫', style: TextStyle(fontSize: 50)),
          SizedBox(height: 12),
          Text('Bu kullanıcıyı engelledin',
              style: TextStyle(
                  fontFamily: 'Cinzel', fontSize: 14, color: AppTheme.muted)),
          SizedBox(height: 6),
          Text('Gönderilerini görmek için engeli kaldır',
              style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.muted)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppTheme.purple3.withOpacity(0.3));
  }

  Widget _buildPostsGrid(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getProfilePosts(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔮', style: TextStyle(fontSize: 50)),
                SizedBox(height: 12),
                Text('Henüz gönderi yok',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        color: AppTheme.muted)),
              ],
            ),
          );
        }

        final posts = snapshot.data!.docs;
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () => _showPostDetail(context, posts[index].id, data),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  AppTheme.purple1,
                  AppTheme.purple2.withOpacity(0.8)
                ])),
                child: Stack(
                  children: [
                    Center(
                        child: Text(data['fortuneEmoji'] ?? '🔮',
                            style: const TextStyle(fontSize: 36))),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(data['fortuneType'] ?? '',
                            style: const TextStyle(
                                fontSize: 7,
                                color: AppTheme.gold,
                                fontFamily: 'Cinzel')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
