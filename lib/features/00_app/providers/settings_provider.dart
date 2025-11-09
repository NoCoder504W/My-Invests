// lib/features/00_app/providers/settings_provider.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:portefeuille/core/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum UserLevel { novice, expert }

class SettingsProvider extends ChangeNotifier {
  // Clés Hive
  static const String _kIsOnlineMode = 'isOnlineMode';
  static const String _kUserLevel = 'userLevel';
  static const String _kAppColor = 'appColor';

  // NOUVELLE CLÉ DE MIGRATION
  static const String _kMigrationV1Done = 'migration_v1_done';

  // Clé sécurisée
  static const String _kFmpApiKey = 'fmpApiKey';

  // Valeurs par défaut
  static const bool _defaultOnlineMode = false;
  static const int _defaultUserLevelIndex = 0;
  static const int _defaultAppColorValue = 0xFF00bcd4;

  late final Box _settingsBox;
  late final FlutterSecureStorage _secureStorage;

  // Variables d'état
  bool _isOnlineMode = _defaultOnlineMode;
  UserLevel _userLevel = UserLevel.values[_defaultUserLevelIndex];
  Color _appColor = const Color(_defaultAppColorValue);
  String? _fmpApiKey;

  // NOUVEAU
  bool _migrationV1Done = false;

  // Getters publics
  bool get isOnlineMode => _isOnlineMode;
  UserLevel get userLevel => _userLevel;
  Color get appColor => _appColor;
  String? get fmpApiKey => _fmpApiKey;
  bool get hasFmpApiKey => _fmpApiKey != null && _fmpApiKey!.isNotEmpty;

  // NOUVEAU
  bool get migrationV1Done => _migrationV1Done;

  SettingsProvider() {
    _settingsBox = Hive.box(AppConstants.kSettingsBoxName);
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    _loadSyncSettings();
    _loadAsyncSettings();
  }

  /// Charge les paramètres synchrones depuis Hive.
  void _loadSyncSettings() {
    _isOnlineMode = _settingsBox.get(
      _kIsOnlineMode,
      defaultValue: _defaultOnlineMode,
    );
    final userLevelIndex = _settingsBox.get(
      _kUserLevel,
      defaultValue: _defaultUserLevelIndex,
    );
    final allLevels = UserLevel.values;
    if (userLevelIndex >= 0 && userLevelIndex < allLevels.length) {
      _userLevel = allLevels[userLevelIndex];
    } else {
      _userLevel = allLevels[_defaultUserLevelIndex];
    }
    final appColorValue = _settingsBox.get(
      _kAppColor,
      defaultValue: _defaultAppColorValue,
    );
    _appColor = Color(appColorValue);

    // NOUVEAU : Charger le drapeau de migration
    _migrationV1Done = _settingsBox.get(_kMigrationV1Done, defaultValue: false);
  }

  /// Charge les paramètres asynchrones (clé API).
  Future<void> _loadAsyncSettings() async {
    _fmpApiKey = await _secureStorage.read(key: _kFmpApiKey);
    notifyListeners();
  }

  // NOUVEAU : Méthode pour définir le drapeau de migration
  Future<void> setMigrationV1Done() async {
    _migrationV1Done = true;
    await _settingsBox.put(_kMigrationV1Done, true);
    // Pas besoin de notifyListeners() si appelé depuis le PortfolioProvider
  }

  void toggleOnlineMode(bool value) {
    _isOnlineMode = value;
    _settingsBox.put(_kIsOnlineMode, value);
    notifyListeners();
  }

  void setUserLevel(UserLevel level) {
    _userLevel = level;
    _settingsBox.put(_kUserLevel, level.index);
    notifyListeners();
  }

  void setAppColor(Color color) {
    _appColor = color;
    _settingsBox.put(_kAppColor, color.value);
    notifyListeners();
  }

  Future<void> setFmpApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      _fmpApiKey = null;
      await _secureStorage.delete(key: _kFmpApiKey);
    } else {
      _fmpApiKey = key;
      await _secureStorage.write(key: _kFmpApiKey, value: key);
    }
    notifyListeners();
  }
}