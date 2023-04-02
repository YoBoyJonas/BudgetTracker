import 'package:budget_tracker/components/expense_tile.dart';
import 'package:budget_tracker/controllers/db_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:budget_tracker/data/income_expense_data.dart';
import 'package:provider/provider.dart';

class AddTab extends StatefulWidget {
  const AddTab({super.key});

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();

  final newIncomeNameController = TextEditingController();
  final newIncomeAmountController = TextEditingController();

  void addNewExpense(String mainText){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(mainText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
          //expense name
          TextField(
            controller: newExpenseNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),               
              ),
              labelText: 'Kategorija'
            ),
          ),

          const Padding(padding: EdgeInsets.all(6.0)),
          //expense amount
          TextField(
            controller: newExpenseAmountController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              labelText: 'Kaina'
            ),
          ),
        ],),
        actions:[
          //save button
          MaterialButton(
            onPressed: save,
            child: const Text ('Išsaugoti'),
          ),
          // cancel button
          MaterialButton(
            onPressed: cancel,
            child: const Text ('Atmesti'),
          ),
        ],
      ),
      );
  }

  //save
  void save(){
    ExpenseItem newExpense = ExpenseItem (
      name: newExpenseNameController.text,
      amount: newExpenseAmountController.text,
      dateTime: DateTime.now(),
      type: 'Expense',
    );
    //adds expense to firestore database
    createExpense(item: newExpense);

    if (double.parse(newExpenseAmountController.text) >= 0)
    {
      DbHelper dbHelper = DbHelper();
      dbHelper.addData(double.parse(newExpenseAmountController.text), 'Expense');
    }

    Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);

    Navigator.pop(context);
    clear();
  }


  void addNewIncome(String mainText){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(mainText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [       
          //income name
          TextField(
            controller: newIncomeNameController,
              decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              labelText: 'Kategorija'
            ),
          ),

          const Padding(padding: EdgeInsets.all(6.0)),

          //income amount
          TextField(
            controller: newIncomeAmountController,
              decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              labelText: 'Gautos pajamos'
            ),
          ),
        ],),
        actions:[
          //save button
          MaterialButton(
            onPressed: saveIncome, 
            child: const Text ('Išsaugoti'),          
          ),
          // cancel button
          MaterialButton(
            onPressed: cancelIncome,
            child: const Text ('Atmesti'),
          ),
        ],
      ),
      );
  }

  void saveIncome() 
  {
    ExpenseItem newIncome = ExpenseItem (
      name: newIncomeNameController.text,
      amount: newIncomeAmountController.text,
      dateTime: DateTime.now(),
      type: 'Income'
    );
    //adds income to firestore database
    createExpense(item: newIncome);
    if (double.parse(newIncomeAmountController.text) >= 0)
    {
      DbHelper dbHelper = DbHelper();
       dbHelper.addData(double.parse(newIncomeAmountController.text), 'Income');      
    }
    
    Provider.of<ExpenseData>(context, listen: false).addNewExpense(newIncome);
    Navigator.pop(context);
    
    clearIncomeControllers();
  }

  //cancel
  void cancel(){

    Navigator.pop(context);
    clear();
  }

  void clear()
  {
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
  }

  void cancelIncome(){

    Navigator.pop(context);
    clearIncomeControllers();
  }

  void clearIncomeControllers()
  {
    newIncomeNameController.clear();
    newIncomeAmountController.clear();
  }


  @override
  Widget build(BuildContext context) {  
    return Consumer<ExpenseData>(  
        builder:(context, valueExpense, child) => Scaffold(         
          body: Column(
            children:[
              Expanded(
                child:  ListView.builder(
                  itemCount: valueExpense.getAllExpenseList().length,
                  itemBuilder: (context, index) => ExpenseTile(
                    name: valueExpense.getAllExpenseList()[index].name,
                    amount: valueExpense.getAllExpenseList()[index].amount, 
                    dateTime: valueExpense.getAllExpenseList()[index].dateTime,
                    type: valueExpense.getAllExpenseList()[index].type)             
                ), 
              ),


              Center(child: Row(children: <Widget>[
                //Opens expenses page  
                Container(  
                  //alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(25),
                  width: 120,
                  height: 60,  
                  child: OutlinedButton(
                    onPressed: () => addNewExpense('Pridėkite išlaidą'), 
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      side: const BorderSide(color: Colors.brown, style: BorderStyle.solid, width: 3),
                      backgroundColor: const Color.fromARGB(248, 226, 214, 192)               
                    ),                   
                    child: const Text('Išlaidos', style: TextStyle(fontSize: 20.0,color: Colors.red, fontWeight: FontWeight.bold)),
                  ),  
                ),

              const Spacer(),
              
              //Opens Income page 
                Container( 
                  //alignment: Alignment.centerRight, 
                  margin: const EdgeInsets.all(25),
                  width: 120,
                  height: 60,
                     
                  child: OutlinedButton(  
                    onPressed: () => addNewIncome('Pridėkite pinigus'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      side: const BorderSide(color: Colors.brown, style: BorderStyle.solid, width: 3),
                      backgroundColor: const Color.fromARGB(248, 226, 214, 192)                       
                    ),  
                    child: const Text('Pajamos', style: TextStyle(fontSize: 20.0, color: Colors.green, fontWeight: FontWeight.bold),),      
                  ),  
                ),
             ], 
             )),
            ]
          )
    ) 
     
    ); 
  }

  //adds expense to firestore database
  Future createExpense({required ExpenseItem item}) async {
    
    final docLedger = FirebaseFirestore.instance.collection('income_expense').doc();
   
    final json = {
      'name': item.name,
      'amount': item.amount,
      'dateTime': item.dateTime,
      'type': item.type
    };

    await docLedger.set(json);
  }
}