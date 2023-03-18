import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:budget_tracker/models/income_item.dart';

class IncomeData{
  //list of ALL incomes
  List<IncomeItem> overallIncomeList = [];
  //income balance
  double incomeBalance = 0;
  //get income list
  List<IncomeItem> getAllIncomeList(){
    return overallIncomeList;
  }
  //add new income
  void addNewIncome(IncomeItem newIncome){
    overallIncomeList.add(newIncome);
    incomeBalance += double.parse(newIncome.amount);
  }

  //delete income
  void deleteIncome(IncomeItem income){
    overallIncomeList.remove(income);
  }
  //get weekday from dateTime object
  String getDayName(DateTime dateTime){
    switch(dateTime.weekday){
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
  //get date for the start of the week
  DateTime startOfWeekDate(){
    DateTime? startOfWeek;

    DateTime today = DateTime.now();

    //go backwards from today to find sunday
    for(int i =0; i < 7; i++){
      if(getDayName(today.subtract(Duration(days: i))) == 'Sun'){
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

  Map<String, double> calculateDailyIncomeSummary(){
    Map<String, double> dailyIncomeSummary = {

    };
    for(var income in overallIncomeList){
      String date = convertDateTimeToString(income.dateTime);
      double amount = double.parse(income.amount);
    
      if(dailyIncomeSummary.containsKey(date)){
        double currentAmount = dailyIncomeSummary[date]!;
        currentAmount += amount;
        dailyIncomeSummary[date] = currentAmount;
      } else {
        dailyIncomeSummary.addAll({date: amount});
      }
    }
    return dailyIncomeSummary;
  }
}