import 'package:flutter/foundation.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:portefeuille/features/07_management/services/pdf/statement_parser.dart';

class TradeRepublicParser implements StatementParser {
  @override
  String get bankName => "Trade Republic";

  @override
  bool canParse(String rawText) {
    final canParse = rawText.contains("Trade Republic Bank GmbH") || rawText.contains("TRADE REPUBLIC");
    debugPrint("TradeRepublicParser.canParse: $canParse");
    return canParse;
  }

  @override
  List<ParsedTransaction> parse(String rawText) {
    final List<ParsedTransaction> transactions = [];
    
    // Normalisation du texte : remplacer les sauts de ligne par des espaces pour faciliter les regex
    // Mais attention, parfois la structure ligne par ligne est utile.
    // On va essayer de parser ligne par ligne ou par blocs.
    
    // Regex générique pour un achat/vente standard chez TR (Format approximatif, à affiner avec de vrais exemples)
    // Ex: "Achat de 10 titres Apple Inc. au cours de 150,00 EUR"
    // Ex: "Market Order Buy 10.5 shares Tesla Inc. at 200.00 USD"
    
    // Pattern 1 : Achat/Vente classique (Français)
    // "Achat de 4,1234 titres Nom de l'actif au cours de 123,45 EUR"
    // NOTE: On utilise [\s\S]*? pour le nom de l'actif car il peut contenir des espaces ou des sauts de ligne
    final regexOrderFR = RegExp(
      r'(Achat|Vente)\s+de\s+([\d,]+)\s+titres\s+([\s\S]*?)\s+au\s+cours\s+de\s+([\d,]+)\s+(EUR|USD)',
      caseSensitive: false,
    );

    // Pattern 2 : Dividende (Français)
    // "Dividende pour 10 titres Apple Inc. Montant par titre 0,25 USD"
    final regexDividendFR = RegExp(
      r'Dividende\s+pour\s+([\d,]+)\s+titres\s+([\s\S]*?)\s+Montant',
      caseSensitive: false,
    );
    
    // Extraction des dates (souvent en haut du document : "Date : 12.05.2023")
    final regexDate = RegExp(r'Date\s*[:.]?\s*(\d{2})[./](\d{2})[./](\d{4})');
    DateTime? docDate;
    final dateMatch = regexDate.firstMatch(rawText);
    if (dateMatch != null) {
      docDate = DateTime(
        int.parse(dateMatch.group(3)!),
        int.parse(dateMatch.group(2)!),
        int.parse(dateMatch.group(1)!),
      );
      debugPrint("TradeRepublicParser: Date found: $docDate");
    } else {
      debugPrint("TradeRepublicParser: No date found");
    }

    // Recherche des correspondances pour les ordres
    final matches = regexOrderFR.allMatches(rawText);
    debugPrint("TradeRepublicParser: Found ${matches.length} order matches");

    for (final match in matches) {
      final typeStr = match.group(1)!.toLowerCase();
      final qtyStr = match.group(2)!.replaceAll(',', '.');
      final assetName = match.group(3)!.trim();
      final priceStr = match.group(4)!.replaceAll(',', '.');
      final currency = match.group(5)!;

      final quantity = double.tryParse(qtyStr) ?? 0.0;
      final price = double.tryParse(priceStr) ?? 0.0;
      final amount = quantity * price; // Approximation, le montant net est souvent ailleurs

      transactions.add(ParsedTransaction(
        date: docDate ?? DateTime.now(), // Fallback si date non trouvée
        type: typeStr == 'achat' ? TransactionType.Buy : TransactionType.Sell,
        assetName: assetName,
        quantity: quantity,
        price: price,
        amount: amount,
        fees: 1.0, // TR a souvent 1€ de frais, mais c'est une supposition
        currency: currency,
      ));
      debugPrint("TradeRepublicParser: Added transaction: $typeStr $quantity $assetName @ $price $currency");
    }

    // Recherche des dividendes
    final dividendMatches = regexDividendFR.allMatches(rawText);
    debugPrint("TradeRepublicParser: Found ${dividendMatches.length} dividend matches");

    for (final match in dividendMatches) {
      final qtyStr = match.group(1)!.replaceAll(',', '.');
      final assetName = match.group(2)!.trim();
      
      // Pour le dividende, il faut chercher le montant total plus loin
      // C'est complexe sans le texte complet. On met un placeholder.
      
      transactions.add(ParsedTransaction(
        date: docDate ?? DateTime.now(),
        type: TransactionType.Dividend,
        assetName: assetName,
        quantity: double.tryParse(qtyStr) ?? 0.0,
        price: 0,
        amount: 0, // À extraire plus précisément
        fees: 0,
        currency: "EUR",
      ));
      debugPrint("TradeRepublicParser: Added dividend: $assetName");
    }

    return transactions;
  }
}
