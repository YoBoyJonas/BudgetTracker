import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:budget_tracker/Bar graph/bar_graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_format/date_format.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreen();
}

class _StatisticsScreen extends State<StatisticsScreen> {
  //current users UID
  final uid = FirebaseAuth.instance.currentUser!.uid;

  List<double> summary = [
     0,
     0,
     0,
     0,
     0,
     0,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(uid).doc('Amounts').collection('Expenses').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final userSnapshot = snapshot.data?.docs;

                  if (userSnapshot!.isNotEmpty) {
                    for(int i = 0; i < 6; i++){
                      var currDate = DateTime.now();
                      var d = Jiffy(currDate).subtract(months: i).dateTime;
                      final today = formatDate(d, [yyyy, mm]);
                      String docName = '${today}Expense';
                      for (var doc in userSnapshot) {
                        if(doc.id == docName){
                          double bal = double.parse(doc.get('Balance').toString());
                          summary[i] = bal;
                        }
                      }
                    }
                  }
        return Center(
          child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.93,
          child: MyBarGraph(weeklySummary: summary,)
          ),
          );
        }
      ),
    );
  }

}


