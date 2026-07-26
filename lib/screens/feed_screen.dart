import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/services/notification_service.dart';
import 'package:falcim/services/chat_service.dart';
import 'package:falcim/screens/notifications_screen.dart';
import 'package:falcim/screens/chats_screen.dart';
import 'package:falcim/constants.dart';
import 'package:falcim/l10n/app_localizations.dart';
import 'package:falcim/services/language_service.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  final _notificationService = NotificationService();
  final _chatService = ChatService();
  final _postService = PostService();
  late TabController _tabController;

  Stream<QuerySnapshot>? _followingStream;
  bool _followingStreamLoaded = false;

  final List<Map<String, String>> _stories = [
    {'emoji': '♈', 'name': 'Koç', 'sign': 'Koç'},
    {'emoji': '♉', 'name': 'Boğa', 'sign': 'Boğa'},
    {'emoji': '♊', 'name': 'İkizler', 'sign': 'İkizler'},
    {'emoji': '♋', 'name': 'Yengeç', 'sign': 'Yengeç'},
    {'emoji': '♌', 'name': 'Aslan', 'sign': 'Aslan'},
    {'emoji': '♍', 'name': 'Başak', 'sign': 'Başak'},
    {'emoji': '♎', 'name': 'Terazi', 'sign': 'Terazi'},
    {'emoji': '♏', 'name': 'Akrep', 'sign': 'Akrep'},
    {'emoji': '♐', 'name': 'Yay', 'sign': 'Yay'},
    {'emoji': '♑', 'name': 'Oğlak', 'sign': 'Oğlak'},
    {'emoji': '♒', 'name': 'Kova', 'sign': 'Kova'},
    {'emoji': '♓', 'name': 'Balık', 'sign': 'Balık'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFollowingStream();
    _tabController.addListener(() {
      if (_tabController.index == 0 && !_followingStreamLoaded)
        _loadFollowingStream();
    });
  }

  Future<void> _loadFollowingStream() async {
    final stream = await _postService.getFollowingPosts();
    if (mounted)
      setState(() {
        _followingStream = stream;
        _followingStreamLoaded = true;
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHoroscopeStory(BuildContext context, Map<String, String> story) {
    final languageService = context.read<LanguageService>();
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black87,
          pageBuilder: (ctx, _, __) => _HoroscopeStoryPage(
              story: story, languageName: languageService.languageName),
          transitionsBuilder: (ctx, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(l10n),
          _buildStories(),
          const Divider(color: Color(0xFF2D1654), thickness: 1, height: 1),
          Container(
            color: AppTheme.deep,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold,
              indicatorWeight: 2,
              labelColor: AppTheme.gold,
              unselectedLabelColor: AppTheme.muted,
              labelStyle: const TextStyle(
                  fontFamily: 'Cinzel', fontSize: 12, letterSpacing: 0.5),
              unselectedLabelStyle:
                  const TextStyle(fontFamily: 'Cinzel', fontSize: 12),
              tabs: [
                Tab(text: '✦ ${l10n.feed}'),
                Tab(text: '🔮 ${l10n.explore}'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFollowingFeed(l10n), _buildExploreFeed(l10n)],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text('✦ FALZADE',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2))),
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            child: StreamBuilder<int>(
              stream: _notificationService.getUnreadCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppTheme.purple1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.4))),
                      child: const Center(
                          child: Text('🔔', style: TextStyle(fontSize: 16)))),
                  if (count > 0)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(count > 9 ? '9+' : '$count',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))))),
                ]);
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatsScreen())),
            child: StreamBuilder<int>(
              stream: _chatService.getUnreadCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppTheme.purple1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.4))),
                      child: const Center(
                          child: Text('💬', style: TextStyle(fontSize: 16)))),
                  if (count > 0)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(count > 9 ? '9+' : '$count',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))))),
                ]);
              },
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildStories() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return GestureDetector(
            onTap: () => _showHoroscopeStory(context, story),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(children: [
                Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          AppTheme.gold,
                          AppTheme.violet,
                          AppTheme.rose
                        ])),
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppTheme.purple1),
                        child: Center(
                            child: Text(story['emoji']!,
                                style: const TextStyle(fontSize: 24))))),
                const SizedBox(height: 4),
                Text(story['name']!,
                    style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.muted,
                        fontFamily: 'Nunito')),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowingFeed(AppLocalizations l10n) {
    if (!_followingStreamLoaded)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.gold));
    if (_followingStream == null) return _buildEmptyFollowing(l10n);
    return StreamBuilder<QuerySnapshot>(
      stream: _followingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return _buildEmptyFollowing(l10n);
        return RefreshIndicator(
          color: AppTheme.gold,
          backgroundColor: AppTheme.purple1,
          onRefresh: () async => await _loadFollowingStream(),
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return _buildPost(
                  doc.id, doc.data() as Map<String, dynamic>, l10n);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyFollowing(AppLocalizations l10n) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔮', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        Text(l10n.feed,
            style: const TextStyle(
                fontFamily: 'Cinzel', fontSize: 16, color: AppTheme.white)),
        const SizedBox(height: 8),
        Text(l10n.fortuneTellAndShare,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppTheme.muted)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => _tabController.animateTo(1),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3]),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('🔮 ${l10n.explore}',
                  style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: Colors.white,
                      letterSpacing: 0.5))),
        ),
      ]),
    );
  }

  Widget _buildExploreFeed(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: _postService.getFeedPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔮', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(l10n.noPostsYet,
                  style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                      color: AppTheme.muted)),
              const SizedBox(height: 8),
              Text(l10n.fortuneTellAndShare,
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
            ]),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildPost(doc.id, doc.data() as Map<String, dynamic>, l10n);
          },
        );
      },
    );
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
      'Balık': '♓'
    };
    return signs[sign] ?? '⭐';
  }

  Widget _buildPost(
      String postId, Map<String, dynamic> data, AppLocalizations l10n) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final likes = List<String>.from(data['likes'] ?? []);
    final isLiked = likes.contains(currentUid);
    final isOwner = data['uid'] == currentUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppTheme.purple2.withOpacity(0.4)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [AppTheme.purple2, AppTheme.violet]),
                    border: Border.all(
                        color: AppTheme.gold.withOpacity(0.3), width: 1.5)),
                child: Center(
                    child: Text(_getSignEmoji(data['sign'] ?? ''),
                        style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        data['name'] != null &&
                                data['name'].toString().isNotEmpty
                            ? '${data['name']} ${data['surname'] ?? ''}'.trim()
                            : data['username'] ?? '',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                            fontFamily: 'Nunito')),
                    Text('@${data['username'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.gold,
                            fontFamily: 'Nunito')),
                  ]),
            ),
            GestureDetector(
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
                          if (isOwner) ...[
                            ListTile(
                                leading: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                title: Text(l10n.deletePost,
                                    style: const TextStyle(
                                        color: Colors.redAccent)),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _postService.deletePost(postId);
                                }),
                            ListTile(
                                leading: const Icon(Icons.share_outlined,
                                    color: AppTheme.white),
                                title: Text(l10n.share,
                                    style:
                                        const TextStyle(color: AppTheme.white)),
                                onTap: () {
                                  Navigator.pop(context);
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          '${data['fortuneType']} ${l10n.fortuneReading}:\n${data['fortuneResult']}\n\n#Falzade'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(l10n.copiedToClipboard)));
                                }),
                          ] else ...[
                            ListTile(
                                leading: const Icon(Icons.flag_outlined,
                                    color: Colors.orangeAccent),
                                title: const Text('Gönderiyi Bildir',
                                    style:
                                        TextStyle(color: Colors.orangeAccent)),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showReportDialog(postId, data);
                                }),
                          ],
                          const SizedBox(height: 20),
                        ]));
              },
              child: const Text('⋮',
                  style: TextStyle(color: AppTheme.muted, fontSize: 20)),
            ),
          ]),
        ),
        Container(
            width: double.infinity,
            height: 220,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppTheme.purple1, AppTheme.purple2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Stack(children: [
              Center(
                  child: Text(data['fortuneEmoji'] ?? '🔮',
                      style: const TextStyle(fontSize: 70))),
              Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.gold.withOpacity(0.4))),
                      child: Text(
                          '${data['fortuneEmoji']} ${data['fortuneType']}',
                          style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 9,
                              color: AppTheme.gold,
                              letterSpacing: 1)))),
            ])),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Text(data['fortuneResult'] ?? '',
                style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5))),
        Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Row(children: [
              GestureDetector(
                  onTap: () async {
                    await _postService.toggleLike(postId);
                    if (!isLiked && data['uid'] != currentUid) {
                      await _notificationService.sendNotification(
                          toUid: data['uid'], type: 'like', postId: postId);
                    }
                  },
                  child: Row(children: [
                    Text(isLiked ? '❤️' : '🤍',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text('${likes.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.muted,
                            fontFamily: 'Nunito')),
                  ])),
              const SizedBox(width: 16),
              GestureDetector(
                  onTap: () => _showComments(postId, data['uid'], l10n),
                  child: Row(children: [
                    const Text('💬', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text('${data['commentCount'] ?? 0}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.muted,
                            fontFamily: 'Nunito')),
                  ])),
              const SizedBox(width: 16),
              GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '${data['fortuneType']} ${l10n.fortuneReading}:\n${data['fortuneResult']}\n\n#Falzade'));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copiedToClipboard)));
                  },
                  child: const Text('📤', style: TextStyle(fontSize: 20))),
            ])),
      ]),
    );
  }

  void _showReportDialog(String postId, Map<String, dynamic> data) {
    final reasons = [
      'Uygunsuz içerik',
      'Spam veya reklam',
      'Taciz veya zorbalık',
      'Sahte bilgi',
      'Diğer',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.purple1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.muted, borderRadius: BorderRadius.circular(2))),
        const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Gönderiyi Bildir',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 14,
                    color: Colors.orangeAccent))),
        ...reasons.map((reason) => ListTile(
              leading: const Icon(Icons.flag_outlined,
                  color: AppTheme.muted, size: 18),
              title: Text(reason,
                  style: const TextStyle(
                      color: AppTheme.white,
                      fontFamily: 'Nunito',
                      fontSize: 13)),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance.collection('reports').add({
                  'postId': postId,
                  'reportedUid': data['uid'],
                  'reporterUid': FirebaseAuth.instance.currentUser?.uid,
                  'reason': reason,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Bildiriminiz alındı. Teşekkürler.'),
                      backgroundColor: Colors.orangeAccent));
                }
              },
            )),
        const SizedBox(height: 20),
      ]),
    );
  }

  void _showComments(
      String postId, String postOwnerUid, AppLocalizations l10n) {
    final commentController = TextEditingController();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.purple1,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.comments,
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        color: AppTheme.white))),
            SizedBox(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(
                        child: CircularProgressIndicator(color: AppTheme.gold));
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty)
                    return Center(
                        child: Text(l10n.noFortuneYet,
                            style: const TextStyle(
                                color: AppTheme.muted, fontFamily: 'Nunito')));
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment =
                          comments[index].data() as Map<String, dynamic>;
                      final commentId = comments[index].id;
                      final isMyComment = comment['uid'] == currentUid;
                      final isPostOwner = currentUid == postOwnerUid;
                      final canDelete = isMyComment || isPostOwner;
                      return ListTile(
                        leading: Text(comment['sign'] ?? '⭐',
                            style: const TextStyle(fontSize: 24)),
                        title: Text('@${comment['username'] ?? ''}',
                            style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 12,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(comment['comment'] ?? '',
                            style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 13,
                                fontFamily: 'Nunito')),
                        trailing: canDelete
                            ? GestureDetector(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            backgroundColor: AppTheme.purple1,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            title: Text(l10n.deleteComment,
                                                style: const TextStyle(
                                                    fontFamily: 'Cinzel',
                                                    color: Colors.redAccent,
                                                    fontSize: 14)),
                                            content: Text(
                                                l10n.deleteCommentConfirm,
                                                style: const TextStyle(
                                                    color: AppTheme.muted,
                                                    fontFamily: 'Nunito',
                                                    fontSize: 13)),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: Text(l10n.cancel,
                                                      style: const TextStyle(
                                                          color:
                                                              AppTheme.muted))),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text(l10n.delete,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .redAccent))),
                                            ],
                                          ));
                                  if (confirm == true)
                                    await _postService.deleteComment(
                                        postId: postId, commentId: commentId);
                                },
                                child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.delete_outline,
                                        color: Colors.redAccent, size: 18)),
                              )
                            : null,
                      );
                    },
                  );
                },
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
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                  child: TextField(
                      controller: commentController,
                      style: const TextStyle(
                          color: AppTheme.white, fontFamily: 'Nunito'),
                      decoration: InputDecoration(
                          hintText: l10n.writeComment,
                          hintStyle: const TextStyle(color: AppTheme.muted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12))),
                )),
                const SizedBox(width: 8),
                GestureDetector(
                    onTap: () async {
                      if (commentController.text.isNotEmpty) {
                        final comment = commentController.text.trim();
                        await _postService.addComment(
                            postId: postId, comment: comment);
                        await _notificationService.sendNotification(
                            toUid: postOwnerUid,
                            type: 'comment',
                            postId: postId,
                            comment: comment);
                        commentController.clear();
                      }
                    },
                    child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [AppTheme.violet, AppTheme.purple3]),
                            borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 18))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ==================== BURÇ HİKAYESİ ====================
