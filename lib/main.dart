import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:falcim/l10n/app_localizations.dart';
import 'package:falcim/firebase_options.dart';
import 'package:falcim/screens/splash_screen.dart';
import 'package:falcim/services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final languageService = LanguageService();
  await languageService.init();

  runApp(
    ChangeNotifierProvider.value(
      value: languageService,
      child: const FalcimApp(),
    ),
  );
}

class FalcimApp extends StatelessWidget {
  const FalcimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();

    return MaterialApp(
      title: 'Falcım',
      debugShowCheckedModeBanner: false,
      locale: languageService.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('fr'),
        Locale('it'),
        Locale('es'),
        Locale('pt'),
        Locale('nl'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0618),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFFF4C842),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
