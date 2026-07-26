import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/services/post_service.dart';
import 'package:falcim/constants.dart';
import 'package:falcim/l10n/app_localizations.dart';
import 'package:falcim/services/language_service.dart';
import 'package:provider/provider.dart';
import 'package:falcim/screens/tarot_screen.dart';
import 'package:falcim/screens/iskambil_screen.dart';
import 'package:falcim/screens/lenormand_screen.dart';
import 'package:falcim/screens/melek_screen.dart';
import 'package:falcim/screens/runik_screen.dart';
import 'package:falcim/screens/ogham_screen.dart';
import 'package:falcim/screens/zar_screen.dart';
import 'package:falcim/screens/pendulum_screen.dart';
import 'package:falcim/screens/grafology_screen.dart';
import 'package:falcim/screens/numeroloji_screen.dart';
import 'package:falcim/screens/ruya_screen.dart';
import 'package:falcim/screens/evet_hayir_screen.dart';
import 'package:falcim/screens/katina_screen.dart';
import 'package:falcim/screens/bakla_screen.dart';
import 'package:falcim/screens/yildiz_haritasi_screen.dart';
import 'package:falcim/screens/ay_screen.dart';
import 'package:falcim/screens/kristal_screen.dart';
import 'package:falcim/screens/enerji_screen.dart';
import 'package:falcim/screens/kabala_screen.dart';
import 'package:falcim/screens/mum_screen.dart';
import 'package:falcim/screens/su_screen.dart';
import 'package:falcim/screens/cicek_screen.dart';
import 'package:falcim/screens/boncuk_screen.dart';
import 'package:falcim/screens/nazar_screen.dart';
import 'package:falcim/screens/druid_screen.dart';

class FortuneScreen extends StatelessWidget {
  const FortuneScreen({super.key});

