import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_runtime.dart';
import '../data/seed_units.dart';
import '../models/app_role.dart';
import '../models/session_user.dart';
import '../models/unit.dart';

enum MobileAuthStatus {
  signedIn,
  registrationComplete,
  emailConfirmationRequired,
}

class MobileAuthResult {
  const MobileAuthResult({
    required this.status,
    this.user,
    required this.message,
  });

  final MobileAuthStatus status;
  final SessionUser? user;
  final String message;
}

abstract final class SupabaseAuthService {
  static SupabaseClient get _client {
    if (!supabaseApplicationReady) {
      throw const AuthException(
        'This app build is not connected to EBOMIM services. Ask IT for a configured release.',
      );
    }
    return Supabase.instance.client;
  }

  static Future<MobileAuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final authUser = response.user;
    if (authUser == null) {
      throw AuthException('Unable to sign in. Check your email and password.');
    }

    final sessionUser = await loadSessionUser(authUser.id);
    if (sessionUser == null) {
      await _client.auth.signOut();
      return const MobileAuthResult(
        status: MobileAuthStatus.registrationComplete,
        message:
            'Your account profile was not found. Please create your account again or contact support.',
      );
    }

    return MobileAuthResult(
      status: MobileAuthStatus.signedIn,
      user: sessionUser,
      message: 'Signed in successfully.',
    );
  }

  static Future<MobileAuthResult> signUpWithProfile({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required AppRole role,
    String? directorateCode,
    String? unitCode,
    String? stateName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'role': _supabaseRole(role),
        if (directorateCode != null && directorateCode.isNotEmpty) 'directorate_code': directorateCode,
        if (unitCode != null && unitCode.isNotEmpty) 'unit_code': unitCode,
        if (stateName != null && stateName.isNotEmpty) 'state_name': stateName,
      },
    );
    final authUser = response.user;
    if (authUser == null) {
      throw AuthException('Unable to create account. Please try again.');
    }

    if (response.session == null) {
      return const MobileAuthResult(
        status: MobileAuthStatus.emailConfirmationRequired,
        message:
            'Registration complete. Check your email to confirm it, then sign in.',
      );
    }

    final sessionUser = await loadSessionUser(authUser.id);
    if (sessionUser == null) {
      await _client.auth.signOut();
      throw AuthException('Registration completed, but profile setup failed.');
    }

    return MobileAuthResult(
      status: MobileAuthStatus.signedIn,
      user: sessionUser,
      message: 'Registration complete.',
    );
  }

  static Future<void> signOut() async {
    if (!supabaseApplicationReady) return;
    await _client.auth.signOut();
  }

  static Future<SessionUser?> loadSessionUser(String userId) async {
    if (!supabaseApplicationReady) return null;
    final row = await _client
        .from('profiles')
        .select('''
          id,
          full_name,
          role,
          email,
          phone,
          avatar_url,
          directorates(code, name),
          units(code, name),
          reference_states(id, name)
        ''')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;
    final roleName = row['role'] as String?;
    final role = _mobileRoleFromSupabase(roleName);
    if (role == null) return null;

    final directorate = row['directorates'] as Map<String, dynamic>?;
    final directorateCode = directorate?['code'] as String?;
    final directorateName = directorate?['name'] as String?;
    
    final stateInfo = row['reference_states'] as Map<String, dynamic>?;
    final stateId = stateInfo?['id'] as String?;
    final stateName = stateInfo?['name'] as String?;

    if (role != AppRole.stateCoordinator) {
      if (directorateCode == null || directorateName == null) return null;
    } else {
      if (stateName == null) return null;
    }

    final unit = row['units'] as Map<String, dynamic>?;
    final primaryUnitCode = unit?['code'] as String?;
    final units = directorateCode != null ? unitsForDirectorate(directorateCode) : <Unit>[];
    final unitIds = switch (role) {
      AppRole.unitHead => [if (primaryUnitCode != null) primaryUnitCode],
      AppRole.manager => units.map((u) => u.id).toList(),
      AppRole.director => <String>[],
      AppRole.stateCoordinator => const <String>[],
    };

    return SessionUser(
      id: userId,
      displayName: row['full_name'] as String? ?? 'IMS User',
      role: role,
      directorateId: directorateCode,
      directorateName: directorateName,
      stateId: stateId,
      stateName: stateName,
      unitIds: unitIds,
      primaryUnitId: role == AppRole.unitHead ? primaryUnitCode : null,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  static const String _avatarBucket = 'avatars';

  /// Saves [localCroppedPath] as JPEG at `{userId}/avatar.jpg` and updates [profiles.avatar_url].
  static Future<SessionUser?> uploadAvatarJpeg(String localCroppedPath) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw AuthException('Sign in again to update your photo.');
    }
    final file = File(localCroppedPath);
    if (!await file.exists()) {
      throw AuthException('Could not read the image file.');
    }

    final path = '${authUser.id}/avatar.jpg';
    await _client.storage.from(_avatarBucket).upload(
          path,
          file,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final publicUrl = _client.storage.from(_avatarBucket).getPublicUrl(path);
    await _client.from('profiles').update({'avatar_url': publicUrl}).eq('id', authUser.id);

    return loadSessionUser(authUser.id);
  }

  static Future<SessionUser?> clearAvatar() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw AuthException('Sign in again to update your photo.');
    }
    final path = '${authUser.id}/avatar.jpg';
    try {
      await _client.storage.from(_avatarBucket).remove([path]);
    } catch (_) {
      // Object may not exist.
    }
    await _client.from('profiles').update({'avatar_url': null}).eq('id', authUser.id);
    return loadSessionUser(authUser.id);
  }

  static AppRole? _mobileRoleFromSupabase(String? role) {
    return switch (role) {
      'unit_head' => AppRole.unitHead,
      'manager' => AppRole.manager,
      'director' => AppRole.director,
      'state_coordinator' => AppRole.stateCoordinator,
      _ => null,
    };
  }

  static String _supabaseRole(AppRole role) {
    return switch (role) {
      AppRole.unitHead => 'unit_head',
      AppRole.manager => 'manager',
      AppRole.director => 'director',
      AppRole.stateCoordinator => 'state_coordinator',
    };
  }
}
