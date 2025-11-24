import 'package:flutter_test/flutter_test.dart';
import 'package:portefeuille/core/data/models/asset_metadata.dart';
import 'package:portefeuille/core/data/models/portfolio.dart';
import 'package:portefeuille/core/data/models/sync_status.dart';
import 'package:portefeuille/core/data/repositories/portfolio_repository.dart';
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:portefeuille/core/data/models/institution.dart';
import 'package:portefeuille/core/data/models/account.dart';
import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:portefeuille/core/data/models/account_type.dart';
import 'package:portefeuille/core/data/abstractions/i_settings.dart';

class MockSettings implements ISettings {
  @override
  String get baseCurrency => 'EUR';
  @override
  List<String> get serviceOrder => ['Yahoo'];
  @override
  bool get hasFmpApiKey => false;
  @override
  String? get fmpApiKey => null;
  @override
  int get appColorValue => 0xFF000000;
}

class MockPortfolioRepository extends Fake implements PortfolioRepository {
  final Map<String, AssetMetadata> _metadata = {};

  @override
  AssetMetadata getOrCreateAssetMetadata(String ticker) {
    if (!_metadata.containsKey(ticker)) {
      _metadata[ticker] = AssetMetadata(ticker: ticker);
    }
    return _metadata[ticker]!;
  }

  @override
  Future<void> saveAssetMetadata(AssetMetadata metadata) async {
    _metadata[metadata.ticker] = metadata;
  }
  
  @override
  Future<void> addSyncLog(dynamic log) async {}
}

class MockApiService extends ApiService {
  final Map<String, PriceResult> _results = {};

  MockApiService() : super(settings: MockSettings());

  void setPrice(String ticker, double price, {String currency = 'EUR'}) {
    _results[ticker] = PriceResult(
      price: price,
      currency: currency,
      source: ApiSource.Yahoo,
      ticker: ticker,
    );
  }

  @override
  Future<PriceResult> getPrice(String ticker) async {
    return _results[ticker] ?? PriceResult.failure(ticker);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPortfolioRepository repository;
  late MockApiService apiService;
  late SyncService syncService;

  setUp(() {
    repository = MockPortfolioRepository();
    apiService = MockApiService();
    syncService = SyncService(
      repository: repository,
      apiService: apiService,
      uuid: const Uuid(),
    );
  });

  test('SyncService detects price spike and sets pendingValidation', () async {
    // Arrange
    const ticker = 'AAPL';
    final metadata = repository.getOrCreateAssetMetadata(ticker);
    metadata.updatePrice(100.0, 'USD'); // Initial price
    await repository.saveAssetMetadata(metadata);

    // Mock API returning a huge spike (200.0 is > 100.0 * 1.5)
    apiService.setPrice(ticker, 200.0, currency: 'USD');

    // Create a dummy portfolio with this asset via a transaction
    final portfolio = Portfolio(
      id: '1',
      name: 'Test',
      institutions: [
        Institution(id: '1', name: 'Inst', accounts: [
          Account(id: '1', name: 'Acc', type: AccountType.cto, transactions: [
            Transaction(
              id: '1',
              accountId: '1',
              date: DateTime.now(),
              type: TransactionType.Buy,
              assetTicker: ticker,
              assetName: 'Apple',
              quantity: 1,
              price: 100,
              fees: 0,
              amount: 100,
              notes: '',
            )
          ])
        ])
      ],
    );

    // Act
    await syncService.synchronize(portfolio);

    // Assert
    final updatedMetadata = repository.getOrCreateAssetMetadata(ticker);
    expect(updatedMetadata.syncStatus, equals(SyncStatus.pendingValidation));
    expect(updatedMetadata.pendingPrice, equals(200.0));
    expect(updatedMetadata.currentPrice, equals(100.0)); // Price should NOT change
  });

  test('SyncService updates price normally if change is small', () async {
    // Arrange
    const ticker = 'AAPL';
    final metadata = repository.getOrCreateAssetMetadata(ticker);
    metadata.updatePrice(100.0, 'USD');
    await repository.saveAssetMetadata(metadata);

    // Mock API returning a small increase (120.0 is < 100.0 * 1.5)
    apiService.setPrice(ticker, 120.0, currency: 'USD');

    final portfolio = Portfolio(
      id: '1',
      name: 'Test',
      institutions: [
        Institution(id: '1', name: 'Inst', accounts: [
          Account(id: '1', name: 'Acc', type: AccountType.cto, transactions: [
            Transaction(
              id: '1',
              accountId: '1',
              date: DateTime.now(),
              type: TransactionType.Buy,
              assetTicker: ticker,
              assetName: 'Apple',
              quantity: 1,
              price: 100,
              fees: 0,
              amount: 100,
              notes: '',
            )
          ])
        ])
      ],
    );

    // Act
    await syncService.synchronize(portfolio);

    // Assert
    final updatedMetadata = repository.getOrCreateAssetMetadata(ticker);
    expect(updatedMetadata.syncStatus, equals(SyncStatus.synced));
    expect(updatedMetadata.currentPrice, equals(120.0));
    expect(updatedMetadata.pendingPrice, isNull);
  });
}
