import 'package:todo_app_flutter/services/auth/auth_provider.dart';
import 'package:todo_app_flutter/services/auth/auth_user.dart';
import 'package:todo_app_flutter/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> logOut() async => provider.logOut();

  @override
  Future<void> sendEmailVerification() async =>
      provider.sendEmailVerification();
}
