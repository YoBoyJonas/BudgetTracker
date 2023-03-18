import 'package:budget_tracker/models/expense_Item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:budget_tracker/data/expense_data.dart';

class AddTab extends StatefulWidget {
  const AddTab({super.key});

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();
  void addNewExpense(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Pridekite islaida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
          //expense name
          TextField(
            controller: newExpenseNameController,
          ),

          //expense amount
          TextField(
            controller: newExpenseAmountController,
          ),
        ],),
        actions:[
          //save button
          MaterialButton(
            onPressed: save,
            child: Text ('Issaugoti'),
          ),
          // cancel button
          MaterialButton(
            onPressed: cancel,
            child: Text ('Atmesti'),
          ),
        ],
      ),
      );
  }

  //save
  void save(){
    // ExpenseItem newExpense = ExpenseItem(
    //   name: newExpenseNameController.text, 
    //   amount: newExpenseAmountController.text, 
    //   dateTime: DateTime.now(),
    //   );
    // Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);
  }
  //cancel
  void cancel(){

  }

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(  
      home: Scaffold(  
          body: Center(child: Row(children: <Widget>[
            //Opens expenses page  
            Container(  
              //alignment: Alignment.bottomRight,
              margin: EdgeInsets.all(25),  
              child: OutlinedButton(  
                child: Text('Expenses', style: TextStyle(fontSize: 20.0),),
                onPressed: addNewExpense,  
              ),  
            ),  
            //Opens Income page
            Container( 
              //alignment: Alignment.centerRight, 
              margin: EdgeInsets.all(25),  
              child: OutlinedButton(  
                child: Text('Income', style: TextStyle(fontSize: 20.0),),    
                onPressed: () {},  
              ),  
            ),  
          ]  
         ))  
      ),  
    );  
  }
}