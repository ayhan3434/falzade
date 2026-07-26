import 'package:flutter/material.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/auth_service.dart';
import 'package:falcim/screens/main_screen.dart';
import 'package:falcim/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _passwordVisible = false;
  bool _loading = false;
  String? _selectedSign;

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
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onUsernameChanged(String value) async {
    final l10n = AppLocalizations.of(context)!;
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
        _usernameError = available ? null : l10n.usernameTaken;
      });
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }
    if (_selectedSign == null) {
      _showError(l10n.selectSignError);
      return;
    }
    if (_usernameAvailable != true) {
      _showError(l10n.usernameTaken);
      return;
    }

    setState(() => _loading = true);
    final error = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      username: _usernameController.text.trim(),
      sign: _selectedSign!,
    );
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
    } else {
      if (mounted)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainScreen()));
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
    final l10n = AppLocalizations.of(context)!;

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
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: AppTheme.purple1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.purple3.withOpacity(0.4))),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.white, size: 16)),
                ),
                const SizedBox(width: 16),
                ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.goldToLilac.createShader(bounds),
                    child: Text(l10n.createAccount,
                        style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2))),
              ]),
              const SizedBox(height: 8),
              Text(l10n.starsWaiting,
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(
                    child: _buildTextField(
                        controller: _nameController,
                        hint: l10n.name,
                        icon: Icons.person_outline)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildTextField(
                        controller: _surnameController,
                        hint: l10n.surname,
                        icon: Icons.person_outline)),
              ]),
              const SizedBox(height: 14),
              _buildUsernameField(l10n),
              const SizedBox(height: 14),
              _buildTextField(
                  controller: _emailController,
                  hint: l10n.email,
                  icon: Icons.email_outlined),
              const SizedBox(height: 14),
              _buildTextField(
                  controller: _passwordController,
                  hint: l10n.password,
                  icon: Icons.lock_outline,
                  isPassword: true),
              const SizedBox(height: 24),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.selectSign,
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
                onTap: _loading ? null : _register,
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
                          : Text('✦ ${l10n.register}',
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 2))),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                      text: TextSpan(
                          text: '${l10n.hasAccount} ',
                          style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                              fontFamily: 'Nunito'),
                          children: [
                        TextSpan(
                            text: l10n.login,
                            style: const TextStyle(
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

  Widget _buildUsernameField(AppLocalizations l10n) {
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
              hintText: l10n.usernameHint,
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
        Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(l10n.usernameAvailable,
                style: const TextStyle(
                    color: Colors.green, fontSize: 11, fontFamily: 'Nunito'))),
    ]);
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
