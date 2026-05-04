class Directorate {
  const Directorate({
    required this.id,
    required this.name,
    required this.groupLabel,
    this.isAdministrationHub = false,
  });

  final String id;
  final String name;
  final String groupLabel;
  final bool isAdministrationHub;
}
