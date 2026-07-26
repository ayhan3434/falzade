import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class NazarScreen extends StatefulWidget {
  const NazarScreen({super.key});
  @override
  State<NazarScreen> createState() => _NazarScreenState();
}

class _NazarScreenState extends State<NazarScreen>
    with TickerProviderStateMixin {
  final _intentController = TextEditingController();
  String _intent = '';
  bool _loading = false;
  String? _result;
  Map<String, dynamic>? _reading;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  static const _nazarDurumlari = [
    {
      'durum': 'Temiz Enerji',
      'emoji': '🧿',
      'anlam': 'Nazar boncuğu sağlam, koruma güçlü',
      'color': 0xFF0288D1
    },
    {
      'durum': 'Hafif Enerji',
      'emoji': '🧿',
      'anlam': 'Küçük bir bulutlanma var, dikkat et',
      'color': 0xFF0097A7
    },
    {
      'durum': 'Yoğun Nazar',
      'emoji': '🧿',
      'anlam': 'Güçlü bir enerji var, temizlenme zamanı',
      'color': 0xFF1565C0
    },
    {
      'durum': 'Koruyucu Kalkan',
      'emoji': '🧿',
      'anlam': 'Güçlü koruma, kötü enerjiler uzakta',
      'color': 0xFF00695C
    },
  ];

  static const _korumalar = [
    'Tuz ve biberle ev temizliği yap',
    'Mavi boncukları yanında taşı',
    'Tütsü ile ortamını temizle',
    'Ay ışığında kristallerini şarj et',
    'Üç kez nefes vererek dua et',
    'Lavanta yağı ile enerji çalışması yap',
  ];

  void _generateReading() {
    final random = Random();
    _reading = {
      'durum': _nazarDurumlari[random.nextInt(_nazarDurumlari.length)],
      'koruma': _korumalar[random.nextInt(_korumalar.length)],
      'guc': 40 + random.nextInt(60),
    };
  }

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
    _rotateAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _intentController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_intent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen niyetinizi yazın'),
          backgroundColor: Colors.redAccent));
      return;
    }
    _generateReading();
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
                  'Nazar falı yorumu yap.\n\nNiyet: $_intent\nNazar Durumu: ${_reading!['durum']['durum']} - ${_reading!['durum']['anlam']}\nKoruma Gücü: %${_reading!['guc']}\nÖnerilen Koruma: ${_reading!['koruma']}\n\nNazar boncuğunun enerjisini, kişinin etrafındaki nazarı ve korumasını niyetle ilişkilendirerek yorumla. Kötü enerjilerden korunma yollarını mistik şekilde anlat. Türkçe, 5-6 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Nazar boncuğu şu an sessiz... 🧿';
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
      _reading = null;
    });
    _intentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final nazarColor = _reading != null
        ? Color(_reading!['durum']['color'] as int)
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
            child: const Text('🧿 Nazar Falı',
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
            const Text('Nazar Boncuğunun Sırrı',
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
              builder: (context, child) =>
                  Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: nazarColor
                                    .withOpacity(0.2 * _pulseAnimation.value),
                                width: 1)))),
                Transform.rotate(
                    angle: -_rotateAnimation.value * 0.6,
                    child: Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF0097A7)
                                    .withOpacity(0.2 * _pulseAnimation.value),
                                width: 1)))),
                Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                        width: 95,
                        height: 95,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(
                              color: nazarColor
                                  .withOpacity(0.5 * _pulseAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 10)
                        ]),
                        child: const Center(
                            child:
                                Text('🧿', style: TextStyle(fontSize: 60))))),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('"Nazar boncuğu kötü enerjileri emer ve seni korur..."',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.5)),
            const SizedBox(height: 24),
            if (_result == null) ...[
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
                        'Niyetinizi yazın...\n(Kendinizi korunmuş hissediyor musunuz?)',
                    hintStyle: TextStyle(
                        color: AppTheme.muted, fontSize: 12, height: 1.5),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.remove_red_eye,
                            color: AppTheme.gold, size: 20)),
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
                const Text('Nazar okunuyor... 🧿✨',
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
                            gradient: const LinearGradient(
                                colors: [Color(0xFF01579B), Color(0xFF006064)]),
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF0288D1).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ]),
                        child: const Center(
                            child: Text('🧿 Nazarıma Bak',
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 15,
                                    color: Colors.white,
                                    letterSpacing: 1))))),
            ] else ...[
              if (_reading != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: nazarColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: nazarColor.withOpacity(0.3))),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            const Text('🧿', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(_reading!['durum']['durum'] as String,
                                style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 10,
                                    color: nazarColor)),
                            const Text('Durum',
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9,
                                    color: AppTheme.muted))
                          ]),
                          Column(children: [
                            const Text('🛡️', style: TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text('%${_reading!['guc']}',
                                style: const TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 14,
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.bold)),
                            const Text('Koruma Gücü',
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9,
                                    color: AppTheme.muted))
                          ]),
                        ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: (_reading!['guc'] as int) / 100,
                            backgroundColor: AppTheme.purple3.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(nazarColor),
                            minHeight: 6)),
                    const SizedBox(height: 10),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.2))),
                        child: Row(children: [
                          const Text('💡 ', style: TextStyle(fontSize: 14)),
                          Expanded(
                              child: Text('Öneri: ${_reading!['koruma']}',
                                  style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      color: AppTheme.gold)))
                        ])),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              _buildResultSection(_result!, 'Nazar Falı', '🧿'),
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
