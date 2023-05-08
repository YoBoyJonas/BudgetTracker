import 'package:budget_tracker/Bar%20graph/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;

class MyBarGraph extends StatelessWidget {
  final List weeklySummary;
  const MyBarGraph({
    super.key,
    required this.weeklySummary
    });

  @override
  Widget build(BuildContext context) {
    //initialize bar data
    BarData myBarData = BarData(
      month1Amount: weeklySummary[0], 
      month2Amount: weeklySummary[1], 
      month3Amount: weeklySummary[2], 
      month4Amount: weeklySummary[3], 
      month5Amount: weeklySummary[4], 
      month6Amount: weeklySummary[5]
    );
myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        maxY: myBarData.max,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getLeftTitles)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getBottomTitles,)), 
        ),
        barGroups:  myBarData.barData
        .map(
          (data) => BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: globals.selectedWidgetColor,
                width: 25,
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(width: 3, color: Colors.brown),
              ),
            ],
          ),
        )
        .toList(),
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta){
    const style =  TextStyle(
      color: Colors.brown,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      
    );
    var currDate = DateTime.now();
    Widget text;
    switch(value.toInt()){
      case 0:
        var d = Jiffy(currDate).subtract(months: 0).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      case 1:
        var d = Jiffy(currDate).subtract(months: 1).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      case 2:
        var d = Jiffy(currDate).subtract(months: 2).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      case 3:
        var d = Jiffy(currDate).subtract(months: 3).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      case 4:
        var d = Jiffy(currDate).subtract(months: 4).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      case 5:
        var d = Jiffy(currDate).subtract(months: 5).dateTime;
        final today = formatDate(d, [mm]);
        text = Text(today.toString(), style: style,);
        break;
      default:
        text = Text('00', style: style,);
        break;
    }
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
  Widget getLeftTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.brown,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  Widget text = RotatedBox(
    quarterTurns: 3,
    child: Text(
      value.round().toString(),
      style: style,
    ),
  );
  return SideTitleWidget(
    child: text,
    axisSide: meta.axisSide,
  );
}
}