import 'package:flutter/material.dart';
import 'package:falcim/theme/app_theme.dart';
import 'package:falcim/l10n/app_localizations.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});
  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _signs = [
    {'emoji': '♈', 'name': 'Koç', 'dates': '21 Mar - 19 Nis'},
    {'emoji': '♉', 'name': 'Boğa', 'dates': '20 Nis - 20 May'},
    {'emoji': '♊', 'name': 'İkizler', 'dates': '21 May - 20 Haz'},
    {'emoji': '♋', 'name': 'Yengeç', 'dates': '21 Haz - 22 Tem'},
    {'emoji': '♌', 'name': 'Aslan', 'dates': '23 Tem - 22 Ağu'},
    {'emoji': '♍', 'name': 'Başak', 'dates': '23 Ağu - 22 Eyl'},
    {'emoji': '♎', 'name': 'Terazi', 'dates': '23 Eyl - 22 Eki'},
    {'emoji': '♏', 'name': 'Akrep', 'dates': '23 Eki - 21 Kas'},
    {'emoji': '♐', 'name': 'Yay', 'dates': '22 Kas - 21 Ara'},
    {'emoji': '♑', 'name': 'Oğlak', 'dates': '22 Ara - 19 Oca'},
    {'emoji': '♒', 'name': 'Kova', 'dates': '20 Oca - 18 Şub'},
    {'emoji': '♓', 'name': 'Balık', 'dates': '19 Şub - 20 Mar'},
  ];

  final List<String> _comments = [
    'Bugün Mars\'ın etkisiyle enerjin zirveye çıkıyor. Yeni başlangıçlar için mükemmel bir gün! Aşk hayatında sürpriz gelişmeler seni bekliyor. ✨',
    'Venüs\'ün koruması altındasın. Maddi konularda şanslı bir dönem başlıyor. Sabırlı ol, güzel şeyler kapıda! 🌸',
    'Merkür\'ün etkisiyle iletişim becerilerin ön plana çıkıyor. Sosyal hayatın hareketlenecek, yeni tanışmalar sürpriz getirebilir! 💫',
    'Ay\'ın etkisiyle duygusal bir dönemdesin. İç sesinle konuş, sezgilerin seni doğru yöne götürecek. Aile bağları güçleniyor. 🌙',
    'Güneş\'in ışığı üzerine parlıyor! Kariyer konularında cesur adımlar at. Liderlik özelliklerin bugün çok işine yarayacak. ⭐',
    'Merkür retrosu sona eriyor, kafan netleşiyor. Sağlık konularına dikkat et, kendinle ilgilenme zamanı. Meditasyon yap! 🌿',
    'Venüs seni romantik yapıyor. İlişkilerde denge ve uyum ön planda. Yeni bir aşkın tohumları atılıyor olabilir! 💜',
    'Plüton\'un derin etkisiyle içsel dönüşüm yaşıyorsun. Eski kalıpları bırak, yeniye kapı aç. Güç sende! 🔮',
    'Jüpiter\'in şansı seninle! Seyahat ve eğitim konularında fırsatlar kapını çalıyor. Cesur ol, atla! 🏹',
    'Satürn disiplini getiriyor. Uzun vadeli planların için harika bir dönem. Çalış, sabret, kazan! 🏔️',
    'Uranüs sürprizler getiriyor! Teknoloji ve yenilik konularında parlıyorsun. Farklı düşün, öne çık! ⚡',
    'Neptün\'ün büyüsü seni sarıyor. Sanatsal yeteneklerin açılıyor, hayallerinin peşinden git! 🌊',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.deep,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(l10n),
          _buildSignsList(),
          Expanded(child: _buildDetail(l10n)),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ShaderMask(
          shaderCallback: (bounds) => AppTheme.goldToLilac.createShader(bounds),
          child: Text('✦ ${l10n.dailyComment}',
              style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2))),
    );
  }

  Widget _buildSignsList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _signs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10, bottom: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppTheme.purple2, AppTheme.violet])
                      : null,
                  color: isSelected ? null : AppTheme.purple1.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSelected
                          ? AppTheme.gold.withOpacity(0.6)
                          : AppTheme.purple3.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_signs[index]['emoji']!,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text(_signs[index]['name']!,
                        style: TextStyle(
                            fontSize: 9,
                            color: isSelected ? AppTheme.gold : AppTheme.muted,
                            fontFamily: 'Nunito')),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetail(AppLocalizations l10n) {
    final sign = _signs[_selectedIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.purple2, AppTheme.violet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.violet.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ]),
          child: Column(children: [
            Text(sign['emoji']!, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(sign['name']!,
                style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 24,
                    color: AppTheme.white,
                    letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(sign['dates']!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.gold, fontFamily: 'Nunito')),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.purple1.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🌟', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(l10n.dailyComment,
                  style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 13,
                      color: AppTheme.gold.withOpacity(0.9),
                      letterSpacing: 1)),
            ]),
            const SizedBox(height: 12),
            Text(_comments[_selectedIndex],
                style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.muted,
                    height: 1.7)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.purple1.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.purple3.withOpacity(0.4))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('✦ ${l10n.dailyComment}',
                style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    color: AppTheme.gold.withOpacity(0.9),
                    letterSpacing: 1)),
            const SizedBox(height: 16),
            _buildEnergyBar('❤️ Aşk', 0.8, AppTheme.rose),
            const SizedBox(height: 10),
            _buildEnergyBar('💼 Kariyer', 0.65, AppTheme.violet),
            const SizedBox(height: 10),
            _buildEnergyBar('🌿 Sağlık', 0.9, const Color(0xFF34D399)),
            const SizedBox(height: 10),
            _buildEnergyBar('🍀 Şans', 0.7, AppTheme.gold),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEnergyBar(String label, double value, Color color) {
    return Row(children: [
      SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.muted, fontFamily: 'Nunito'))),
      Expanded(
        child: Container(
            height: 6,
            decoration: BoxDecoration(
                color: AppTheme.purple2,
                borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)
                    ])))),
      ),
      const SizedBox(width: 8),
      Text('${(value * 100).toInt()}%',
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600)),
    ]);
  }
}
