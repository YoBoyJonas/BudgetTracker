import 'package:budget_tracker/datetime/date_time_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExpenseData extends ChangeNotifier{
  //list of ALL expenses
  List<ExpenseItem> overallExpenseList = [];
  //expense balance
  double expenseBalance = 0;
  double incomeBalance = 0;
  //get expense list
  List<ExpenseItem> getAllExpenseList(){
    return overallExpenseList;
  }
  //add new expense
  void addNewExpense(ExpenseItem newExpense){
    overallExpenseList.add(newExpense);
    expenseBalance += double.parse(newExpense.amount);

    notifyListeners();
  }

    void addNewIncome(ExpenseItem newIncome){
    overallExpenseList.add(newIncome);
    incomeBalance += double.parse(newIncome.amount);

    notifyListeners();
  }

  //delete expense
  void deleteExpense(ExpenseItem expense){
    overallExpenseList.remove(expense);

    notifyListeners();
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

  Map<String, double> calculateDailyExpensesSummary(){
    Map<String, double> dailyExpenseSummary = {

    };
    for(var expense in overallExpenseList){
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);
    
      if(dailyExpenseSummary.containsKey(date)){
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }
}