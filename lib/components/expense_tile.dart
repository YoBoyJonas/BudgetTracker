import 'package:flutter/material.dart';

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
    return ListTile(     
      title: type == 'Income'?
      Text(name,style:const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1.5))
      :Text(name,style:const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      subtitle: Text('${dateTime.day.toString().padLeft(2,"0")}/${dateTime.month.toString().padLeft(2,"0")}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2,"0")}'),
      trailing: Text('\$$amount'),
    );
  }
}