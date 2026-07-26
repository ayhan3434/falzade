import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'FALCIM'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'Evren sana bir mesaj göndermek istiyor...'**
  String get tagline;

  /// No description provided for @universeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Evren sana bir mesaj göndermek istiyor...'**
  String get universeMessage;

  /// No description provided for @selectFortune.
  ///
  /// In tr, this message translates to:
  /// **'Fal Seç'**
  String get selectFortune;

  /// No description provided for @feed.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get feed;

  /// No description provided for @explore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get explore;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @horoscope.
  ///
  /// In tr, this message translates to:
  /// **'Burçlar'**
  String get horoscope;

  /// No description provided for @chats.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get chats;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get hasAccount;

  /// No description provided for @googleLogin.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get googleLogin;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In tr, this message translates to:
  /// **'Soyisim'**
  String get surname;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get username;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @starsWaiting.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar seni bekliyor...'**
  String get starsWaiting;

  /// No description provided for @selectSign.
  ///
  /// In tr, this message translates to:
  /// **'Burcunu seç'**
  String get selectSign;

  /// No description provided for @bio.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get bio;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @shareToFeedAndProfile.
  ///
  /// In tr, this message translates to:
  /// **'✦ Akışta ve Profilde Paylaş'**
  String get shareToFeedAndProfile;

  /// No description provided for @shareToProfileOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Profilimde Paylaş'**
  String get shareToProfileOnly;

  /// No description provided for @dontShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşma'**
  String get dontShare;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Bak'**
  String get tryAgain;

  /// No description provided for @posts.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get posts;

  /// No description provided for @followers.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In tr, this message translates to:
  /// **'Takip'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In tr, this message translates to:
  /// **'Takip Et'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In tr, this message translates to:
  /// **'Takipte'**
  String get unfollow;

  /// No description provided for @comments.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz...'**
  String get writeComment;

  /// No description provided for @noPostsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz gönderi yok'**
  String get noPostsYet;

  /// No description provided for @fortuneTellAndShare.
  ///
  /// In tr, this message translates to:
  /// **'Fal çek ve paylaş!'**
  String get fortuneTellAndShare;

  /// No description provided for @noFortuneYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz fal yok 🔮'**
  String get noFortuneYet;

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı 🔮'**
  String get userNotFound;

  /// No description provided for @searchUser.
  ///
  /// In tr, this message translates to:
  /// **'İsim, @kullanıcıadı veya e-posta...'**
  String get searchUser;

  /// No description provided for @dailyComment.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Yorum ✨'**
  String get dailyComment;

  /// No description provided for @starsConsulting.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlara danışılıyor... ✨'**
  String get starsConsulting;

  /// No description provided for @tapToClose.
  ///
  /// In tr, this message translates to:
  /// **'Ekrana dokun kapatmak için'**
  String get tapToClose;

  /// No description provided for @deletePost.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Sil'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiyi silmek istediğine emin misin?'**
  String get deletePostConfirm;

  /// No description provided for @deleteComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorumu Sil'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu yorumu silmek istiyor musun?'**
  String get deleteCommentConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silmek istediğine emin misin? Bu işlem geri alınamaz.'**
  String get deleteAccountConfirm;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @sendMessage.
  ///
  /// In tr, this message translates to:
  /// **'Zühre\'ye sor... 🔮'**
  String get sendMessage;

  /// No description provided for @fortuneReading.
  ///
  /// In tr, this message translates to:
  /// **'falım'**
  String get fortuneReading;

  /// No description provided for @copiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı!'**
  String get copiedToClipboard;

  /// No description provided for @postShared.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi paylaşıldı! ✨'**
  String get postShared;

  /// No description provided for @usernameAvailable.
  ///
  /// In tr, this message translates to:
  /// **'✅ Kullanıcı adı müsait!'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı alınmış.'**
  String get usernameTaken;

  /// No description provided for @fillAllFields.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tüm alanları doldur.'**
  String get fillAllFields;

  /// No description provided for @selectSignError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen burcunu seç.'**
  String get selectSignError;

  /// No description provided for @weakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf, en az 6 karakter gir.'**
  String get weakPassword;

  /// No description provided for @emailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu email zaten kullanımda.'**
  String get emailInUse;

  /// No description provided for @wrongPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yanlış.'**
  String get wrongPassword;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seç'**
  String get selectLanguage;

  /// No description provided for @welcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldin!'**
  String get welcomeBack;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Son birkaç adım kaldı ✨'**
  String get onboardingSubtitle;

  /// No description provided for @letsStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım'**
  String get letsStart;

  /// No description provided for @usernameHint.
  ///
  /// In tr, this message translates to:
  /// **'kullanici_adi'**
  String get usernameHint;

  /// No description provided for @usernameHelper.
  ///
  /// In tr, this message translates to:
  /// **'Bu ad ile diğerleri seni bulacak.'**
  String get usernameHelper;

  /// No description provided for @fortuneLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlanıyor... ✨'**
  String get fortuneLoading;

  /// No description provided for @starsQuiet.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar şu an sessiz... 🌙'**
  String get starsQuiet;

  /// No description provided for @universeQuiet.
  ///
  /// In tr, this message translates to:
  /// **'Evren şu an konuşmuyor... ✨'**
  String get universeQuiet;

  /// No description provided for @getFortune.
  ///
  /// In tr, this message translates to:
  /// **'Falıma Bak'**
  String get getFortune;

  /// No description provided for @fortuneWaiting.
  ///
  /// In tr, this message translates to:
  /// **'seni bekliyor... Hazır olduğunda falına baktır.'**
  String get fortuneWaiting;

  /// No description provided for @shareQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bu yorumu paylaşmak ister misin?'**
  String get shareQuestion;

  /// No description provided for @photosUploaded.
  ///
  /// In tr, this message translates to:
  /// **'fotoğraf yüklendi'**
  String get photosUploaded;

  /// No description provided for @photos.
  ///
  /// In tr, this message translates to:
  /// **'fotoğraf'**
  String get photos;

  /// No description provided for @coffeeTip.
  ///
  /// In tr, this message translates to:
  /// **'💡 İpucu: Fincanı ters çevir, 5 dakika bekle. Sonra içini, dışını ve tabağı ayrı ayrı fotoğrafla.'**
  String get coffeeTip;

  /// No description provided for @starsLookingAtCup.
  ///
  /// In tr, this message translates to:
  /// **'Yıldızlar fincana bakıyor... ☕✨'**
  String get starsLookingAtCup;

  /// No description provided for @handTip.
  ///
  /// In tr, this message translates to:
  /// **'💡 İpucu: Avucunu açık tut, parmaklar görünsün. İyi aydınlatılmış bir ortamda çek.'**
  String get handTip;

  /// No description provided for @linesBeingRead.
  ///
  /// In tr, this message translates to:
  /// **'Çizgiler okunuyor... ✋✨'**
  String get linesBeingRead;

  /// No description provided for @newPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Fotoğraf Çek'**
  String get newPhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'nl',
        'pt',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
