import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late String _selectedSign;
  bool _loading = false;

  final List<Map<String, String>> _signs = [
    {'emoji': '♈', 'name': 'Koç'},
    {'emoji': '♉', 'name': 'Boğa'},
    {'emoji': '♊', 'name': 'İkizler'},
    {'emoji': '♋', 'name': 'Yengeç'},
    {'emoji': '♌', 'name': 'Aslan'},
    {'emoji': '♍', 'name': 'Başak'},
    {'emoji': '♎', 'name': 'Terazi'},
    {'emoji': '♏', 'name': 'Akrep'},
    {'emoji': '♐', 'name': 'Yay'},
    {'emoji': '♑', 'name': 'Oğlak'},
    {'emoji': '♒', 'name': 'Kova'},
    {'emoji': '♓', 'name': 'Balık'},
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.userData['username'] ?? '',
    );
    _bioController = TextEditingController(
      text: widget.userData['bio'] ?? '',
    );
    _selectedSign = widget.userData['sign'] ?? 'Koç';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      _showError('Kullanıcı adı boş olamaz.');
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'sign': _selectedSign,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Profil kaydedilemedi.');
    }

    setState(() => _loading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 30),
              _buildAvatar(),
              const SizedBox(height: 30),
              _buildLabel('Kullanıcı Adı'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _usernameController,
                hint: 'kullanici_adi',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 20),
              _buildLabel('Hakkımda'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _bioController,
                hint: 'Kendinden bahset... 🔮',
                icon: Icons.edit_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildLabel('Burcunu Değiştir'),
              const SizedBox(height: 12),
              _buildSignGrid(),
              const SizedBox(height: 36),
              _buildSaveButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: const Text(
            'Profili Düzenle',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final sign = _selectedSign;
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
    final signEmoji = signs[sign] ?? '⭐';

    return Center(
      child: Container(
        width: 90,
        height: 90,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppTheme.gold, AppTheme.violet, AppTheme.rose],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppTheme.purple2, AppTheme.violet],
            ),
          ),
          child: Center(
            child: Text(signEmoji, style: const TextStyle(fontSize: 40)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Cinzel',
        fontSize: 12,
        color: AppTheme.gold.withOpacity(0.9),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.purple1.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppTheme.white,
          fontFamily: 'Nunito',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppTheme.muted,
            fontFamily: 'Nunito',
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppTheme.violet, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSignGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _signs.length,
      itemBuilder: (context, index) {
        final sign = _signs[index];
        final isSelected = _selectedSign == sign['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedSign = sign['name']!),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.violet.withOpacity(0.4)
                  : AppTheme.purple1.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.gold
                    : AppTheme.purple3.withOpacity(0.3),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sign['emoji']!, style: const TextStyle(fontSize: 18)),
                Text(
                  sign['name']!,
                  style: TextStyle(
                    fontSize: 7,
                    color: isSelected ? AppTheme.gold : AppTheme.muted,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _loading ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.violet, AppTheme.purple3],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violet.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  '✦ Kaydet',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