class _HoroscopeStoryPage extends StatefulWidget {
  final Map<String, String> story;
  final String languageName;
  const _HoroscopeStoryPage({required this.story, required this.languageName});
  @override
  State<_HoroscopeStoryPage> createState() => _HoroscopeStoryPageState();
}

class _HoroscopeStoryPageState extends State<_HoroscopeStoryPage> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHoroscope();
  }

  Future<void> _loadHoroscope() async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.day} ${_monthName(today.month)} ${today.year}';
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.claudeApiKey,
          'anthropic-version': '2023-06-01'
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 300,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Write a daily horoscope for ${widget.story['sign']} sign for $dateStr. Respond in ${widget.languageName}. Be mystical, poetic and motivating. 3-4 sentences. Use emojis. No markdown, no # symbols, plain text only.'
            }
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted)
          setState(() {
            _content = data['content'][0]['text'] as String;
            _loading = false;
          });
      } else {
        if (mounted)
          setState(() {
            _content = '🌙';
            _loading = false;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _content = '✨';
          _loading = false;
        });
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                AppTheme.void_,
                AppTheme.purple1,
                AppTheme.purple2
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Stack(children: [
                Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20)))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.story['emoji']!,
                            style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        ShaderMask(
                            shaderCallback: (bounds) =>
                                AppTheme.goldToLilac.createShader(bounds),
                            child: Text('${widget.story['name']}',
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 2))),
                        const SizedBox(height: 8),
                        Text(l10n.dailyComment,
                            style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.gold.withOpacity(0.8))),
                        const SizedBox(height: 32),
                        if (_loading)
                          Column(children: [
                            const CircularProgressIndicator(
                                color: AppTheme.gold, strokeWidth: 2),
                            const SizedBox(height: 16),
                            Text(l10n.starsConsulting,
                                style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontFamily: 'Cormorant Garamond',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic)),
                          ])
                        else
                          Flexible(
                            child: SingleChildScrollView(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                            color: AppTheme.gold
                                                .withOpacity(0.3))),
                                    child: Text(_content,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: 'Cormorant Garamond',
                                            fontSize: 17,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                            height: 1.8))),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(l10n.tapToClose,
                            style: TextStyle(
                                color: AppTheme.muted.withOpacity(0.5),
                                fontFamily: 'Nunito',
                                fontSize: 12)),
                      ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
