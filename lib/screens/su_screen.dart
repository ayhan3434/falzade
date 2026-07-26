import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class SuScreen extends StatefulWidget {
  const SuScreen({super.key});
  @override
  State<SuScreen> createState() => _SuScreenState();
}

class _SuScreenState extends State<SuScreen> with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _secilenSu;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  static const _suTipleri = [
    {
      'enerji': 'Okyanus',
      'emoji': '🌊',
      'anlam': 'Derin bilinçaltı ve duygular',
      'color': 0xFF01579B
    },
    {
      'enerji': 'Nehir',
      'emoji': '🏞️',
      'anlam': 'Akış ve değişim',
      'color': 0xFF00695C
    },
    {
      'enerji': 'Yağmur',
      'emoji': '🌧️',
      'anlam': 'Arınma ve yenilenme',
      'color': 0xFF1565C0
    },
    {
      'enerji': 'Göl',
      'emoji': '🏔️',
      'anlam': 'Sessizlik ve huzur',
      'color': 0xFF006064
    },
    {
      'enerji': 'Pınar',
      'emoji': '💧',
      'anlam': 'Tazelik ve başlangıç',
      'color': 0xFF0277BD
    },
    {
      'enerji': 'Sis',
      'emoji': '🌫️',
      'anlam': 'Gizemli mesajlar',
      'color': 0xFF37474F
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _waveController, curve: Curves.easeInOut));
    _rippleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _rippleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_rippleController);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _rippleController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_secilenSu == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen bir su tipi seçin'),
          backgroundColor: Colors.redAccent));
      return;
    }
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConstants.claudeApiKey,
          'anthropic-version': '2023-06-01'
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 600,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Su falı yorumu yap.\n\nNiyet: $_intent\nSeçilen Su: ${_secilenSu!['enerji']} ${_secilenSu!['emoji']} - ${_secilenSu!['anlam']}\n\nSeçilen su tipinin enerjisini ve niyeti ilişkilendirerek mistik ve şiirsel bir yorum yap. Suyun akışı ve yansımalarının kişiye ne anlattığını yorumla. Türkçe, 6-7 cümle, emoji kullan, markdown kullanma.'
            }
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = 'Su şu an sessiz... 🌊';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Evren şu an konuşmuyor... ✨';
        _loading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _intent = '';
      _result = null;
      _secilenSu = null;
    });
    _intentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final suColor = _secilenSu != null
        ? Color(_secilenSu!['color'] as int)
        : const Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: AppTheme.deep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppTheme.gold, size: 20),
            onPressed: () => Navigator.pop(context)),
        title: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: const Text('🌊 Su Falı',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Text('Su Tipini Seç, Niyetini Yaz',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_waveAnimation, _rippleAnimation]),
              builder: (context, child) =>
                  Stack(alignment: Alignment.center, children: [
                Container(
                    width: 140,
                    height: 140,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(
                          color: suColor
                              .withOpacity(0.3 + 0.2 * _waveAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 10),
                    ])),
                Container(
                    width: 120 + 10 * _rippleAnimation.value,
                    height: 120 + 10 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: suColor.withOpacity(
                                0.3 * (1 - _rippleAnimation.value)),
                            width: 1))),
                Text(_secilenSu != null ? _secilenSu!['emoji'] as String : '🌊',
                    style: const TextStyle(fontSize: 75)),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('"Su her şeyi bilir, her şeyi taşır..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5)),
            const SizedBox(height: 24),
            if (_result == null) ...[
              // Su tipi seçimi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _secilenSu != null
                            ? suColor.withOpacity(0.6)
                            : AppTheme.purple3.withOpacity(0.4))),
                child: Column(children: [
                  const Text('Su Tipini Seç',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.gold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.0),
                    itemCount: _suTipleri.length,
                    itemBuilder: (context, index) {
                      final su = _suTipleri[index];
                      final color = Color(su['color'] as int);
                      final isSelected = _secilenSu == su;
                      return GestureDetector(
                        onTap: () => setState(() => _secilenSu = su),
                        child: Container(
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.3)
                                  : AppTheme.purple1.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected
                                      ? color
                                      : AppTheme.purple3.withOpacity(0.3),
                                  width: isSelected ? 2 : 1)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(su['emoji'] as String,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(su['enerji'] as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Cinzel',
                                        fontSize: 10,
                                        color: isSelected
                                            ? color
                                            : AppTheme.white)),
                                const SizedBox(height: 2),
                                Text(su['anlam'] as String,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 8,
                                        color: AppTheme.muted)),
                              ]),
                        ),
                      );
                    },
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              // Niyet yazma
              Container(
                decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                child: TextField(
                  controller: _intentController,
                  style: const TextStyle(
                      color: AppTheme.white, fontFamily: 'Nunito'),
                  maxLines: 3,
                  onChanged: (v) => setState(() => _intent = v),
                  decoration: const InputDecoration(
                    hintText:
                        'Niyetinizi yazın...\n(Suyun yüzeyine ne yansıtmak istiyorsunuz?)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child:
                            Icon(Icons.water, color: AppTheme.gold, size: 20)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_loading) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Su yüzeyi şekilleniyor... 🌊✨',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else
                GestureDetector(
                    onTap: _getReading,
                    child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              _secilenSu != null ? suColor : AppTheme.muted,
                              _secilenSu != null
                                  ? suColor.withOpacity(0.7)
                                  : AppTheme.muted
                            ]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color: suColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: Center(
                            child: Text(
                                _secilenSu != null
                                    ? '🌊 Suya Bak'
                                    : '🌊 Su Tipi Seç',
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Colors.white,
                                    letterSpacing: 1))))),
            ] else ...[
              if (_secilenSu != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: suColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: suColor.withOpacity(0.3))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_secilenSu!['emoji'] as String,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_secilenSu!['enerji'] as String,
                                  style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 14,
                                      color: suColor)),
                              Text(_secilenSu!['anlam'] as String,
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      color: AppTheme.muted)),
                            ]),
                      ]),
                ),
                const SizedBox(height: 16),
              ],
              _buildResultSection(_result!, 'Su Falı', '🌊'),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildResultSection(String result, String fortuneType, String emoji) {
    return Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF01579B).withOpacity(0.1),
                AppTheme.purple1.withOpacity(0.6)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF0288D1).withOpacity(0.2))),
          child: Text(result,
              style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  height: 1.8))),
      const SizedBox(height: 24),
      const Text('Bu yorumu paylaşmak ister misin?',
          style: TextStyle(
              fontFamily: 'Cinzel', fontSize: 13, color: AppTheme.gold)),
      const SizedBox(height: 12),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
                shareToFeed: true,
                shareToProfile: true);
            if (context.mounted)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Gönderi paylaşıldı! ✨'),
                  backgroundColor: AppTheme.violet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))));
          },
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3]),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('✦ Akışta ve Profilde Paylaş',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: Colors.white,
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () async {
            final ps = PostService();
            await ps.createPost(
                caption:
                    '"${result.substring(0, result.length > 80 ? 80 : result.length)}..."',
                fortuneType: fortuneType,
                fortuneEmoji: emoji,
                fortuneResult: result,
                shareToFeed: false,
                shareToProfile: true);
            if (context.mounted)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Gönderi paylaşıldı! ✨'),
                  backgroundColor: AppTheme.violet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))));
          },
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.violet.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Sadece Profilimde Paylaş',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 13,
                          color: AppTheme.white,
                          letterSpacing: 1))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.muted.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('Paylaşma',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.muted,
                          fontFamily: 'Nunito'))))),
      const SizedBox(height: 10),
      GestureDetector(
          onTap: _reset,
          child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(25)),
              child: const Center(
                  child: Text('🔄 Yeni Fal',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gold,
                          fontFamily: 'Nunito'))))),
      const SizedBox(height: 20),
    ]);
  }
}
