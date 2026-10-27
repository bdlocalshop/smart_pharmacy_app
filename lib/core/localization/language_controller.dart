import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_strings.dart';

const _kLanguageStorageKey = 'app_language_preference';

/// Notifier that manages active language and persists selection in secure storage.
class LanguageNotifier extends Notifier<AppLanguage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  AppLanguage build() {
    _loadSavedLanguage();
    return AppLanguage.en;
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final saved = await _storage.read(key: _kLanguageStorageKey);
      if (saved == AppLanguage.bn.code) {
        state = AppLanguage.bn;
      } else if (saved == AppLanguage.en.code) {
        state = AppLanguage.en;
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    state = language;
    try {
      await _storage.write(key: _kLanguageStorageKey, value: language.code);
    } catch (_) {
      // Non-fatal
    }
  }

  Future<void> toggleLanguage() async {
    final next = state == AppLanguage.en ? AppLanguage.bn : AppLanguage.en;
    await setLanguage(next);
  }
}

/// Provider for language notifier
final appLanguageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

/// Provider for reactive AppStrings dictionary
final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});

