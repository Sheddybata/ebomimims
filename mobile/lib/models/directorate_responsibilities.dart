import 'dart:convert';

/// Charter text + verses for a directorate (loaded from assets).
class DirectorateResponsibilities {
  const DirectorateResponsibilities({
    required this.spiritualFoundation,
    required this.director,
    required this.manager,
    required this.unitHeadByUnitId,
  });

  final List<String> spiritualFoundation;
  final List<String> director;
  final List<String> manager;
  final Map<String, List<String>> unitHeadByUnitId;

  factory DirectorateResponsibilities.fromJson(Map<String, dynamic> json) {
    final unitsRaw = json['units'] as Map<String, dynamic>? ?? {};
    return DirectorateResponsibilities(
      spiritualFoundation:
          (json['spiritualFoundation'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      director: (json['director'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      manager: (json['manager'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      unitHeadByUnitId: unitsRaw.map(
        (k, v) => MapEntry(
          k,
          (v as List<dynamic>).map((e) => e.toString()).toList(),
        ),
      ),
    );
  }

  static DirectorateResponsibilities? tryParse(String raw) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return DirectorateResponsibilities.fromJson(j);
    } catch (_) {
      return null;
    }
  }
}
