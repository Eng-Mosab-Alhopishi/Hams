import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

enum AppStyle { glass, neumorph }

class SettingsState {
  final int webpQuality;
  final int maxDimension;
  final ThemeMode themeMode;
  final Locale locale;
  final AppStyle appStyle;

  const SettingsState({
    required this.webpQuality,
    required this.maxDimension,
    required this.themeMode,
    required this.locale,
    required this.appStyle,
  });

  SettingsState copyWith({
    int? webpQuality,
    int? maxDimension,
    ThemeMode? themeMode,
    Locale? locale,
    AppStyle? appStyle,
  }) {
    return SettingsState(
      webpQuality: webpQuality ?? this.webpQuality,
      maxDimension: maxDimension ?? this.maxDimension,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      appStyle: appStyle ?? this.appStyle,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(SettingsState(
          webpQuality: _prefs.getInt('webpQuality') ?? AppConstants.webpQuality,
          maxDimension: _prefs.getInt('maxDimension') ?? AppConstants.maxImageDimension,
          themeMode: ThemeMode.values[_prefs.getInt('themeMode') ?? 0],
          locale: Locale(_prefs.getString('languageCode') ?? 'en'),
          appStyle: AppStyle.values[_prefs.getInt('appStyle') ?? 0],
        ));

  void updateQuality(int quality) {
    state = state.copyWith(webpQuality: quality);
    _prefs.setInt('webpQuality', quality);
  }

  void updateMaxDimension(int dim) {
    state = state.copyWith(maxDimension: dim);
    _prefs.setInt('maxDimension', dim);
  }

  void updateThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt('themeMode', mode.index);
  }

  void updateLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    _prefs.setString('languageCode', locale.languageCode);
  }

  void updateAppStyle(AppStyle style) {
    state = state.copyWith(appStyle: style);
    _prefs.setInt('appStyle', style.index);
  }

  void reset() {
    state = const SettingsState(
      webpQuality: AppConstants.webpQuality,
      maxDimension: AppConstants.maxImageDimension,
      themeMode: ThemeMode.system,
      locale: Locale('en'),
      appStyle: AppStyle.glass,
    );
    _prefs.clear();
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