  final List<Map<String, dynamic>> _fortuneTypes = const [
    {
      'emoji': '☕',
      'name': 'Kahve Falı',
      'desc': 'Fincanını fotoğrafla, AI yorumlasın',
      'color1': 0xFF1E0F35,
      'color2': 0xFF2D1654,
      'type': 'coffee'
    },
    {
      'emoji': '🃏',
      'name': 'Tarot',
      'desc': 'Günlük 3 kart çek',
      'color1': 0xFF0D1535,
      'color2': 0xFF1A2060,
      'type': 'tarot'
    },
    {
      'emoji': '✋',
      'name': 'El Falı',
      'desc': 'Avucunu fotoğrafla, AI yorumlasın',
      'color1': 0xFF200D30,
      'color2': 0xFF3A1060,
      'type': 'hand'
    },
    {
      'emoji': '🎴',
      'name': 'İskambil Falı',
      'desc': 'Karıştır, kes, 7 kart aç',
      'color1': 0xFF0D1535,
      'color2': 0xFF1A2060,
      'type': 'iskambil'
    },
    {
      'emoji': '🫘',
      'name': 'Bakla Falı',
      'desc': 'Geleneksel Türk kehaneti',
      'color1': 0xFF1E0F35,
      'color2': 0xFF2D1654,
      'type': 'bakla'
    },
    {
      'emoji': '👼',
      'name': 'Melek Falı',
      'desc': 'Meleklerin mesajı',
      'color1': 0xFF0D2035,
      'color2': 0xFF1A4060,
      'type': 'melek'
    },
    {
      'emoji': '📜',
      'name': 'Katina Falı',
      'desc': 'Antik Mısır 5 kart kehaneti',
      'color1': 0xFF200F30,
      'color2': 0xFF351565,
      'type': 'katina'
    },
    {
      'emoji': '⭐',
      'name': 'Yıldız Haritası',
      'desc': 'Doğum haritanı keşfet',
      'color1': 0xFF0D2035,
      'color2': 0xFF1A4060,
      'type': 'yildizharitasi'
    },
    {
      'emoji': '💭',
      'name': 'Rüya Yorumu',
      'desc': 'Rüyanı anlat, yorumlayalım',
      'color1': 0xFF1A0D2A,
      'color2': 0xFF2D1650,
      'type': 'ruya'
    },
    {
      'emoji': '🔢',
      'name': 'Numeroloji',
      'desc': 'İsmin ve doğum tarihin',
      'color1': 0xFF200F30,
      'color2': 0xFF351565,
      'type': 'numeroloji'
    },
    {
      'emoji': '🌙',
      'name': 'Ay Falı',
      'desc': 'Ay\'ın etkisini keşfet',
      'color1': 0xFF0D1535,
      'color2': 0xFF1A2060,
      'type': 'ay'
    },
    {
      'emoji': '🎱',
      'name': 'Evet / Hayır',
      'desc': 'Sorunun cevabını al',
      'color1': 0xFF1A0D2A,
      'color2': 0xFF2D1650,
      'type': 'evethayir'
    },
    {
      'emoji': '💎',
      'name': 'Kristal Falı',
      'desc': 'Kristallerin enerjisi',
      'color1': 0xFF0D2035,
      'color2': 0xFF1A4060,
      'type': 'kristal'
    },
    {
      'emoji': '🍃',
      'name': 'Çay Falı',
      'desc': 'Çay yapraklarını yorumla',
      'color1': 0xFF1E0F35,
      'color2': 0xFF2D1654,
      'type': 'cay'
    },
    {
      'emoji': '🪬',
      'name': 'Enerji Falı',
      'desc': 'Aura ve enerji analizi',
      'color1': 0xFF200D30,
      'color2': 0xFF3A1060,
      'type': 'enerji'
    },
    {
      'emoji': '᚛',
      'name': 'Runik Alfabe',
      'desc': 'Viking kehanet taşları',
      'color1': 0xFF200F30,
      'color2': 0xFF351565,
      'type': 'runik'
    },
    {
      'emoji': '🎯',
      'name': 'Pendulum',
      'desc': 'Sarkaç kehaneti',
      'color1': 0xFF0D1535,
      'color2': 0xFF1A2060,
      'type': 'pendulum'
    },
    {
      'emoji': '🎲',
      'name': 'Zar Falı',
      'desc': 'Zarların gizemi',
      'color1': 0xFF1A0D2A,
      'color2': 0xFF2D1650,
      'type': 'zar'
    },
    {
      'emoji': '🌺',
      'name': 'Lenormand',
      'desc': 'Fransız 36 kart kehaneti',
      'color1': 0xFF200D30,
      'color2': 0xFF3A1060,
      'type': 'lenormand'
    },
    {
      'emoji': '🌿',
      'name': 'Ogham',
      'desc': 'Kelt ağaç kehaneti',
      'color1': 0xFF0D2035,
      'color2': 0xFF1A4060,
      'type': 'ogham'
    },
    {
      'emoji': '✍️',
      'name': 'Grafology',
      'desc': 'El yazısı analizi',
      'color1': 0xFF1E0F35,
      'color2': 0xFF2D1654,
      'type': 'grafology'
    },
    {
      'emoji': '🔯',
      'name': 'Kabala',
      'desc': 'Yahudi mistisizmi',
      'color1': 0xFF200F30,
      'color2': 0xFF351565,
      'type': 'kabala'
    },
    {
      'emoji': '🕯️',
      'name': 'Mum Falı',
      'desc': 'Mumun alevinden kehanet',
      'color1': 0xFF1A0D2A,
      'color2': 0xFF2D1650,
      'type': 'mum'
    },
    {
      'emoji': '🌊',
      'name': 'Su Falı',
      'desc': 'Suyun yüzeyindeki işaretler',
      'color1': 0xFF0D1535,
      'color2': 0xFF1A2060,
      'type': 'su'
    },
    {
      'emoji': '🌸',
      'name': 'Çiçek Falı',
      'desc': 'Yaprakların gizemi',
      'color1': 0xFF200D30,
      'color2': 0xFF3A1060,
      'type': 'cicek'
    },
    {
      'emoji': '📿',
      'name': 'Boncuk Falı',
      'desc': 'Boncukların enerjisi',
      'color1': 0xFF0D2035,
      'color2': 0xFF1A4060,
      'type': 'boncuk'
    },
    {
      'emoji': '🧿',
      'name': 'Nazar Falı',
      'desc': 'Nazar boncuğunun sırrı',
      'color1': 0xFF1E0F35,
      'color2': 0xFF2D1654,
      'type': 'nazar'
    },
    {
      'emoji': '🌙',
      'name': 'Druid Falı',
      'desc': 'Antik Kelt kehaneti',
      'color1': 0xFF200F30,
      'color2': 0xFF351565,
      'type': 'druid'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            _buildHeader(context, l10n),
            _buildCrystalBall(),
            _buildSubtitle(l10n),
            _buildFortuneGrid(context),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.goldToLilac.createShader(bounds),
            child: Text(l10n.selectFortune,
                style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2))),
      ]),
    );
  }

  Widget _buildCrystalBall() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Stack(alignment: Alignment.center, children: [
        Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
              BoxShadow(
                  color: AppTheme.violet.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 20)
            ])),
        const Text('🔮', style: TextStyle(fontSize: 80)),
      ]),
    );
  }

  Widget _buildSubtitle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Text('"${l10n.universeMessage}"',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppTheme.muted,
              height: 1.5)),
    );
  }

  Widget _buildFortuneGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2),
        itemCount: _fortuneTypes.length,
        itemBuilder: (context, index) =>
            _buildFortuneCard(context, _fortuneTypes[index]),
      ),
    );
  }

  Widget _buildFortuneCard(BuildContext context, Map<String, dynamic> fortune) {
    final type = fortune['type'] as String;
    final hasCamera = type == 'coffee' || type == 'hand' || type == 'grafology';
    return GestureDetector(
      onTap: () => _navigate(context, fortune),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(fortune['color1']), Color(fortune['color2'])],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.purple3.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.purple2.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  Text(fortune['emoji'], style: const TextStyle(fontSize: 36)),
                  if (hasCamera)
                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                                color: AppTheme.gold,
                                borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 10))),
                ]),
                const SizedBox(height: 8),
                Text(fortune['name'],
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 12,
                        color: AppTheme.white,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(fortune['desc'],
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.muted,
                        fontFamily: 'Nunito',
                        height: 1.3)),
              ]),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Map<String, dynamic> fortune) {
    final type = fortune['type'] as String;
    switch (type) {
      case 'coffee':
        showModalBottomSheet(
            context: context,
            backgroundColor: AppTheme.void_,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (_) => const _CoffeeFortuneSheet());
        break;
      case 'tarot':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TarotScreen()));
        break;
      case 'hand':
        showModalBottomSheet(
            context: context,
            backgroundColor: AppTheme.void_,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (_) => const _HandFortuneSheet());
        break;
      case 'iskambil':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const IskambilScreen()));
        break;
      case 'bakla':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BaklaScreen()));
        break;
      case 'melek':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MelekScreen()));
        break;
      case 'katina':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const KatinaScreen()));
        break;
      case 'ruya':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const RuyaScreen()));
        break;
      case 'numeroloji':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NumerologiScreen()));
        break;
      case 'evethayir':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EvetHayirScreen()));
        break;
      case 'runik':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const RunikScreen()));
        break;
      case 'pendulum':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PendulumScreen()));
        break;
      case 'zar':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ZarScreen()));
        break;
      case 'lenormand':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LenormandScreen()));
        break;
      case 'ogham':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OghamScreen()));
        break;
      case 'grafology':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GrafologyScreen()));
        break;
      case 'yildizharitasi':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const YildizHaritasiScreen()));
        break;
      case 'ay':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AyScreen()));
        break;
      case 'kristal':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const KristalScreen()));
        break;
      case 'enerji':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EnerjiScreen()));
        break;
      case 'kabala':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const KabalaScreen()));
        break;
      case 'mum':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MumScreen()));
        break;
      case 'su':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SuScreen()));
        break;
      case 'cicek':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CicekScreen()));
        break;
      case 'boncuk':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BoncukScreen()));
        break;
      case 'nazar':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const NazarScreen()));
        break;
      case 'druid':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const DruidScreen()));
        break;
      case 'cay':
        showModalBottomSheet(
            context: context,
            backgroundColor: AppTheme.void_,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (_) => const _CayFortuneSheet());
        break;
      default:
        showModalBottomSheet(
            context: context,
            backgroundColor: AppTheme.void_,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            builder: (_) => _AiFortuneSheet(fortune: fortune));
    }
  }
}

