import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_tracker/screens/add_tab.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker/globals/globals.dart' as globals;

class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  final String type;


  const ExpenseTile({
    super.key,
    required this.name,
    required this.amount,
    required this.dateTime,  
    required this.type,
    });

    
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: type == 'Income' ? globals.selectedWidgetColor : globals.selectedWidgetColor,
        borderRadius: BorderRadius.circular(70),
        border: Border.all(
          width: 2,
          color: type == 'Income' ? Colors.greenAccent : Colors.redAccent,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListTile(
              title: Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                name,
                style: TextStyle(color: type == 'Income' ? Colors.green : Colors.red,fontWeight: FontWeight.bold,letterSpacing: 1.5,fontSize: 20,),
              ),
              subtitle: Text(
                '${dateTime.day.toString().padLeft(2,"0")}/${dateTime.month.toString().padLeft(2,"0")}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2,"0")}',
              ),
              trailing: Text('\$ $amount',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25,),),
            ),
          ),
          IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Patvirtinkite ištrinimą!"),
                  content: const Text("Ar tikrai norite ištrinti šį elementą?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Atšaukti'),
                      child: const Text("Atšaukti", style: TextStyle(color: Colors.red, fontSize: 20)),
                    ),
                    TextButton(
                      onPressed: () {
                        removeData(amount, dateTime, name, type);
                        type == 'Income'
                            ? changeTheBalanceField(
                                dateTime, amount, 'minus')
                            : changeTheBalanceField(
                                dateTime, amount, 'plus');
                        Navigator.pop(context, 'Tęsti');
                      },
                      child: const Text("Tęsti", style: TextStyle(color: Colors.green, fontSize: 20)),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.close),
        ),
        ],
      ),
    );
  }

  Future<void> changeTheBalanceField(DateTime dateTime, String amount, String symbol) async{
    String formattedDate = DateFormat('yyyyMM').format(dateTime);
    String suffix = 'Balance';
    String suffixExpense = 'Expense';
    final uid = FirebaseAuth.instance.currentUser!.uid;

    var element = await FirebaseFirestore.instance.collection(uid)
      .doc('Amounts')
      .collection('Balances')
      .doc('$formattedDate$suffix')
      .get();
    
    double currentBalance = element.data()!['Balance'];

    await FirebaseFirestore.instance.collection(uid)
      .doc('Amounts')
      .collection('Balances')
      .doc('$formattedDate$suffix')
      .update({'Balance' : symbol == 'minus' 
        ? currentBalance - double.parse(amount) 
        : currentBalance + double.parse(amount)});


    var element2 = await FirebaseFirestore.instance.collection(uid)
      .doc('Amounts')
      .collection('Expenses')
      .doc('$formattedDate$suffixExpense')
      .get();
    double currentExpense = element2.data()!['Balance'];
    if (symbol == 'plus')
    {
      await FirebaseFirestore.instance.collection(uid)
      .doc('Amounts')
      .collection('Expenses')
      .doc('$formattedDate$suffixExpense')
      .update({'Balance' : currentExpense - double.parse(amount)});

      await calculateMaxExpense();
    }
  }

  Future<void> removeData(String amount, DateTime dateTime, String name, String type) async{
    String formattedDate = DateFormat('yyyyMM').format(dateTime);
    String suffix = 'income_expense';
    final uid = FirebaseAuth.instance.currentUser!.uid;
    //deletes all data frome firestore database

    var element = await FirebaseFirestore.instance.collection(uid)
      .doc('income_expense')
      .collection('$formattedDate$suffix')
      .where('amount', isEqualTo: amount)
      .where('dateTime', isEqualTo: dateTime)
      .where('name', isEqualTo: name)
      .where('type', isEqualTo: type)
      .get();

    if(element.docs.isNotEmpty)
    {
      var docRef = element.docs.first.reference;
      await docRef.delete();
    }
  }
}