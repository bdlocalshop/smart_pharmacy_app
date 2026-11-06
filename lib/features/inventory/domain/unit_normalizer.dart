import 'dart:math' as math;

/// Utility for pharmacy dispensing unit type auto-normalization,
/// abbreviation expansion, alias resolution, and fuzzy typo matching.
class UnitNormalizer {
  /// Default fallback unit when raw input is absent, empty, or unresolvable.
  static const String defaultUnit = 'Unknown';

  /// Standard canonical pharmacy unit types.
  static const List<String> canonicalUnits = [
    'Unknown',
    'Tablet',
    'Capsule',
    'Strip',
    'Syrup',
    'Suspension',
    'Box',
    'Vial',
    'Ampoule',
    'Ointment',
    'Oral Gel',
    'Suppository',
    'Drop',
    'Eye Drop',
    'Ear Drop',
    'Injection',
    'Inhaler',
    'Cream',
    'Powder',
    'Sachet',
    'Bottle',
    'Piece',
    'Solution',
    'Lotion',
    'Spray',
    'Respule',
    'Gel',
    'Patch',
    'Cartridge',
    'Infusion',
  ];

  /// Comprehensive dictionary of abbreviations, shorthand, and aliases.
  static const Map<String, String> _abbreviationMap = {
    // Unknown / Empty
    '': 'Unknown',
    'unknown': 'Unknown',
    'unk': 'Unknown',
    'u/k': 'Unknown',
    'n/a': 'Unknown',
    'na': 'Unknown',
    'none': 'Unknown',
    'null': 'Unknown',
    '-': 'Unknown',
    '--': 'Unknown',
    '?': 'Unknown',
    'not available': 'Unknown',

    // Tablets
    'tab': 'Tablet',
    'tabs': 'Tablet',
    'tablet': 'Tablet',
    'tablets': 'Tablet',
    'tab.': 'Tablet',
    'tbl': 'Tablet',
    'tbl.': 'Tablet',
    'caplet': 'Tablet',
    'caplets': 'Tablet',
    'chewable': 'Tablet',
    'chewable tablet': 'Tablet',
    'effervescent tablet': 'Tablet',

    // Capsules
    'cap': 'Capsule',
    'caps': 'Capsule',
    'capsule': 'Capsule',
    'capsules': 'Capsule',
    'cap.': 'Capsule',
    'softgel': 'Capsule',
    'softgels': 'Capsule',
    'soft gel': 'Capsule',

    // Syrups & Suspensions
    'syr': 'Syrup',
    'syrup': 'Syrup',
    'syrups': 'Syrup',
    'syr.': 'Syrup',
    'susp': 'Suspension',
    'suspension': 'Suspension',
    'suspensions': 'Suspension',
    'susp.': 'Suspension',
    'dry syrup': 'Suspension',

    // Strips & Boxes & Packs
    'strip': 'Strip',
    'strips': 'Strip',
    'str': 'Strip',
    'str.': 'Strip',
    'box': 'Box',
    'boxes': 'Box',
    'bx': 'Box',
    'pack': 'Box',
    'packs': 'Box',
    'packet': 'Box',
    'packets': 'Box',
    'pkt': 'Box',

    // Injections, Vials & Ampoules
    'inj': 'Injection',
    'injection': 'Injection',
    'injections': 'Injection',
    'inj.': 'Injection',
    'injectable': 'Injection',
    'vial': 'Vial',
    'vials': 'Vial',
    'vil': 'Vial',
    'amp': 'Ampoule',
    'ampoule': 'Ampoule',
    'ampoules': 'Ampoule',
    'ampul': 'Ampoule',
    'ampuls': 'Ampoule',
    'amp.': 'Ampoule',
    'infusion': 'Infusion',
    'iv': 'Injection',
    'i.v.': 'Injection',

    // Topicals (Ointment, Cream, Gel, Lotion)
    'oint': 'Ointment',
    'ointment': 'Ointment',
    'ointments': 'Ointment',
    'oint.': 'Ointment',
    'crm': 'Cream',
    'cream': 'Cream',
    'creams': 'Cream',
    'crm.': 'Cream',
    'gel': 'Gel',
    'gels': 'Gel',
    'oral gel': 'Oral Gel',
    'oralgel': 'Oral Gel',
    'lotion': 'Lotion',
    'lotions': 'Lotion',
    'paste': 'Ointment',

    // Drops
    'drop': 'Drop',
    'drops': 'Drop',
    'drp': 'Drop',
    'drps': 'Drop',
    'eye drop': 'Eye Drop',
    'eye drops': 'Eye Drop',
    'eyedrop': 'Eye Drop',
    'eyedrops': 'Eye Drop',
    'ear drop': 'Ear Drop',
    'ear drops': 'Ear Drop',
    'eardrop': 'Ear Drop',
    'eardrops': 'Ear Drop',
    'nasal drop': 'Drop',
    'nasal drops': 'Drop',

    // Inhalers & Sprays & Respules
    'inh': 'Inhaler',
    'inhaler': 'Inhaler',
    'inhalers': 'Inhaler',
    'inhalation': 'Inhaler',
    'spray': 'Spray',
    'sprays': 'Spray',
    'nasal spray': 'Spray',
    'respule': 'Respule',
    'respules': 'Respule',
    'neb': 'Respule',
    'nebulizer': 'Respule',

    // Suppositories & Enemas
    'supp': 'Suppository',
    'suppository': 'Suppository',
    'suppositories': 'Suppository',
    'supp.': 'Suppository',
    'enema': 'Enema',
    'enemas': 'Enema',

    // Solutions & Liquids & Bottles
    'sol': 'Solution',
    'soln': 'Solution',
    'sol.': 'Solution',
    'soln.': 'Solution',
    'solution': 'Solution',
    'solutions': 'Solution',
    'liq': 'Solution',
    'liquid': 'Solution',
    'bottle': 'Bottle',
    'bottles': 'Bottle',
    'btl': 'Bottle',
    'btl.': 'Bottle',

    // Powders & Sachets
    'sachet': 'Sachet',
    'sachets': 'Sachet',
    'sach': 'Sachet',
    'powder': 'Powder',
    'powders': 'Powder',
    'pwd': 'Powder',

    // Pieces / Units / Patches
    'pc': 'Piece',
    'pcs': 'Piece',
    'piece': 'Piece',
    'pieces': 'Piece',
    'unit': 'Piece',
    'units': 'Piece',
    'patch': 'Patch',
    'patches': 'Patch',
    'transdermal patch': 'Patch',
    'cartridge': 'Cartridge',
    'cartridges': 'Cartridge',
  };