// ==================== AI FALI ====================
class _AiFortuneSheet extends StatefulWidget {
  final Map<String, dynamic> fortune;
  const _AiFortuneSheet({required this.fortune});
  @override
  State<_AiFortuneSheet> createState() => _AiFortuneSheetState();
}

class _AiFortuneSheetState extends State<_AiFortuneSheet> {
  bool _loading = false;
  String? _result;

  String _buildPrompt() {
    final prompts = {
      'Çay Falı':
          'Imagine tea leaf shapes and give a mystical tea leaf fortune reading. Describe the shapes and symbols formed by the leaves at the bottom of the cup.'
    };
    return prompts[widget.fortune['name']] ??
        'Give a mystical and poetic fortune reading for ${widget.fortune['name']}.';
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    final langName = context.read<LanguageService>().languageName;
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
                  '${_buildPrompt()} Write in $langName. 4-5 sentences, mystical and poetic, use emojis, no markdown, plain text only.'
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
          _result = '🌙';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = '✨';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(widget.fortune['emoji'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.goldToLilac.createShader(bounds),
                child: Text(widget.fortune['name'],
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 1))),
            const SizedBox(height: 8),
            Text(widget.fortune['desc'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted)),
            const SizedBox(height: 32),
            if (_result == null && !_loading) ...[
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: AppTheme.purple1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.gold.withOpacity(0.2))),
                  child: Text(
                      '"${widget.fortune['name']} ${l10n.fortuneWaiting}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted,
                          height: 1.6))),
              const SizedBox(height: 32),
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
                      child: Center(
                          child: Text('🔮 ${l10n.getFortune}',
                              style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: 1))))),
            ] else if (_loading) ...[
              const CircularProgressIndicator(
                  color: AppTheme.gold, strokeWidth: 2),
              const SizedBox(height: 16),
              Text('${widget.fortune['name']} ${l10n.starsConsulting}',
                  style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
            ] else ...[
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
                          height: 1.8))),
              const SizedBox(height: 24),
              Text(l10n.shareQuestion,
                  style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: AppTheme.gold)),
              const SizedBox(height: 16),
              _shareButton(context, l10n.shareToFeedAndProfile, true, true,
                  widget.fortune['name'], widget.fortune['emoji']),
              const SizedBox(height: 10),
              _shareButton(context, l10n.shareToProfileOnly, false, true,
                  widget.fortune['name'], widget.fortune['emoji']),
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
                      child: Center(
                          child: Text(l10n.dontShare,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.muted,
                                  fontFamily: 'Nunito'))))),
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () => setState(() => _result = null),
                  child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppTheme.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Text('🔄 ${l10n.tryAgain}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gold,
                                  fontFamily: 'Nunito'))))),
              const SizedBox(height: 20),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _shareButton(BuildContext context, String label, bool toFeed,
      bool toProfile, String type, String emoji) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ps = PostService();
        await ps.createPost(
            caption:
                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
            fortuneType: type,
            fortuneEmoji: emoji,
            fortuneResult: _result!,
            shareToFeed: toFeed,
            shareToProfile: toProfile);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.postShared),
              backgroundColor: AppTheme.violet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))));
      },
      child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              gradient: toFeed
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3])
                  : null,
              border: toFeed
                  ? null
                  : Border.all(color: AppTheme.violet.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: toFeed ? Colors.white : AppTheme.white,
                      letterSpacing: 1)))),
    );
  }
}

