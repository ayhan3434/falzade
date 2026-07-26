import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/auth_service.dart';
import 'package:falcim/services/language_service.dart';
import 'package:falcim/screens/register_screen.dart';
import 'package:falcim/screens/main_screen.dart';
import 'package:falcim/screens/google_onboarding_screen.dart';
import 'package:falcim/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _passwordVisible = false;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }
    setState(() => _loading = true);
    final error = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
    setState(() => _loading = false);
    if (error != null) {
      _showError(error);
    } else {
      if (mounted)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _googleLoading = true);
    final result = await _authService.signInWithGoogle();
    setState(() => _googleLoading = false);
    if (!mounted) return;

    if (result['error'] != null) {
      if (result['error'] != 'Google girişi iptal edildi.')
        _showError(result['error']);
      return;
    }

    if (result['isNewUser'] == true) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => GoogleOnboardingScreen(
                  uid: result['uid'],
                  name: result['name'],
                  surname: result['surname'],
                  email: result['email'])));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty) {
      _showError(l10n.email);
      return;
    }
    final error =
        await _authService.resetPassword(_emailController.text.trim());
    if (mounted) {
      if (error != null) {
        _showError(error);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Şifre sıfırlama linki gönderildi! 📧'),
            backgroundColor: AppTheme.violet,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))));
      }
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
          const Text('🌍 Select Language',
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
                if (context.mounted) Navigator.pop(context);
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
    final l10n = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();
    final currentLang = LanguageService.supportedLanguages.firstWhere(
        (l) => l['code'] == languageService.locale.languageCode,
        orElse: () => {'flag': '🌍', 'name': 'Language', 'code': 'en'});

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
              // Dil seçici — sağ üst
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GestureDetector(
                    onTap: _showLanguageSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppTheme.purple1.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.gold.withOpacity(0.3))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(currentLang['flag']!,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(currentLang['name']!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.gold,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down,
                            color: AppTheme.gold, size: 14),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('🔮', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('✦ FALZADE ✦',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 4))),
              const SizedBox(height: 8),
              Text(l10n.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 40),
              _buildTextField(
                  controller: _emailController,
                  hint: l10n.email,
                  icon: Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _passwordController,
                  hint: l10n.password,
                  icon: Icons.lock_outline,
                  isPassword: true),
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: _resetPassword,
                      child: Text(l10n.forgotPassword,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w600)))),
              const SizedBox(height: 28),
              // Giriş Yap butonu
              GestureDetector(
                onTap: _loading ? null : _login,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.violet, AppTheme.purple3]),
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
                          : Text('✦ ${l10n.login}',
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 2))),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Divider(
                        color: AppTheme.purple3.withOpacity(0.4),
                        thickness: 1)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('veya',
                        style: TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 12))),
                Expanded(
                    child: Divider(
                        color: AppTheme.purple3.withOpacity(0.4),
                        thickness: 1)),
              ]),
              const SizedBox(height: 16),
              // Google butonu
              GestureDetector(
                onTap: _googleLoading ? null : _googleLogin,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: Center(
                      child: _googleLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.violet)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Image.network(
                                      'https://www.google.com/favicon.ico',
                                      width: 20,
                                      height: 20),
                                  const SizedBox(width: 10),
                                  Text(l10n.googleLogin,
                                      style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 15,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600)),
                                ])),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: RichText(
                      text: TextSpan(
                          text: '${l10n.noAccount} ',
                          style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                              fontFamily: 'Nunito'),
                          children: [
                        TextSpan(
                            text: l10n.register,
                            style: TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.w700))
                      ]))),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.purple1.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_passwordVisible,
        style: const TextStyle(
            color: AppTheme.white, fontFamily: 'Nunito', fontSize: 14),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppTheme.muted, fontFamily: 'Nunito', fontSize: 14),
            prefixIcon: Icon(icon, color: AppTheme.violet, size: 20),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    child: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.muted,
                        size: 20))
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      ),
    );
  }
}
