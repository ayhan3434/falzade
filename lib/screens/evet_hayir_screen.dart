import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class EvetHayirScreen extends StatefulWidget {
  const EvetHayirScreen({super.key});

  @override
  State<EvetHayirScreen> createState() => _EvetHayirScreenState();
}

class _EvetHayirScreenState extends State<EvetHayirScreen>
    with TickerProviderStateMixin {
  final _random = Random();
  final _questionController = TextEditingController();
  String _question = '';
  bool _loading = false;
  bool _spinning = false;
  String? _answer;
  String? _result;

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const _answers = [
    'EVET',
    'HAYIR',
    'BELKI',
    'KESİNLİKLE EVET',
    'KESİNLİKLE HAYIR',
    'ŞÜPHELİ'
  ];
  static const _answerColors = {
    'EVET': Color(0xFF00C853),
    'HAYIR': Color(0xFFD50000),
    'BELKI': Color(0xFFFFAB00),
    'KESİNLİKLE EVET': Color(0xFF00E676),
    'KESİNLİKLE HAYIR': Color(0xFFFF1744),
    'ŞÜPHELİ': Color(0xFF7C4DFF),
  };
  static const _answerEmojis = {
    'EVET': '✅',
    'HAYIR': '❌',
    'BELKI': '🤔',
    'KESİNLİKLE EVET': '🌟',
    'KESİNLİKLE HAYIR': '🚫',
    'ŞÜPHELİ': '🔮',
  };
  static const _weights = [30, 25, 20, 10, 10, 5];

  @override
  void initState() {
    super.initState();
    _spinController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _spinAnimation = Tween<double>(begin: 0, end: 8 * pi).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.easeOut));
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_glowController);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _glowController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  String _getWeightedAnswer() {
    final total = _weights.reduce((a, b) => a + b);
    int rand = _random.nextInt(total);
    for (int i = 0; i < _weights.length; i++) {
      rand -= _weights[i];
      if (rand < 0) return _answers[i];
    }
    return _answers[0];
  }

  Future<void> _askQuestion() async {
    if (_question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen sorunuzu yazın'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _spinning = true;
      _answer = null;
      _result = null;
    });
    _spinController.reset();

    final answer = _getWeightedAnswer();

    await _spinController.forward();

    if (mounted)
      setState(() {
        _spinning = false;
        _answer = answer;
      });
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
          'max_tokens': 350,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Evet/Hayır falı yorumu yap. Soru: "$_question"\nEvrenin cevabı: $_answer\n\nBu cevabı soruyla ilişkilendirerek mistik ve şiirsel şekilde yorumla. Neden bu cevabın geldiğini anlat. Türkçe, 3-4 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Evren şu an sessiz... 🌙';
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
      _answer = null;
      _result = null;
      _question = '';
    });
    _questionController.clear();
    _spinController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final answerColor =
        _answer != null ? _answerColors[_answer]! : AppTheme.gold;

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
          child: const Text('🎱 Evet / Hayır',
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
              const Text('Evrenin Cevabı',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 32),

              // 8 top animasyonu
              AnimatedBuilder(
                animation: Listenable.merge([_spinAnimation, _glowAnimation]),
                builder: (context, child) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _answer != null
                            ? [
                                answerColor.withOpacity(0.3),
                                const Color(0xFF1A0D2A)
                              ]
                            : [
                                const Color(0xFF2A1A4A),
                                const Color(0xFF0A0520)
                              ],
                        center: Alignment.topLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_answer != null
                                  ? answerColor
                                  : AppTheme.violet)
                              .withOpacity(
                                  _spinning ? 0.6 : _glowAnimation.value * 0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: (_answer != null ? answerColor : AppTheme.gold)
                            .withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: _spinning
                        ? Transform.rotate(
                            angle: _spinAnimation.value,
                            child: const Center(
                                child:
                                    Text('🎱', style: TextStyle(fontSize: 80))),
                          )
                        : _answer != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(_answerEmojis[_answer]!,
                                        style: const TextStyle(fontSize: 40)),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(_answer!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Cinzel',
                                              fontSize: 14,
                                              color: answerColor,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1)),
                                    ),
                                  ])
                            : const Center(
                                child:
                                    Text('🎱', style: TextStyle(fontSize: 80))),
                  );
                },
              ),
              const SizedBox(height: 32),

              if (_answer == null && !_spinning) ...[
                const Text('"Sorunuzu sorun, evren cevaplasın..."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 24),
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
                    maxLines: 3,
                    onChanged: (v) => setState(() => _question = v),
                    decoration: const InputDecoration(
                      hintText:
                          'Sorunuzu buraya yazın...\n(Evet/Hayır ile cevaplanabilecek bir soru)',
                      hintStyle: TextStyle(
                          color: AppTheme.muted, fontSize: 13, height: 1.5),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _askQuestion,
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
                      ],
                    ),
                    child: const Center(
                        child: Text('🎱 Cevabı Öğren',
                            style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1))),
                  ),
                ),
              ] else if (_spinning) ...[
                const Text('Evren düşünüyor...',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 8),
                Text('"$_question"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppTheme.muted,
                        fontStyle: FontStyle.italic)),
              ] else if (_answer != null) ...[
                Text('"$_question"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
                const SizedBox(height: 16),
                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 12),
                  const Text('Yorum yapılıyor... ✨',
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
                      color: answerColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: answerColor.withOpacity(0.3)),
                    ),
                    child: Text(_result!,
                        style: const TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
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
                          fortuneType: 'Evet / Hayır',
                          fortuneEmoji: '🎱',
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
                          fortuneType: 'Evet / Hayır',
                          fortuneEmoji: '🎱',
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
                                    fontFamily: 'Nunito')))),
                  ),
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
                        ],
                      ),
                      child: const Center(
                          child: Text('🔮 Yorumu Gör',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
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
                                    fontFamily: 'Nunito')))),
                  ),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
