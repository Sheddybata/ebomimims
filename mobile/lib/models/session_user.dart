import 'app_role.dart';

/// Logged-in user for mock auth (replace with Firebase later).
class SessionUser {
  const SessionUser({
    required this.id,
    required this.displayName,
    required this.role,
    this.directorateId,
    this.directorateName,
    this.stateId,
    this.stateName,
    this.unitIds = const [],
    this.primaryUnitId,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final AppRole role;
  
  final String? directorateId;
  final String? directorateName;
  
  final String? stateId;
  final String? stateName;

  /// Managers: multiple units. Unit heads: typically one active unit.
  final List<String> unitIds;
  final String? primaryUnitId;

  /// From onboarding; optional for older saved sessions.
  final String? phone;
  final String? email;

  /// Public URL from Supabase Storage (`avatars` bucket); shown on Profile only.
  final String? avatarUrl;

  bool get isUnitHead => role == AppRole.unitHead;
  bool get isManager => role == AppRole.manager;
  bool get isDirector => role == AppRole.director;
  bool get isStateCoordinator => role == AppRole.stateCoordinator;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'role': role.name,
        if (directorateId != null) 'directorateId': directorateId,
        if (directorateName != null) 'directorateName': directorateName,
        if (stateId != null) 'stateId': stateId,
        if (stateName != null) 'stateName': stateName,
        'unitIds': unitIds,
        'primaryUnitId': primaryUnitId,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
        id: j['id'] as String,
        displayName: j['displayName'] as String,
        role: AppRole.values.byName(j['role'] as String),
        directorateId: j['directorateId'] as String?,
        directorateName: j['directorateName'] as String?,
        stateId: j['stateId'] as String?,
        stateName: j['stateName'] as String?,
        unitIds: (j['unitIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        primaryUnitId: j['primaryUnitId'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );
}