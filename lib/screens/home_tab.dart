import 'dart:ffi';
import 'package:budget_tracker/controllers/db_helper.dart';
import 'package:budget_tracker/data/income_expense_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DbHelper dbHelper = DbHelper();
  double totalBalance = 0;
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
                      }
                    }
                  }
                  totalBalance = tempBalance;
                  return ListView(
                    children:[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: const EdgeInsets.all(
                            12.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(70),
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
                                    color: Colors.yellowAccent,
                                    letterSpacing: 1.5,                      
                                  ),
                                ),
                                Text(
                                    '$totalBalance \$',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                    fontSize: 26.0,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                
                                
                      
                              ],
                            ),
                          ),
                        ),
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