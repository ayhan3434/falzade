import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('users')
        .where('usernameLower', isEqualTo: username.toLowerCase().trim())
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  String? validateUsername(String username) {
    final clean = username.trim();
    if (clean.isEmpty) return 'Kullanıcı adı boş olamaz.';
    if (clean.length < 3) return 'En az 3 karakter olmalı.';
    if (clean.length > 20) return 'En fazla 20 karakter olabilir.';
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(clean))
      return 'Sadece harf, rakam ve _ kullanılabilir.';
    return null;
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String username,
    required String sign,
  }) async {
    try {
      final formatError = validateUsername(username);
      if (formatError != null) return formatError;

      final available = await isUsernameAvailable(username);
      if (!available)
        return 'Bu kullanıcı adı zaten alınmış. Başka bir tane dene.';

      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await result.user!.sendEmailVerification();

      final cleanUsername = username.trim();
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'name': name,
        'surname': surname,
        'username': cleanUsername,
        'usernameLower': cleanUsername.toLowerCase(),
        'nameLower': name.toLowerCase(),
        'surnameLower': surname.toLowerCase(),
        'email': email.toLowerCase().trim(),
        'sign': sign,
        'bio': '',
        'followers': [],
        'following': [],
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password')
        return 'Şifre çok zayıf, en az 6 karakter gir.';
      if (e.code == 'email-already-in-use') return 'Bu email zaten kullanımda.';
      return 'Bir hata oluştu: ${e.message}';
    }
  }

  Future<String?> login(
      {required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return 'E-posta adresinizi doğrulamanız gerekiyor. Lütfen gelen kutunuzu kontrol edin.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found')
        return 'Bu email ile kayıtlı kullanıcı bulunamadı.';
      if (e.code == 'wrong-password') return 'Şifre yanlış.';
      return 'Bir hata oluştu: ${e.message}';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found')
        return 'Bu email ile kayıtlı kullanıcı bulunamadı.';
      return 'Bir hata oluştu: ${e.message}';
    }
  }

  // Güncellendi: Map döner — yeni kullanıcı mı, mevcut mu, hata mı
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '874063597243-1tl014qr5bfh8g3g1hl2s4eiqcejjbdq.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return {'error': 'Google girişi iptal edildi.'};

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final user = result.user!;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        // Yeni kullanıcı — onboarding ekranına yönlendir
        final nameParts = (user.displayName ?? 'Kullanıcı').split(' ');
        final name = nameParts.first;
        final surname =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        return {
          'isNewUser': true,
          'uid': user.uid,
          'name': name,
          'surname': surname,
          'email': user.email ?? '',
        };
      }

      // Mevcut kullanıcı — direkt giriş
      return {'isNewUser': false};
    } catch (e) {
      return {'error': 'Google ile giriş başarısız: $e'};
    }
  }

  Future<void> logout() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<String?> deleteAccount({String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Kullanıcı bulunamadı.';
      final uid = user.uid;

      // Yeniden kimlik doğrulama
      try {
        final providers = user.providerData.map((p) => p.providerId).toList();
        if (providers.contains('google.com')) {
          // Google kullanıcısı
          final googleSignIn = GoogleSignIn();
          final googleUser = await googleSignIn.signIn();
          if (googleUser == null) return 'Google doğrulaması iptal edildi.';
          final googleAuth = await googleUser.authentication;
          final credential =
              GoogleAuthProvider.credential(idToken: googleAuth.idToken);
          await user.reauthenticateWithCredential(credential);
        } else {
          // Email/şifre kullanıcısı
          if (password == null || password.isEmpty) return 'REQUIRE_PASSWORD';
          final email = user.email ?? '';
          final credential =
              EmailAuthProvider.credential(email: email, password: password);
          await user.reauthenticateWithCredential(credential);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') return 'Şifre yanlış.';
        return 'Doğrulama başarısız: ${e.message}';
      }

      // Önce verileri sil
      final posts = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in posts.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('users').doc(uid).delete();

      // Sonra hesabı sil
      await user.delete();
      return null;
    } catch (e) {
      return 'Hesap silinemedi: $e';
    }
  }
}
