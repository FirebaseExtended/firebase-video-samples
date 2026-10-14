import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../datasource/auth_remote_datasource.dart';
import '../model/user.dart';

class AuthRepository {
  AuthRepository(this._authRemoteDataSource);

  final AuthRemoteDataSource _authRemoteDataSource;

  fb_auth.User? get currentUser => _authRemoteDataSource.currentUser;

  Stream<fb_auth.User?> get authStateChanges =>
      _authRemoteDataSource.authStateChanges;

  Future<AppUser> createAnonymousAccount() {
    return _authRemoteDataSource.createAnonymousAccount();
  }
}
