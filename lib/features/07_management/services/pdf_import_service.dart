import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:portefeuille/features/07_management/services/pdf/statement_parser.dart';
import 'package:portefeuille/features/07_management/services/pdf/parsers/trade_republic_parser.dart';
import 'package:portefeuille/features/07_management/services/pdf/parsers/boursorama_parser.dart';

class PdfImportService {
  final List<StatementParser> _parsers = [
    TradeRepublicParser(),
    BoursoramaParser(),
  ];
  
  Future<List<ParsedTransaction>> extractTransactions(File file) async {
    final List<ParsedTransaction> transactions = [];
    
    try {
      // Load the PDF document.
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Extract text from all pages.
      String text = PdfTextExtractor(document).extractText();
      
      // Dispose the document.
      document.dispose();

      debugPrint("--- PDF CONTENT START ---");
      debugPrint(text);
      debugPrint("--- PDF CONTENT END ---");

      // Find the right parser
      for (final parser in _parsers) {
        debugPrint("Testing parser: ${parser.bankName}");
        if (parser.canParse(text)) {
          debugPrint("Parser MATCHED: ${parser.bankName}");
          transactions.addAll(parser.parse(text));
          break;
        } else {
          debugPrint("Parser REJECTED: ${parser.bankName}");
        }
      }
      
      if (transactions.isEmpty) {
        debugPrint("No parser matched or no transactions found.");
      }
      
    } catch (e) {
      debugPrint('Error extracting PDF: $e');
    }
    
    return transactions;
  }
}
