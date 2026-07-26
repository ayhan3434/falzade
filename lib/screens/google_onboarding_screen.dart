import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/auth_service.dart';
import 'package:falcim/screens/main_screen.dart';

class GoogleOnboardingScreen extends StatefulWidget {
  final String name;
  final String surname;
  final String email;
  final String uid;
  const GoogleOnboardingScreen({
    super.key,
    required this.name,
    required this.surname,
    required this.email,
    required this.uid,
  });

  @override
  State<GoogleOnboardingScreen> createState() => _GoogleOnboardingScreenState();
}

class _GoogleOnboardingScreenState extends State<GoogleOnboardingScreen> {
  final _usernameController = TextEditingController();
  final _authService = AuthService();
  String? _selectedSign;
  bool _loading = false;
  bool _checkingUsername = false;
  bool? _usernameAvailable;
  String? _usernameError;

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
    // Gmail adresinden öneri üret
    final suggestion =
        widget.email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    _usernameController.text = suggestion;
    _onUsernameChanged(suggestion);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _onUsernameChanged(String value) async {
    final formatError = _authService.validateUsername(value);
    if (formatError != null) {
      setState(() {
        _usernameAvailable = null;
        _usernameError = formatError;
        _checkingUsername = false;
      });
      return;
    }
    setState(() {
      _checkingUsername = true;
      _usernameError = null;
      _usernameAvailable = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_usernameController.text.trim() != value.trim()) return;
    final available = await _authService.isUsernameAvailable(value);
    if (mounted)
      setState(() {
        _usernameAvailable = available;
        _checkingUsername = false;
        _usernameError = available ? null : 'Bu kullanıcı adı alınmış.';
      });
  }

  Future<void> _complete() async {
    if (_usernameAvailable != true) {
      _showError('Geçerli ve müsait bir kullanıcı adı gir.');
      return;
    }
    if (_selectedSign == null) {
      _showError('Lütfen burcunu seç.');
      return;
    }

    setState(() => _loading = true);

    try {
      final username = _usernameController.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'uid': widget.uid,
        'name': widget.name,
        'surname': widget.surname,
        'username': username,
        'usernameLower': username.toLowerCase(),
        'nameLower': widget.name.toLowerCase(),
        'surnameLower': widget.surname.toLowerCase(),
        'email': widget.email.toLowerCase(),
        'sign': _selectedSign!,
        'bio': '',
        'followers': [],
        'following': [],
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Bir hata oluştu, tekrar dene.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.void_, AppTheme.deep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const SizedBox(height: 30),
              const Text('🔮', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 12),
              ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('Hoş Geldin!',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2))),
              const SizedBox(height: 8),
              Text('Merhaba ${widget.name}, son birkaç adım kaldı ✨',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              // Kullanıcı adı
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Kullanıcı Adın',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.gold.withOpacity(0.9),
                          letterSpacing: 1))),
              const SizedBox(height: 8),
              _buildUsernameField(),
              const SizedBox(height: 8),
              const Text(
                  'Bu ad ile diğerleri seni bulacak. İstersen değiştirebilirsin.',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppTheme.muted)),

              const SizedBox(height: 28),

              // Burç seçimi
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Burcunu Seç',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.gold.withOpacity(0.9),
                          letterSpacing: 1))),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1),
                itemCount: _signs.length,
                itemBuilder: (context, index) {
                  final sign = _signs[index];
                  final isSelected = _selectedSign == sign['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSign = sign['name']),
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
                              width: isSelected ? 1.5 : 1)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sign['emoji']!,
                                style: const TextStyle(fontSize: 18)),
                            Text(sign['name']!,
                                style: TextStyle(
                                    fontSize: 7,
                                    color: isSelected
                                        ? AppTheme.gold
                                        : AppTheme.muted,
                                    fontFamily: 'Nunito')),
                          ]),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              GestureDetector(
                onTap: _loading ? null : _complete,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.gold2, AppTheme.violet]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.violet.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ]),
                  child: Center(
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('✦ Başlayalım',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 2))),
                ),
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    Color borderColor = AppTheme.purple3.withOpacity(0.4);
    if (_usernameAvailable == true) borderColor = Colors.green;
    if (_usernameAvailable == false || _usernameError != null)
      borderColor = Colors.redAccent;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        decoration: BoxDecoration(
            color: AppTheme.purple1.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: borderColor,
                width: _usernameAvailable != null ? 1.5 : 1)),
        child: TextField(
          controller: _usernameController,
          style: const TextStyle(
              color: AppTheme.white, fontFamily: 'Nunito', fontSize: 14),
          onChanged: _onUsernameChanged,
          decoration: InputDecoration(
              hintText: 'kullanici_adi',
              hintStyle: const TextStyle(
                  color: AppTheme.muted, fontFamily: 'Nunito', fontSize: 14),
              prefixIcon: const Icon(Icons.alternate_email,
                  color: AppTheme.violet, size: 20),
              suffixIcon: _checkingUsername
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.gold)))
                  : _usernameAvailable == true
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 22)
                      : _usernameAvailable == false
                          ? const Icon(Icons.cancel,
                              color: Colors.redAccent, size: 22)
                          : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        ),
      ),
      if (_usernameError != null)
        Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(_usernameError!,
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontFamily: 'Nunito')))
      else if (_usernameAvailable == true)
        const Padding(
            padding: EdgeInsets.only(top: 6, left: 12),
            child: Text('✅ Kullanıcı adı müsait!',
                style: TextStyle(
                    color: Colors.green, fontSize: 11, fontFamily: 'Nunito'))),
    ]);
  }
}
