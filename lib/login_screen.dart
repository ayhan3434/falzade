import 'package:flutter/material.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/screens/register_screen.dart';
import 'package:falcim/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.void_, AppTheme.deep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Logo
                const Text('🔮', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),

                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text(
                    '✦ FALCIM ✦',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Hesabına giriş yap',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                  ),
                ),

                const SizedBox(height: 50),

                // Email alanı
                _buildTextField(
                  controller: _emailController,
                  hint: 'E-posta adresi',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                // Şifre alanı
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Şifre',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 12),

                // Şifremi unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Şifremi unuttum',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gold.withOpacity(0.8),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Giriş butonu
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.violet, AppTheme.purple3],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                    child: const Center(
                      child: Text(
                        '✦ Giriş Yap',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Ayırıcı
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: AppTheme.purple2),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'veya',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: AppTheme.purple2),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Google ile giriş
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.purple3.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌐', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 10),
                        Text(
                          'Google ile devam et',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Kayıt ol
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Hesabın yok mu? ',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 13,
                        fontFamily: 'Nunito',
                      ),
                      children: [
                        TextSpan(
                          text: 'Kayıt Ol',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
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
        border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_passwordVisible,
        style: const TextStyle(
          color: AppTheme.white,
          fontFamily: 'Nunito',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.muted,
            fontFamily: 'Nunito',
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppTheme.violet, size: 20),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  child: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
