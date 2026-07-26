import 'package:flutter/material.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/screens/feed_screen.dart';
import 'package:falcim/screens/explore_screen.dart';
import 'package:falcim/screens/fortune_screen.dart';
import 'package:falcim/screens/horoscope_screen.dart';
import 'package:falcim/screens/profile_screen.dart';
import 'package:falcim/screens/zuhre_screen.dart';
import 'package:falcim/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const ExploreScreen(),
    const FortuneScreen(),
    const ZuhreScreen(),
    const HoroscopeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: AppTheme.void_,
            border: Border(
                top: BorderSide(color: AppTheme.purple3.withOpacity(0.3)))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, '🏠', l10n.feed),
                _buildNavItem(1, '🔍', l10n.explore),
                _buildNavItem(2, '✨', l10n.selectFortune),
                _buildNavItem(3, '🔮', 'Zühre'),
                _buildNavItem(4, '⭐', l10n.horoscope),
                _buildNavItem(5, '👤', l10n.profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String emoji, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.violet.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppTheme.violet.withOpacity(0.4))
                : null),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: TextStyle(fontSize: isSelected ? 22 : 20)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontFamily: 'Cinzel',
                  color: isSelected ? AppTheme.gold : AppTheme.muted,
                  letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}
