import 'dart:html';

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
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            decoration: 
              BoxDecoration(
                color: const Color.fromARGB(248, 226, 214, 192),
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                  width: 2,
                  color: Colors.greenAccent, style: BorderStyle.solid,
                  )
              ),     
            child: ListTile(
              title: Text(name,style:const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 20)),
              subtitle: Text('${dateTime.day.toString().padLeft(2,"0")}/${dateTime.month.toString().padLeft(2,"0")}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2,"0")}'),
              trailing: Text('\$ $amount', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
            )
          )
          
          :Container(
            margin: const EdgeInsets.only(top: 5.0),
            decoration: 
              BoxDecoration(
                color: const Color.fromARGB(248, 226, 214, 192),
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                  width: 2,
                  color: Colors.redAccent, style: BorderStyle.solid,
                  )
              ),     
            child: ListTile(
              title: Text(name,style:const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 20)),
              subtitle: Text('${dateTime.day.toString().padLeft(2,"0")}/${dateTime.month.toString().padLeft(2,"0")}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2,"0")}'),
              trailing: Text('\$ $amount', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25)),
            )
          )
    );
  }
}