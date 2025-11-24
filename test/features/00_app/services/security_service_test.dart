import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:portefeuille/features/00_app/services/security_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'security_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, LocalAuthentication, SharedPreferences])
void main() {
  late SecurityService securityService;
  late MockFlutterSecureStorage mockStorage;
  late MockLocalAuthentication mockLocalAuth;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLocalAuth = MockLocalAuthentication();
    mockPrefs = MockSharedPreferences();
    
    securityService = SecurityService(
      secureStorage: mockStorage,
      localAuth: mockLocalAuth,
      prefs: mockPrefs,
    );
  });

  test('isSecurityEnabled should return false by default', () {
    when(mockPrefs.getBool('security_enabled')).thenReturn(null);
    expect(securityService.isSecurityEnabled, false);
  });

  test('setSecurityEnabled should save preference', () async {
    when(mockPrefs.setBool('security_enabled', true)).thenAnswer((_) async => true);
    await securityService.setSecurityEnabled(true);
    verify(mockPrefs.setBool('security_enabled', true)).called(1);
  });
}
