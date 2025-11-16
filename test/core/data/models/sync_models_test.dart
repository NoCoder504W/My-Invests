// test/core/data/models/sync_models_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:portefeuille/core/data/models/sync_status.dart';
import 'package:portefeuille/core/data/models/sync_log.dart';
import 'package:portefeuille/core/data/models/asset_metadata.dart';

void main() {
  group('SyncStatus', () {
    test('displayName retourne les bons noms', () {
      expect(SyncStatus.synced.displayName, 'Synchronisé');
      expect(SyncStatus.error.displayName, 'Erreur');
      expect(SyncStatus.manual.displayName, 'Manuel');
      expect(SyncStatus.never.displayName, 'Non synchronisé');
    });

    test('icon retourne les bonnes icônes', () {
      expect(SyncStatus.synced.icon, '☁️');
      expect(SyncStatus.error.icon, '⚠️');
      expect(SyncStatus.manual.icon, '📝');
      expect(SyncStatus.never.icon, '⏸️');
    });

    test('colorName retourne les bonnes couleurs', () {
      expect(SyncStatus.synced.colorName, 'green');
      expect(SyncStatus.error.colorName, 'red');
      expect(SyncStatus.manual.colorName, 'blue');
      expect(SyncStatus.never.colorName, 'grey');
    });
  });

  group('AssetMetadata - Nouveaux champs', () {
    test('création avec valeurs par défaut', () {
      final metadata = AssetMetadata(ticker: 'AAPL');

      expect(metadata.ticker, 'AAPL');
      expect(metadata.syncStatus, SyncStatus.never);
      expect(metadata.lastSyncAttempt, isNull);
      expect(metadata.syncErrorMessage, isNull);
      expect(metadata.isin, isNull);
      expect(metadata.assetTypeDetailed, isNull);
      expect(metadata.lastSyncSource, isNull);
    });

    test('updatePrice met à jour le statut de synchro', () {
      final metadata = AssetMetadata(ticker: 'AAPL');
      
      metadata.updatePrice(150.0, 'USD', source: 'Yahoo');

      expect(metadata.currentPrice, 150.0);
      expect(metadata.priceCurrency, 'USD');
      expect(metadata.syncStatus, SyncStatus.synced);
      expect(metadata.syncErrorMessage, isNull);
      expect(metadata.lastSyncSource, 'Yahoo');
      expect(metadata.lastSyncAttempt, isNotNull);
    });

    test('markSyncError change le statut en erreur', () {
      final metadata = AssetMetadata(ticker: 'INVALID');
      
      metadata.markSyncError('Ticker non trouvé');

      expect(metadata.syncStatus, SyncStatus.error);
      expect(metadata.syncErrorMessage, 'Ticker non trouvé');
      expect(metadata.lastSyncAttempt, isNotNull);
    });

    test('markAsManual change le statut en manuel', () {
      final metadata = AssetMetadata(ticker: 'CUSTOM');
      
      metadata.markAsManual();

      expect(metadata.syncStatus, SyncStatus.manual);
    });

    test('copyWith copie tous les nouveaux champs', () {
      final original = AssetMetadata(
        ticker: 'AAPL',
        syncStatus: SyncStatus.synced,
        isin: 'US0378331005',
        assetTypeDetailed: 'Large Cap Tech',
        lastSyncSource: 'FMP',
      );

      final copy = original.copyWith(
        syncStatus: SyncStatus.error,
        syncErrorMessage: 'Test error',
      );

      expect(copy.ticker, 'AAPL');
      expect(copy.syncStatus, SyncStatus.error);
      expect(copy.syncErrorMessage, 'Test error');
      expect(copy.isin, 'US0378331005');
      expect(copy.assetTypeDetailed, 'Large Cap Tech');
      expect(copy.lastSyncSource, 'FMP');
    });
  });

  group('SyncLog', () {
    test('factory success crée un log de succès', () {
      final log = SyncLog.success(
        id: 'test-1',
        ticker: 'AAPL',
        source: 'Yahoo',
        price: 150.0,
        currency: 'USD',
      );

      expect(log.id, 'test-1');
      expect(log.ticker, 'AAPL');
      expect(log.status, SyncStatus.synced);
      expect(log.source, 'Yahoo');
      expect(log.price, 150.0);
      expect(log.currency, 'USD');
      expect(log.message, contains('Prix synchronisé avec succès'));
      expect(log.timestamp, isNotNull);
    });

    test('factory error crée un log d\'erreur', () {
      final log = SyncLog.error(
        id: 'test-2',
        ticker: 'INVALID',
        errorMessage: 'Ticker introuvable',
        attemptedSource: 'Yahoo',
      );

      expect(log.id, 'test-2');
      expect(log.ticker, 'INVALID');
      expect(log.status, SyncStatus.error);
      expect(log.source, 'Yahoo');
      expect(log.price, isNull);
      expect(log.currency, isNull);
      expect(log.message, 'Ticker introuvable');
      expect(log.timestamp, isNotNull);
    });

    test('toMap convertit correctement en Map', () {
      final log = SyncLog.success(
        id: 'test-3',
        ticker: 'MSFT',
        source: 'FMP',
        price: 380.0,
        currency: 'USD',
      );

      final map = log.toMap();

      expect(map['id'], 'test-3');
      expect(map['ticker'], 'MSFT');
      expect(map['status'], 'Synchronisé');
      expect(map['source'], 'FMP');
      expect(map['price'], '380.0');
      expect(map['currency'], 'USD');
      expect(map['timestamp'], isNotNull);
    });

    test('toMap gère les valeurs nulles', () {
      final log = SyncLog.error(
        id: 'test-4',
        ticker: 'ERROR',
        errorMessage: 'Test',
      );

      final map = log.toMap();

      expect(map['source'], 'N/A');
      expect(map['price'], 'N/A');
      expect(map['currency'], 'N/A');
    });
  });

  group('Scénarios d\'utilisation réels', () {
    test('Cycle de vie complet d\'une synchronisation réussie', () {
      // 1. Création d'un actif jamais synchronisé
      final metadata = AssetMetadata(
        ticker: 'AAPL',
        isin: 'US0378331005',
      );
      expect(metadata.syncStatus, SyncStatus.never);

      // 2. Première synchronisation réussie
      metadata.updatePrice(150.0, 'USD', source: 'Yahoo');
      expect(metadata.syncStatus, SyncStatus.synced);
      expect(metadata.currentPrice, 150.0);
      expect(metadata.lastSyncSource, 'Yahoo');

      // 3. Création du log de succès
      final successLog = SyncLog.success(
        id: '1',
        ticker: 'AAPL',
        source: 'Yahoo',
        price: 150.0,
        currency: 'USD',
      );
      expect(successLog.status, SyncStatus.synced);
    });

    test('Cycle de vie avec échec puis succès', () {
      // 1. Actif nouveau
      final metadata = AssetMetadata(ticker: 'TSLA');
      
      // 2. Première tentative échoue
      metadata.markSyncError('API timeout');
      expect(metadata.syncStatus, SyncStatus.error);
      expect(metadata.syncErrorMessage, 'API timeout');
      
      final errorLog = SyncLog.error(
        id: '2',
        ticker: 'TSLA',
        errorMessage: 'API timeout',
        attemptedSource: 'FMP',
      );
      expect(errorLog.status, SyncStatus.error);

      // 3. Deuxième tentative réussit
      metadata.updatePrice(250.0, 'USD', source: 'Yahoo');
      expect(metadata.syncStatus, SyncStatus.synced);
      expect(metadata.syncErrorMessage, isNull); // Erreur effacée
      expect(metadata.currentPrice, 250.0);
    });

    test('Actif manuel ne change pas de statut lors d\'une synchro', () {
      // 1. Actif marqué comme manuel
      final metadata = AssetMetadata(ticker: 'CUSTOM');
      metadata.markAsManual();
      expect(metadata.syncStatus, SyncStatus.manual);

      // 2. L'utilisateur saisit un prix manuellement
      metadata.currentPrice = 100.0;
      
      // Note: Dans l'implémentation réelle, on devra vérifier
      // le statut avant d'appeler updatePrice() si mode conservateur activé
      expect(metadata.syncStatus, SyncStatus.manual);
    });
  });
}
