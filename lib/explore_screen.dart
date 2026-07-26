import 'package:flutter/material.dart';
import 'package:falcim/theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _users = [
    {
      'emoji': '🌙',
      'username': 'zeynep_ay',
      'name': 'Zeynep Ay',
      'sign': '♏ Akrep',
    },
    {
      'emoji': '⭐',
      'username': 'elif_yildiz',
      'name': 'Elif Yıldız',
      'sign': '♒ Kova',
    },
    {
      'emoji': '🌊',
      'username': 'selin_mystic',
      'name': 'Selin Deniz',
      'sign': '♓ Balık',
    },
    {
      'emoji': '🔮',
      'username': 'ayse_fal',
      'name': 'Ayşe Nur',
      'sign': '♋ Yengeç',
    },
    {
      'emoji': '✨',
      'username': 'merve_stars',
      'name': 'Merve Yıldız',
      'sign': '♌ Aslan',
    },
    {
      'emoji': '🌸',
      'username': 'dilan_mystic',
      'name': 'Dilan Çiçek',
      'sign': '♉ Boğa',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildPopularTitle(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ShaderMask(
        shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
        child: const Text(
          'Keşfet',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.purple1.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: AppTheme.white,
            fontFamily: 'Nunito',
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            hintText: 'İsim, soyisim, kullanıcı adı ara...',
            hintStyle: TextStyle(
              color: AppTheme.muted,
              fontFamily: 'Nunito',
              fontSize: 13,
            ),
            prefixIcon: Icon(Icons.search, color: AppTheme.violet, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text('✦ ', style: TextStyle(color: AppTheme.gold, fontSize: 14)),
          Text(
            'Popüler Falcılar',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 13,
              color: AppTheme.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, String> user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.purple1, AppTheme.purple2.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.purple2, AppTheme.violet],
              ),
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(user['emoji']!, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user['username']!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user['sign']!,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.gold,
              fontFamily: 'Cormorant Garamond',
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
