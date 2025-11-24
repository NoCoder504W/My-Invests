part of '../portfolio_provider.dart';

mixin PortfolioAssets on PortfolioState {
  // ============================================================
  // ASSETS
  // ============================================================

  @override
  void _rebuildAssetMap() {
    _assetMap.clear();
    if (_activePortfolio == null) return;
    
    for (var institution in _activePortfolio!.institutions) {
      for (var account in institution.accounts) {
        for (var asset in account.assets) {
          _assetMap[asset.ticker] = asset;
        }
      }
    }
  }

  Asset? findAssetByTicker(String ticker) {
    return _assetMap[ticker];
  }

  Future<void> updateAssetYield(String ticker, double newYield,
      {bool isManual = true}) async {
    final metadata = _repository.getOrCreateAssetMetadata(ticker);
    metadata.updateYield(newYield, isManual: isManual);
    await _repository.saveAssetMetadata(metadata);
    await refreshData();
  }

  Future<void> updateAssetYields(Map<String, double> yields) async {
    for (var entry in yields.entries) {
      final metadata = _repository.getOrCreateAssetMetadata(entry.key);
      metadata.updateYield(entry.value);
      await _repository.saveAssetMetadata(metadata);
    }
    await refreshData();
  }

  Future<void> updateAssetPrice(String ticker, double newPrice,
      {String? currency}) async {
    debugPrint("🔄 [Provider] updateAssetPrice");
    final metadata = _repository.getOrCreateAssetMetadata(ticker);
    final targetCurrency = currency ??
        ((metadata.priceCurrency?.isEmpty ?? true)
            ? _settingsProvider!.baseCurrency
            : metadata.priceCurrency!);
    metadata.updatePrice(newPrice, targetCurrency);
    await _repository.saveAssetMetadata(metadata);
    await refreshData();
  }

  Future<void> updateAssetPrices(Map<String, double> prices) async {
    debugPrint("🔄 [Provider] updateAssetPrices (Batch: ${prices.length})");
    for (var entry in prices.entries) {
      final metadata = _repository.getOrCreateAssetMetadata(entry.key);
      final targetCurrency = ((metadata.priceCurrency?.isEmpty ?? true)
          ? _settingsProvider!.baseCurrency
          : metadata.priceCurrency!);
      metadata.updatePrice(entry.value, targetCurrency);
      await _repository.saveAssetMetadata(metadata);
    }
    await refreshData();
  }

  // ============================================================
  // ASSET METADATA
  // ============================================================

  Future<void> updateAssetMetadata(AssetMetadata metadata) async {
    await _repository.saveAssetMetadata(metadata);
    // Recharger les données pour que les actifs (Assets) soient mis à jour avec les nouvelles métadonnées (lat/lon, etc.)
    await refreshData();
  }

  Future<void> updateAssetMetadatas(List<AssetMetadata> metadatas) async {
    for (var m in metadatas) {
      await _repository.saveAssetMetadata(m);
    }
    await refreshData();
  }

  Future<void> saveMetadata(AssetMetadata metadata) async {
    await _repository.saveAssetMetadata(metadata);
    notifyListeners();
  }
}