  /// Normalizes any raw unit type string into a canonical, cleanly formatted unit name.
  ///
  /// Steps:
  /// 1. Cleans input (trims whitespace and common punctuation).
  /// 2. Checks [knownUnits] for exact case-insensitive match.
  /// 3. Looks up in built-in [_abbreviationMap].
  /// 4. Attempts singularization (removing trailing 's' or 'es') and looks up in aliases/known units.
  /// 5. Performs fuzzy typo matching (Levenshtein distance <= 1 or similarity >= 0.82)
  ///    against canonical and known units.
  /// 6. Falls back to a clean Title Case format for custom/unrecognized unit types.
  static String normalize(String? rawUnit, {Iterable<String>? knownUnits}) {
    if (rawUnit == null) return defaultUnit;

    final cleaned = _cleanInput(rawUnit);
    if (cleaned.isEmpty) return defaultUnit;

    final lower = cleaned.toLowerCase();

    // 1. Direct dictionary match
    if (_abbreviationMap.containsKey(lower)) {
      return _abbreviationMap[lower]!;
    }

    // 2. Exact case-insensitive match against known units (preserves existing DB casing)
    if (knownUnits != null) {
      for (final ku in knownUnits) {
        if (ku.trim().toLowerCase() == lower) {
          return ku.trim();
        }
      }
    }

    // 3. Exact case-insensitive match against canonical units
    for (final cu in canonicalUnits) {
      if (cu.toLowerCase() == lower) {
        return cu;
      }
    }

    // 4. Singularization check: strip trailing 's' or 'es'
    if (lower.length > 3) {
      String? singular;
      if (lower.endsWith('es') && lower.length > 4) {
        singular = lower.substring(0, lower.length - 2);
      } else if (lower.endsWith('s')) {
        singular = lower.substring(0, lower.length - 1);
      }

      if (singular != null) {
        if (_abbreviationMap.containsKey(singular)) {
          return _abbreviationMap[singular]!;
        }
        for (final cu in canonicalUnits) {
          if (cu.toLowerCase() == singular) {
            return cu;
          }
        }
        if (knownUnits != null) {
          for (final ku in knownUnits) {
            if (ku.trim().toLowerCase() == singular) {
              return ku.trim();
            }
          }
        }
      }
    }

    // 5. Fuzzy match against all canonical + known units
    final candidateUnits = <String>{
      ...canonicalUnits.where((u) => u != defaultUnit),
      if (knownUnits != null) ...knownUnits.where((u) => u.trim().isNotEmpty && u != defaultUnit),
    };

    String? bestFuzzyMatch;
    double highestScore = 0.0;

    for (final candidate in candidateUnits) {
      final candLower = candidate.toLowerCase();
      final dist = damerauLevenshteinDistance(lower, candLower);
      final maxLen = math.max(lower.length, candLower.length);
      final similarity = 1.0 - (dist / maxLen);

      // Typos allow 1 edit distance for words >= 4 chars, or 2 edits for words >= 6 chars
      final allowableDist = candLower.length >= 6 ? 2 : 1;
      if (dist <= allowableDist && similarity >= 0.70) {
        if (similarity > highestScore) {
          highestScore = similarity;
          bestFuzzyMatch = candidate;
        }
      }
    }

    if (bestFuzzyMatch != null) {
      return bestFuzzyMatch;
    }

    // 6. Clean Title Case fallback for custom units (e.g. "sublingual wafer" -> "Sublingual Wafer")
    return _toTitleCase(cleaned);
  }

