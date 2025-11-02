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
}
