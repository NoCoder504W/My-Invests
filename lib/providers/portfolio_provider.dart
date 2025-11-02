import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/portfolio.dart';
import '../models/institution.dart';
import '../models/account.dart';
import '../models/asset.dart';
import '../models/account_type.dart';

class PortfolioProvider extends ChangeNotifier {
  Portfolio? _portfolio;
  final Box<Portfolio> _portfolioBox = Hive.box('portfolio_box');

  Portfolio? get portfolio => _portfolio;

  PortfolioProvider() {
    _loadPortfolio();
  }

  void _loadPortfolio() {
    if (_portfolioBox.isNotEmpty) {
      _portfolio = _portfolioBox.getAt(0);
      notifyListeners();
    }
  }

  void createDemoPortfolio() {
    _portfolio = _getDemoData();
    _savePortfolio();
    notifyListeners();
  }

  void createEmptyPortfolio() {
    _portfolio = Portfolio(institutions: []);
    _savePortfolio();
    notifyListeners();
  }

  void updatePortfolio(Portfolio portfolio) {
    _portfolio = portfolio;
    _savePortfolio();
    notifyListeners();
  }

  void clearPortfolio() {
    _portfolio = null;
    _portfolioBox.clear();
    notifyListeners();
  }

  void _savePortfolio() {
    if (_portfolio != null) {
      _portfolioBox.put(0, _portfolio!); 
    }
  }

  Portfolio _getDemoData() {
     return Portfolio(
      institutions: [
        Institution(
          name: 'Boursorama Banque',
          accounts: [
            Account(
              name: 'Compte-Titres Ordinaire',
              type: AccountType.cto,
              cashBalance: 150.75,
              assets: [
                Asset(name: 'Apple Inc.', ticker: 'AAPL', quantity: 10, averagePrice: 150.0, currentPrice: 175.2, estimatedAnnualYield: 0.008),
                Asset(name: 'Microsoft Corp.', ticker: 'MSFT', quantity: 15, averagePrice: 280.5, currentPrice: 310.8, estimatedAnnualYield: 0.0095),
                Asset(name: 'ETF S&P 500 UCITS', ticker: 'CW8', quantity: 25, averagePrice: 80.0, currentPrice: 95.0, estimatedAnnualYield: 0.12),
              ],
            ),
            Account(
              name: "Plan d'Épargne en Actions",
              type: AccountType.pea,
              cashBalance: 50.25,
              assets: [
                Asset(name: 'LVMH Moët Hennessy', ticker: 'MC', quantity: 5, averagePrice: 700.0, currentPrice: 850.5, estimatedAnnualYield: 0.016),
                Asset(name: 'Airbus SE', ticker: 'AIR', quantity: 10, averagePrice: 120.0, currentPrice: 135.0, estimatedAnnualYield: 0.012),
              ],
            ),
             Account(
              name: 'Assurance Vie',
              type: AccountType.assuranceVie,
              cashBalance: 1000.0, // Fonds Euro
              assets: [],
            ),
          ],
        ),
        Institution(
          name: 'Coinbase',
          accounts: [
            Account(
              name: 'Portefeuille Crypto',
              type: AccountType.crypto,
              cashBalance: 200.0,
              assets: [
                Asset(name: 'Bitcoin', ticker: 'BTC', quantity: 0.05, averagePrice: 35000.0, currentPrice: 42000.0, estimatedAnnualYield: 0.45),
                Asset(name: 'Ethereum', ticker: 'ETH', quantity: 0.5, averagePrice: 2000.0, currentPrice: 2500.0, estimatedAnnualYield: 0.35),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
