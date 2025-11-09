// lib/features/00_app/providers/portfolio_provider.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/account.dart';
import 'package:portefeuille/core/data/models/asset.dart';
import 'package:portefeuille/core/data/models/institution.dart';
import 'package:portefeuille/core/data/models/portfolio.dart';
import 'package:portefeuille/core/data/models/savings_plan.dart';
import 'package:portefeuille/core/data/repositories/portfolio_repository.dart';
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';

// --- NOUVEAUX IMPORTS MIGRATION ---
import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:uuid/uuid.dart';
// --- FIN NOUVEAUX IMPORTS ---

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _repository;
  final ApiService _apiService;
  SettingsProvider? _settingsProvider;
  bool _isFirstSettingsUpdate = true;

  // NOUVEAU : Pour générer les ID de migration
  final _uuid = const Uuid();

  List<Portfolio> _portfolios = [];
  Portfolio? _activePortfolio;
  bool _isLoading = true;
  bool _isSyncing = false;

  List<Portfolio> get portfolios => _portfolios;
  Portfolio? get activePortfolio => _activePortfolio;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  PortfolioProvider({
    required PortfolioRepository repository,
    required ApiService apiService,
  })  : _repository = repository,
        _apiService = apiService {
    // Charge les portefeuilles IMMÉDIATEMENT
    // (ils peuvent contenir des données "stale")
    loadAllPortfolios();
  }

  /// Met à jour le provider avec la dernière instance de SettingsProvider.
  /// Appelée par le ProxyProvider lorsque les paramètres changent.
  void updateSettings(SettingsProvider settingsProvider) {
    final bool wasOffline = _settingsProvider?.isOnlineMode ?? false;
    final bool wasNull = _settingsProvider == null;
    _settingsProvider = settingsProvider;

    // --- MODIFICATION MAJEURE : GESTION DE LA MIGRATION ---
    if (_isFirstSettingsUpdate) {
      _isFirstSettingsUpdate = false;

      // 1. VÉRIFIER ET LANCER LA MIGRATION
      // Doit être 'async' mais la méthode update ne peut pas l'être,
      // donc on utilise un Future anonyme.
      Future(() async {
        if (!settingsProvider.migrationV1Done) {
          await _runDataMigrationV1(settingsProvider);
        }

        // 2. DÉCLENCHER LA SYNCHRO (après migration potentielle)
        if (_settingsProvider!.isOnlineMode) {
          await synchroniserLesPrix();
        }
      });

      return; // Fin de la logique du premier chargement
    }
    // --- FIN MODIFICATION ---

    // Logique de synchro (si l'utilisateur active/désactive le mode en ligne)
    if (_settingsProvider!.isOnlineMode && !wasOffline && !wasNull) {
      synchroniserLesPrix();
    }
  }

  /// Charge tous les portefeuilles (potentiellement avec des données périmées)
  void loadAllPortfolios() async {
    _portfolios = _repository.getAllPortfolios();
    if (_portfolios.isNotEmpty) {
      _activePortfolio = _portfolios.first;
    }
    _isLoading = false;
    notifyListeners();
    // La synchronisation des prix est déplacée dans updateSettings
    // pour s'assurer qu'elle s'exécute APRÈS la migration.
  }

  /// Ajoute une transaction et recharge les données.
  Future<void> addTransaction(Transaction transaction) async {
    // 1. Sauvegarder la nouvelle transaction
    await _repository.saveTransaction(transaction);

    // 2. Recharger les portefeuilles
    // Cela force la ré-injection des transactions (via getAllPortfolios)
    // et le recalcul des getters.
    loadAllPortfolios();

    // 3. Notifier (déjà fait par loadAllPortfolios)
  }

  // --- NOUVELLE MÉTHODE ---
  /// Supprime une transaction et recharge les données.
  Future<void> deleteTransaction(String transactionId) async {
    // 1. Supprimer la transaction
    await _repository.deleteTransaction(transactionId);
    // 2. Recharger les portefeuilles pour recalculer les soldes
    loadAllPortfolios();
  }

  /// Met à jour une transaction existante et recharge les données.
  Future<void> updateTransaction(Transaction transaction) async {
    // 1. Sauvegarder la transaction (put écrase l'existant avec le même ID)
    await _repository.saveTransaction(transaction);
    // 2. Recharger les portefeuilles
    loadAllPortfolios();
  }

  // --- NOUVELLE MÉTHODE DE MIGRATION ---
  /// Convertit les champs `stale_` en transactions.
  Future<void> _runDataMigrationV1(SettingsProvider settingsProvider) async {
    // Vérifie s'il y a des données à migrer
    final bool needsMigration = _portfolios.any((p) => p.institutions
        .any((i) => i.accounts.any((a) =>
    a.stale_cashBalance != null || (a.stale_assets?.isNotEmpty ?? false))));

    if (!needsMigration) {
      debugPrint("Migration V1 : Aucune donnée périmée trouvée. Ignoré.");
      await settingsProvider.setMigrationV1Done();
      return;
    }

    debugPrint("--- DÉBUT MIGRATION V1 ---");
    final List<Transaction> newTransactions = [];

    for (final portfolio in _portfolios) {
      bool portfolioNeedsSave = false;
      for (final inst in portfolio.institutions) {
        for (final acc in inst.accounts) {
          // Date fictive pour les transactions migrées
          final migrationDate = DateTime(2024, 1, 1);

          // 1. Migrer les liquidités (stale_cashBalance)
          if (acc.stale_cashBalance != null && acc.stale_cashBalance! > 0) {
            debugPrint(
                "Migration : Ajout Dépôt (cash) ${acc.stale_cashBalance} pour ${acc.name}");
            newTransactions.add(Transaction(
              id: _uuid.v4(),
              accountId: acc.id,
              type: TransactionType.Deposit,
              date: migrationDate,
              amount: acc.stale_cashBalance!,
              notes: "Migration v1 (Liquidités)",
            ));
            acc.stale_cashBalance = null; // Nettoyer
            portfolioNeedsSave = true;
          }

          // 2. Migrer les actifs (stale_assets)
          if (acc.stale_assets != null && acc.stale_assets!.isNotEmpty) {
            debugPrint(
                "Migration : ${acc.stale_assets!.length} actifs pour ${acc.name}");

            for (final asset in acc.stale_assets!) {
              // Lire les données périmées de l'asset
              final qty = asset.stale_quantity;
              final pru = asset.stale_averagePrice;

              if (qty != null && pru != null && qty > 0) {
                final totalCost = qty * pru;
                debugPrint(
                    "Migration : Actif ${asset.ticker} (Qty: $qty, PRU: $pru)");

                // Étape 2a: Dépôt pour "couvrir" le coût de l'actif
                newTransactions.add(Transaction(
                  id: _uuid.v4(),
                  accountId: acc.id,
                  type: TransactionType.Deposit,
                  date: migrationDate,
                  amount: totalCost,
                  notes: "Migration v1 (Coût ${asset.ticker})",
                ));

                // Étape 2b: Achat de l'actif (impact cash négatif)
                newTransactions.add(Transaction(
                  id: _uuid.v4(),
                  accountId: acc.id,
                  type: TransactionType.Buy,
                  date: migrationDate,
                  assetTicker: asset.ticker,
                  assetName: asset.name,
                  quantity: qty,
                  price: pru,
                  amount: -totalCost,
                  fees: 0,
                  notes: "Migration v1 (Achat ${asset.ticker})",
                ));
              }
              // Nettoyer l'asset (inutile, car stale_assets sera null)
            }
            acc.stale_assets = null; // Nettoyer
            portfolioNeedsSave = true;
          }
        }
      }

      // 3. Sauvegarder le portefeuille "nettoyé" (champs stale_ à null)
      if (portfolioNeedsSave) {
        debugPrint("Migration : Nettoyage du portefeuille ${portfolio.name}");
        await _repository.savePortfolio(portfolio);
      }
    }

    // 4. Sauvegarder TOUTES les nouvelles transactions en une fois
    debugPrint("Migration : Sauvegarde de ${newTransactions.length} transactions...");
    for (final tx in newTransactions) {
      await _repository.saveTransaction(tx);
    }

    // 5. Marquer la migration comme terminée
    await settingsProvider.setMigrationV1Done();

    // 6. Recharger les données (Portfolio + Transactions injectées)
    debugPrint("--- FIN MIGRATION V1 : Rechargement des données ---");
    loadAllPortfolios();
  }
  // --- FIN NOUVELLE MÉTHODE ---


  // --- Le reste du fichier (synchroniserLesPrix, addDemoPortfolio, etc.) reste identique ---
  // ... (Collez le reste du fichier PortfolioProvider à partir d'ici) ...

  Future<void> synchroniserLesPrix() async {
    if (_activePortfolio == null) return;
    if (_isSyncing) return;
    if (_settingsProvider?.isOnlineMode != true) return;

    _isSyncing = true;
    notifyListeners();

    try {
      bool hasChanges = false;
      final portfolioToSync = _activePortfolio!;

      // 1. Collecter tous les actifs (MAJ : utilise le getter)
      List<Asset> allAssets = [];
      for (var inst in portfolioToSync.institutions) {
        for (var acc in inst.accounts) {
          // NOTE : 'assets' est maintenant un getter qui sera vide
          // car la logique n'est pas implémentée.
          // La synchro ne fonctionnera qu'après l'implémentation des getters.
          allAssets.addAll(acc.assets);
        }
      }

      final tickers =
      allAssets.map((a) => a.ticker).where((t) => t.isNotEmpty).toSet();
      if (tickers.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      Map<String, double?> prices = {};
      await Future.wait(tickers.map((ticker) async {
        final price = await _apiService.getPrice(ticker);
        if (price != null) {
          prices[ticker] = price;
        }
      }));
      for (var asset in allAssets) {
        if (prices.containsKey(asset.ticker)) {
          final newPrice = prices[asset.ticker]!;
          if (asset.currentPrice != newPrice) {
            asset.currentPrice = newPrice;
            hasChanges = true;
          }
        }
      }

      if (hasChanges) {
        updateActivePortfolio();
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ Erreur lors de la synchronisation des prix : $e");
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void setActivePortfolio(String portfolioId) {
    try {
      _activePortfolio = _portfolios.firstWhere((p) => p.id == portfolioId);
      notifyListeners();
    } catch (e) {
      debugPrint("Portefeuille non trouvé : $portfolioId");
    }
  }

  void addDemoPortfolio() {
    if (_portfolios.any((p) => p.name == "Portefeuille de Démo")) {
      return;
    }
    final demo = _repository.createDemoPortfolio();
    _portfolios.add(demo);
    _activePortfolio = demo;

    // MODIFIÉ : Recharger pour hydrater les transactions de démo
    loadAllPortfolios();
  }

  void addNewPortfolio(String name) {
    final newPortfolio = _repository.createEmptyPortfolio(name);
    _portfolios.add(newPortfolio);
    _activePortfolio = newPortfolio;
    notifyListeners();
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
    notifyListeners();
  }

  void updateActivePortfolio() {
    if (_activePortfolio == null) return;
    _repository.savePortfolio(_activePortfolio!);
    notifyListeners();
  }

  void renameActivePortfolio(String newName) {
    if (_activePortfolio == null) return;
    _activePortfolio!.name = newName;
    updateActivePortfolio();
  }

  Future<void> deletePortfolio(String portfolioId) async {
    // TODO: Il faudra aussi supprimer les transactions liées à ce portefeuille
    await _repository.deletePortfolio(portfolioId);
    _portfolios.removeWhere((p) => p.id == portfolioId);
    if (_activePortfolio?.id == portfolioId) {
      _activePortfolio = _portfolios.isNotEmpty ? _portfolios.first : null;
    }
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _repository.deleteAllData();
    _portfolios = [];
    _activePortfolio = null;

    // NOUVEAU : Réinitialiser aussi le drapeau de migration
    await _settingsProvider?.setMigrationV1Done(); // Marque comme fait (car vide)

    notifyListeners();
  }

  void addInstitution(Institution newInstitution) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.institutions.add(newInstitution);
    savePortfolio(updatedPortfolio);
  }

  void addAccount(String institutionId, Account newAccount) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      updatedPortfolio.institutions
          .firstWhere((inst) => inst.id == institutionId)
          .accounts
          .add(newAccount);
      savePortfolio(updatedPortfolio);
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
    }
  }

  // CETTE MÉTHODE EST MAINTENANT OBSOLÈTE
  // L'ajout d'asset se fera via une TRANSACTION
  void addAsset(String accountId, Asset newAsset) {
    /*
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      for (var inst in updatedPortfolio.institutions) {
        for (var acc in inst.accounts) {
          if (acc.id == accountId) {
            // ERREUR : acc.assets est un getter
            // acc.assets.add(newAsset);
            savePortfolio(updatedPortfolio);
            return;
          }
        }
      }
      debugPrint("Compte non trouvé : $accountId");
    } catch (e) {
      debugPrint("Erreur lors de l'ajout de l'actif : $e");
    }
    */
  }

  // ========== GESTION DES PLANS D'ÉPARGNE ==========

  void addSavingsPlan(SavingsPlan newPlan) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.savingsPlans.add(newPlan);
    savePortfolio(updatedPortfolio);
  }

  void updateSavingsPlan(String planId, SavingsPlan updatedPlan) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    final index =
    updatedPortfolio.savingsPlans.indexWhere((p) => p.id == planId);
    if (index != -1) {
      updatedPortfolio.savingsPlans[index] = updatedPlan;
      savePortfolio(updatedPortfolio);
    } else {
      debugPrint("Plan d'épargne non trouvé : $planId");
    }
  }

  void deleteSavingsPlan(String planId) {
    if (_activePortfolio == null) return;
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.savingsPlans.removeWhere((p) => p.id == planId);
    savePortfolio(updatedPortfolio);
  }
}