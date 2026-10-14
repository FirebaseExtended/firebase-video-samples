import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../model/user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({fb_auth.FirebaseAuth? auth})
      : _auth = auth ?? fb_auth.FirebaseAuth.instance;

  final fb_auth.FirebaseAuth _auth;

  fb_auth.User? get currentUser => _auth.currentUser;

  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser> createAnonymousAccount() async {
    final authResult = await _auth.signInAnonymously();
    return AppUser(authId: authResult.user?.uid ?? '');
  }
}
