import 'package:budget_tracker/Bar graph/individual_bar.dart';

class BarData{
  final double month1Amount;
  final double month2Amount;
  final double month3Amount;
  final double month4Amount;
  final double month5Amount;
  final double month6Amount;

  BarData({
    required this.month1Amount,
    required this.month2Amount,
    required this.month3Amount,
    required this.month4Amount,
    required this.month5Amount,
    required this.month6Amount,
  });

  List<IndividualBar> barData = [];

  //initialize bar data
  void initializeBarData() {
    barData = [
      IndividualBar(x: 0, y: month1Amount),
      IndividualBar(x: 1, y: month2Amount),
      IndividualBar(x: 2, y: month3Amount),
      IndividualBar(x: 3, y: month4Amount),
      IndividualBar(x: 4, y: month5Amount),
      IndividualBar(x: 5, y: month6Amount)
    ];
  }

}