  /// Calculates the Damerau-Levenshtein edit distance (insert, delete, substitute, transpose)
  /// between two strings.
  static int damerauLevenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final d = List.generate(s.length + 1, (_) => List<int>.filled(t.length + 1, 0));

    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= s.length; i++) {
      for (int j = 1; j <= t.length; j++) {
        final cost = (s.codeUnitAt(i - 1) == t.codeUnitAt(j - 1)) ? 0 : 1;
        d[i][j] = math.min(
          d[i - 1][j] + 1,
          math.min(
            d[i][j - 1] + 1,
            d[i - 1][j - 1] + cost,
          ),
        );
        if (i > 1 &&
            j > 1 &&
            s.codeUnitAt(i - 1) == t.codeUnitAt(j - 2) &&
            s.codeUnitAt(i - 2) == t.codeUnitAt(j - 1)) {
          d[i][j] = math.min(d[i][j], d[i - 2][j - 2] + 1);
        }
      }
    }
    return d[s.length][t.length];
  }

  /// Strips redundant surrounding punctuation and collapses multiple whitespaces.
  static String _cleanInput(String input) {
    var s = input.trim();
    // Remove surrounding quotes or parentheses
    while ((s.startsWith('"') && s.endsWith('"')) ||
        (s.startsWith('\'') && s.endsWith('\'')) ||
        (s.startsWith('(') && s.endsWith(')')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      s = s.substring(1, s.length - 1).trim();
    }
    // Remove trailing dot if not a known abbreviation with dot
    if (s.endsWith('.') && s.length > 2 && !_abbreviationMap.containsKey(s.toLowerCase())) {
      s = s.substring(0, s.length - 1).trim();
    }
    // Collapse multiple internal spaces
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a string into Title Case while preserving uppercase acronyms (e.g. PFS, IV, MDI).
  static String _toTitleCase(String text) {
    final words = text.split(' ');
    final capitalized = words.map((w) {
      if (w.isEmpty) return '';
      // Preserve acronyms that are 2-4 uppercase characters
      if (w.length >= 2 && w.length <= 4 && w == w.toUpperCase()) {
        return w;
      }
      if (w.length == 1) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    });
    return capitalized.join(' ');
  }
}
