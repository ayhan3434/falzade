import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class PendulumScreen extends StatefulWidget {
  const PendulumScreen({super.key});

  @override
  State<PendulumScreen> createState() => _PendulumScreenState();
}

class _PendulumScreenState extends State<PendulumScreen>
    with TickerProviderStateMixin {
  final _random = Random();

  late AnimationController _swingController;
  late Animation<double> _swingAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  bool _isSwinging = false;
  bool _answered = false;
  String? _answer;
  String? _result;
  bool _loading = false;
  String _question = '';
  final _questionController = TextEditingController();

  static const _answers = ['EVET', 'HAYIR', 'BELİRSİZ'];
  static const _answerColors = {
    'EVET': Color(0xFF00C853),
    'HAYIR': Color(0xFFD50000),
    'BELİRSİZ': Color(0xFFFFAB00),
  };
  static const _answerEmojis = {
    'EVET': '✅',
    'HAYIR': '❌',
    'BELİRSİZ': '🔮',
  };
  static const _answerMeanings = {
    'EVET':
        'Evren güçlü bir EVET enerjisi gönderiyor. Sarkaç sağa doğru kararlı bir şekilde sallanıyor.',
    'HAYIR':
        'Evren şu an için HAYIR diyor. Sarkaç sola doğru net bir şekilde sallanıyor.',
    'BELİRSİZ':
        'Enerji henüz netleşmemiş. Sarkaç dairesel hareket yapıyor. Biraz bekle ve tekrar sor.',
  };

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _swingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
        CurvedAnimation(parent: _swingController, curve: Curves.easeInOut));
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _swingController.dispose();
    _glowController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _startSwinging() async {
    if (_question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen önce sorunuzu yazın'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isSwinging = true;
      _answered = false;
      _answer = null;
      _result = null;
    });

    // Sallama animasyonu - 3 saniye
    _swingController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 4));

    // Cevabı belirle
    final answerIndex = _random.nextInt(3);
    // Ağırlık: EVET %45, HAYIR %35, BELİRSİZ %20
    final weighted = _random.nextInt(100);
    String finalAnswer;
    if (weighted < 45) {
      finalAnswer = 'EVET';
    } else if (weighted < 80) {
      finalAnswer = 'HAYIR';
    } else {
      finalAnswer = 'BELİRSİZ';
    }

    // Cevaba göre animasyonu ayarla
    _swingController.stop();
    if (finalAnswer == 'EVET') {
      _swingAnimation = Tween<double>(begin: 0.25, end: 0.35).animate(
          CurvedAnimation(parent: _swingController, curve: Curves.easeInOut));
    } else if (finalAnswer == 'HAYIR') {
      _swingAnimation = Tween<double>(begin: -0.35, end: -0.25).animate(
          CurvedAnimation(parent: _swingController, curve: Curves.easeInOut));
    } else {
      _swingAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(parent: _swingController, curve: Curves.easeInOut));
    }
    _swingController.repeat(reverse: true);

    if (mounted) {
      setState(() {
        _isSwinging = false;
        _answered = true;
        _answer = finalAnswer;
      });
    }
  }

  Future<void> _getReading() async {
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
          'max_tokens': 400,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Pendulum (sarkaç) falı yorumu yap. Soru: "$_question"\nSarkaç cevabı: $_answer\nAnlamı: ${_answerMeanings[_answer]}\n\nBu cevabı soruyla ilişkilendirerek mistik ve şiirsel şekilde yorumla. Türkçe, 3-4 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Sarkaç şu an sessiz... 🎯';
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
    _swingController.stop();
    _swingAnimation = Tween<double>(begin: -0.3, end: 0.3).animate(
        CurvedAnimation(parent: _swingController, curve: Curves.easeInOut));
    setState(() {
      _answered = false;
      _answer = null;
      _result = null;
      _isSwinging = false;
      _question = '';
    });
    _questionController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
          child: const Text('🎯 Pendulum',
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
              const Text('Sarkaç Kehaneti',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 8),
              const Text('Sorunuzu sorun, sarkaç cevaplasın',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 13,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              // Sarkaç animasyonu
              SizedBox(
                height: 220,
                child: AnimatedBuilder(
                  animation: _swingAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _PendulumPainter(
                        angle: _swingAnimation.value,
                        glowIntensity: _glowAnimation.value,
                        answer: _answer,
                      ),
                      child: Container(),
                    );
                  },
                ),
              ),

              // Cevap göstergesi
              if (_answered && _answer != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: _answerColors[_answer]!.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _answerColors[_answer]!.withOpacity(0.6),
                        width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_answerEmojis[_answer]!,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text(_answer!,
                          style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 24,
                              color: _answerColors[_answer],
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(_answerMeanings[_answer]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted,
                        height: 1.5)),
              ] else if (_isSwinging) ...[
                const SizedBox(height: 16),
                const Text('Sarkaç sallanıyor... 🎯',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ],

              const SizedBox(height: 24),

              // Soru girişi
              if (!_answered) ...[
                Container(
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppTheme.purple3.withOpacity(0.4))),
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(
                        color: AppTheme.white, fontFamily: 'Nunito'),
                    maxLines: 2,
                    onChanged: (v) => setState(() => _question = v),
                    decoration: const InputDecoration(
                      hintText:
                          'Sorunuzu buraya yazın... (Ör: Bu iş benim için doğru mu?)',
                      hintStyle: TextStyle(color: AppTheme.muted, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 İpucu: Evet/Hayır ile cevaplanabilecek net bir soru sorun. Zihninizi sakin tutun ve soruya odaklanın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted,
                          height: 1.5)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _isSwinging ? null : _startSwinging,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _isSwinging
                          ? null
                          : const LinearGradient(
                              colors: [AppTheme.gold, AppTheme.violet]),
                      color:
                          _isSwinging ? AppTheme.muted.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: _isSwinging
                          ? []
                          : [
                              BoxShadow(
                                  color: AppTheme.violet.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5))
                            ],
                    ),
                    child: Center(
                        child: Text(
                            _isSwinging
                                ? 'Sarkaç sallanıyor...'
                                : '🎯 Sarkacı Başlat',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color:
                                    _isSwinging ? AppTheme.muted : Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else if (_loading) ...[
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 12),
                const Text('Sarkaç yorumlanıyor... ✨',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ] else if (_result != null) ...[
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
                        fortuneType: 'Pendulum',
                        fortuneEmoji: '🎯',
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
                        fortuneType: 'Pendulum',
                        fortuneEmoji: '🎯',
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
                            child: Text('🔄 Yeni Soru Sor',
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
                    onTap: _reset,
                    child: Container(
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.muted.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(23)),
                        child: const Center(
                            child: Text('🔄 Tekrar Sor',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.muted,
                                    fontFamily: 'Nunito'))))),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final double angle;
  final double glowIntensity;
  final String? answer;

  _PendulumPainter(
      {required this.angle, required this.glowIntensity, this.answer});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = 20.0;
    final length = size.height - 60;

    // İp ucu koordinatları
    final endX = cx + length * sin(angle);
    final endY = cy + length * cos(angle);

    // Glow rengi
    Color glowColor;
    if (answer == 'EVET')
      glowColor = const Color(0xFF00C853);
    else if (answer == 'HAYIR')
      glowColor = const Color(0xFFD50000);
    else
      glowColor = const Color(0xFFFFD700);

    // Glow efekti
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.3 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(Offset(cx, cy), Offset(endX, endY), glowPaint);

    // İp
    final ropePaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy), Offset(endX, endY), ropePaint);

    // Tutma noktası
    final anchorPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(cx, cy), 6, anchorPaint);

    // Sarkaç taşı - glow
    final stoneGlowPaint = Paint()
      ..color = glowColor.withOpacity(0.4 * glowIntensity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(endX, endY), 22, stoneGlowPaint);

    // Sarkaç taşı
    final gradient = RadialGradient(
      colors: [glowColor.withOpacity(0.8), const Color(0xFF1A0D2A)],
      center: Alignment.topLeft,
    );
    final stonePaint = Paint()
      ..shader = gradient
          .createShader(Rect.fromCircle(center: Offset(endX, endY), radius: 18))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 18, stonePaint);

    // Taş kenarı
    final stoneBorderPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(endX, endY), 18, stoneBorderPaint);

    // Taş üzerindeki sembol
    final textPainter = TextPainter(
      text: TextSpan(
        text: answer == 'EVET'
            ? '✦'
            : answer == 'HAYIR'
                ? '✗'
                : '○',
        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(endX - textPainter.width / 2, endY - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(_PendulumPainter oldDelegate) => true;
}
