import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/responsibilities_catalog.dart';
import '../data/seed_units.dart';
import '../models/app_role.dart';
import '../models/directorate_responsibilities.dart';
import '../models/session_user.dart';
import 'auth_provider.dart';

final responsibilitiesForSessionProvider =
    Provider<DirectorateResponsibilities?>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return null;
  return kResponsibilitiesCatalog[user.directorateId];
});

final responsibilityViewProvider = Provider<ResponsibilityView?>((ref) {
  final user = ref.watch(authProvider);
  final data = ref.watch(responsibilitiesForSessionProvider);
  if (user == null) return null;
  return buildResponsibilityView(user, data);
});

/// Role-specific bullets + verses for the signed-in user.
class ResponsibilityView {
  const ResponsibilityView({
    required this.spiritualFoundation,
    required this.roleTitle,
    required this.items,
    this.unitLabel,
  });

  final List<String> spiritualFoundation;
  final String roleTitle;
  final List<String> items;
  final String? unitLabel;
}

ResponsibilityView? buildResponsibilityView(
  SessionUser user,
  DirectorateResponsibilities? data,
) {
  if (user.role == AppRole.stateCoordinator) {
    return ResponsibilityView(
      spiritualFoundation: const ['"Go ye into all the world..." (Mark 16:15)'],
      roleTitle: 'State Coordinator',
      unitLabel: user.stateName ?? 'State',
      items: const [
        'Coordinate state-wide ministry activities and programs.',
        'Submit regular attendance, offering, and testimonies directly to Administration.',
      ],
    );
  }
  if (data == null) return null;
  switch (user.role) {
    case AppRole.director:
      return ResponsibilityView(
        spiritualFoundation: data.spiritualFoundation,
        roleTitle: 'Director',
        items: data.director,
      );
    case AppRole.manager:
      return ResponsibilityView(
        spiritualFoundation: data.spiritualFoundation,
        roleTitle: 'Manager',
        items: data.manager,
      );
    case AppRole.unitHead:
      final uid = user.primaryUnitId;
      if (uid == null) {
        return ResponsibilityView(
          spiritualFoundation: data.spiritualFoundation,
          roleTitle: 'Unit head',
          items: const [
            'Select your unit on the login screen to see unit-specific responsibilities.',
          ],
        );
      }
      String? unitName;
      final dId = user.directorateId;
      if (dId != null) {
        for (final u in unitsForDirectorate(dId)) {
          if (u.id == uid) {
            unitName = u.name;
            break;
          }
        }
      }
      final items = data.unitHeadByUnitId[uid];
      return ResponsibilityView(
        spiritualFoundation: data.spiritualFoundation,
        roleTitle: 'Your unit',
        unitLabel: unitName ?? uid,
        items: items ??
            [
              'Responsibilities for this unit are not yet in the charter file. (Unit id: $uid)',
            ],
      );
    case AppRole.stateCoordinator:
      // handled above
      return null;
  }
}
