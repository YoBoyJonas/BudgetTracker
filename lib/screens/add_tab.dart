import 'package:budget_tracker/components/expense_tile.dart';
import 'package:budget_tracker/controllers/db_helper.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String selectedCategory = "0";

  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
    final GlobalKey<FormFieldState> formFieldKey2 = GlobalKey();

  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();

  final newIncomeNameController = TextEditingController();
  final newIncomeAmountController = TextEditingController();

  void addNewExpense(String mainText){
    showDialog(
      context: context, 
      builder: (context) => StatefulBuilder(
        builder: (context, setState){
          return AlertDialog(
                    title: Text(mainText),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          
          //expense name
          Row(
            children: [
              SizedBox(
                width: 170.0,
                child: TextFormField(
                  key: formFieldKey,
                  controller: newExpenseNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),               
                    ),
                    labelText: 'Kategorija'
                  ),
                  validator: (text){
                    if (text == null || text.isEmpty){
                      return 'Pasirinkite kategoriją';
                    }
                    return null;
                  },
                ),
              ),

            const SizedBox(width: 20),

                  Flexible(child: Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                  
                      child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('income_expense').snapshots(),
                  
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> expenseItems = [];
                  
                        if (!snapshot.hasData){
                          const CircularProgressIndicator();
                        }
                        else {
                          final categories = snapshot.data?.docs.reversed.toList();
                  
                          expenseItems.add(const DropdownMenuItem(
                            value: "0",
                            child: Text('Kategorija'),
                            ),
                          );

                          for (var category in categories!){                            
                              if (category['type'] == "Expense"){
                                int counter =0;
                                for(var expense in expenseItems){

                                  if ((expense.child as Text).data!.toLowerCase == category['name'].toLowerCase()){break;}
                                  else if ((expense.child as Text).data!.toLowerCase() != category['name'].toLowerCase()){counter++;}

                                  if (counter == expenseItems.length){
                                    var nameText = category['name'].toString().toUpperCase();
                                    expenseItems.add(DropdownMenuItem(
                                      value: category.id,
                                      child: Text(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        nameText,
                                        style: const TextStyle(color: Colors.red, letterSpacing: 0.25, fontWeight: FontWeight.bold, fontSize: 12),
                                      )                        
                                      )  
                                      );

                                      createExpenseCategories(item: nameText);
                                      break;
                                  }
                                }
                            }
                          }
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('expense_categories').snapshots(),
                  
                          builder: (context, snapshot){
                          return DropdownButton(
                          items: expenseItems,
                          onChanged: (categoryValue) async{
                            var collection = FirebaseFirestore.instance.collection('income_expense');
                            var docSnapshot = await collection.doc(categoryValue).get();
                            Map<String, dynamic>? data = docSnapshot.data();

                            if (categoryValue == "0"){
                              newExpenseNameController.text = "";
                            }
                            else{
                              newExpenseNameController.text = data?['name'].toUpperCase();
                            }

                            setState(() {
                              selectedCategory = categoryValue;
                            });
                        },
                        value: selectedCategory,
                        isExpanded: true,
                        );
                          }           
                      );
                        
                      }
                    ),
                    ),
                  )),
            ],

          ),

      
          const Padding(padding: EdgeInsets.all(6.0)),
          //expense amount
          TextFormField(
            key: formFieldKey2,
            controller: newExpenseAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              labelText: 'Kaina',
            ),

            validator: (text){
              if (text == null || text.isEmpty){
                return 'Įveskite sumą';
              }
              return null;
            },
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
          );
        })
      );
  }
  //save
  void save(){
    if (formFieldKey.currentState!.validate() && formFieldKey2.currentState!.validate()) {
      ExpenseItem newExpense = ExpenseItem (
      name: newExpenseNameController.text.toUpperCase(),
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
  }

  void addNewIncome(String mainText){
    showDialog(
      context: context, 
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(mainText),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [       
              //income name
              Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: TextFormField(
                      key: formFieldKey,
                      controller: newIncomeNameController,
                        decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        labelText: 'Kategorija',
                      ),
                  
                      validator: (text){
                        if (text == null || text.isEmpty){
                          return 'Pasirinkite kategoriją';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 20),

                  Flexible(child: Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('income_expense').snapshots(),
                  
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> incomeItems = [];
                  
                        if (!snapshot.hasData){
                          const CircularProgressIndicator();
                        }
                        else {
                          final categories = snapshot.data?.docs.reversed.toList();
                  
                          incomeItems.add(const DropdownMenuItem(
                            value: "0",
                            child: Text('Kategorija'),
                            ),
                          );

                          for (var category in categories!){                            
                              if (category['type'] == "Income"){
                                int counter =0;
                                for(var income in incomeItems){

                                  if ((income.child as Text).data!.toLowerCase == category['name'].toLowerCase()){break;}
                                  else if ((income.child as Text).data!.toLowerCase() != category['name'].toLowerCase()){counter++;}

                                  if (counter == incomeItems.length){
                                    var nameText = category['name'].toString().toUpperCase();
                                    incomeItems.add(DropdownMenuItem(      
                                      value: category.id,
                                      child: Text(      
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,                             
                                        nameText,
                                        style: const TextStyle(color: Colors.green, letterSpacing: 0.25, fontWeight: FontWeight.bold, fontSize: 12),
                                      )                        
                                      )  
                                      );

                                      createIncomeCategories(item: nameText);
                                      break;
                                  }
                                }
                            }
                          }
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('income_categories').snapshots(),
                  
                          builder: (context, snapshot){
                          return DropdownButton(
                          items: incomeItems,
                          onChanged: (categoryValue) async{
                            var collection = FirebaseFirestore.instance.collection('income_expense');
                            var docSnapshot = await collection.doc(categoryValue).get();
                            Map<String, dynamic>? data = docSnapshot.data();

                            if (categoryValue == "0"){
                              newIncomeNameController.text = "";
                            }
                            else{
                              newIncomeNameController.text = data?['name'].toUpperCase();
                            }

                            setState(() {
                              selectedCategory = categoryValue;
                            });
                        },
                        value: selectedCategory,
                        isExpanded: true,
                        );
                          }           
                      );
                        
                      }
                    ),
                    ),
                  ))
                ],     
              ),

              const Padding(padding: EdgeInsets.all(6.0)),

              TextFormField(
              key: formFieldKey2,
              controller: newIncomeAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                labelText: 'Gautos pajamos'
              ),
              
              validator: (text){
                if (text == null || text.isEmpty){
                  return 'Įveskite pajamas';
                }
                return null;
              },
              
              ),
              //income amount      
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
          );
        }
      ),
      );
  }

  void saveIncome() 
  {
    if (formFieldKey.currentState!.validate() && formFieldKey2.currentState!.validate()) {
      ExpenseItem newIncome = ExpenseItem (
        name: newIncomeNameController.text.toUpperCase(),
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
  }

  //cancel
  void cancel(){

    Navigator.pop(context);
    clear();
    selectedCategory = "0";
  }

  void clear()
  {
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
    selectedCategory = "0";
  }

  void cancelIncome(){

    Navigator.pop(context);
    clearIncomeControllers();
    selectedCategory = "0";
  }

  void clearIncomeControllers()
  {
    newIncomeNameController.clear();
    newIncomeAmountController.clear();
    selectedCategory = "0";
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

    Future createIncomeCategories({required String item}) async {
    
    final docLedger = FirebaseFirestore.instance.collection('income_categories').doc();
   
    final json = {
      'categories': item,
    };

    await docLedger.set(json);
  }

      Future createExpenseCategories({required String item}) async {
    
    final docLedger = FirebaseFirestore.instance.collection('expense_categories').doc();
   
    final json = {
      'categories': item,
    };

    await docLedger.set(json);
  }
}