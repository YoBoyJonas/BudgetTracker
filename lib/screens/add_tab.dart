import 'package:budget_tracker/components/expense_tile.dart';
import 'package:budget_tracker/models/expense_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget_tracker/data/income_expense_data.dart';
import 'package:provider/provider.dart';
import 'package:date_format/date_format.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;
import 'package:isoweek/isoweek.dart';

import '../background_provider.dart';

class AddTab extends StatefulWidget {
  const AddTab({Key? key}) : super(key: key);

  @override
  State<AddTab> createState() => _AddTabState();
}

class _AddTabState extends State<AddTab> {
  String selectedCategory = "0";
  //current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime todaysDate = DateTime.now();

  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
    final GlobalKey<FormFieldState> formFieldKey2 = GlobalKey();

  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();

  final newIncomeNameController = TextEditingController();
  final newIncomeAmountController = TextEditingController();

  Future<void> addNewExpense(String mainText) async{
    showDialog(
      barrierDismissible: false,
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
                  width: MediaQuery.of(context).size.width * 0.42,
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
          
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          
                Flexible(child: Container(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('${formatDate(todaysDate, [yyyy, mm])}income_expense').snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> expenseItems = [];
      
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        } else {
                          final categories = snapshot.data?.docs.reversed.toList();
                                
                          for (var category in categories!) {
                            if (category['type'] == "Expense") {
                              bool isCategoryExists = false;
                              for (var expense in expenseItems) {
                                if ((expense.child as Text).data!.toLowerCase() == category['name'].toLowerCase()
                                  && (expense.child as Text).data!.toLowerCase() !="category") {
                                  isCategoryExists = true;
                                  break;
                                }
                              }
                              if (!isCategoryExists) {
                                var nameText = category['name'].toString().toUpperCase();
                                expenseItems.add(DropdownMenuItem(
                                  value: category.id,
                                  child: Text(nameText),
                                ));
      
                                // Add unique category to 'Expense_Categories' collection
                                FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').where('category',
                                  isEqualTo: category['name']).get().then((value) {
                                  if (value.size == 0) {
                                    FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').add({
                                      'category': category['name'],
                                      'status': 'Active'                                    
                                      });
                                  }
                                });
                              }
                            }
                          }
                        }                   
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const CircularProgressIndicator();
      
