import 'dart:ffi';

import 'package:budget_tracker/controllers/db_helper.dart';
import 'package:budget_tracker/data/income_expense_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';


class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DbHelper dbHelper = DbHelper();
  double totalBalance = 0;
  

  getTotalBalance(Map entireData){
    totalBalance = 0;
    entireData.forEach((key, value) {
      if (value['type'] == "Income"){
        totalBalance += (value['amount'] as double);
      } else{
        totalBalance -= (value['amount'] as double);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map>(
        future: dbHelper.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            return const Center(child: Text("Unexpected Error !"),);
          }
          if (snapshot.hasData){
            getTotalBalance(snapshot.data!);
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
          }else {
            return const Center(
              child: Text("Unexpected Error !"),
            );
          }
        
        },
      ),
    );
  }
}