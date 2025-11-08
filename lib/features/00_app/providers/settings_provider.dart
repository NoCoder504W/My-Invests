// lib/features/00_app/providers/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // NOUVEL IMPORT
import 'package:portefeuille/core/utils/constants.dart'; // NOUVEL IMPORT

enum UserLevel { novice, expert }

class SettingsProvider extends ChangeNotifier {
  // Clés pour la persistance Hive
  static const String _kIsOnlineMode = 'isOnlineMode';
  static const String _kUserLevel = 'userLevel';
  static const String _kAppColor = 'appColor';

  // Valeurs par défaut
  static const bool _defaultOnlineMode = false;
  static const int _defaultUserLevelIndex = 0; // UserLevel.novice
  static const int _defaultAppColorValue = 0xFF00bcd4; // Cyan par défaut

  late final Box _settingsBox;

  // Variables d'état local
  bool _isOnlineMode = _defaultOnlineMode;
  UserLevel _userLevel = UserLevel.values[_defaultUserLevelIndex];
  Color _appColor = const Color(_defaultAppColorValue);

  // Getters publics
  bool get isOnlineMode => _isOnlineMode;
  UserLevel get userLevel => _userLevel;
  Color get appColor => _appColor;

  SettingsProvider() {
    // 1. Initialiser la boîte
    _settingsBox = Hive.box(AppConstants.kSettingsBoxName);
    // 2. Charger les paramètres persistés
    _loadSettings();
  }

  /// Charge les paramètres depuis la Hive Box.
  void _loadSettings() {
    // Charger le mode en ligne
    _isOnlineMode = _settingsBox.get(
      _kIsOnlineMode,
      defaultValue: _defaultOnlineMode,
    );

    // Charger le niveau utilisateur (stocké comme un index 'int')
    final userLevelIndex = _settingsBox.get(
      _kUserLevel,
      defaultValue: _defaultUserLevelIndex,
    );

    // --- CORRECTION ---
    // 'elementAtOrElse' n'existe pas. On vérifie les limites de l'index.
    final allLevels = UserLevel.values;
    if (userLevelIndex >= 0 && userLevelIndex < allLevels.length) {
      _userLevel = allLevels[userLevelIndex];
    } else {
      _userLevel = allLevels[_defaultUserLevelIndex];
    }
    // --- FIN CORRECTION ---

    // Charger la couleur (stockée comme une valeur 'int')
    final appColorValue = _settingsBox.get(
      _kAppColor,
      defaultValue: _defaultAppColorValue,
    );
    _appColor = Color(appColorValue);

    // Pas de notifyListeners() nécessaire lors de l'initialisation.
  }

  void toggleOnlineMode(bool value) {
    _isOnlineMode = value;
    _settingsBox.put(_kIsOnlineMode, value); // SAUVEGARDE
    notifyListeners();
  }

  void setUserLevel(UserLevel level) {
    _userLevel = level;
    _settingsBox.put(_kUserLevel, level.index); // SAUVEGARDE
    notifyListeners();
  }

  void setAppColor(Color color) {
    _appColor = color;
    _settingsBox.put(_kAppColor, color.value); // SAUVEGARDE
    notifyListeners();
  }
}