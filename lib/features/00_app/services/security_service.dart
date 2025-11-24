import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _kSecurityEnabledKey = 'security_enabled';
  static const String _kPinCodeKey = 'pin_code';
  static const String _kHasProposedSecurityKey = 'has_proposed_security';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  SecurityService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication(),
        _prefs = prefs;

  /// Vérifie si la sécurité est activée
  bool get isSecurityEnabled => _prefs.getBool(_kSecurityEnabledKey) ?? false;

  /// Active ou désactive la sécurité
  Future<void> setSecurityEnabled(bool enabled) async {
    await _prefs.setBool(_kSecurityEnabledKey, enabled);
  }

  /// Vérifie si le matériel supporte la biométrie
  Future<bool> get canCheckBiometrics async {
    try {
      return await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Authentifie l'utilisateur via biométrie
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à l\'application',
        // options: const AuthenticationOptions(
        //   stickyAuth: true,
        //   biometricOnly: false,
        // ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Définit un code PIN (stocké de manière sécurisée)
  Future<void> setPinCode(String pin) async {
    await _secureStorage.write(key: _kPinCodeKey, value: pin);
  }

  /// Vérifie le code PIN
  Future<bool> verifyPinCode(String pin) async {
    final storedPin = await _secureStorage.read(key: _kPinCodeKey);
    return storedPin == pin;
  }

  /// Vérifie si un code PIN est configuré
  Future<bool> hasPinCode() async {
    final pin = await _secureStorage.read(key: _kPinCodeKey);
    return pin != null && pin.isNotEmpty;
  }
  
  /// Supprime le code PIN
  Future<void> removePinCode() async {
    await _secureStorage.delete(key: _kPinCodeKey);
  }

  /// Vérifie si on a déjà proposé la sécurité
  bool get hasProposedSecurity => _prefs.getBool(_kHasProposedSecurityKey) ?? false;

  /// Marque que la sécurité a été proposée
  Future<void> setHasProposedSecurity() async {
    await _prefs.setBool(_kHasProposedSecurityKey, true);
  }
}
