import 'dart:ffi';

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
  double totalBalance = 0;
  double totalExpenses = 0;
  //current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;
  //gets todays date
  DateTime todaysDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          Scaffold(
              appBar: AppBar(
                title: FutureBuilder<String>(
                  future: getUserNickName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return Text(
                        'Labas, ${snapshot.data}!',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.blue,
                            decoration: TextDecoration.none,
                          ),
                        );
                    }
                  }
                ),
                flexibleSpace: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green,
                        globals.selectedWidgetColor,
                        globals.selectedWidgetColor,
                        Colors.red,
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      tileMode: TileMode.clamp,
                    ),
                    border: const Border(
                      bottom: BorderSide(
                        color: Colors.brown,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: 
            FutureBuilder(
                future: Future.wait([
                  getMonthData(formatDate(todaysDate.subtract(Duration(days: 30)), [yyyy, mm])),
                  getMonthData(formatDate(todaysDate, [yyyy, mm])),
                ]),
                builder: (context, AsyncSnapshot<List<Map<String, double>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  
                  double previousMonthBalance = snapshot.data![0]['balance']!;
                  double currentMonthBalance = snapshot.data![1]['balance']!;
                  double currentMonthExpense = snapshot.data![1]['expense']!;

                  if (globals.carryOverSurplusMoney && previousMonthBalance > 0){
                    totalBalance = previousMonthBalance + currentMonthBalance;
                  } else {
                    totalBalance = currentMonthBalance;
                  }
                  totalExpenses = currentMonthExpense;


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
                                width: MediaQuery.of(context).size.width * 0.44,
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

          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.6), 
            child: 
              Container(
                decoration: BoxDecoration(
                  color: globals.selectedWidgetColor,
                  borderRadius: const BorderRadius.vertical(),
                    border: Border.all(
                      width: 3,
                      color: Colors.brown, style: BorderStyle.solid,
                    )
                  ),
                child: Column(
                  children: [     
                    Row(
                      children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text('PRIMINTUKAS', style: TextStyle(color: Colors.blue, letterSpacing: 2, fontSize: 26, fontWeight: FontWeight.bold, decoration: TextDecoration.none))
                            ),
                          ),
                      ],
                    ),

                    Container(padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.03)),
                    Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Text("Daugiausiai išleidai ant ", 
                                style: TextStyle(color: Colors.lightBlue, letterSpacing: 1.5, fontSize: 16, decoration: TextDecoration.none)                             
                                ),
                              ),
                            ),
                          ] 
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.bottomRight,
                                  child: FutureBuilder<String>(
                                        future: getMaxName(),
                                        builder: (context, snapshot){
                                          if (snapshot.hasData) {
                                            return Text(
                                              '${snapshot.data!} ',
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                letterSpacing: 1.5,
                                                fontSize: 17,
                                                decoration: TextDecoration.none,
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Text(
                                            "Duomenų ",
                                            style: TextStyle(
                                              color: Colors.red,
                                              letterSpacing: 1.5,
                                              fontSize: 16,
                                              decoration: TextDecoration.none,
                                            )
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                  ),
                                ),
                              ),
                              
                              Expanded(
                                child: FutureBuilder<double>(
                                  future: getMaxExpense(),
                                  builder: (context, snapshot){
                                    if (snapshot.hasData) {
                                      return Text(
                                        '${snapshot.data!.toString()}\$',
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          letterSpacing: 1.5,
                                          fontSize: 17,
                                          decoration: TextDecoration.none,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                        return const Text(
                                        "nerasta",
                                        style: TextStyle(
                                          color: Colors.red,
                                          letterSpacing: 1.5,
                                          fontSize: 16,
                                          decoration: TextDecoration.none,
                                        )
                                        );
                                      }
                                    return const SizedBox();
                                  },
                                ),
                              ),                
                            ],
                          ),
                        ),

                            
                      ],
                    )
                  ],
                )
              )
          )
        ],
      )
    );
  }

  Future<String> getUserNickName() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

    return result['nickName'] ?? 'User';
  }

  Future<Map<String, double>> getMonthData(String month) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(uid)
        .doc('income_expense')
        .collection(month + 'income_expense')
        .get();

    double tempBalance = 0;
    double tempExpense = 0;

    for (var doc in querySnapshot.docs) {
      if (doc["type"] == 'Income') {
        tempBalance += double.parse(doc["amount"]);
      } else if (doc["type"] == 'Expense') {
        tempBalance -= double.parse(doc["amount"]);
        tempExpense += double.parse(doc["amount"]);
      }
    }

    return {'balance': tempBalance, 'expense': tempExpense};
}

  Future<double> getMaxExpense() async{
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('202305MaxExpense').get();
    double maxBalance = element.data()!['Amount'];
    return maxBalance;
  }

  Future<String> getMaxName() async{
    final element = await FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').doc('202305MaxExpense').get();
    String maxName = element.data()!['Name'];
    return maxName;
  }
}