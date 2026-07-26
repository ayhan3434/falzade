import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class AyScreen extends StatefulWidget {
  const AyScreen({super.key});

  @override
  State<AyScreen> createState() => _AyScreenState();
}

class _AyScreenState extends State<AyScreen> with TickerProviderStateMixin {
  String? _selectedSign;
  bool _loading = false;
  String? _result;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _signs = [
    '♈ Koç',
    '♉ Boğa',
    '♊ İkizler',
    '♋ Yengeç',
    '♌ Aslan',
    '♍ Başak',
    '♎ Terazi',
    '♏ Akrep',
    '♐ Yay',
    '♑ Oğlak',
    '♒ Kova',
    '♓ Balık',
  ];

  // Güncel ay fazını hesapla
  Map<String, dynamic> _getCurrentMoonPhase() {
    final now = DateTime.now();
    // Bilinen yeni ay referans tarihi: 6 Ocak 2000
    final reference = DateTime(2000, 1, 6);
    final daysSince = now.difference(reference).inDays;
    final cycleDay = daysSince % 29.53;

    String phase;
    String emoji;
    String energy;
    double illumination;

    if (cycleDay < 1.85) {
      phase = 'Yeni Ay';
      emoji = '🌑';
      illumination = 0;
      energy = 'Yeni başlangıçlar, niyet belirleme ve tohum ekme zamanı';
    } else if (cycleDay < 7.38) {
      phase = 'Hilal';
      emoji = '🌒';
      illumination = cycleDay / 7.38 * 25;
      energy = 'Büyüme, ilerleme ve harekete geçme enerjisi';
    } else if (cycleDay < 9.22) {
      phase = 'İlk Dördün';
      emoji = '🌓';
      illumination = 50;
      energy = 'Karar verme, zorlukları aşma ve güç toplama zamanı';
    } else if (cycleDay < 14.77) {
      phase = 'Şişen Ay';
      emoji = '🌔';
      illumination = 50 + (cycleDay - 9.22) / 5.55 * 25;
      energy = 'Bolluk, yaratıcılık ve manifestasyon enerjisi';
    } else if (cycleDay < 16.61) {
      phase = 'Dolunay';
      emoji = '🌕';
      illumination = 100;
      energy = 'Zirve enerji, tamamlanma, aydınlanma ve kutlama zamanı';
    } else if (cycleDay < 22.15) {
      phase = 'Azalan Ay';
      emoji = '🌖';
      illumination = 100 - (cycleDay - 16.61) / 5.54 * 25;
      energy = 'Şükran, paylaşma ve bırakma enerjisi';
    } else if (cycleDay < 24.0) {
      phase = 'Son Dördün';
      emoji = '🌗';
      illumination = 50;
      energy = 'Temizlenme, bırakma ve içe dönme zamanı';
    } else {
      phase = 'Kararan Ay';
      emoji = '🌘';
      illumination = 25 - (cycleDay - 24.0) / 5.53 * 25;
      energy = 'Dinlenme, yansıma ve hazırlık enerjisi';
    }

    // Ayın hangi burçta olduğu (yaklaşık)
    const moonSigns = [
      'Koç',
      'Boğa',
      'İkizler',
      'Yengeç',
      'Aslan',
      'Başak',
      'Terazi',
      'Akrep',
      'Yay',
      'Oğlak',
      'Kova',
      'Balık'
    ];
    final moonSignIndex = (daysSince ~/ 2.5) % 12;
    final moonSign = moonSigns[moonSignIndex];

    return {
      'phase': phase,
      'emoji': emoji,
      'illumination': illumination.round(),
      'energy': energy,
      'moonSign': moonSign,
      'cycleDay': cycleDay.round(),
    };
  }

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_selectedSign == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen doğum burcunuzu seçin'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _loading = true);
    final moon = _getCurrentMoonPhase();

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
                  'Ay falı yorumu yap.\n\nDoğum Burcu: $_selectedSign\nBugünkü Ay Fazı: ${moon['phase']} ${moon['emoji']} (Aydınlanma: %${moon['illumination']})\nAyın Bulunduğu Burç: ${moon['moonSign']}\nAy Enerjisi: ${moon['energy']}\nAy Döngüsünün ${moon['cycleDay']}. günü\n\nBu ay fazının $_selectedSign burcuna özel etkisini yorumla. Aşk, kariyer ve ruhsal gelişim alanlarında ayın mesajını anlat. Türkçe, 6-7 cümle, mistik ve şiirsel ol, emoji kullan, markdown kullanma.'
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
          _result = 'Ay şu an sessiz... 🌙';
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
      _selectedSign = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moon = _getCurrentMoonPhase();

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
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: const Text('🌙 Ay Falı',
              style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Ayın Gizemi',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),

              // Ay animasyonu
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF4A90D9)
                              .withOpacity(0.4 * _glowAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 20),
                      BoxShadow(
                          color: AppTheme.violet
                              .withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 70,
                          spreadRadius: 30),
                    ],
                  ),
                  child: Center(
                      child: Text(moon['emoji'] as String,
                          style: const TextStyle(fontSize: 75))),
                ),
              ),
              const SizedBox(height: 16),

              // Güncel ay fazı kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF4A90D9).withOpacity(0.4)),
                ),
                child: Column(children: [
                  Text('Bugün: ${moon['phase']}',
                      style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                          color: Color(0xFF4A90D9),
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMoonStat(
                            '💡', 'Aydınlanma', '%${moon['illumination']}'),
                        _buildMoonStat(
                            '✨', 'Ayın Burcu', moon['moonSign'] as String),
                        _buildMoonStat(
                            '📅', 'Döngü', '${moon['cycleDay']}. gün'),
                      ]),
                  const SizedBox(height: 8),
                  Text(moon['energy'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted,
                          height: 1.4)),
                ]),
              ),
              const SizedBox(height: 24),

              if (_result == null) ...[
                const Text('Doğum Burcunuzu Seçin',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold,
                        letterSpacing: 1)),
                const SizedBox(height: 16),

                // Burç grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: _signs.map((sign) {
                    final isSelected = _selectedSign == sign;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSign = sign),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [AppTheme.gold, AppTheme.violet])
                              : null,
                          color: isSelected
                              ? null
                              : AppTheme.purple1.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSelected
                                  ? AppTheme.gold
                                  : AppTheme.purple3.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(sign,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.muted,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Ay kehaneti okunuyor... 🌙✨',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _getReading,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1A3A6A), AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Center(
                          child: Text('🌙 Ay Falıma Bak',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                // Seçilen burç badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.gold, AppTheme.violet]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_selectedSign!,
                      style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 20),

                // Yorum
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF0A1628).withOpacity(0.9),
                      AppTheme.purple1.withOpacity(0.6)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF4A90D9).withOpacity(0.3)),
                  ),
                  child: Text(_result!,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          height: 1.8)),
                ),
                const SizedBox(height: 24),
                const Text('Bu yorumu paylaşmak ister misin?',
                    style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final ps = PostService();
                    await ps.createPost(
                        caption:
                            '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                        fortuneType: 'Ay Falı',
                        fortuneEmoji: '🌙',
                        fortuneResult: _result!,
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
                                  letterSpacing: 1)))),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final ps = PostService();
                    await ps.createPost(
                        caption:
                            '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
                        fortuneType: 'Ay Falı',
                        fortuneEmoji: '🌙',
                        fortuneResult: _result!,
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
                          border: Border.all(
                              color: AppTheme.violet.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(25)),
                      child: const Center(
                          child: Text('Sadece Profilimde Paylaş',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 13,
                                  color: AppTheme.white,
                                  letterSpacing: 1)))),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.muted.withOpacity(0.3)),
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
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: const Center(
                            child: Text('🔄 Yeni Fal Bak',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoonStat(String emoji, String label, String value) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(
              fontFamily: 'Cinzel', fontSize: 11, color: AppTheme.white)),
      Text(label,
          style: const TextStyle(
              fontFamily: 'Nunito', fontSize: 9, color: AppTheme.muted)),
    ]);
  }
}