// ==================== KAHVE FALI ====================
class _CoffeeFortuneSheet extends StatefulWidget {
  const _CoffeeFortuneSheet();
  @override
  State<_CoffeeFortuneSheet> createState() => _CoffeeFortuneSheetState();
}

class _CoffeeFortuneSheetState extends State<_CoffeeFortuneSheet> {
  final _picker = ImagePicker();
  File? _image1, _image2, _image3;
  bool _loading = false;
  String? _result;

  int get _photoCount =>
      [_image1, _image2, _image3].where((e) => e != null).length;

  Future<void> _pickImage(int slot, ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final isValid = await _checkIfCoffee(bytes);
    if (!isValid) {
      if (mounted)
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.purple1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Kahve Fincanı Değil ☕',
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: AppTheme.gold,
                            fontSize: 15)),
                    content: const Text(
                        'Yüklediğin resim bir kahve fincanı veya kahve telvesi içermiyor.',
                        style: TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam',
                              style: TextStyle(color: AppTheme.gold)))
                    ]));
      return;
    }
    setState(() {
      if (slot == 1)
        _image1 = file;
      else if (slot == 2)
        _image2 = file;
      else
        _image3 = file;
      _result = null;
    });
  }

  Future<bool> _checkIfCoffee(List<int> bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 10,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Is there a coffee cup or coffee grounds in this image? Answer only YES or NO.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['content'][0]['text'] as String)
            .toUpperCase()
            .contains('YES');
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _analyzeAll() async {
    setState(() => _loading = true);
    final langName = context.read<LanguageService>().languageName;
    try {
      final List<Map<String, dynamic>> imageContents = [];
      for (final img in [_image1, _image2, _image3]) {
        if (img != null) {
          final bytes = await img.readAsBytes();
          imageContents.add({
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': 'image/jpeg',
              'data': base64Encode(bytes)
            }
          });
        }
      }
      imageContents.add({
        'type': 'text',
        'text':
            'Look at these ${imageContents.length} coffee cup photos and give a mystical coffee fortune reading. Write in $langName. 5-6 sentences, use emojis, no markdown, plain text only.'
      });
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 600,
                'messages': [
                  {'role': 'user', 'content': imageContents}
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = '🌙';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = '✨';
        _loading = false;
      });
    }
  }

  void _showPickOptions(int slot) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.purple1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppTheme.white),
                  title: const Text('Fotoğraf Çek',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(slot, ImageSource.camera);
                  }),
              ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: AppTheme.white),
                  title: const Text('Galeriden Seç',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(slot, ImageSource.gallery);
                  }),
              const SizedBox(height: 20),
            ]));
  }

  Widget _buildPhotoSlot(int slot, String label, File? image) {
    return GestureDetector(
      onTap: () => _showPickOptions(slot),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
            color: AppTheme.purple1.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: image != null
                    ? AppTheme.gold.withOpacity(0.6)
                    : AppTheme.purple3.withOpacity(0.4))),
        child: image != null
            ? Stack(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(image,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover)),
                Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                            color: AppTheme.gold, shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14))),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15))),
                        child: Text(label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 9,
                                color: AppTheme.gold)))),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_photo_alternate_outlined,
                    color: AppTheme.muted, size: 32),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 9,
                        color: AppTheme.muted))
              ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('☕', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('Kahve Falı',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1))),
              const SizedBox(height: 8),
              const Text('3 farklı açıdan fotoğraf yükle, AI yorumlasın ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),
              if (_result == null) ...[
                Row(children: [
                  Expanded(child: _buildPhotoSlot(1, 'Fincan İçi', _image1)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPhotoSlot(2, 'Fincan Dışı', _image2)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildPhotoSlot(3, 'Tabak', _image3)),
                ]),
                const SizedBox(height: 16),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _photoCount
                                    ? AppTheme.gold
                                    : AppTheme.muted.withOpacity(0.3))))),
                const SizedBox(height: 8),
                Text('$_photoCount/3 ${l10n.photosUploaded}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppTheme.muted)),
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.2))),
                    child: Text(l10n.coffeeTip,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: AppTheme.muted,
                            height: 1.5))),
                const SizedBox(height: 20),
                if (_loading) ...[
                  const CircularProgressIndicator(
                      color: AppTheme.gold, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(l10n.starsLookingAtCup,
                      style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.muted)),
                ] else if (_photoCount >= 1)
                  GestureDetector(
                      onTap: _analyzeAll,
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
                          child: Center(
                              child: Text(
                                  _photoCount == 3
                                      ? '🔮 ${l10n.getFortune}!'
                                      : '🔮 ${l10n.getFortune} ($_photoCount ${l10n.photos})',
                                  style: const TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 15,
                                      color: Colors.white,
                                      letterSpacing: 1))))),
              ] else ...[
                Row(children: [
                  if (_image1 != null)
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image1!,
                                height: 90, fit: BoxFit.cover))),
                  if (_image1 != null && _image2 != null)
                    const SizedBox(width: 6),
                  if (_image2 != null)
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image2!,
                                height: 90, fit: BoxFit.cover))),
                  if (_image2 != null && _image3 != null)
                    const SizedBox(width: 6),
                  if (_image3 != null)
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image3!,
                                height: 90, fit: BoxFit.cover))),
                ]),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.purple3.withOpacity(0.4))),
                    child: Text(_result!,
                        style: const TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.muted,
                            height: 1.8))),
                const SizedBox(height: 20),
                Text(l10n.shareQuestion,
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold)),
                const SizedBox(height: 16),
                _shareBtn(context, l10n.shareToFeedAndProfile, true,
                    'Kahve Falı', '☕', l10n),
                const SizedBox(height: 10),
                _shareBtn(context, l10n.shareToProfileOnly, false, 'Kahve Falı',
                    '☕', l10n),
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
                        child: Center(
                            child: Text(l10n.dontShare,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.muted,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => setState(() {
                          _image1 = null;
                          _image2 = null;
                          _image3 = null;
                          _result = null;
                        }),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text('🔄 ${l10n.newPhoto}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 20),
              ],
            ])),
      ),
    );
  }

  Widget _shareBtn(BuildContext context, String label, bool toFeed, String type,
      String emoji, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ps = PostService();
        await ps.createPost(
            caption:
                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
            fortuneType: type,
            fortuneEmoji: emoji,
            fortuneResult: _result!,
            shareToFeed: toFeed,
            shareToProfile: true);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.postShared),
              backgroundColor: AppTheme.violet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))));
      },
      child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              gradient: toFeed
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3])
                  : null,
              border: toFeed
                  ? null
                  : Border.all(color: AppTheme.violet.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: toFeed ? Colors.white : AppTheme.white,
                      letterSpacing: 1)))),
    );
  }
}

