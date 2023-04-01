import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseItem{
  final String name;
  final String amount;
  final DateTime dateTime;
  final String type;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.type,
  });

  //adds it to firestore database
  void addToDatabase()
  {
    // Reference to document
    final docLedger = FirebaseFirestore.instance.collection('Ledger').doc('my-id');

    final json = {
      'name': name,
      'amount': amount,
      'date': dateTime,
      'type': type,
    };
  }
}