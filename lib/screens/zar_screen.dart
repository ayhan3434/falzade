import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class ZarScreen extends StatefulWidget {
  const ZarScreen({super.key});

  @override
  State<ZarScreen> createState() => _ZarScreenState();
}

class _ZarScreenState extends State<ZarScreen> with TickerProviderStateMixin {
  final _random = Random();

  List<int> _diceValues = [1, 1, 1];
  bool _loading = false;
  bool _rolling = false;
  String? _result;
  bool _rolled = false;

  late List<AnimationController> _shakeControllers;
  late List<Animation<double>> _shakeAnimations;

  static const _diceMeanings = {
    1: 'Yeni başlangıç, teklik ve özgünlük',
    2: 'Denge, ortaklık ve ikili ilişkiler',
    3: 'Yaratıcılık, şans ve büyüme',
    4: 'İstikrar, güven ve temel',
    5: 'Değişim, özgürlük ve macera',
    6: 'Uyum, tamamlanma ve başarı',
  };

  static const _sumMeanings = {
    3: 'En düşük toplam - Sabır ve bekleme zamanı 🌱',
    4: 'Güçlü temel - İstikrarlı ilerleme ⚓',
    5: 'Değişim rüzgarı - Yeni kapılar açılıyor 🌬️',
    6: 'Denge noktası - Her şey yolunda gidiyor ⚖️',
    7: 'Şans sayısı - Evren seninle! 🍀',
    8: 'Bolluk - Maddi kazanç yakın 💰',
    9: 'Tamamlanma - Bir dönem kapanıyor 🌙',
    10: 'Mükemmel denge - Büyük başarı kapıda 🏆',
    11: 'Ruhsal uyanış - Sezgilerin güçleniyor ✨',
    12: 'En yüksek enerji - Harika şeyler geliyor! 🌟',
    13: 'Dönüşüm - Büyük değişim yakın 🦋',
    14: 'Güç ve cesaret - Korkma ilerle ⚡',
    15: 'Bilgelik - Doğru karar zamanı 🦉',
    16: 'Bereket - Bolluk ve şans dolu dönem 🌺',
    17: 'Zafer - Hedefine ulaşıyorsun 🎯',
    18: 'En yüksek toplam - Mükemmel başarı! 🌈',
  };

  @override
  void initState() {
    super.initState();
    _shakeControllers = List.generate(
        3,
        (i) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 100)));
    _shakeAnimations = _shakeControllers
        .map((c) => Tween<double>(begin: -8, end: 8)
            .animate(CurvedAnimation(parent: c, curve: Curves.elasticInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _shakeControllers) c.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    setState(() {
      _rolling = true;
      _result = null;
      _rolled = false;
    });

    // Sallama animasyonu
    for (int round = 0; round < 8; round++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        setState(() {
          _diceValues = List.generate(3, (_) => _random.nextInt(6) + 1);
        });
        for (final c in _shakeControllers) {
          c.forward(from: 0);
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _rolling = false;
        _rolled = true;
      });
    }
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    final sum = _diceValues.reduce((a, b) => a + b);
    final diceDesc = List.generate(
            3,
            (i) =>
                '${i + 1}. Zar: ${_diceValues[i]} - ${_diceMeanings[_diceValues[i]]}')
        .join('\n');
    final sumMeaning = _sumMeanings[sum] ?? 'Özel bir toplam';

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
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Zar falı yorumu yap. Atılan zarlar:\n$diceDesc\nToplam: $sum - $sumMeaning\n\nHer zarın anlamını ve toplam sayının mesajını mistik ve şiirsel şekilde yorumla. Türkçe, 4-5 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Zarlar şu an sessiz... 🎲';
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
      _rolled = false;
      _result = null;
      _diceValues = [1, 1, 1];
    });
  }

  Widget _buildDie(int value, int index) {
    final dots = _getDots(value);
    return AnimatedBuilder(
      animation: _shakeAnimations[index],
      builder: (context, child) => Transform.translate(
        offset:
            _rolling ? Offset(_shakeAnimations[index].value, 0) : Offset.zero,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.gold.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.violet.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5)),
              BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(-2, -2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: dots,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getDots(int value) {
    // Her değer için hangi pozisyonlarda nokta olacağı
    const patterns = {
      1: [false, false, false, false, true, false, false, false, false],
      2: [false, false, true, false, false, false, true, false, false],
      3: [false, false, true, false, true, false, true, false, false],
      4: [true, false, true, false, false, false, true, false, true],
      5: [true, false, true, false, true, false, true, false, true],
      6: [true, false, true, true, false, true, true, false, true],
    };

    final pattern = patterns[value] ?? List.filled(9, false);
    return pattern
        .map((hasDot) => Center(
              child: hasDot
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1A0D2A), shape: BoxShape.circle),
                    )
                  : const SizedBox.shrink(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sum = _diceValues.reduce((a, b) => a + b);

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
          child: const Text('🎲 Zar Falı',
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
              const Text('Evrenin Zarları',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              if (!_rolled && !_rolling) ...[
                const Text('🎲', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text('"Zarları at, evrenin sana ne söylediğini dinle..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                const Text(
                    '3 zar atılacak, her birinin ve toplamının özel bir anlamı var',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 32),
              ],

              // Zarlar
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.purple1.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.purple3.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      List.generate(3, (i) => _buildDie(_diceValues[i], i)),
                ),
              ),

              if (_rolled) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.gold, AppTheme.violet]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Toplam: $sum  •  ${_sumMeanings[sum] ?? '✨'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 12,
                          color: Colors.white)),
                ),
              ],

              const SizedBox(height: 24),

              if (_rolling) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Zarlar sallanıyor... 🎲',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else if (!_rolled) ...[
                GestureDetector(
                  onTap: _rollDice,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppTheme.gold, AppTheme.violet]),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.violet.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5))
                        ]),
                    child: const Center(
                        child: Text('🎲 Zarları At!',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else if (_loading) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Zarlar yorumlanıyor... 🎲✨',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else if (_result != null) ...[
                // Zar detayları
                ...List.generate(
                    3,
                    (i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppTheme.purple1.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.purple3.withOpacity(0.3))),
                          child: Row(children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                  child: Text('${_diceValues[i]}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A0D2A)))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(_diceMeanings[_diceValues[i]] ?? '',
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 11,
                                        color: AppTheme.muted))),
                          ]),
                        )),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                  child: Text(_result!,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted,
                          height: 1.8)),
                ),
                const SizedBox(height: 20),
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
                        fortuneType: 'Zar Falı',
                        fortuneEmoji: '🎲',
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
                        fortuneType: 'Zar Falı',
                        fortuneEmoji: '🎲',
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
                    onTap: _reset,
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: const Center(
                            child: Text('🔄 Tekrar At',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
              ] else ...[
                GestureDetector(
                  onTap: _getReading,
                  child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppTheme.gold, AppTheme.violet]),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.violet.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ]),
                      child: const Center(
                          child: Text('🔮 Yorumu Gör',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1)))),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _rollDice,
                  child: Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.muted.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(23)),
                      child: const Center(
                          child: Text('🎲 Tekrar At',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                  fontFamily: 'Nunito')))),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
