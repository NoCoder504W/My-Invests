import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockSettingsProvider extends SettingsProvider {
  @override
  bool get isOnlineMode => true;
  @override
  bool get hasFmpApiKey => false;
  @override
  List<String> get serviceOrder => ['Yahoo'];
  @override
  String get baseCurrency => 'EUR';
}

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) _handler;
  MockHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Convert BaseRequest to Request to access body if needed, but here we just need url
    final http.Request req;
    if (request is http.Request) {
      req = request;
    } else {
      req = http.Request(request.method, request.url);
    }
    
    final response = await _handler(req);
    return http.StreamedResponse(
        Stream.value(utf8.encode(response.body)), response.statusCode,
        headers: response.headers);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  test('getPrice() resolves ISIN to Ticker and returns price mapped to ISIN', () async {
    final mockSettings = MockSettingsProvider();
    
    final mockClient = MockHttpClient((request) async {
      final url = request.url.toString();
      
      // 1. Initial call for ISIN (Yahoo Spark) -> Fails
      if (url.contains('spark') && url.contains('FR0000120271')) {
        return http.Response('Not Found', 404);
      }
      
      // 2. Search call for ISIN
      if (url.contains('search') && url.contains('FR0000120271')) {
        return http.Response(jsonEncode({
          'quotes': [
            {
              'symbol': 'TTE.PA',
              'shortname': 'TotalEnergies',
              'exchDisp': 'Paris',
              'quoteType': 'EQUITY'
            }
          ]
        }), 200);
      }
      
      // 3. Recursive call for Ticker (Yahoo Spark) -> Success
      if (url.contains('spark') && url.contains('TTE.PA')) {
        return http.Response(jsonEncode({
          'spark': {
            'result': [
              {
                'symbol': 'TTE.PA',
                'response': [
                  {
                    'meta': {
                      'regularMarketPrice': 60.5,
                      'currency': 'EUR'
                    }
                  }
                ]
              }
            ]
          }
        }), 200);
      }
      
      return http.Response('Not Found', 404);
    });

    final apiService = ApiService(settings: mockSettings, httpClient: mockClient);

    final result = await apiService.getPrice('FR0000120271');

    expect(result.price, equals(60.5));
    expect(result.currency, equals('EUR'));
    expect(result.ticker, equals('FR0000120271')); // Must match the requested ISIN
    expect(result.source, equals(ApiSource.Yahoo));
  });
}
