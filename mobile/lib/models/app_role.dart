/// Field roles supported in the mobile app (Next.js handles executive roles).
enum AppRole {
  unitHead,
  manager,
  director,
  stateCoordinator,
}

extension AppRoleLabel on AppRole {
  String get label => switch (this) {
        AppRole.unitHead => 'Unit Head',
        AppRole.manager => 'Manager',
        AppRole.director => 'Director',
        AppRole.stateCoordinator => 'State Coordinator',
      };
}