                            var categoryDocs = snapshot.data!.docs;
                            var expenseItems = [      const DropdownMenuItem(value: "0", child: Text("Kategorija"))    ];
                            for (var i = 0; i < categoryDocs.length; i++) {
                              var category = categoryDocs[i];
                              if (category['status'] == 'Active'){
                                expenseItems.add(DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category['category'], style: const TextStyle(color: Colors.red, letterSpacing: 0.25, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2,),
                                ));
                              }
                            }
      
                            return DropdownButton(
                              items: expenseItems, 
                              onChanged: (categoryValue) async {
                                globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                if (categoryValue == "0") {
                                  newExpenseNameController.text = "";
                                }
      
                                var categoryDoc = await FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').doc(categoryValue).get();
                                if (categoryDoc.exists) {
                                  var categoryName = categoryDoc.data()!['category'].toUpperCase();
                                  newExpenseNameController.text = categoryName;
                                }
      
                                setState(() {
                                selectedCategory = categoryValue!;
                                });
                              },
                              
                              value: selectedCategory,
                              isExpanded: true,
                            );
                          },
                        );
                      },
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
                onPressed: () async {
                  await save();
                  calculateMaxExpense();
                  globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                },
                child: const Text ('Išsaugoti'),
              ),
              // cancel button
              MaterialButton(
                onPressed: () {
                  cancel();
                  globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                },
                child: const Text ('Atmesti'),
              ),       
            ],
            );
        })
      );
  }

  
  //save
 Future<void> save()async {
    if (formFieldKey.currentState!.validate() && formFieldKey2.currentState!.validate()) {
      ExpenseItem newExpense = ExpenseItem (
      name: newExpenseNameController.text.toUpperCase(),
      amount: newExpenseAmountController.text,
      dateTime: DateTime.now(),
      type: 'Expense',
    );

    Provider.of<ExpenseData>(context, listen: false).addNewExpense(newExpense);

    Navigator.pop(context);
    //adds expense to firestore database
    await createExpense(item: newExpense);
    clear();
    }
  }

  

  void addNewIncome(String mainText){
    showDialog(
      barrierDismissible: false,
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
                    width: MediaQuery.of(context).size.width * 0.42,
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

                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),

                  Flexible(child: Container(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('${formatDate(todaysDate, [yyyy, mm])}income_expense').snapshots(),
                          builder: (context, snapshot) {
                            List<DropdownMenuItem> incomeItems = [];
          
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            } else {
                              final categories = snapshot.data?.docs.reversed.toList();
                                    
                              for (var category in categories!) {
                                if (category['type'] == "Income") {
                                  bool isCategoryExists = false;
                                  for (var income in incomeItems) {
                                    if ((income.child as Text).data!.toLowerCase() == category['name'].toLowerCase()
                                     && (income.child as Text).data!.toLowerCase() !="category") {
                                      isCategoryExists = true;
                                      break;
                                    }
                                  }
                                  if (!isCategoryExists) {
                                    var nameText = category['name'].toString().toUpperCase();
                                    incomeItems.add(DropdownMenuItem(
                                      value: category.id,
                                      child: Text(nameText),
                                    ));
          
                                    // Add unique category to 'Income_Categories' collection
                                    FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').where('category',
                                      isEqualTo: category['name']).get().then((value) {
                                      if (value.size == 0) {
                                        FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').add({
                                          'category': category['name'],
                                          'status' : 'Active'                              
                                          });
                                      }
                                    });
                                  }
                                }
                              }
                            }                   
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const CircularProgressIndicator();
          
                                var categoryDocs = snapshot.data!.docs;
                                var incomeItems = [      const DropdownMenuItem(value: "0", child: Text("Kategorija"))    ];
                                for (var i = 0; i < categoryDocs.length; i++) {
                                  var category = categoryDocs[i];
                                  if (category['status'] == 'Active'){
                                    incomeItems.add(DropdownMenuItem(
                                      value: category.id,
                                      child: Text(category['category'], style: const TextStyle(color: Colors.green, letterSpacing: 0.25, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
                                    ));
                                  }
                                }
          
                                return DropdownButton(
                                  items: incomeItems, 
                                  onChanged: (categoryValue) async {
                                    globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                                    if (categoryValue == "0") {
                                      newIncomeNameController.text = "";
                                    }
          
                                    var categoryDoc = await FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').doc(categoryValue).get();
                                    if (categoryDoc.exists) {
                                      var categoryName = categoryDoc.data()!['category'].toUpperCase();
                                      newIncomeNameController.text = categoryName;
                                    }
          
                                    setState(() {
                                    selectedCategory = categoryValue!;
                                    });
                                  },
                                  value: selectedCategory,
                                  isExpanded: true,
                                );
                              },
                            );
                            
                          },
                        ),
                      ),
                    )),
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
                onPressed: () {
                  saveIncome();
                  globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                }, 
                child: const Text ('Išsaugoti'),          
              ),
              // cancel button
              MaterialButton(
                onPressed: () {
                  cancelIncome();
                  globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                },
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

      
      Provider.of<ExpenseData>(context, listen: false).addNewIncome(newIncome);
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
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final backgroundImage = backgroundProvider.backgroundImage;
    return MaterialApp(
      home: Stack(
        children: [
          if (backgroundImage != null)  
          Container(
            decoration: BoxDecoration(
            image: DecorationImage(image: backgroundImage!, fit: BoxFit.cover)
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: Consumer<ExpenseData>(  
        builder:(context, valueExpense, child) => Scaffold(   
          backgroundColor: Colors.transparent,      
          body: FutureBuilder<bool>(
            future: getInterval(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                if(snapshot.data == true){
                  return Column(
                children:[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('${formatDate(todaysDate, [yyyy, mm])}income_expense').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final userSnapshot = snapshot.data?.docs;
          
                      return FutureBuilder<Object>(
                        future: getCurrencySign(),
                        builder: (context, snapshot2) {
                          if(snapshot2.hasData){
                          return Expanded ( child: Container(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical, 
                                itemCount: userSnapshot?.length,
                                itemBuilder: (context, index) => Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: ExpenseTile(
                                    name: userSnapshot![index]["name"],
                                    amount: userSnapshot[index]["amount"], 
                                    dateTime: userSnapshot[index]["dateTime"].toDate(),
                                    type: userSnapshot[index]["type"],
                                    currencySign: snapshot2.data!.toString(),
                                    ),
                                ), ),
                          ),
                          );
                          } else {
                            return Expanded ( child: Container(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical, 
                                itemCount: userSnapshot?.length,
                                itemBuilder: (context, index) => Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: ExpenseTile(
                                    name: userSnapshot![index]["name"],
                                    amount: userSnapshot[index]["amount"], 
                                    dateTime: userSnapshot[index]["dateTime"].toDate(),
                                    type: userSnapshot[index]["type"],
                                    currencySign: '\$',
                                    ),
                                ), ),
                          ),
                          );
                          }
                        }
                      );
                    }
                  ),
          
                  Center(child: Row(children: <Widget>[
                    //Opens expenses page  
                    Container(  
                      //alignment: Alignment.bottomRight,
                      margin: const EdgeInsets.all(25),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: OutlinedButton(
                        onPressed: () { 
                          globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                          addNewExpense('Pridėkite išlaidą');
                        }, 
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
                          side: BorderSide(color: Colors.brown, style: BorderStyle.solid, width: MediaQuery.of(context).size.width * 0.007),
                          backgroundColor: globals.selectedWidgetColor          
                        ),                   
                        child: const Text('Išlaidos', style: TextStyle(fontSize: 20.0,color: Colors.red, fontWeight: FontWeight.bold)),
                      ),  
                    ),
          
                  const Spacer(),
                  
                  //Opens Income page 
                    Container( 
                      //alignment: Alignment.centerRight, 
                      margin: const EdgeInsets.all(25),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.15,             
                      child: OutlinedButton(  
                        onPressed: () {
                          globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                          addNewIncome('Pridėkite pinigus');
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
                          side: BorderSide(color: Colors.brown, style: BorderStyle.solid, width: MediaQuery.of(context).size.width * 0.007),
                          backgroundColor: globals.selectedWidgetColor                     
                        ),  
                        child: const Text('Pajamos', style: TextStyle(fontSize: 20.0, color: Colors.green, fontWeight: FontWeight.bold),),      
                      ),  
                    ),
                 ], 
                 )),
                ]
              );
            }
                
                else{
                  Week currentWeek = Week.current(); 
                  Week weekFromIso = Week.fromISOString(currentWeek.toString());
                  return Column(
                children:[
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('${weekFromIso}income_expense').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      final userSnapshot = snapshot.data?.docs;
          
                      return FutureBuilder<Object>(
                        future: getCurrencySign(),
                        builder: (context, snapshot2) {
                          if(snapshot2.hasData){
                          return Expanded ( child: Container(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical, 
                                itemCount: userSnapshot?.length,
                                itemBuilder: (context, index) => Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: ExpenseTile(
                                    name: userSnapshot![index]["name"],
                                    amount: userSnapshot[index]["amount"], 
                                    dateTime: userSnapshot[index]["dateTime"].toDate(),
                                    type: userSnapshot[index]["type"],
                                    currencySign: snapshot2.data!.toString(),
                                    ),
                                ), ),
                          ),
                          );
                          } else {
                            return Expanded ( child: Container(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical, 
                                itemCount: userSnapshot?.length,
                                itemBuilder: (context, index) => Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: ExpenseTile(
                                    name: userSnapshot![index]["name"],
                                    amount: userSnapshot[index]["amount"], 
                                    dateTime: userSnapshot[index]["dateTime"].toDate(),
                                    type: userSnapshot[index]["type"],
                                    currencySign: '\$',
                                    ),
                                ), ),
                          ),
                          );
                          }
                        }
                      );
                    }
                  ),
          
                  Center(child: Row(children: <Widget>[
                    //Opens expenses page  
                    Container(  
                      //alignment: Alignment.bottomRight,
                      margin: const EdgeInsets.all(25),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: OutlinedButton(
                        onPressed: () { 
                          globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                          addNewExpense('Pridėkite išlaidą');
                        }, 
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
                          side: BorderSide(color: Colors.brown, style: BorderStyle.solid, width: MediaQuery.of(context).size.width * 0.007),
                          backgroundColor: globals.selectedWidgetColor          
                        ),                   
                        child: const Text('Išlaidos', style: TextStyle(fontSize: 20.0,color: Colors.red, fontWeight: FontWeight.bold)),
                      ),  
                    ),
          
                  const Spacer(),
                  
                  //Opens Income page 
                    Container( 
                      //alignment: Alignment.centerRight, 
                      margin: const EdgeInsets.all(25),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.15,             
                      child: OutlinedButton(  
                        onPressed: () {
                          globals.audioPlayer.playSoundEffect(globals.SoundEffect.buttonClick);
                          addNewIncome('Pridėkite pinigus');
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
                          side: BorderSide(color: Colors.brown, style: BorderStyle.solid, width: MediaQuery.of(context).size.width * 0.007),
                          backgroundColor: globals.selectedWidgetColor                     
                        ),  
                        child: const Text('Pajamos', style: TextStyle(fontSize: 20.0, color: Colors.green, fontWeight: FontWeight.bold),),      
                      ),  
                    ),
                 ], 
                 )),
                ]
              );
            
                }
              }
              else{
                return const CircularProgressIndicator();
              }
}
          )
    ) 
     
    )
          ),
        ],),
    );
  }

  //adds expense to firestore database
  Future createExpense({required ExpenseItem item}) async {
    //gets todays date
    var todaysDate = DateTime.now();
    //formats it into months
    final today = formatDate(todaysDate, [yyyy, mm]);
    //gets current week
    Week currentWeek = Week.current(); 
    Week weekFromIso = Week.fromISOString(currentWeek.toString());
    //monthly
    final docLedger = FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('$today''income_expense').doc();
    final balance = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Balances').doc('$today''Balance');
    final expenseBalance = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''Expense');
    final expenseBalanceSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''Expense').get();
    final balanceSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Balances').doc('$today''Balance').get();
    //-----------
    //weekly 
    final weeklyDocLedger = FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('$weekFromIso''income_expense').doc();
    final weeklyBalance = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Balances').doc('$weekFromIso''Balance');
    final weeklyExpenseBalance = FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$weekFromIso''Expense');
    final weeklyExpenseBalanceSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$weekFromIso''Expense').get();
    final weeklyBalanceSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Balances').doc('$weekFromIso''Balance').get();
    //-----------

    final json = {
      'name': item.name,
      'amount': item.amount,
      'dateTime': item.dateTime,
      'type': item.type
    };


    if(item.type == 'Expense'){
      //adds to monthly catalogs
      if(expenseBalanceSnapshot.exists)
      {
        Map<String, dynamic> data = expenseBalanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal += double.parse(item.amount);
        expenseBalance.update({'Balance' : bal });
      }
      else
      {
        double bal = double.parse(item.amount);
        expenseBalance.set({'Balance' : bal });
      }
      if(balanceSnapshot.exists)
      {
        Map<String, dynamic> data = balanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal -= double.parse(item.amount);
        balance.update({'Balance' : bal });
      }
      else
      {
        double bal =  0 - double.parse(item.amount);
        balance.set({'Balance' : bal });
      }
      //adds to weekly catalogs
      if(weeklyExpenseBalanceSnapshot.exists)
      {
        Map<String, dynamic> data = weeklyExpenseBalanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal += double.parse(item.amount);
        weeklyExpenseBalance.update({'Balance' : bal });
      }
      else
      {
        double bal = double.parse(item.amount);
        weeklyExpenseBalance.set({'Balance' : bal });
      }
      if(weeklyBalanceSnapshot.exists)
      {
        Map<String, dynamic> data = weeklyBalanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal -= double.parse(item.amount);
        weeklyBalance.update({'Balance' : bal });
      }
      else
      {
        double bal =  0 - double.parse(item.amount);
        weeklyBalance.set({'Balance' : bal });
      }
    }
    else
    {
      //adds to monthly catalogs
      if(balanceSnapshot.exists)
      {
        Map<String, dynamic> data = balanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal += double.parse(item.amount);
        balance.update({'Balance' : bal });
      }
      else
      {
        double bal = double.parse(item.amount);
        balance.set({'Balance' : bal });
      }
      //adds to weekly catalogs
      if(weeklyBalanceSnapshot.exists)
      {
        Map<String, dynamic> data = weeklyBalanceSnapshot.data()!;
        double bal = double.parse(data['Balance'].toString());
        bal += double.parse(item.amount);
        weeklyBalance.update({'Balance' : bal });
      }
      else
      {
        double bal = double.parse(item.amount);
        weeklyBalance.set({'Balance' : bal });
      }
    }
    await docLedger.set(json);
    await weeklyDocLedger.set(json);
  }

    Future createIncomeCategories({required String item}) async {
    
    final docLedger = FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Income_Categories').doc();
   
    final json = {
      'category': item,
    };

    await docLedger.set(json);
  }

      Future createExpenseCategories({required String item}) async {
    
    final docLedger = FirebaseFirestore.instance.collection(uid).doc('Categories').collection('Expense_Categories').doc();

    final json = {
      'category': item,
    };

    await docLedger.set(json);
  }
    Future<bool> getInterval() async{
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      String bal = data['monthly'].toString();
      if(bal == 'true' || bal == 'false'){
        //print("pirmas ifas");
        return bal == 'true';
      }
      else{
        //print("pirmas elsas");
        FirebaseFirestore.instance.collection(uid).doc('Settings').set({'monthly' : true});
        return true; 
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'monthly' : true});
      return true;
    }
  }
}

