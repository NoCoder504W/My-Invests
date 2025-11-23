part of '../portfolio_provider.dart';

mixin PortfolioSync on PortfolioState {
  // ============================================================
  // SYNCHRONISATION
  // ============================================================

  Future<void> synchroniserLesPrix() async {
    if (!_canSync()) return;

    debugPrint("🔄 [Provider] synchroniserLesPrix");
    _setActivity(const Syncing(0, 0));
    _syncMessage = "Synchronisation en cours...";
    notifyListeners();

    final result = await _syncService.synchronize(_activePortfolio!);

    if (result.hasUpdates) {
      await refreshData();
    }

    _setActivity(const Idle());
    _syncMessage = result.getSummaryMessage();
    notifyListeners();
  }

  Future<void> forceSynchroniserLesPrix() async {
    if (!_canSync()) return;

    debugPrint("🔄 [Provider] forceSynchroniserLesPrix");
    _setActivity(const Syncing(0, 0));
    _syncMessage = "Synchronisation forcée en cours...";
    notifyListeners();

    final result = await _syncService.forceSync(_activePortfolio!);

    if (result.hasUpdates) {
      await refreshData();
    }

    _setActivity(const Idle());
    _syncMessage = result.getSummaryMessage();
    notifyListeners();
  }

  bool _canSync() {
    return _activePortfolio != null &&
        _activity is Idle &&
        _settingsProvider?.isOnlineMode == true;
  }

  void clearSyncMessage() {
    _syncMessage = null;
    notifyListeners();
  }

  // ============================================================
  // SYNC LOGS
  // ============================================================

  List<SyncLog> getAllSyncLogs() => _repository.getAllSyncLogs();

  List<SyncLog> getRecentSyncLogs(int limit) =>
      _repository.getRecentSyncLogs(limit: limit);

  Future<void> clearAllSyncLogs() async {
    await _repository.clearAllSyncLogs();
    notifyListeners();
  }
}
