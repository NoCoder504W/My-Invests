// lib/core/data/models/exchange_rate_history.dart
import 'package:hive/hive.dart';

part 'exchange_rate_history.g.dart';

@HiveType(typeId: 11)
class ExchangeRateHistory {
  /// Paire de devises (ex: "USD-EUR")
  @HiveField(0)
  final String pair;

  /// Date (tronquée au jour)
  @HiveField(1)
  final DateTime date;

  /// Taux de change (Combien de "EUR" pour 1 "USD")
  @HiveField(2)
  final double rate;

  ExchangeRateHistory({
    required this.pair,
    required this.date,
    required this.rate,
  });
}
