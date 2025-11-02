import 'package:hive/hive.dart';
import 'account.dart';

part 'institution.g.dart';

@HiveType(typeId: 1)
class Institution {
  @HiveField(0)
  final String name;

  @HiveField(1)
  List<Account> accounts;

  Institution({required this.name, this.accounts = const []});

  double get totalValue {
    return accounts.fold(0.0, (sum, account) => sum + account.totalValue);
  }

  double get profitAndLoss {
    return accounts.fold(0.0, (sum, account) => sum + account.profitAndLoss);
  }

  double get profitAndLossPercentage {
    final totalPnl = profitAndLoss;
    final currentValue = totalValue;
    if (currentValue == totalPnl) {
      return 0;
    }
    final previousValue = currentValue - totalPnl;
    return totalPnl / previousValue;
  }

  Institution deepCopy() {
    return Institution(
      name: name,
      accounts: accounts.map((account) => account.deepCopy()).toList(),
    );
  }
}
