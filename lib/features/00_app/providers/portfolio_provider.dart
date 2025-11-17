// lib/features/00_app/providers/portfolio_provider.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/account.dart';
import 'package:portefeuille/core/data/models/asset.dart';
// NOUVEAUX IMPORTS
import 'package:portefeuille/core/data/models/aggregated_asset.dart';
import 'package:portefeuille/core/data/models/aggregated_portfolio_data.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
// FIN NOUVEAUX IMPORTS
import 'package:portefeuille/core/data/models/institution.dart';
import 'package:portefeuille/core/data/models/portfolio.dart';
import 'package:portefeuille/core/data/models/projection_data.dart';
import 'package:portefeuille/core/data/models/savings_plan.dart';
import 'package:portefeuille/core/data/models/sync_log.dart';
import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/data/repositories/portfolio_repository.dart';
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:portefeuille/core/data/models/asset_metadata.dart';
// IMPORTS DES SERVICES DE LOGIQUE
import 'portfolio_migration_logic.dart';
import 'portfolio_sync_logic.dart';
import 'portfolio_transaction_logic.dart';
import 'portfolio_hydration_service.dart';
import 'demo_data_service.dart';
// NOUVEL IMPORT SERVICE
import 'package:portefeuille/features/00_app/services/portfolio_calculation_service.dart';
// NOUVEL IMPORT POUR L'ENUM
import 'background_activity.dart';

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _repository;
  final ApiService _apiService;
  SettingsProvider? _settingsProvider;
  bool _isFirstSettingsUpdate = true;
  final _uuid = const Uuid();

  // Classes de logique
  late final PortfolioMigrationLogic _migrationLogic;
  late final PortfolioSyncLogic _syncLogic;
  late final PortfolioTransactionLogic _transactionLogic;
  late final PortfolioHydrationService _hydrationService;
  late final DemoDataService _demoDataService;
  // NOUVEAU SERVICE DE CALCUL
  late final PortfolioCalculationService _calculationService;

  // État du Provider
  List<Portfolio> _portfolios = [];
  Portfolio? _activePortfolio;
  bool _isLoading = true;
  String? _syncMessage;
  // --- NOUVEL ÉTAT ---
  /// Vrai si le provider recalcule les totaux après un changement de devise.
  BackgroundActivity _activity = BackgroundActivity.none;
  // --- FIN NOUVEL ÉTAT ---

  // -----------------------------------------------------------------
  // ▼▼▼ ÉTAT DES VALEURS CALCULÉES (MODIFIÉ) ▼▼▼
  // -----------------------------------------------------------------

  /// Stocke TOUS les résultats des calculs (valeurs converties, agrégats, etc.)
  AggregatedPortfolioData _aggregatedData = AggregatedPortfolioData.empty;
  // -----------------------------------------------------------------
  // ▲▲▲ FIN ÉTAT CALCULÉ ▲▲▲
  // -----------------------------------------------------------------

  // Getters (État brut)
  List<Portfolio> get portfolios => _portfolios;
  Portfolio? get activePortfolio => _activePortfolio;
  bool get isLoading => _isLoading;
  String? get syncMessage => _syncMessage;
  // --- NOUVEAUX GETTERS ---
  /// Retourne l'activité de fond spécifique (pour l'AppBar, etc.)
  BackgroundActivity get activity => _activity;

  /// Getter principal pour l'UI : l'interface doit-elle "shimmer" ?
  bool get isProcessingInBackground => _activity != BackgroundActivity.none;
  // --- FIN NOUVEAUX GETTERS ---

  Map<String, AssetMetadata> get allMetadata =>
      _repository.getAllAssetMetadata();
  // -----------------------------------------------------------------
  // ▼▼▼ GETTERS POUR L'INTERFACE (MODIFIÉ) ▼▼▼
  // -----------------------------------------------------------------
  // Tous ces getters lisent maintenant depuis l'objet _aggregatedData

  /// La devise de base active (ex: "USD")
  String get currentBaseCurrency => _aggregatedData.baseCurrency;
  /// La valeur totale convertie (ex: 10800.0)
  double get activePortfolioTotalValue => _aggregatedData.totalValue;
  /// La P/L totale convertie
  double get activePortfolioTotalPL => _aggregatedData.totalPL;
  /// Le % de P/L (calculé à partir des valeurs converties)
  double get activePortfolioTotalPLPercentage {
    if (_aggregatedData.totalInvested == 0.0) return 0.0;
    return _aggregatedData.totalPL / _aggregatedData.totalInvested;
  }

  /// Le rendement annuel (on garde celui du portfolio, c'est un %)
  double get activePortfolioEstimatedAnnualYield =>
      _activePortfolio?.estimatedAnnualYield ?? 0.0;

  // --- Getters par Compte ---
  double getConvertedAccountValue(String accountId) =>
      _aggregatedData.accountValues[accountId] ?? 0.0;
  double getConvertedAccountPL(String accountId) =>
      _aggregatedData.accountPLs[accountId] ?? 0.0;
  double getConvertedAccountInvested(String accountId) =>
      _aggregatedData.accountInvested[accountId] ?? 0.0;
  // --- Getters par Actif (pour AssetListItem) ---
  double getConvertedAssetTotalValue(String assetId) =>
      _aggregatedData.assetTotalValues[assetId] ?? 0.0;
  double getConvertedAssetPL(String assetId) =>
      _aggregatedData.assetPLs[assetId] ?? 0.0;
  // --- Getters pour les Agrégats ---
  List<AggregatedAsset> get aggregatedAssets => _aggregatedData.aggregatedAssets;
  Map<AssetType, double> get aggregatedValueByAssetType =>
      _aggregatedData.valueByAssetType;
  // -----------------------------------------------------------------
  // ▲▲▲ FIN GETTERS ▲▲▲
  // -----------------------------------------------------------------

  PortfolioProvider({
    required PortfolioRepository repository,
    required ApiService apiService,
  })  : _repository = repository,
        _apiService = apiService {
    // Initialisation des services de logique
    _migrationLogic = PortfolioMigrationLogic(
      repository: _repository,
      settingsProvider: _settingsProvider ?? SettingsProvider(),
      uuid: _uuid,
    );
    _syncLogic = PortfolioSyncLogic(
      repository: _repository,
      apiService: _apiService,
      settingsProvider: _settingsProvider ?? SettingsProvider(),
    );
    _transactionLogic = PortfolioTransactionLogic(
      repository: _repository,
    );
    _hydrationService = PortfolioHydrationService(
      repository: _repository,
      apiService: _apiService,
      settingsProvider: _settingsProvider ?? SettingsProvider(),
    );
    _demoDataService = DemoDataService(
      repository: _repository,
    );
    // NOUVEAU : Initialisation du service de calcul
    _calculationService = PortfolioCalculationService(
      apiService: _apiService,
    );
    loadAllPortfolios();
  }

  // -----------------------------------------------------------------
  // ▼▼▼ MÉTHODE DE CALCUL PRINCIPALE (SUPPRIMÉE) ▼▼▼
  // -----------------------------------------------------------------

  // L'ancienne méthode `_recalculateConvertedTotals` a été
  // DÉPLACÉE vers `PortfolioCalculationService`.
  // -----------------------------------------------------------------
  // ▲▲▲ FIN MÉTHODE DE CALCUL ▲▲▲
  // -----------------------------------------------------------------

  void updateSettings(SettingsProvider settingsProvider) {
    final bool wasOffline = _settingsProvider?.isOnlineMode ?? false;
    final bool wasNull = _settingsProvider == null;
    final bool currencyChanged = (_settingsProvider != null &&
        _settingsProvider!.baseCurrency != settingsProvider.baseCurrency);
    _settingsProvider = settingsProvider;
    _migrationLogic.settingsProvider = settingsProvider;
    _syncLogic.settingsProvider = settingsProvider;
    _hydrationService.settingsProvider = settingsProvider;
    // -----------------------------------------------------------------
    // ▼▼▼ CORRECTION DU BUG LOGIQUE (MODIFIÉ) ▼▼▼
    // -----------------------------------------------------------------
    if (currencyChanged && !_isLoading) {
      debugPrint("Devise de base modifiée. Recalcul des totaux...");
      _activity = BackgroundActivity.recalculating;
      notifyListeners(); // Déclenche les shimmers

      // Appelle la NOUVELLE méthode légère
      _recalculateAggregatedData().catchError((e) {
        debugPrint("❌ Erreur critique lors du recalcul de la devise: $e");
        // En cas d'erreur, il faut impérativement arrêter les shimmers
        // et notifier l'UI pour éviter un état de chargement infini.
        _activity = BackgroundActivity.none;
        notifyListeners();
      });
    }
    // -----------------------------------------------------------------
    // ▲▲▲ FIN CORRECTION ▲▲▲
    // -----------------------------------------------------------------

    if (_isFirstSettingsUpdate) {
      _isFirstSettingsUpdate = false;
      Future(() async {
        try {
          while (_isLoading) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          bool needsReload = false;
          if (!settingsProvider.migrationV1Done) {
            await _migrationLogic.runDataMigrationV1(_portfolios);
            needsReload = true;
          }
          if (settingsProvider.migrationV1Done &&
              !settingsProvider.migrationV2Done) {
            await _migrationLogic.runDataMigrationV2();
            needsReload = true;
          }
          if (needsReload) {
            // Appelle la méthode lourde
            await _refreshDataFromSource();
          }
          if (_settingsProvider!.isOnlineMode && _activePortfolio != null) {
            await synchroniserLesPrix();
          }
        } catch (e) {
          debugPrint("⚠️ Erreur lors de l'initialisation : $e");
        }
      });
      return;
    }

    if (_settingsProvider!.isOnlineMode &&
        !wasOffline &&
        !wasNull &&
        _activePortfolio != null) {
      synchroniserLesPrix().catchError((e) {
        debugPrint("⚠️ Impossible de synchroniser les prix : $e");
      });
    }
  }

  // -----------------------------------------------------------------
  // ▼▼▼ RÉFACTORING : SÉPARATION DE LA LOGIQUE ▼▼▼
  // -----------------------------------------------------------------

  /// **NOUVELLE MÉTHODE (LÉGÈRE)**
  /// Recalcule uniquement les données agrégées (Étape 2) sans recharger
  /// depuis la base de données.
  /// Idéal pour un changement de devise de base.
  Future<void> _recalculateAggregatedData() async {
    // 1. (MODIFIÉ) Calcule TOUS les totaux convertis en devise de BASE
    //    en utilisant le service dédié.
    _aggregatedData = await _calculationService.calculate(
      activePortfolio: _activePortfolio,
      settingsProvider: _settingsProvider,
      allMetadata: allMetadata, // Utilise le getter `allMetadata`
    );
    // 2. Réinitialise le drapeau
    _activity = BackgroundActivity.none;

    // 3. Notifie l'interface
    notifyListeners();
  }

  /// **MÉTHODE RENOMMÉE (LOURDE)**
  /// Recharge tout depuis la source (Hive) ET recalcule les agrégats.
  /// À utiliser lors d'un changement de DONNÉES (ex: nouvelle transaction).
  Future<void> _refreshDataFromSource() async {
    // 1. Recharge et hydrate les assets (en devise de COMPTE)
    _portfolios = await _hydrationService.getHydratedPortfolios();
    // 2. Sélectionne le portefeuille actif
    if (_portfolios.isNotEmpty) {
      if (_activePortfolio == null) {
        _activePortfolio = _portfolios.first;
      } else {
        try {
          _activePortfolio =
              _portfolios.firstWhere((p) => p.id == _activePortfolio!.id);
        } catch (e) {
          _activePortfolio = _portfolios.isNotEmpty ? _portfolios.first : null;
        }
      }
    } else {
      _activePortfolio = null;
    }

    // 3. Appelle la nouvelle méthode légère pour terminer le calcul
    // (cela mettra aussi à jour les listeners et _activity)
    await _recalculateAggregatedData();
  }

  // -----------------------------------------------------------------
  // ▲▲▲ FIN RÉFACTORING ▲▲▲
  // -----------------------------------------------------------------

  Future<void> loadAllPortfolios() async {
    _isLoading = true;
    notifyListeners();
    // Gère les migrations si nécessaire
    if (_settingsProvider != null) {
      if (!_settingsProvider!.migrationV1Done) {
        await _migrationLogic.runDataMigrationV1(_portfolios);
      }
      if (_settingsProvider!.migrationV1Done &&
          !_settingsProvider!.migrationV2Done) {
        await _migrationLogic.runDataMigrationV2();
      }
    }

    // Appelle la méthode LOURDE (Étapes 1 + 2)
    await _refreshDataFromSource();
    _isLoading = false;
    notifyListeners(); // Notifie une seconde fois que _isLoading est false
  }

  // ... (Le reste du fichier : CRUD, etc. est inchangé) ...
  // Ils appellent tous _refreshDataFromSource(), qui appelle maintenant _recalculateAggregatedData(),
  // donc ils sont automatiquement à jour.

  Future<void> forceSynchroniserLesPrix() async {
    if (_activePortfolio == null || _activity != BackgroundActivity.none) return;
    _activity = BackgroundActivity.syncing;
    _syncMessage = "Synchronisation forcée en cours...";
    notifyListeners();

    final result = await _syncLogic.forceSynchroniserLesPrix(_activePortfolio!);
    if (result.updatedCount > 0) {
      await _refreshDataFromSource(); // Appel LOURD
    }

    _activity = BackgroundActivity.none;
    _syncMessage = result.getSummaryMessage();
    notifyListeners();
  }

  Future<void> synchroniserLesPrix() async {
    if (_activePortfolio == null ||
        _activity != BackgroundActivity.none ||
        _settingsProvider?.isOnlineMode != true) return;
    _activity = BackgroundActivity.syncing;
    _syncMessage = "Synchronisation en cours...";
    notifyListeners();

    final result = await _syncLogic.synchroniserLesPrix(_activePortfolio!);
    if (result.updatedCount > 0) {
      await _refreshDataFromSource(); // Appel LOURD
    }

    _activity = BackgroundActivity.none;
    _syncMessage = result.getSummaryMessage();
    notifyListeners();
  }

  void clearSyncMessage() {
    _syncMessage = null;
  }

  List<SyncLog> getAllSyncLogs() {
    return _repository.getAllSyncLogs();
  }

  List<SyncLog> getRecentSyncLogs(int limit) {
    return _repository.getRecentSyncLogs(limit: limit);
  }

  Future<void> clearAllSyncLogs() async {
    await _repository.clearAllSyncLogs();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionLogic.addTransaction(transaction);
    await _refreshDataFromSource(); // Appel LOURD
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionLogic.deleteTransaction(transactionId);
    await _refreshDataFromSource(); // Appel LOURD
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionLogic.updateTransaction(transaction);
    await _refreshDataFromSource(); // Appel LOURD
  }

  void setActivePortfolio(String portfolioId) {
    try {
      _activePortfolio = _portfolios.firstWhere((p) => p.id == portfolioId);
      // Recalculer les totaux pour le nouveau portefeuille
      _recalculateAggregatedData(); // Appel LÉGER (les données sont déjà en mémoire)
    } catch (e) {
      debugPrint("Portefeuille non trouvé : $portfolioId");
    }
  }

  void addDemoPortfolio() {
    if (_portfolios.any((p) => p.name == "Portefeuille de Démo (2020-2025)")) {
      return;
    }
    final demo = _demoDataService.createDemoPortfolio();
    _portfolios.add(demo);
    _activePortfolio = demo;
    _refreshDataFromSource(); // Appel LOURD
  }

  void addNewPortfolio(String name) {
    final newPortfolio = _repository.createEmptyPortfolio(name);
    _portfolios.add(newPortfolio);
    _activePortfolio = newPortfolio;
    _refreshDataFromSource(); // Appel LOURD
  }

  void savePortfolio(Portfolio portfolio) {
    int index = _portfolios.indexWhere((p) => p.id == portfolio.id);
    if (index != -1) {
      _portfolios[index] = portfolio;
    } else {
      _portfolios.add(portfolio);
    }
    if (_activePortfolio?.id == portfolio.id) {
      _activePortfolio = portfolio;
    }
    _repository.savePortfolio(portfolio);
    _refreshDataFromSource(); // Appel LOURD
  }

  void updateActivePortfolio() {
    if (_activePortfolio == null) return;
    _repository.savePortfolio(_activePortfolio!);
    _refreshDataFromSource(); // Appel LOURD
  }

  void renameActivePortfolio(String newName) {
    if (_activePortfolio == null) return;
    _activePortfolio!.name = newName;
    updateActivePortfolio(); // Appelle _refreshDataFromSource
  }

  Future<void> deletePortfolio(String portfolioId) async {
    Portfolio? portfolioToDelete;
    try {
      portfolioToDelete = _portfolios.firstWhere((p) => p.id == portfolioId);
    } catch (e) {
      debugPrint(
          "Impossible de supprimer le portefeuille : ID $portfolioId non trouvé.");
      return;
    }

    final List<Future<void>> deleteFutures = [];
    for (final inst in portfolioToDelete.institutions) {
      for (final acc in inst.accounts) {
        for (final tx in acc.transactions) {
          deleteFutures.add(_transactionLogic.deleteTransaction(tx.id));
        }
      }
    }
    if (deleteFutures.isNotEmpty) {
      await Future.wait(deleteFutures);
    }

    await _repository.deletePortfolio(portfolioId);
    _portfolios.removeWhere((p) => p.id == portfolioId);
    if (_activePortfolio?.id == portfolioId) {
      _activePortfolio = _portfolios.isNotEmpty ? _portfolios.first : null;
    }
    _refreshDataFromSource(); // Appel LOURD
  }

  Future<void> resetAllData() async {
    await _repository.deleteAllData();
    _portfolios = [];
    _activePortfolio = null;
    await _settingsProvider?.setMigrationV1Done();
    await _settingsProvider?.setMigrationV2Done();
    _refreshDataFromSource(); // Appel LOURD
  }

  void addInstitution(Institution newInstitution) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.institutions.add(newInstitution);
    savePortfolio(updatedPortfolio); // Appelle _refreshDataFromSource
  }

  void addAccount(String institutionId, Account newAccount) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      updatedPortfolio.institutions
          .firstWhere((inst) => inst.id == institutionId)
          .accounts
          .add(newAccount);
      savePortfolio(updatedPortfolio); // Appelle _refreshDataFromSource
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
    }
  }

  void addSavingsPlan(SavingsPlan newPlan) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.savingsPlans.add(newPlan);
    savePortfolio(updatedPortfolio); // Appelle _refreshDataFromSource
  }

  void updateSavingsPlan(String planId, SavingsPlan updatedPlan) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    final index =
    updatedPortfolio.savingsPlans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      updatedPortfolio.savingsPlans[index] = updatedPlan;
      savePortfolio(updatedPortfolio); // Appelle _refreshDataFromSource
    } else {
      debugPrint("Plan d'épargne non trouvé : $planId");
    }
  }

  void deleteSavingsPlan(String planId) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.savingsPlans.removeWhere((p) => p.id == planId);
    savePortfolio(updatedPortfolio); // Appelle _refreshDataFromSource
  }

  Asset? findAssetByTicker(String ticker) {
    if (_activePortfolio == null) return null;
    for (var institution in _activePortfolio!.institutions) {
      for (var account in institution.accounts) {
        for (var asset in account.assets) {
          if (asset.ticker == ticker) return asset;
        }
      }
    }
    return null;
  }

  List<ProjectionData> getProjectionData(int duration) {
    if (_activePortfolio == null) return [];
    // NOTE : Cette projection utilise les valeurs de _aggregatedData
    final totalValue = _aggregatedData.totalValue;
    final totalInvested = _aggregatedData.totalInvested;
    final portfolioAnnualYield = activePortfolioEstimatedAnnualYield;

    // La logique des plans reste la même
    double totalMonthlyInvestment = 0;
    double weightedPlansYield = 0;
    for (var plan in _activePortfolio!.savingsPlans.where((p) => p.isActive)) {
      final targetAsset = findAssetByTicker(plan.targetTicker);
      final assetYield = (targetAsset?.estimatedAnnualYield ?? 0.0);
      totalMonthlyInvestment += plan.monthlyAmount;
      weightedPlansYield += plan.monthlyAmount * assetYield;
    }
    final double averagePlansYield = (totalMonthlyInvestment > 0)
        ? weightedPlansYield / totalMonthlyInvestment
        : 0.0;
    // TODO: Convertir totalMonthlyInvestment dans la devise de base
    // Pour l'instant, on suppose que les plans sont en devise de base

    return ProjectionCalculator.generateProjectionData(
      duration: duration,
      initialPortfolioValue: totalValue,
      initialInvestedCapital: totalInvested,
      portfolioAnnualYield: portfolioAnnualYield,
      totalMonthlyInvestment: totalMonthlyInvestment,
      averagePlansYield: averagePlansYield,
    );
  }

  Future<void> updateAssetYield(String ticker, double newYield) async {
    final metadata = _repository.getOrCreateAssetMetadata(ticker);
    metadata.updateYield(newYield, isManual: true);
    await _repository.saveAssetMetadata(metadata);
    await _refreshDataFromSource(); // Appel LOURD
  }

  Future<void> updateAssetPrice(String ticker, double newPrice,
      {String? currency}) async {
    final metadata = _repository.getOrCreateAssetMetadata(ticker);
    final targetCurrency = currency ??
        ((metadata.priceCurrency?.isEmpty ?? true)
            ? _settingsProvider!.baseCurrency
            : metadata.priceCurrency!);
    metadata.updatePrice(newPrice, targetCurrency);
    await _repository.saveAssetMetadata(metadata);
    await _refreshDataFromSource(); // Appel LOURD
  }
}