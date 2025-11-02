import 'package:hive/hive.dart';
import 'institution.dart';

part 'portfolio.g.dart';

@HiveType(typeId: 0)
class Portfolio extends HiveObject {
  @HiveField(0)
  List<Institution> institutions;

  Portfolio({this.institutions = const []});

  double get totalValue {
    return institutions.fold(0.0, (sum, inst) => sum + inst.totalValue);
  }

  double get estimatedAnnualYield {
    final totalVal = totalValue;
    if (totalVal == 0) {
      return 0.0;
    }
    final weightedYield = institutions.fold(0.0, (sum, inst) => sum + (inst.totalValue * inst.estimatedAnnualYield));
    return weightedYield / totalVal;
  }

  Portfolio deepCopy() {
    return Portfolio(
      institutions: institutions.map((inst) => inst.deepCopy()).toList(),
    );
  }
}