Future<void> calculateMaxExpense() async{
  final uid = FirebaseAuth.instance.currentUser!.uid;
   //weekly stuff
   Week currentWeek = Week.current(); 
  Week weekFromIso = Week.fromISOString(currentWeek.toString());
   final weeklySnapshot = await FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('${weekFromIso}income_expense').get();
   final weeklyDocList = weeklySnapshot.docs;
   final weeklyNameToTotalAmount = <String, double>{};
   //------------
    final snapshot = await FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('202305income_expense').get();
    final docList = snapshot.docs;
    final nameToTotalAmount = <String, double>{};
    var todaysDate = DateTime.now();
    final today = formatDate(todaysDate, [yyyy, mm]);

    //reset the old value (needs to be here because of removes of elements)
    final maxExpenseBalanceReset = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense').get();
    if (maxExpenseBalanceReset.exists) {
      await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense').update({'Amount': 0});
    }
 
    if (docList.isEmpty){
      await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense')
            .set({'Name' : 0, 'Amount' : 0});
      return;
    }
    for (final doc in docList)
    {
      final type = doc.data()['type'] as String;
      if (type == 'Expense')
      {
        final name = doc.data()['name'] as String;
        final amount = double.parse(doc.data()['amount']);

        if (nameToTotalAmount.containsKey(name) && type == 'Expense') {
          nameToTotalAmount[name] = (nameToTotalAmount[name]! + amount);
        } else if (!nameToTotalAmount.containsKey(name) && type == 'Expense'){
          nameToTotalAmount[name] = amount;
        }

        final maxExpenseName = nameToTotalAmount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final maxExpenseAmount = nameToTotalAmount.values.reduce((a, b) => a > b ? a : b);

        final maxExpenseBalanceDoc = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense').get();

        if (!maxExpenseBalanceDoc.exists) {
          await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense')
            .set({'Name' : maxExpenseName, 'Amount' : maxExpenseAmount});
        } else {
          final existingAmount = maxExpenseBalanceDoc.data()!['Amount'];
          if (maxExpenseAmount > existingAmount){
            await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('$today''MaxExpense')
              .update({'Name' : maxExpenseName, 'Amount' : maxExpenseAmount});
          }
        }
        }
        
    }     
    //weekly stuff
    if (weeklyDocList.isEmpty){
      await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense')
            .set({'Name' : 0, 'Amount' : 0});
      return;
    }
    for (final doc in weeklyDocList)
    {
      final type = doc.data()['type'] as String;
      if (type == 'Expense')
      {
        final name = doc.data()['name'] as String;
        final amount = double.parse(doc.data()['amount']);

        if (weeklyNameToTotalAmount.containsKey(name) && type == 'Expense') {
          weeklyNameToTotalAmount[name] = (weeklyNameToTotalAmount[name]! + amount);
        } else if (!weeklyNameToTotalAmount.containsKey(name) && type == 'Expense'){
          weeklyNameToTotalAmount[name] = amount;
        }

        final maxExpenseName = weeklyNameToTotalAmount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final maxExpenseAmount = weeklyNameToTotalAmount.values.reduce((a, b) => a > b ? a : b);

        final maxExpenseBalanceDoc = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense').get();

        if (!maxExpenseBalanceDoc.exists) {
          await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense')
            .set({'Name' : maxExpenseName, 'Amount' : maxExpenseAmount});
        } else {
          final existingAmount = maxExpenseBalanceDoc.data()!['Amount'];
          if (maxExpenseAmount > existingAmount){
            await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('${weekFromIso}MaxExpense')
              .update({'Name' : maxExpenseName, 'Amount' : maxExpenseAmount});
          }
        }
        }
        
    }   
    //------------------
  }
  Future<String> getCurrencySign() async{
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final settingsSnapshot = await FirebaseFirestore.instance.collection(uid).doc('Settings').get();
    if (settingsSnapshot.exists) {
      Map<String, dynamic> data = settingsSnapshot.data()!;
      if (data.containsKey('currency_sign')) {
        String bal = data['currency_sign'].toString();
        return bal;
      } else {
        // The 'currency_sign' field does not exist, so set the value
        await FirebaseFirestore.instance
          .collection(uid)
          .doc('Settings')
          .update({'currency_sign' : '\$'});
        return '\$';
      }
    }
    else
    {
      FirebaseFirestore.instance.collection(uid).doc('Settings').set({'currency_sign' : '\$'});
      return '\$';
    }
  }