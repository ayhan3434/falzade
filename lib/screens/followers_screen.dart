import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/user_service.dart';
import 'package:falcim/screens/user_profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final List<String> uids;
  final String title;

  const FollowersScreen({
    super.key,
    required this.uids,
    required this.title,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final _userService = UserService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppTheme.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: Text(
              widget.title,
              style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text('(${widget.uids.length})',
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 14, color: AppTheme.muted)),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (widget.uids.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔮', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text(
              widget.title == 'Takipçiler'
                  ? 'Henüz takipçi yok'
                  : 'Henüz kimse takip edilmiyor',
              style: const TextStyle(
                  fontFamily: 'Cinzel', fontSize: 14, color: AppTheme.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.uids.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uids[index])
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox(height: 70);
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data == null) return const SizedBox();

            final sign = data['sign'] ?? '';
            final signEmoji = _getSignEmoji(sign);

            return FutureBuilder<bool>(
              future: _userService.isFollowing(data['uid'] ?? ''),
              builder: (context, followSnapshot) {
                final isFollowing = followSnapshot.data ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userData: data),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [AppTheme.gold, AppTheme.violet]),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.purple2),
                            child: Center(
                                child: Text(signEmoji,
                                    style: const TextStyle(fontSize: 22))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['username'] ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white)),
                              Text('$signEmoji $sign Burcu',
                                  style: const TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.gold)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await _userService.toggleFollow(data['uid'] ?? '');
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isFollowing
                                  ? null
                                  : const LinearGradient(colors: [
                                      AppTheme.violet,
                                      AppTheme.purple3
                                    ]),
                              border: isFollowing
                                  ? Border.all(
                                      color: AppTheme.purple3.withOpacity(0.6))
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isFollowing ? 'Takipte' : 'Takip Et',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 11,
                                  color: isFollowing
                                      ? AppTheme.muted
                                      : AppTheme.white,
                                  letterSpacing: 0.5),
                            ),
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
      },
    );
  }
}
