part of '../portfolio_provider.dart';

mixin PortfolioInstitutions on PortfolioState {
  // ============================================================
  // INSTITUTIONS & ACCOUNTS
  // ============================================================

  Future<void> addInstitution(Institution newInstitution) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] addInstitution");
    final updatedPortfolio = _activePortfolio!.deepCopy();
    updatedPortfolio.institutions.add(newInstitution);
    await savePortfolio(updatedPortfolio);
  }

  Future<void> updateInstitution(Institution updatedInstitution) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] updateInstitution");
    final updatedPortfolio = _activePortfolio!.deepCopy();
    final index = updatedPortfolio.institutions.indexWhere((i) => i.id == updatedInstitution.id);
    if (index != -1) {
      updatedPortfolio.institutions[index] = updatedInstitution;
      await savePortfolio(updatedPortfolio);
    } else {
      debugPrint("Institution non trouvée : ${updatedInstitution.id}");
    }
  }

  Future<void> deleteInstitution(String institutionId) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] deleteInstitution");

    final updatedPortfolio = _activePortfolio!.deepCopy();
    
    // 1. Trouver l'institution à supprimer
    Institution? institutionToDelete;
    try {
      institutionToDelete = updatedPortfolio.institutions.firstWhere((i) => i.id == institutionId);
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
      return;
    }

    // 2. Supprimer toutes les transactions associées à tous les comptes de cette institution
    final deleteFutures = <Future<void>>[];
    for (final acc in institutionToDelete.accounts) {
      for (final tx in acc.transactions) {
        deleteFutures.add(_transactionService.delete(tx.id));
      }
    }
    
    if (deleteFutures.isNotEmpty) {
      await Future.wait(deleteFutures);
    }

    // 3. Supprimer l'institution
    updatedPortfolio.institutions.removeWhere((i) => i.id == institutionId);

    // 4. Sauvegarder
    savePortfolio(updatedPortfolio);
  }

  Future<void> addAccount(String institutionId, Account newAccount) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] addAccount");
    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      updatedPortfolio.institutions
          .firstWhere((inst) => inst.id == institutionId)
          .accounts
          .add(newAccount);
      await savePortfolio(updatedPortfolio);
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
    }
  }

  Future<void> updateAccount(String institutionId, Account updatedAccount) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] updateAccount");

    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      // 1. Trouver l'institution
      final institution = updatedPortfolio.institutions
          .firstWhere((inst) => inst.id == institutionId);

      // 2. Trouver l'index de l'ancien compte
      final accountIndex =
      institution.accounts.indexWhere((acc) => acc.id == updatedAccount.id);

      if (accountIndex != -1) {
        // 3. Remplacer l'ancien compte par le nouveau
        institution.accounts[accountIndex] = updatedAccount;
        // 4. Sauvegarder
        await savePortfolio(updatedPortfolio);
      } else {
        debugPrint("Compte non trouvé : ${updatedAccount.id}");
      }
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
    }
  }

  Future<void> deleteAccount(String institutionId, String accountId) async {
    if (_activePortfolio == null) return;
    debugPrint("🔄 [Provider] deleteAccount");

    final updatedPortfolio = _activePortfolio!.deepCopy();
    try {
      // 1. Trouver l'institution
      final institution = updatedPortfolio.institutions
          .firstWhere((inst) => inst.id == institutionId);

      // 2. Trouver le compte à supprimer
      Account? accountToDelete;
      try {
        accountToDelete =
            institution.accounts.firstWhere((acc) => acc.id == accountId);
      } catch (e) {
        debugPrint("Compte non trouvé : $accountId");
        return;
      }

      // 3. Supprimer toutes les transactions associées (TRÈS IMPORTANT)
      final deleteFutures = <Future<void>>[];
      for (final tx in accountToDelete.transactions) {
        deleteFutures.add(_transactionService.delete(tx.id));
      }
      if (deleteFutures.isNotEmpty) {
        await Future.wait(deleteFutures);
      }

      // 4. Supprimer le compte de la liste
      institution.accounts.removeWhere((acc) => acc.id == accountId);

      // 5. Sauvegarder
      savePortfolio(updatedPortfolio);
    } catch (e) {
      debugPrint("Institution non trouvée : $institutionId");
    }
  }

  // ============================================================
  // SAVINGS PLANS
  // ============================================================

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
