import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';

class YildizHaritasiScreen extends StatefulWidget {
  const YildizHaritasiScreen({super.key});

  @override
  State<YildizHaritasiScreen> createState() => _YildizHaritasiScreenState();
}

class _YildizHaritasiScreenState extends State<YildizHaritasiScreen>
    with TickerProviderStateMixin {
  final _cityController = TextEditingController();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String _city = '';
  bool _loading = false;
  String? _result;
  Map<String, String>? _chartData;

  late AnimationController _starController;
  late Animation<double> _starAnimation;

  String _getSunSign(DateTime date) {
    final month = date.month;
    final day = date.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Koç ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Boğa ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return 'İkizler ♊';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22))
      return 'Yengeç ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22))
      return 'Aslan ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22))
      return 'Başak ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return 'Terazi ♎';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 'Akrep ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 'Yay ♐';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return 'Oğlak ♑';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Kova ♒';
    return 'Balık ♓';
  }

  String _getMoonSign(DateTime date) {
    const signs = [
      'Koç ♈',
      'Boğa ♉',
      'İkizler ♊',
      'Yengeç ♋',
      'Aslan ♌',
      'Başak ♍',
      'Terazi ♎',
      'Akrep ♏',
      'Yay ♐',
      'Oğlak ♑',
      'Kova ♒',
      'Balık ♓'
    ];
    final daysSinceEpoch = date.difference(DateTime(2000, 1, 1)).inDays;
    final moonCycle = (daysSinceEpoch % 30).toInt();
    return signs[(moonCycle ~/ 2.5).toInt() % 12];
  }

  String _getRisingSign(DateTime date, TimeOfDay time) {
    const signs = [
      'Koç ♈',
      'Boğa ♉',
      'İkizler ♊',
      'Yengeç ♋',
      'Aslan ♌',
      'Başak ♍',
      'Terazi ♎',
      'Akrep ♏',
      'Yay ♐',
      'Oğlak ♑',
      'Kova ♒',
      'Balık ♓'
    ];
    final sunSignIndex = signs.indexOf(_getSunSign(date));
    final hourOffset = time.hour ~/ 2;
    return signs[(sunSignIndex + hourOffset) % 12];
  }

  String _getPlanetPositions(DateTime date) {
    final year = date.year;
    final month = date.month;
    const signs = [
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
    final mercury = signs[((year * 4 + month * 3) % 12)];
    final venus = signs[((year * 3 + month * 5) % 12)];
    final mars = signs[((year * 2 + month * 7) % 12)];
    final jupiter = signs[((year + month * 2) % 12)];
    final saturn = signs[((year ~/ 2 + month) % 12)];
    return 'Merkür: $mercury, Venüs: $venus, Mars: $mars, Jüpiter: $jupiter, Satürn: $saturn';
  }

  // Türkçe ay isimleri
  static const _months = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _starController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _starAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(_starController);
  }

  @override
  void dispose() {
    _starController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold, surface: AppTheme.purple1),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppTheme.gold, surface: AppTheme.purple1),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthTime = picked);
  }

  Future<void> _calculateChart() async {
    if (_birthDate == null || _birthTime == null || _city.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm bilgileri doldurun'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final sunSign = _getSunSign(_birthDate!);
    final moonSign = _getMoonSign(_birthDate!);
    final risingSign = _getRisingSign(_birthDate!, _birthTime!);
    final planets = _getPlanetPositions(_birthDate!);

    setState(() {
      _chartData = {
        'sunSign': sunSign,
        'moonSign': moonSign,
        'risingSign': risingSign,
        'planets': planets,
      };
      _loading = true;
    });

    final birthInfo =
        '${_formatDate(_birthDate!)} saat ${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}, $_city';

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
          'max_tokens': 700,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Doğum haritası (natal chart) yorumu yap.\n\nDoğum bilgileri: $birthInfo\nGüneş Burcu: $sunSign\nAy Burcu: $moonSign\nYükselen Burç: $risingSign\nGezegen Konumları: $planets\n\nBu doğum haritasını astrolojik açıdan detaylı yorumla. Kişinin karakteri, yetenekleri, aşk hayatı, kariyer ve kaderi hakkında mistik ve şiirsel bir yorum yap. Her burç ve gezegenin etkisini anlat. Türkçe, 7-8 cümle, emoji kullan, markdown kullanma.'
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
          _result = 'Yıldızlar şu an sessiz... 🌙';
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
      _birthDate = null;
      _birthTime = null;
      _city = '';
      _result = null;
      _chartData = null;
    });
    _cityController.clear();
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
          child: const Text('⭐ Yıldız Haritası',
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
              const Text('Doğum Haritanı Keşfet',
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _starAnimation,
                builder: (context, child) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.gold
                              .withOpacity(0.3 * _starAnimation.value),
                          blurRadius: 40,
                          spreadRadius: 15),
                      BoxShadow(
                          color: AppTheme.violet
                              .withOpacity(0.2 * _starAnimation.value),
                          blurRadius: 60,
                          spreadRadius: 25),
                    ],
                  ),
                  child: const Center(
                      child: Text('🌌', style: TextStyle(fontSize: 70))),
                ),
              ),
              const SizedBox(height: 16),
              const Text('"Doğduğun an gökyüzü sana özel bir harita çizdi..."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted,
                      height: 1.5)),
              const SizedBox(height: 32),
              if (_result == null) ...[
                // Doğum tarihi
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _birthDate != null
                              ? AppTheme.gold.withOpacity(0.6)
                              : AppTheme.purple3.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _birthDate != null
                            ? _formatDate(_birthDate!)
                            : 'Doğum tarihinizi seçin',
                        style: TextStyle(
                            color: _birthDate != null
                                ? AppTheme.white
                                : AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 14),
                      ),
                      const Spacer(),
                      if (_birthDate != null)
                        const Icon(Icons.check_circle,
                            color: AppTheme.gold, size: 18),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Doğum saati
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _birthTime != null
                              ? AppTheme.gold.withOpacity(0.6)
                              : AppTheme.purple3.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time_outlined,
                          color: AppTheme.gold, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _birthTime != null
                            ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
                            : 'Doğum saatinizi seçin',
                        style: TextStyle(
                            color: _birthTime != null
                                ? AppTheme.white
                                : AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 14),
                      ),
                      const Spacer(),
                      if (_birthTime != null)
                        const Icon(Icons.check_circle,
                            color: AppTheme.gold, size: 18),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Doğum şehri
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.purple1.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _city.isNotEmpty
                            ? AppTheme.gold.withOpacity(0.6)
                            : AppTheme.purple3.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(
                        color: AppTheme.white, fontFamily: 'Nunito'),
                    onChanged: (v) => setState(() => _city = v),
                    decoration: InputDecoration(
                      hintText: 'Doğum şehriniz (Ör: İstanbul)',
                      hintStyle:
                          const TextStyle(color: AppTheme.muted, fontSize: 13),
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          color: AppTheme.gold, size: 20),
                      suffixIcon: _city.isNotEmpty
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.gold, size: 18)
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: const Text(
                      '💡 Doğum saatiniz yükselen burcunuzu belirler. Bilmiyorsanız öğle saatini (12:00) girebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppTheme.muted,
                          height: 1.5)),
                ),
                const SizedBox(height: 24),

                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 16),
                  const Text('Yıldız haritanız hesaplanıyor... ⭐✨',
                      style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else ...[
                  GestureDetector(
                    onTap: _calculateChart,
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
                          child: Text('🌌 Haritamı Hesapla',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1))),
                    ),
                  ),
                ],
              ] else ...[
                if (_chartData != null) ...[
                  Row(children: [
                    Expanded(
                        child: _buildSignCard('☀️', 'Güneş Burcu',
                            _chartData!['sunSign']!, const Color(0xFFFF8C00))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildSignCard('🌙', 'Ay Burcu',
                            _chartData!['moonSign']!, const Color(0xFF4A90D9))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _buildSignCard(
                            '⬆️',
                            'Yükselen Burç',
                            _chartData!['risingSign']!,
                            const Color(0xFF9B59B6))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildSignCard('🌍', 'Doğum Yeri', _city,
                            const Color(0xFF27AE60))),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.purple3.withOpacity(0.3))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🪐 Gezegen Konumları',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 11,
                                  color: AppTheme.gold)),
                          const SizedBox(height: 8),
                          Text(_chartData!['planets']!,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: AppTheme.muted,
                                  height: 1.5)),
                        ]),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.purple1.withOpacity(0.8),
                      const Color(0xFF0D1A3A).withOpacity(0.8)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
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
                        fortuneType: 'Yıldız Haritası',
                        fortuneEmoji: '⭐',
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
                        fortuneType: 'Yıldız Haritası',
                        fortuneEmoji: '⭐',
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
                            child: Text('🔄 Yeni Harita',
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

  Widget _buildSignCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cinzel', fontSize: 9, color: AppTheme.muted)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
