import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/user_service.dart';
import 'package:falcim/screens/user_profile_screen.dart';
import 'package:falcim/l10n/app_localizations.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  final _userService = UserService();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _onSearchChanged(String value) async {
    final q = value.trim();
    setState(() {
      _searchQuery = q;
      _searching = q.isNotEmpty;
    });
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (_searchController.text.trim() != q) return;
    final results = await _userService.searchUsersMulti(q);
    if (mounted)
      setState(() {
        _searchResults = results;
        _searching = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(l10n),
          _buildSearchBar(l10n),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                const Icon(Icons.search, color: AppTheme.muted, size: 14),
                const SizedBox(width: 6),
                Text(l10n.searchUser,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppTheme.muted)),
              ]),
            ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildAllUsers(l10n)
                : _searching
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.gold, strokeWidth: 2))
                    : _buildSearchResultsList(l10n),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: Text(l10n.explore,
                style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2))),
      ]),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
            color: AppTheme.purple1.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
              color: AppTheme.white, fontFamily: 'Nunito', fontSize: 14),
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
              hintText: l10n.searchUser,
              hintStyle: const TextStyle(
                  color: AppTheme.muted, fontFamily: 'Nunito', fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.violet, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchResults = [];
                        });
                      },
                      child: const Icon(Icons.close,
                          color: AppTheme.muted, size: 18))
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(AppLocalizations l10n) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('"$_searchQuery" ${l10n.userNotFound}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.muted,
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 16,
                  fontStyle: FontStyle.italic)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) =>
          _buildUserCard(_searchResults[index], l10n),
    );
  }

  Widget _buildAllUsers(AppLocalizations l10n) {
    return StreamBuilder<QuerySnapshot>(
      stream: _userService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.gold));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(
              child: Text(l10n.userNotFound,
                  style: const TextStyle(
                      color: AppTheme.muted,
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontStyle: FontStyle.italic)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildUserCard(data, l10n);
          },
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> data, AppLocalizations l10n) {
    final sign = data['sign'] ?? '';
    final signEmoji = _getSignEmoji(sign);
    final targetUid = data['uid'] ?? '';
    final username = data['username'] ?? '';
    final name = data['name'] ?? '';
    final surname = data['surname'] ?? '';

    return FutureBuilder<bool>(
      future: _userService.isFollowing(targetUid),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;

        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userData: data))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.purple1.withOpacity(0.5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.purple3.withOpacity(0.3))),
            child: Row(children: [
              Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [AppTheme.gold, AppTheme.violet])),
                  child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppTheme.purple2),
                      child: Center(
                          child: Text(signEmoji,
                              style: const TextStyle(fontSize: 24))))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (name.isNotEmpty)
                        Text('$name $surname',
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white)),
                      GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: '@$username'));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l10n.copiedToClipboard),
                                backgroundColor: AppTheme.violet,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))));
                          },
                          child: Text('@$username',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: AppTheme.gold,
                                  letterSpacing: 0.3))),
                      Text(
                          '$signEmoji $sign • ${(data['followers'] as List?)?.length ?? 0} ${l10n.followers}',
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: AppTheme.muted)),
                    ]),
              ),
              GestureDetector(
                onTap: () async {
                  await _userService.toggleFollow(targetUid);
                  setState(() {});
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        gradient: isFollowing
                            ? null
                            : const LinearGradient(
                                colors: [AppTheme.violet, AppTheme.purple3]),
                        border: isFollowing
                            ? Border.all(
                                color: AppTheme.purple3.withOpacity(0.6))
                            : null,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(isFollowing ? l10n.unfollow : l10n.follow,
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 11,
                            color:
                                isFollowing ? AppTheme.muted : AppTheme.white,
                            letterSpacing: 0.5))),
              ),
            ]),
          ),
        );
      },
    );
  }
}
