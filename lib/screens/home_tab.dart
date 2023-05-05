import 'package:budget_tracker/controllers/db_helper.dart';
import 'package:budget_tracker/data/income_expense_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DbHelper dbHelper = DbHelper();
  double totalBalance = 0;
  double totalExpenses = 0;
  //current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: 
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(uid).doc('income_expense').collection('income_expense').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final userSnapshot = snapshot.data?.docs;
                  double tempBalance = 0;
                  double tempExpense = 0;
                  //gets todays date
                  var todaysDate = DateTime.now();
                  //formats it into months
                  final todaysMonth = formatDate(todaysDate, [mm]);
                  if (userSnapshot!.isNotEmpty) {
                    for (var doc in userSnapshot) {
                      //gets date from document
                      var date = doc["dateTime"].toDate();
                      final month = formatDate(date, [mm]);
                      //checks if data from document is from this month
                      if(doc["type"] == 'Income' && month == todaysMonth){
                        tempBalance += double.parse(doc["amount"]);
                      }
                      else if(doc["type"] == 'Expense' && month == todaysMonth){
                        tempBalance -= double.parse(doc["amount"]);
                        tempExpense += double.parse(doc["amount"]);
                      }
                    }
                  }
                  totalBalance = tempBalance;
                  totalExpenses = tempExpense;
                  return ListView(
                    children:[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Container(                          
                                decoration: BoxDecoration(
                                  color: globals.selectedWidgetColor,
                                  borderRadius: BorderRadius.circular(70),
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.brown, style: BorderStyle.solid,
                                  )
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'BALANSAS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        color: Colors.green,
                                        letterSpacing: 1.5,   
                                        fontWeight: FontWeight.bold                   
                                      ),
                                    ),
                                    Text(
                                        '$totalBalance \$',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                        fontSize: 26.0,
                                        color: Colors.green,
                                      ),
                                    ),           
                                  ],
                                ),
                              ),
                            ),
                          ),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: globals.selectedWidgetColor,
                                    borderRadius: BorderRadius.circular(70),
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.brown, style: BorderStyle.solid,
                                    )
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 8.0,
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'IŠLEISTA',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.redAccent,
                                          letterSpacing: 1.5,      
                                          fontWeight: FontWeight.bold                
                                        ),
                                      ),
                                      Text(
                                          '$totalExpenses \$',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                          fontSize: 26.0,
                                          color: Colors.redAccent,
                                        ),
                                      ),           
                                    ],
                                  ),
                                ),
                              ),
                            ),

                        ],
                      ),
                    ]
                  );



                }
              ),
              
    ),
        ],
      )
    );
  }
}