// ==================== EL FALI ====================
class _HandFortuneSheet extends StatefulWidget {
  const _HandFortuneSheet();
  @override
  State<_HandFortuneSheet> createState() => _HandFortuneSheetState();
}

class _HandFortuneSheetState extends State<_HandFortuneSheet> {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final isValid = await _checkIfHand(bytes);
    if (!isValid) {
      if (mounted)
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.purple1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('El Görünmüyor ✋',
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: AppTheme.gold,
                            fontSize: 15)),
                    content: const Text(
                        'Yüklediğin resimde bir el görünmüyor. Lütfen avucunu açık şekilde gösteren net bir fotoğraf yükle.',
                        style: TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam',
                              style: TextStyle(color: AppTheme.gold)))
                    ]));
      return;
    }
    setState(() {
      _image = file;
      _result = null;
    });
    await _analyzeHand(bytes);
  }

  Future<bool> _checkIfHand(List<int> bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 10,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Is there a human hand in this image? Answer only YES or NO.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['content'][0]['text'] as String)
            .toUpperCase()
            .contains('YES');
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _analyzeHand(List<int> bytes) async {
    setState(() => _loading = true);
    final langName = context.read<LanguageService>().languageName;
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 500,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Look at this hand photo and give a mystical palm reading. Interpret the fate line, heart line, head line and life line. Write in $langName. 5-6 sentences, use emojis, no markdown, plain text only.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = '🌙';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = '✨';
        _loading = false;
      });
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.purple1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppTheme.white),
                  title: const Text('Fotoğraf Çek',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
              ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: AppTheme.white),
                  title: const Text('Galeriden Seç',
                      style: TextStyle(color: AppTheme.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
              const SizedBox(height: 20),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('✋', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('El Falı',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1))),
              const SizedBox(height: 8),
              const Text('Avucunu fotoğrafla, AI çizgilerini yorumlasın ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),
              if (_image == null && !_loading) ...[
                Row(children: [
                  Expanded(
                      child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: AppTheme.purple1.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.4))),
                              child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('📸', style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 8),
                                    Text('Fotoğraf Çek',
                                        style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 11,
                                            color: AppTheme.white))
                                  ])))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: AppTheme.purple1.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.violet.withOpacity(0.4))),
                              child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🖼️', style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 8),
                                    Text('Galeriden Seç',
                                        style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 11,
                                            color: AppTheme.white))
                                  ])))),
                ]),
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.2))),
                    child: Text(l10n.handTip,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: AppTheme.muted,
                            height: 1.5))),
              ],
              if (_loading) ...[
                if (_image != null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover)),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 16),
                Text(l10n.linesBeingRead,
                    style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ],
              if (_result != null && !_loading) ...[
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover)),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.purple3.withOpacity(0.4))),
                    child: Text(_result!,
                        style: const TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.muted,
                            height: 1.8))),
                const SizedBox(height: 20),
                Text(l10n.shareQuestion,
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold)),
                const SizedBox(height: 16),
                _shareBtn(context, l10n.shareToFeedAndProfile, true, 'El Falı',
                    '✋', l10n),
                const SizedBox(height: 10),
                _shareBtn(context, l10n.shareToProfileOnly, false, 'El Falı',
                    '✋', l10n),
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
                        child: Center(
                            child: Text(l10n.dontShare,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.muted,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => setState(() {
                          _image = null;
                          _result = null;
                        }),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text('🔄 ${l10n.newPhoto}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 20),
              ],
            ])),
      ),
    );
  }

  Widget _shareBtn(BuildContext context, String label, bool toFeed, String type,
      String emoji, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ps = PostService();
        await ps.createPost(
            caption:
                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
            fortuneType: type,
            fortuneEmoji: emoji,
            fortuneResult: _result!,
            shareToFeed: toFeed,
            shareToProfile: true);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.postShared),
              backgroundColor: AppTheme.violet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))));
      },
      child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              gradient: toFeed
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3])
                  : null,
              border: toFeed
                  ? null
                  : Border.all(color: AppTheme.violet.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: toFeed ? Colors.white : AppTheme.white,
                      letterSpacing: 1)))),
    );
  }
}

