import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/app_bootstrap.dart';
import '../models/session_user.dart';
import '../persistence/session_storage.dart';
import '../services/supabase_auth_service.dart';

class AuthController extends Notifier<SessionUser?> {
  @override
  SessionUser? build() => AppBootstrap.preloadedUser;

  Future<void> signIn(SessionUser user) async {
    state = user;
    AppBootstrap.preloadedUser = user;
    await SessionStorage.save(user);
  }

  Future<void> signOut() async {
    await SupabaseAuthService.signOut();
    state = null;
    AppBootstrap.preloadedUser = null;
    await SessionStorage.clear();
  }
}

final authProvider = NotifierProvider<AuthController, SessionUser?>(
  AuthController.new,
);
