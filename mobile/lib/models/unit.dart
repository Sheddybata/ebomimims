/// A unit under a directorate; managers may oversee multiple units.
class Unit {
  const Unit({
    required this.id,
    required this.name,
    required this.directorateId,
  });

  final String id;
  final String name;
  final String directorateId;
}
