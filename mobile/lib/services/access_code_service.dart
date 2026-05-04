import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads per-person codes from [assets/config/access_codes.json].
///
/// Replace or extend this with Fire store / API when your backend is ready.
/// JSON format: `[{ "code": "ABC-123", "label": "optional note" }]`
abstract final class AccessCodeService {
  static List<_CodeEntry>? _cache;

  static Future<AccessCodeResult> validate(String raw) async {
    final trimmed = raw.trim().toUpperCase();
    if (trimmed.isEmpty) {
      return AccessCodeResult.invalid('Enter your access code.');
    }

    final entries = await _loadEntries();
    for (final e in entries) {
      if (e.normalizedCode == trimmed) {
        return AccessCodeResult.ok(e.label);
      }
    }
    return AccessCodeResult.invalid('This code is not recognized.');
  }

  static Future<List<_CodeEntry>> _loadEntries() async {
    if (_cache != null) return _cache!;
    try {
      final str = await rootBundle.loadString('assets/config/access_codes.json');
      final list = jsonDecode(str) as List<dynamic>;
      _cache = list
          .map((e) => _CodeEntry.fromJson(e as Map<String, dynamic>))
          .where((e) => e.normalizedCode.isNotEmpty)
          .toList();
    } catch (_) {
      _cache = [];
    }
    return _cache!;
  }
}

class AccessCodeResult {
  const AccessCodeResult._({required this.ok, this.message, this.label});

  factory AccessCodeResult.ok(String? label) =>
      AccessCodeResult._(ok: true, label: label);

  factory AccessCodeResult.invalid(String message) =>
      AccessCodeResult._(ok: false, message: message);

  final bool ok;
  final String? message;
  final String? label;
}

class _CodeEntry {
  _CodeEntry({required this.normalizedCode, this.label});

  factory _CodeEntry.fromJson(Map<String, dynamic> j) {
    final code = (j['code'] as String?)?.trim().toUpperCase() ?? '';
    final label = j['label'] as String?;
    return _CodeEntry(normalizedCode: code, label: label);
  }

  final String normalizedCode;
  final String? label;
}