// ==================== ÇAY FALI ====================
class _CayFortuneSheet extends StatefulWidget {
  const _CayFortuneSheet();
  @override
  State<_CayFortuneSheet> createState() => _CayFortuneSheetState();
}

class _CayFortuneSheetState extends State<_CayFortuneSheet> {
  final _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final isValid = await _checkIfTea(bytes);
    if (!isValid) {
      if (mounted)
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.purple1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: const Text('Çay Fincanı Değil 🍃',
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: AppTheme.gold,
                            fontSize: 15)),
                    content: const Text(
                        'Yüklediğin resimde çay yaprağı veya çay fincanı görünmüyor. Lütfen çay içtikten sonra fincandaki yaprakların fotoğrafını çek.',
                        style: TextStyle(
                            color: AppTheme.muted,
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.5)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam',
                              style: TextStyle(color: AppTheme.gold)))
                    ]));
      return;
    }
    setState(() {
      _image = file;
      _result = null;
    });
    await _analyzeTea(bytes);
  }

  Future<bool> _checkIfTea(List<int> bytes) async {
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 10,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Is there a tea cup with tea leaves or a tea glass in this image? Answer only YES or NO.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['content'][0]['text'] as String)
            .toUpperCase()
            .contains('YES');
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _analyzeTea(List<int> bytes) async {
    setState(() => _loading = true);
    final langName = context.read<LanguageService>().languageName;
    try {
      final base64Image = base64Encode(bytes);
      final response =
          await http.post(Uri.parse('https://api.anthropic.com/v1/messages'),
              headers: {
                'Content-Type': 'application/json',
                'x-api-key': AppConstants.claudeApiKey,
                'anthropic-version': '2023-06-01'
              },
              body: jsonEncode({
                'model': 'claude-haiku-4-5-20251001',
                'max_tokens': 500,
                'messages': [
                  {
                    'role': 'user',
                    'content': [
                      {
                        'type': 'image',
                        'source': {
                          'type': 'base64',
                          'media_type': 'image/jpeg',
                          'data': base64Image
                        }
                      },
                      {
                        'type': 'text',
                        'text':
                            'Look at this tea cup photo and give a mystical tea leaf fortune reading. Describe the shapes and symbols formed by the tea leaves and interpret their meaning. Write in $langName. 5-6 sentences, use emojis, no markdown, plain text only.'
                      }
                    ]
                  }
                ]
              }));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _result = data['content'][0]['text'] as String;
          _loading = false;
        });
      } else {
        setState(() {
          _result = '🌙';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = '✨';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('🍃', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.goldToLilac.createShader(bounds),
                  child: const Text('Çay Falı',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1))),
              const SizedBox(height: 8),
              const Text(
                  'Çay içtikten sonra fincandaki yaprakları fotoğrafla ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.muted)),
              const SizedBox(height: 24),
              if (_image == null && !_loading) ...[
                Row(children: [
                  Expanded(
                      child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: AppTheme.purple1.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.4))),
                              child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('📸', style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 8),
                                    Text('Fotoğraf Çek',
                                        style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 11,
                                            color: AppTheme.white))
                                  ])))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: GestureDetector(
                          onTap: () => _pickImage(ImageSource.gallery),
                          child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: AppTheme.purple1.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.violet.withOpacity(0.4))),
                              child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🖼️', style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 8),
                                    Text('Galeriden Seç',
                                        style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 11,
                                            color: AppTheme.white))
                                  ])))),
                ]),
                const SizedBox(height: 16),
                Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.gold.withOpacity(0.2))),
                    child: const Text(
                        '💡 Çayınızı içtikten sonra fincandaki yaprakları net bir şekilde fotoğraflayın. İyi aydınlatılmış ve net bir fotoğraf daha iyi yorum yapılmasını sağlar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: AppTheme.muted,
                            height: 1.5))),
              ],
              if (_loading) ...[
                if (_image != null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover)),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                    color: AppTheme.gold, strokeWidth: 2),
                const SizedBox(height: 16),
                const Text('Çay yaprakları okunuyor...',
                    style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.muted)),
              ],
              if (_result != null && !_loading) ...[
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover)),
                const SizedBox(height: 20),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppTheme.purple1.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.purple3.withOpacity(0.4))),
                    child: Text(_result!,
                        style: const TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.muted,
                            height: 1.8))),
                const SizedBox(height: 20),
                Text(l10n.shareQuestion,
                    style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 13,
                        color: AppTheme.gold)),
                const SizedBox(height: 16),
                _shareBtn(context, l10n.shareToFeedAndProfile, true, 'Çay Falı',
                    '🍃', l10n),
                const SizedBox(height: 10),
                _shareBtn(context, l10n.shareToProfileOnly, false, 'Çay Falı',
                    '🍃', l10n),
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
                        child: Center(
                            child: Text(l10n.dontShare,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.muted,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () => setState(() {
                          _image = null;
                          _result = null;
                        }),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text('🔄 ${l10n.newPhoto}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gold,
                                    fontFamily: 'Nunito'))))),
                const SizedBox(height: 20),
              ],
            ])),
      ),
    );
  }

  Widget _shareBtn(BuildContext context, String label, bool toFeed, String type,
      String emoji, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final ps = PostService();
        await ps.createPost(
            caption:
                '"${_result!.substring(0, _result!.length > 80 ? 80 : _result!.length)}..."',
            fortuneType: type,
            fortuneEmoji: emoji,
            fortuneResult: _result!,
            shareToFeed: toFeed,
            shareToProfile: true);
        if (context.mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.postShared),
              backgroundColor: AppTheme.violet,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))));
      },
      child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
              gradient: toFeed
                  ? const LinearGradient(
                      colors: [AppTheme.violet, AppTheme.purple3])
                  : null,
              border: toFeed
                  ? null
                  : Border.all(color: AppTheme.violet.withOpacity(0.6)),
              borderRadius: BorderRadius.circular(25)),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: toFeed ? Colors.white : AppTheme.white,
                      letterSpacing: 1)))),
    );
  }
}
