import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/auth_service.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/services/language_service.dart';
import 'package:falcim/screens/login_screen.dart';
import 'package:falcim/screens/edit_profile_screen.dart';
import 'package:falcim/screens/followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  Map<String, dynamic>? _userData;
  bool _loading = true;
  final _authService = AuthService();
  final _postService = PostService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _userData = doc.exists ? doc.data() : {};
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getSignEmoji(String sign) {
    const signs = {
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

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted)
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    if (!isGoogle) {
      final passwordController = TextEditingController();
      final password = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.purple1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hesabı Sil',
              style: TextStyle(
                  fontFamily: 'Cinzel', color: Colors.redAccent, fontSize: 16)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
                'Hesabını silmek için şifreni gir. Bu işlem geri alınamaz.',
                style: TextStyle(
                    color: AppTheme.muted,
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.5)),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style:
                  const TextStyle(color: AppTheme.white, fontFamily: 'Nunito'),
              decoration: InputDecoration(
                  hintText: 'Şifren',
                  hintStyle: const TextStyle(color: AppTheme.muted),
                  filled: true,
                  fillColor: AppTheme.purple2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none)),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Vazgeç',
                    style: TextStyle(color: AppTheme.muted))),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, passwordController.text),
                child: const Text('Sil',
                    style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      );

      if (password == null || password.isEmpty) return;

      final error = await _authService.deleteAccount(password: password);
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error), backgroundColor: Colors.redAccent));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.purple1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hesabı Sil',
              style: TextStyle(
                  fontFamily: 'Cinzel', color: Colors.redAccent, fontSize: 16)),
          content: const Text(
              'Google hesabınla yeniden doğrulama yapılacak ve hesabın silinecek. Bu işlem geri alınamaz.',
              style: TextStyle(
                  color: AppTheme.muted,
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  height: 1.5)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç',
                    style: TextStyle(color: AppTheme.muted))),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Evet, Sil',
                    style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      );

      if (confirm != true) return;

      final error = await _authService.deleteAccount();
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error), backgroundColor: Colors.redAccent));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      }
    }
  }

  void _showLanguageSelector() {
    final languageService = context.read<LanguageService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.purple1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) =>
            Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('🌍 Dil Seç',
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppTheme.white,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          ...LanguageService.supportedLanguages.map((lang) {
            final isSelected =
                languageService.locale.languageCode == lang['code'];
            return ListTile(
              leading:
                  Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(lang['name']!,
                  style: TextStyle(
                      color: isSelected ? AppTheme.gold : AppTheme.white,
                      fontFamily: 'Nunito',
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle,
                      color: AppTheme.gold, size: 20)
                  : null,
              onTap: () async {
                await languageService.setLocale(lang['code']!);
                if (mounted) Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(
          backgroundColor: AppTheme.deep,
          body: Center(child: CircularProgressIndicator(color: AppTheme.gold)));

    final name = _userData?['name'] ?? '';
    final surname = _userData?['surname'] ?? '';
    final username = _userData?['username'] ?? '';
    final sign = _userData?['sign'] ?? '';
    final bio = _userData?['bio'] ?? '';
    final signEmoji = _getSignEmoji(sign);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(children: [
                _buildHeader(username),
                _buildProfileTop(signEmoji, sign, uid),
                _buildProfileInfo(
                    name, surname, username, sign, signEmoji, bio),
                _buildActionButtons(),
                _buildTabs(),
              ]),
            ),
          ],
          body: _selectedTab == 0
              ? _buildPostsGrid(uid)
              : _buildFortunesList(uid),
        ),
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 36),
          Text('@$username',
              style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppTheme.white,
                  letterSpacing: 1)),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppTheme.purple1,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) =>
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 12),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: BorderRadius.circular(2))),
                  ListTile(
                      leading: const Text('🌍', style: TextStyle(fontSize: 22)),
                      title: const Text('Dil Seç',
                          style: TextStyle(
                              color: AppTheme.white, fontFamily: 'Nunito')),
                      onTap: () {
                        Navigator.pop(context);
                        _showLanguageSelector();
                      }),
                  ListTile(
                      leading: const Icon(Icons.logout, color: AppTheme.white),
                      title: const Text('Çıkış Yap',
                          style: TextStyle(color: AppTheme.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _logout();
                      }),
                  ListTile(
                      leading: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      title: const Text('Hesabı Sil',
                          style: TextStyle(color: Colors.redAccent)),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteAccount();
                      }),
                  const SizedBox(height: 40),
                ]),
              );
            },
            child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppTheme.purple1,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                child: const Icon(Icons.more_horiz,
                    color: AppTheme.white, size: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTop(String signEmoji, String sign, String uid) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppTheme.gold, AppTheme.violet, AppTheme.rose])),
            child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppTheme.purple2, AppTheme.violet])),
                child: Center(
                    child:
                        Text(signEmoji, style: const TextStyle(fontSize: 36)))),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.gold2]),
                      border: Border.all(color: AppTheme.deep, width: 2)),
                  child: Center(
                      child: Text(signEmoji,
                          style: const TextStyle(fontSize: 12))))),
        ]),
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
              final followersList = List<String>.from(data?['followers'] ?? []);
              final followingList = List<String>.from(data?['following'] ?? []);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('$postCount', 'Gönderi', null),
                  _buildStat(
                      '${followersList.length}',
                      'Takipçi',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FollowersScreen(
                                  uids: followersList, title: 'Takipçiler')))),
                  _buildStat(
                      '${followingList.length}',
                      'Takip',
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FollowersScreen(
                                  uids: followingList,
                                  title: 'Takip Edilenler')))),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildStat(String number, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Text(number,
            style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.white)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: onTap != null ? AppTheme.gold : AppTheme.muted,
                fontFamily: 'Nunito')),
      ]),
    );
  }

  Widget _buildProfileInfo(String name, String surname, String username,
      String sign, String signEmoji, String bio) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$name $surname ✦',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
                fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: '@$username'));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('@$username kopyalandı!'),
                backgroundColor: AppTheme.violet,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))));
          },
          child: Row(children: [
            Text('@$username',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: AppTheme.gold,
                    letterSpacing: 0.3)),
            const SizedBox(width: 4),
            const Icon(Icons.copy, color: AppTheme.muted, size: 12),
          ]),
        ),
        const SizedBox(height: 3),
        Text('$signEmoji $sign Burcu',
            style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppTheme.gold)),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(bio,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.muted,
                  fontFamily: 'Nunito',
                  height: 1.5)),
        ],
      ]),
    );
  }

  Widget _buildActionButtons() {
    final languageService = context.read<LanguageService>();
    final currentLang = LanguageService.supportedLanguages.firstWhere(
      (l) => l['code'] == languageService.locale.languageCode,
      orElse: () => {'flag': '🌍', 'name': 'Dil'},
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditProfileScreen(userData: _userData!)));
              if (result == true) _loadUserData();
            },
            child: Container(
                height: 36,
                decoration: BoxDecoration(
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(20)),
                child: const Center(
                    child: Text('✏️ Profili Düzenle',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.white,
                            fontFamily: 'Nunito')))),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _showLanguageSelector,
            child: Container(
                height: 36,
                decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.purple1.withOpacity(0.4)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(currentLang['flag']!,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(currentLang['name']!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.gold,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600)),
                    ]))),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppTheme.purple3.withOpacity(0.3)))),
      child: Row(children: [
        _buildTab(0, Icons.grid_on_outlined, 'Gönderiler'),
        _buildTab(1, Icons.auto_fix_high_outlined, 'Fallarım'),
      ]),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: isSelected ? AppTheme.gold : Colors.transparent,
                      width: 2))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 16, color: isSelected ? AppTheme.gold : AppTheme.muted),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 11,
                    color: isSelected ? AppTheme.gold : AppTheme.muted,
                    letterSpacing: 0.5)),
          ]),
        ),
      ),
    );
  }

  Widget _buildPostsGrid(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getProfilePosts(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🔮', style: TextStyle(fontSize: 50)),
              SizedBox(height: 12),
              Text('Henüz gönderi yok',
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                      color: AppTheme.muted)),
              SizedBox(height: 6),
              Text('Fal çek ve paylaş!',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
            ]),
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
            final postId = posts[index].id;
            return GestureDetector(
              onTap: () => _showPostDetail(context, postId, data),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  AppTheme.purple1,
                  AppTheme.purple2.withOpacity(0.8)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(children: [
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
                                  fontFamily: 'Cinzel')))),
                  Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                      backgroundColor: AppTheme.purple1,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: const Text('Gönderiyi Sil',
                                          style: TextStyle(
                                              fontFamily: 'Cinzel',
                                              color: Colors.redAccent,
                                              fontSize: 14)),
                                      content: const Text(
                                          'Bu gönderiyi silmek istediğine emin misin?',
                                          style: TextStyle(
                                              color: AppTheme.muted,
                                              fontFamily: 'Nunito',
                                              fontSize: 13)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Vazgeç',
                                                style: TextStyle(
                                                    color: AppTheme.muted))),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Sil',
                                                style: TextStyle(
                                                    color: Colors.redAccent))),
                                      ],
                                    ));
                            if (confirm == true)
                              await _postService.deletePost(postId);
                          },
                          child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Center(
                                  child: Text('🗑️',
                                      style: TextStyle(fontSize: 13)))))),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFortunesList(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(
              child: Text('Henüz fal yok 🔮',
                  style: TextStyle(
                      color: AppTheme.muted,
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontStyle: FontStyle.italic)));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.purple1.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.purple3.withOpacity(0.3))),
              child: Row(children: [
                Text(data['fortuneEmoji'] ?? '🔮',
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(data['fortuneType'] ?? '',
                          style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 12,
                              color: AppTheme.gold,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(data['fortuneResult'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.muted,
                              height: 1.4)),
                    ])),
              ]),
            );
          },
        );
      },
    );
  }

  void _showPostDetail(
      BuildContext context, String postId, Map<String, dynamic> data) {
    final commentController = TextEditingController();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.void_,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final likes = List<String>.from(data['likes'] ?? []);
              final isLiked = likes.contains(currentUid);
              return DraggableScrollableSheet(
                initialChildSize: 0.85,
                maxChildSize: 0.95,
                minChildSize: 0.5,
                expand: false,
                builder: (_, scrollController) => Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppTheme.muted,
                              borderRadius: BorderRadius.circular(2)))),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(children: [
                        Text(data['fortuneEmoji'] ?? '🔮',
                            style: const TextStyle(fontSize: 60)),
                        const SizedBox(height: 12),
                        Text(data['fortuneType'] ?? '',
                            style: const TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 18,
                                color: AppTheme.white,
                                letterSpacing: 1)),
                        const SizedBox(height: 20),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: AppTheme.purple1.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.purple3.withOpacity(0.4))),
                            child: Text(data['fortuneResult'] ?? '',
                                style: const TextStyle(
                                    fontFamily: 'Cormorant Garamond',
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.muted,
                                    height: 1.8))),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            await _postService.toggleLike(postId);
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
                                        : AppTheme.purple3.withOpacity(0.4))),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(isLiked ? '❤️' : '🤍',
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text('${likes.length} Beğeni',
                                  style: const TextStyle(
                                      color: AppTheme.white,
                                      fontFamily: 'Nunito',
                                      fontSize: 14)),
                            ]),
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
                                    letterSpacing: 1))),
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
                                snapshot.data!.docs.isEmpty)
                              return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Henüz yorum yok 🔮',
                                      style: TextStyle(
                                          color: AppTheme.muted,
                                          fontFamily: 'Nunito',
                                          fontSize: 13)));
                            return Column(
                              children: snapshot.data!.docs.map((doc) {
                                final comment =
                                    doc.data() as Map<String, dynamic>;
                                final commentId = doc.id;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(comment['sign'] ?? '⭐',
                                            style:
                                                const TextStyle(fontSize: 22)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                  '@${comment['username'] ?? ''}',
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
                                            ])),
                                        GestureDetector(
                                            onTap: () =>
                                                _postService.deleteComment(
                                                    postId: postId,
                                                    commentId: commentId),
                                            child: const Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: 18))),
                                      ]),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: AppTheme.purple2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppTheme.purple3.withOpacity(0.4))),
                        child: TextField(
                            controller: commentController,
                            style: const TextStyle(
                                color: AppTheme.white, fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                                hintText: 'Yorum yaz...',
                                hintStyle: TextStyle(color: AppTheme.muted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12))),
                      )),
                      const SizedBox(width: 8),
                      GestureDetector(
                          onTap: () async {
                            if (commentController.text.isNotEmpty) {
                              await _postService.addComment(
                                  postId: postId,
                                  comment: commentController.text.trim());
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
                                  borderRadius: BorderRadius.circular(22)),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 18))),
                    ]),
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
