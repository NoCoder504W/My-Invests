import 'package:flutter_test/flutter_test.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:portefeuille/features/09_imports/services/pdf/parsers/trade_republic_account_statement_parser.dart';

void main() {
  late TradeRepublicAccountStatementParser parser;

  setUp(() {
    parser = TradeRepublicAccountStatementParser();
  });

  const fakeStatementText = """
TRADE REPUBLIC BANK GMBH
75 BOULEVARD HAUSSMANN
75008 PARIS
DATE
01 mai 2025 - 31 juil. 2025

SYNTHÈSE DU RELEVÉ DE COMPTE
PRODUIT SOLDE DÉBUT
Compte courant 9591,91 €

TRANSACTIONS
DATE
TYPE
DESCRIPTION
ENTRÉE D'ARGENT
SORTIE D'ARGENT
SOLDE

01 mai 2025
Intérêts créditeur
Your interest payment
15,25 €
9607,16 €

02 mai 2025
Exécution d'ordre
Savings plan execution XF000BTC0017 Bitcoin, quantity: 0.000113
9,97 €
9597,19 €

02 mai 2025
Exécution d'ordre
Savings plan execution LU0380865021 Xtrackers - Xtrackers Euro Stoxx 50 UCITS ETF 1C, quantity: 0.446677
40,00 €
9552,19 €

02 mai 2025
Exécution d'ordre
Savings plan execution US0378331005 Apple Inc., quantity: 1.5
225,00 €
9327,19 €
""";

  test('Should identify Trade Republic Account Statement', () {
    expect(parser.canParse(fakeStatementText), isTrue);
    expect(parser.canParse("SOME OTHER TEXT"), isFalse);
    expect(parser.canParse("TRADE REPUBLIC BUT NOT STATEMENT"), isFalse);
  });

  test('Should parse transactions correctly', () {
    final transactions = parser.parse(fakeStatementText);

    expect(transactions.length, 4);

    // 1. Interest
    final interest = transactions[0];
    expect(interest.type, TransactionType.Dividend); // Or Interest if available
    expect(interest.amount, 15.25);
    expect(interest.date, DateTime(2025, 5, 1));
    expect(interest.assetName, contains("Your interest payment"));

    // 2. Bitcoin Buy
    final btc = transactions[1];
    expect(btc.type, TransactionType.Buy);
    expect(btc.assetType, AssetType.Crypto);
    expect(btc.isin, "XF000BTC0017");
    expect(btc.quantity, 0.000113);
    expect(btc.amount, 9.97);
    expect(btc.assetName, "Bitcoin");
    // Price = 9.97 / 0.000113 = 88230.08...
    expect(btc.price, closeTo(88230.08, 0.1));

    // 3. ETF Buy
    final etf = transactions[2];
    expect(etf.type, TransactionType.Buy);
    expect(etf.assetType, AssetType.ETF);
    expect(etf.isin, "LU0380865021");
    expect(etf.quantity, 0.446677);
    expect(etf.amount, 40.00);
    expect(etf.assetName, contains("Xtrackers - Xtrackers Euro Stoxx 50 UCITS ETF 1C"));

    // 4. Stock Buy (Apple)
    final apple = transactions[3];
    expect(apple.type, TransactionType.Buy);
    expect(apple.assetType, AssetType.Stock); // Default
    expect(apple.isin, "US0378331005");
    expect(apple.quantity, 1.5);
    expect(apple.amount, 225.00);
    expect(apple.assetName, "Apple Inc.");
  });
}
